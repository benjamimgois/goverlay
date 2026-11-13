#!/usr/bin/env python3
"""
Goverlay Upstream Update Auditor
================================
Monitors upstream GitHub repositories for tools integrated with Goverlay.
Detects new releases, analyzes release notes for breaking changes and deprecations,
and compares upstream configuration options with Goverlay's Pascal source code.
"""

import argparse
import json
import os
import re
import subprocess
import sys
from pathlib import Path
from typing import Dict, List, Optional, Set, Any

ROOT_DIR = Path(__file__).resolve().parents[4]  # /mnt/NVME/Software/goverlay
SKILL_DIR = Path(__file__).resolve().parent.parent
CATALOG_FILE = SKILL_DIR / "references" / "repositories.json"


def run_command(cmd: List[str]) -> tuple[int, str, str]:
    """Execute a system command and return (returncode, stdout, stderr)."""
    try:
        proc = subprocess.run(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            timeout=30,
        )
        return proc.returncode, proc.stdout.strip(), proc.stderr.strip()
    except Exception as e:
        return 1, "", str(e)


def fetch_github_api(endpoint: str) -> Optional[Any]:
    """Fetch JSON from GitHub API using gh CLI with curl fallback."""
    # Try gh first
    rc, stdout, _ = run_command(["gh", "api", endpoint])
    if rc == 0 and stdout:
        try:
            return json.loads(stdout)
        except json.JSONDecodeError:
            pass

    # Fallback to curl
    url = f"https://api.github.com/{endpoint.lstrip('/')}"
    rc, stdout, _ = run_command([
        "curl", "-sSL",
        "-H", "Accept: application/vnd.github.v3+json",
        "-H", "User-Agent: Goverlay-Update-Auditor",
        url
    ])
    if rc == 0 and stdout:
        try:
            return json.loads(stdout)
        except json.JSONDecodeError:
            pass
    return None


def fetch_raw_file(repo: str, branch: str, filepath: str) -> Optional[str]:
    """Fetch raw file content from a GitHub repository."""
    url = f"https://raw.githubusercontent.com/{repo}/{branch}/{filepath.lstrip('/')}"
    rc, stdout, _ = run_command([
        "curl", "-sSL",
        "-H", "User-Agent: Goverlay-Update-Auditor",
        url
    ])
    return stdout if rc == 0 and stdout else None


def get_latest_release_or_tag(repo: str) -> Dict[str, Any]:
    """Fetch the latest release information or latest tag if no release exists."""
    release_data = fetch_github_api(f"repos/{repo}/releases/latest")
    if isinstance(release_data, dict) and "tag_name" in release_data:
        return {
            "type": "release",
            "tag": release_data.get("tag_name"),
            "name": release_data.get("name") or release_data.get("tag_name"),
            "published_at": release_data.get("published_at"),
            "html_url": release_data.get("html_url"),
            "body": release_data.get("body", "")
        }

    # If no latest release, try tags
    tags_data = fetch_github_api(f"repos/{repo}/tags?per_page=1")
    if isinstance(tags_data, list) and len(tags_data) > 0:
        tag_info = tags_data[0]
        return {
            "type": "tag",
            "tag": tag_info.get("name"),
            "name": tag_info.get("name"),
            "published_at": None,
            "html_url": f"https://github.com/{repo}/releases/tag/{tag_info.get('name')}",
            "body": ""
        }

    return {
        "type": "unknown",
        "tag": "unknown",
        "name": "unknown",
        "published_at": None,
        "html_url": f"https://github.com/{repo}",
        "body": ""
    }


def get_recent_releases(repo: str, limit: int = 5) -> List[Dict[str, Any]]:
    """Fetch the most recent releases for a repository, falling back to latest release/tag."""
    releases_data = fetch_github_api(f"repos/{repo}/releases?per_page={max(1, limit)}")
    if isinstance(releases_data, list) and len(releases_data) > 0:
        results: List[Dict[str, Any]] = []
        for rel in releases_data:
            if not isinstance(rel, dict) or "tag_name" not in rel:
                continue
            results.append({
                "type": "release",
                "tag": rel.get("tag_name"),
                "name": rel.get("name") or rel.get("tag_name"),
                "published_at": rel.get("published_at"),
                "html_url": rel.get("html_url"),
                "body": rel.get("body") or ""
            })
        if results:
            return results
    return [get_latest_release_or_tag(repo)]


def parse_sample_config_keys(content: str, config_type: str = "generic") -> Dict[str, str]:
    """Extract configuration keys and descriptions from sample config file content."""
    keys: Dict[str, str] = {}
    lines = content.splitlines()
    doc_buffer: List[str] = []

    for line in lines:
        stripped = line.strip()
        if not stripped:
            doc_buffer = []
            continue

        if stripped.startswith("#") or stripped.startswith(";"):
            # Clean comments
            clean_comment = re.sub(r"^[#;]+\s*", "", stripped)
            # Check if this comment is actually a commented out key assignment (e.g. # fps_limit=0)
            m = re.match(r"^([a-zA-Z0-9_.-]+)\s*(=|\s|$)(.*)", clean_comment)
            if m and "=" in stripped:
                k = m.group(1).strip()
                if len(k) > 1 and not k.lower() in ("warning", "note", "example", "todo", "see", "default"):
                    desc = " ".join(doc_buffer[-2:]) if doc_buffer else "Sample config option"
                    keys[k] = desc
                    continue
            doc_buffer.append(clean_comment)
        else:
            # Uncommented key line (e.g. key = value)
            m = re.match(r"^([a-zA-Z0-9_.-]+)\s*=", stripped)
            if m:
                k = m.group(1).strip()
                desc = " ".join(doc_buffer[-2:]) if doc_buffer else "Config option"
                keys[k] = desc
                doc_buffer = []
    return keys


def extract_goverlay_keys(goverlay_files: List[str]) -> Set[str]:
    """Extract known keys and identifiers from Goverlay Pascal files."""
    known_keys: Set[str] = set()
    for rel_path in goverlay_files:
        full_path = ROOT_DIR / rel_path
        if not full_path.exists():
            continue
        try:
            content = full_path.read_text(encoding="utf-8", errors="ignore")
            # Look for string constants (e.g. 'something', 'something=1', or 'something=val')
            matches = re.findall(r"'([a-zA-Z0-9_.-]+(?:=[^']*)?)'", content)
            for m in matches:
                cleaned = m.strip().lower()
                known_keys.add(cleaned)
                if "=" in cleaned:
                    known_keys.add(cleaned.split("=", 1)[0].strip())
        except Exception:
            pass
    return known_keys


ENV_VAR_BLOCKS = ("PROTON_*", "WINE_*", "DXVK_*", "VKD3D_*", "Other")
IGNORED_ENV_PREFIXES = (
    "VK_", "GL_", "EGL_", "GLX_", "D3D_", "DXGI_", "WIN32_",
    "STATUS_", "ERROR_", "ERR_", "FIXME_", "WARN_", "TRACE_",
    "CMAKE_", "MESON_", "GITHUB_", "CI_",
)
ENV_VAR_PATTERN = re.compile(r"\b([A-Z][A-Z0-9]*_[A-Z0-9_]+)(?:=([^\s`\"',;)]+))?\b")
URL_PATTERN = re.compile(r"https?://\S+")


def classify_env_var(var_name: str) -> str:
    """Classify an environment variable into a display block by prefix."""
    upper = var_name.upper()
    if upper.startswith("PROTON_"):
        return "PROTON_*"
    if upper.startswith("WINE_") or upper.startswith("WINEDLL"):
        return "WINE_*"
    if upper.startswith("DXVK_"):
        return "DXVK_*"
    if upper.startswith("VKD3D_"):
        return "VKD3D_*"
    return "Other"


def extract_env_vars_from_releases(releases: List[Dict[str, Any]]) -> List[Dict[str, str]]:
    """Extract environment variables and line context from a list of releases (newest first)."""
    seen_base: Set[str] = set()
    extracted: List[Dict[str, str]] = []

    for rel in releases:
        body = rel.get("body") or ""
        tag = rel.get("tag") or "unknown"
        for raw_line in body.splitlines():
            line = raw_line.strip()
            if not line:
                continue
            # Strip URLs before matching so path/query tokens are not mistaken for env vars
            searchable = URL_PATTERN.sub(" ", line)
            for match in ENV_VAR_PATTERN.finditer(searchable):
                base_var = match.group(1)
                val = match.group(2)
                if base_var.startswith(IGNORED_ENV_PREFIXES):
                    continue
                if base_var in seen_base:
                    continue
                seen_base.add(base_var)

                display_key = f"{base_var}={val}" if val else base_var
                context = re.sub(r"^[-*•]\s*", "", line)
                context = re.sub(r"\s+", " ", context).strip()
                if len(context) > 180:
                    context = context[:177] + "..."

                extracted.append({
                    "key": display_key,
                    "base_key": base_var,
                    "category": classify_env_var(base_var),
                    "release_tag": tag,
                    "desc": context,
                })
    return extracted


def analyze_release_body(body: str) -> List[str]:
    """Detect potential breaking changes, deprecations, or major feature additions in release body."""
    flags: List[str] = []
    if not body:
        return flags

    patterns = [
        (r"(?i)\b(break|breaking change|incompatible)\b", "⚠️ Breaking change announced"),
        (r"(?i)\b(deprecat(ed|ion))\b", "⚠️ Deprecation notice"),
        (r"(?i)\b(renamed?|syntax changed?)\b", "⚠️ Option/syntax rename"),
        (r"(?i)\b(removed? option|deleted)\b", "⚠️ Option removed"),
        (r"(?i)\b(new option|added support|new feature)\b", "✨ New feature/option introduced"),
        (r"(?i)\b(wayland|hdr|vulkan|dxgi|present mode)\b", "🔧 Core graphics/windowing change"),
    ]

    for regex, desc in patterns:
        if re.search(regex, body):
            flags.append(desc)
    return list(dict.fromkeys(flags))


def audit_tool(tool: Dict[str, Any], check_keys: bool = True, releases_limit: int = 5) -> Dict[str, Any]:
    """Audit a single tool."""
    tool_id = tool["id"]
    repo = tool["repo"]
    name = tool["name"]
    audit_mode = tool.get("audit_mode", "sample_config")
    upstream_sample = tool.get("upstream_sample_config")
    goverlay_files = tool.get("goverlay_files", [])

    missing_keys: List[Dict[str, str]] = []
    missing_env_vars: List[Dict[str, str]] = []
    scanned_releases: List[str] = []

    if audit_mode == "release_notes_env":
        releases = get_recent_releases(repo, limit=releases_limit)
        rel_info = releases[0]
        scanned_releases = [r.get("tag", "unknown") for r in releases]
        flags: List[str] = []
        for r in releases:
            flags.extend(analyze_release_body(r.get("body", "")))
        flags = list(dict.fromkeys(flags))

        if check_keys:
            goverlay_keys = extract_goverlay_keys(goverlay_files)
            for item in extract_env_vars_from_releases(releases):
                if item["base_key"].lower() not in goverlay_keys:
                    missing_env_vars.append(item)
                    missing_keys.append(item)
    else:
        rel_info = get_latest_release_or_tag(repo)
        flags = analyze_release_body(rel_info.get("body", ""))

        if check_keys and upstream_sample:
            # Determine branch (try master, then main)
            sample_content = fetch_raw_file(repo, "master", upstream_sample)
            if not sample_content:
                sample_content = fetch_raw_file(repo, "main", upstream_sample)

            if sample_content:
                upstream_keys = parse_sample_config_keys(sample_content)
                goverlay_keys = extract_goverlay_keys(goverlay_files)

                for key, desc in upstream_keys.items():
                    if key.lower() not in goverlay_keys:
                        # Ignore common trivial/informational keys
                        if key.lower() in ("help", "version", "true", "false", "output_file"):
                            continue
                        missing_keys.append({"key": key, "desc": desc})

    status = "UP_TO_DATE"
    if any("Breaking" in f or "Deprecation" in f or "rename" in f for f in flags):
        status = "ATTENTION_REQUIRED"
    elif missing_keys:
        status = "NEW_OPTIONS_AVAILABLE"
    elif rel_info.get("type") == "release":
        status = "UPSTREAM_RELEASE_FOUND"

    result: Dict[str, Any] = {
        "id": tool_id,
        "name": name,
        "repo": repo,
        "audit_mode": audit_mode,
        "release": rel_info,
        "analysis_flags": flags,
        "missing_keys": missing_keys,
        "status": status,
        "goverlay_files": goverlay_files
    }
    if audit_mode == "release_notes_env":
        result["scanned_releases"] = scanned_releases
        result["missing_env_vars"] = missing_env_vars
    return result


def main():
    parser = argparse.ArgumentParser(description="Goverlay Upstream Update Auditor")
    parser.add_argument("--tool", "-t", type=str, help="Specific tool ID to audit (e.g. mangohud, optiscaler)")
    parser.add_argument("--all", "-a", action="store_true", help="Audit all integrated tools")
    parser.add_argument("--format", "-f", choices=["markdown", "json", "compact"], default="markdown", help="Output format")
    parser.add_argument("--releases", "-r", type=int, default=5, help="Number of recent releases to scan for release_notes_env tools (default: 5)")
    parser.add_argument("--check-keys", action="store_true", default=True, help="Compare configuration keys with upstream")
    parser.add_argument("--output", "-o", type=str, help="Write output to specified file")
    args = parser.parse_args()

    if not CATALOG_FILE.exists():
        print(f"Error: Catalog file not found at {CATALOG_FILE}", file=sys.stderr)
        sys.exit(1)

    catalog = json.loads(CATALOG_FILE.read_text(encoding="utf-8"))
    tools_to_check = catalog.get("tools", [])

    if args.tool:
        tools_to_check = [t for t in tools_to_check if t["id"].lower() == args.tool.lower()]
        if not tools_to_check:
            print(f"Error: Tool '{args.tool}' not found in catalog.", file=sys.stderr)
            sys.exit(1)
    elif not args.all:
        # Default to all if neither specified
        args.all = True

    results = []
    for tool in tools_to_check:
        res = audit_tool(tool, check_keys=args.check_keys, releases_limit=args.releases)
        results.append(res)

    output_str = ""
    if args.format == "json":
        output_str = json.dumps(results, indent=2)
    elif args.format == "markdown":
        output_str = render_markdown(results)
    else:
        output_str = render_compact(results)

    if args.output:
        Path(args.output).write_text(output_str, encoding="utf-8")
        print(f"Report written to {args.output}")
    else:
        print(output_str)


def render_compact(results: List[Dict[str, Any]]) -> str:
    lines = []
    for r in results:
        status_symbol = "🟢"
        if r["status"] == "ATTENTION_REQUIRED":
            status_symbol = "🔴"
        elif r["status"] == "NEW_OPTIONS_AVAILABLE":
            status_symbol = "🟡"
        elif r["status"] == "UPSTREAM_RELEASE_FOUND":
            status_symbol = "🚀"

        rel_tag = r["release"].get("tag", "N/A")
        date = r["release"].get("published_at", "")[:10] if r["release"].get("published_at") else "tag"
        lines.append(f"{status_symbol} {r['name']:<16} {rel_tag:<12} ({date}) -> Missing keys: {len(r['missing_keys'])}")
    return "\n".join(lines)


def render_markdown(results: List[Dict[str, Any]]) -> str:
    md = ["# Goverlay Upstream Audit Report\n"]
    md.append(f"Generated from `{len(results)}` integrated components.\n")

    # Summary table
    md.append("| Component | Repository | Latest Tag | Release Date | Status | New/Missing Keys |")
    md.append("| :--- | :--- | :--- | :--- | :--- | :--- |")
    for r in results:
        badge = "🟢 Up to date"
        if r["status"] == "ATTENTION_REQUIRED":
            badge = "🔴 Attention Required"
        elif r["status"] == "NEW_OPTIONS_AVAILABLE":
            badge = "🟡 New Options"
        elif r["status"] == "UPSTREAM_RELEASE_FOUND":
            badge = "🚀 Upstream Release"

        rel_tag = r["release"].get("tag", "N/A")
        date = r["release"].get("published_at", "")[:10] if r["release"].get("published_at") else "N/A"
        repo_link = f"[{r['repo']}](https://github.com/{r['repo']})"
        missing_count = len(r['missing_keys'])
        md.append(f"| **{r['name']}** | {repo_link} | `{rel_tag}` | {date} | {badge} | {missing_count} |")

    md.append("\n---\n")

    # Detailed sections
    for r in results:
        if r["status"] == "UP_TO_DATE" and not r["missing_keys"]:
            continue

        md.append(f"## {r['name']} (`{r['repo']}`)\n")
        rel = r["release"]
        md.append(f"- **Latest Release/Tag**: [{rel.get('tag')}]({rel.get('html_url')})")
        if rel.get("published_at"):
            md.append(f"- **Published Date**: {rel.get('published_at')}")

        if r.get("audit_mode") == "release_notes_env":
            scanned = ", ".join(f"`{t}`" for t in r.get("scanned_releases", []))
            if scanned:
                md.append(f"- **Scanned Releases**: {scanned}")

        if r["analysis_flags"]:
            md.append("\n### Upstream Highlights / Alerts")
            for flag in r["analysis_flags"]:
                md.append(f"- {flag}")

        if r.get("audit_mode") == "release_notes_env" and r.get("missing_env_vars"):
            md.append("\n### Discovered Environment Variables (Grouped by Prefix)")
            gov_file = r["goverlay_files"][0] if r["goverlay_files"] else "tweaks_md3.pas"
            for block in ENV_VAR_BLOCKS:
                block_items = [item for item in r["missing_env_vars"] if item.get("category") == block]
                if not block_items:
                    continue
                md.append(f"\n#### `{block}`")
                md.append("| Variable | Release Tag | Context | Goverlay File |")
                md.append("| :--- | :--- | :--- | :--- |")
                for item in block_items:
                    clean_desc = item["desc"].replace("|", "\\|").strip()
                    md.append(f"| `{item['key']}` | `{item['release_tag']}` | {clean_desc} | [`{gov_file}`](file://{ROOT_DIR / gov_file}) |")
        elif r["missing_keys"]:
            md.append("\n### Potential Missing Options in Goverlay")
            md.append("| Upstream Key | Description / Sample Context | Goverlay File to Update |")
            md.append("| :--- | :--- | :--- |")
            gov_file = r["goverlay_files"][0] if r["goverlay_files"] else "configkeys.pas"
            for k in r["missing_keys"][:20]:  # Limit top 20 per tool to prevent flooding
                clean_desc = k["desc"].replace("|", "\\|").strip()
                md.append(f"| `{k['key']}` | {clean_desc} | [`{gov_file}`](file://{ROOT_DIR / gov_file}) |")
            if len(r["missing_keys"]) > 20:
                md.append(f"*(and {len(r['missing_keys']) - 20} more keys)*")

        md.append("\n")

    return "\n".join(md)


if __name__ == "__main__":
    main()
