#!/bin/bash

# Script to help submit GOverlay to Flathub
# This script guides you through the submission process

set -e

APP_ID="io.github.benjamimgois.goverlay"
VERSION="1.6.3"
COMMIT_HASH="58b812aef91862da5def44e2ed92ab8f0e1e5ba5"

echo "=========================================="
echo "GOverlay Flathub Submission Helper"
echo "Version: $VERSION"
echo "=========================================="
echo

# Step 1: Verify files exist
echo "[Step 1] Verifying required files..."
if [ ! -f "data/$APP_ID.metainfo.xml" ]; then
    echo "❌ ERROR: metainfo.xml not found!"
    exit 1
fi

if [ ! -f "data/$APP_ID.desktop" ]; then
    echo "❌ ERROR: desktop file not found!"
    exit 1
fi

if [ ! -f "$APP_ID.flathub.yml" ]; then
    echo "❌ ERROR: Flathub manifest not found!"
    exit 1
fi

echo "✓ All required files found"
echo

# Step 2: Validate metadata
echo "[Step 2] Validating AppStream metadata..."
if command -v appstreamcli &> /dev/null; then
    appstreamcli validate data/$APP_ID.metainfo.xml
    echo "✓ AppStream metadata is valid"
else
    echo "⚠ Warning: appstreamcli not found, skipping validation"
fi
echo

# Step 3: Validate desktop file
echo "[Step 3] Validating desktop file..."
if command -v desktop-file-validate &> /dev/null; then
    desktop-file-validate data/$APP_ID.desktop
    echo "✓ Desktop file is valid"
else
    echo "⚠ Warning: desktop-file-validate not found, skipping validation"
fi
echo

# Step 4: Check Git status
echo "[Step 4] Checking Git status..."
if [ -n "$(git status --porcelain)" ]; then
    echo "⚠ Warning: You have uncommitted changes"
    git status --short
    echo
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    echo "✓ Working directory is clean"
fi
echo

# Step 5: Instructions
echo "=========================================="
echo "CORRECT Flathub Submission Process:"
echo "=========================================="
echo
echo "1. Fork the Flathub repository:"
echo "   → Go to https://github.com/flathub/flathub"
echo "   → Click 'Fork'"
echo "   → ⚠️  UNCHECK 'Copy the master branch only'"
echo "   → Create fork"
echo
echo "2. Clone your fork using the new-pr branch:"
echo "   git clone --branch=new-pr git@github.com:YOUR_USERNAME/flathub.git"
echo "   cd flathub"
echo
echo "3. Create a branch for your submission:"
echo "   git checkout -b add-goverlay new-pr"
echo
echo "4. Create app directory and copy manifest:"
echo "   mkdir $APP_ID"
echo "   cd $APP_ID"
echo "   cp ~/Documentos/goverlay/$APP_ID.flathub.yml $APP_ID.yml"
echo
echo "5. Commit and push:"
echo "   cd .."
echo "   git add $APP_ID/"
echo "   git commit -m 'Add $APP_ID'"
echo "   git push origin add-goverlay"
echo
echo "6. Create Pull Request:"
echo "   → Go to https://github.com/YOUR_USERNAME/flathub"
echo "   → Click 'Compare & pull request'"
echo "   → ⚠️  Base branch MUST be 'new-pr' (NOT master!)"
echo "   → Title: 'Add $APP_ID'"
echo "   → Create PR"
echo
echo "7. Respond to review feedback (DO NOT close the PR!)"
echo
echo "=========================================="
echo "Manifest Details:"
echo "=========================================="
echo "App ID: $APP_ID"
echo "Version: $VERSION"
echo "Commit: $COMMIT_HASH"
echo "Repository: https://github.com/benjamimgois/goverlay"
echo "License: GPL-3.0"
echo
echo "Manifest file ready at:"
echo "  $APP_ID.flathub.yml"
echo
echo "For detailed instructions, see:"
echo "  FLATHUB_SUBMISSION.md"
echo "=========================================="
