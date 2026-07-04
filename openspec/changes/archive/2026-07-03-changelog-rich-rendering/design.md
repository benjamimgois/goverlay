## Context

The changelog popup (`changelogunit.pas`) uses `TMemo` to display the GitHub release body as plain text. GitHub's release body is markdown with formatting and embedded images. GitHub's REST API supports an `Accept: application/vnd.github.v3.html` media type that returns the body pre-rendered as HTML in a `body_html` field. Lazarus ships with `TIpHtmlPanel` (TurboPower Internet Professional) capable of rendering basic HTML including text formatting, tables, hyperlinks, and images from URLs.

## Goals / Non-Goals

**Goals:**
- Display the release notes as formatted HTML in the changelog popup.
- Images embedded in the release body (e.g. screenshots hosted on GitHub) render inline.
- The popup remains a self-contained modal with the same drag-to-move UX.

**Non-Goals:**
- Parsing/rendering markdown locally (GitHub does it server-side).
- Rendering complex JS/CSS (TIpHtmlPanel is basic HTML only).
- Changing the trigger logic (`CheckAndShowChangelog`) or the "What's New" menu item.

## Decisions

1. **Server-side conversion.** Add `Accept: application/vnd.github.v3.html` header to the curl call in `GetReleaseNotes`. GitHub converts the release markdown to HTML and returns it in `body_html`. Read `body_html` first, fall back to `body` if missing (backward-compatible).

2. **TIpHtmlPanel rendering.** Replace the `TMemo` in `TChangelogForm` with `TIpHtmlPanel` from the `IpHtmlPanel` unit. Use `SetHtmlFromStr(HtmlStr)` to render. `TIpHtmlPanel` handles scroll, format, images natively.

3. **Image loading.** `TIpHtmlPanel` loads images via its internal HTTP data provider. GitHub-hosted images (https:// URLs in the release body) will load automatically as long as the system has network access.

4. **Form sizing.** Increase `Height` from 460 to 520 for better rendering space. Keep `Width` at 600.

## Risks / Trade-offs

- **[Risk] TIpHtmlPanel fails to load HTTPS images.** Some Lazarus builds have issues with HTTPS in `TIpHttpDataProvider`. *Mitigation:* if no data provider is available, images show as broken icons; text formatting and links still work. This is a soft degradation.
- **[Risk] HTML injection from release body.** The `body_html` comes from GitHub's own renderer, which sanitizes markdown. No user-supplied HTML is involved — GitHub controls the output.
- **[Trade-off] Increased binary size.** Adding `turbopower_ipro` to the project links `IpHtmlPanel` and its parser (~100KB). Acceptable for the UX improvement.

## Open Questions

- Should the form add a manual "reload images" button in case HTTPS images fail to load on first attempt? Skipped for v1 — broken images are acceptable; the text formatting improvement alone justifies the change.