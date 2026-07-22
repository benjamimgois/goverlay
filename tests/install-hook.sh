#!/bin/sh
# Installs the GOverlay pre-commit test gate.
# Run from the repository root:  sh tests/install-hook.sh
#
# The hook runs the local test suite (make -s test) before each commit and
# blocks the commit on failure. Bypass in emergencies with:
#   git commit --no-verify

set -e

HOOK_DIR=".git/hooks"
HOOK_FILE="$HOOK_DIR/pre-commit"

if [ ! -d "$HOOK_DIR" ]; then
    echo "error: $HOOK_DIR not found - run this script from the repository root" >&2
    exit 1
fi

cat > "$HOOK_FILE" <<'EOF'
#!/bin/sh
# GOverlay pre-commit test gate (installed by tests/install-hook.sh)
echo "pre-commit: running test suite (skip with git commit --no-verify)"
if ! make -s test; then
    echo "pre-commit: tests failed - commit aborted" >&2
    exit 1
fi
EOF

chmod +x "$HOOK_FILE"
echo "installed: $HOOK_FILE"
