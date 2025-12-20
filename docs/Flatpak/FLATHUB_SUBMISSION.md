# Flathub Submission Guide for GOverlay

This guide walks through the **official** process of submitting GOverlay to Flathub.

## Prerequisites

1. GitHub account
2. Git configured with your credentials
3. `org.flatpak.Builder` installed for testing
4. All app requirements met (see https://docs.flathub.org/docs/for-app-authors/requirements)

## Important Notes

⚠️ **The submission is done via Pull Request to flathub/flathub, NOT by creating an issue first!**

## Step 1: Install Flatpak Builder and Test Locally

```bash
# Install org.flatpak.Builder
flatpak install -y flathub org.flatpak.Builder

# Add Flathub remote if not already added
flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Test build your app
flatpak run --command=flatpak-builder org.flatpak.Builder --force-clean --install-deps-from=flathub \
  build-dir io.github.benjamimgois.goverlay.flathub.yml

# Run the linter (IMPORTANT!)
flatpak run --command=flatpak-builder org.flatpak.Builder --show-manifest io.github.benjamimgois.goverlay.flathub.yml
```

## Step 2: Fork the Flathub Repository

1. Go to https://github.com/flathub/flathub
2. Click "Fork" button
3. **IMPORTANT**: Uncheck "Copy the master branch only" to get all branches
4. Create the fork

## Step 3: Clone Your Fork Using the new-pr Branch

```bash
# Clone using the new-pr branch (NOT master!)
git clone --branch=new-pr git@github.com:YOUR_USERNAME/flathub.git
cd flathub
```

## Step 4: Create Your Submission Branch

```bash
# Create a new branch from new-pr for your submission
git checkout -b add-goverlay new-pr
```

## Step 5: Add Your App Files

```bash
# Create directory for your app
mkdir io.github.benjamimgois.goverlay
cd io.github.benjamimgois.goverlay

# Copy your manifest (renamed to match app-id.yml)
cp ~/Documentos/goverlay/io.github.benjamimgois.goverlay.flathub.yml io.github.benjamimgois.goverlay.yml

# The manifest must be named exactly: io.github.benjamimgois.goverlay.yml
```

## Step 6: Important Manifest Requirements for Flathub

### 4.1 Update Source to Use Git Tag (Not Local Directory)

The manifest must download from your GitHub releases, not use a local directory.

**Current source (for local builds):**
```yaml
sources:
  - type: dir
    path: .
```

**Required for Flathub:**
```yaml
sources:
  - type: archive
    url: https://github.com/benjamimgois/goverlay/archive/refs/tags/1.6.3.tar.gz
    sha256: <SHA256_HASH>
    # OR use git:
  - type: git
    url: https://github.com/benjamimgois/goverlay.git
    tag: 1.6.3
    commit: <FULL_COMMIT_HASH>
```

### 4.2 Verify Permissions

Flathub reviewers pay close attention to permissions. Current permissions:
- `--filesystem=home` - **May be rejected** (too broad)
- `--share=network` - Required for downloads
- `--device=dri` - Required for GPU access

Consider changing `--filesystem=home` to more specific paths:
```yaml
- --filesystem=~/fgmod:create  # For OptiScaler
- --persist=.  # For app data persistence
```

### 4.3 Screenshot Requirements

Ensure screenshots in metainfo.xml are:
- Hosted on GitHub or a permanent URL
- At least 624x351 pixels
- PNG or JPEG format
- Show actual application usage

## Step 7: Commit Your Changes

```bash
# Go back to the flathub repository root
cd ~/flathub

# Add your app directory
git add io.github.benjamimgois.goverlay/

# Commit with the exact format: "Add [app-id]"
git commit -m "Add io.github.benjamimgois.goverlay"

# Push to your fork
git push origin add-goverlay
```

## Step 8: Create Pull Request

1. Go to https://github.com/YOUR_USERNAME/flathub
2. You should see a prompt to create a Pull Request
3. **IMPORTANT**: Make sure the PR is against the `new-pr` branch (NOT master!)
4. Title: `Add io.github.benjamimgois.goverlay`
5. Description should include:
   ```
   GOverlay is a graphical UI to configure MangoHud, vkBasalt, and OptiScaler on Linux.

   - Upstream: https://github.com/benjamimgois/goverlay
   - License: GPL-3.0-or-later
   - Version: 1.6.3
   ```
6. Create the Pull Request

## Step 9: Respond to Review Feedback

Flathub reviewers will check:
- [ ] Manifest syntax and structure
- [ ] Permissions justification
- [ ] License compatibility
- [ ] AppData/MetaInfo quality
- [ ] Build reproducibility
- [ ] Desktop file compliance
- [ ] Icon quality

**IMPORTANT**: Do NOT close the PR to make changes! Just push new commits to your branch.

```bash
# Make changes to your manifest
cd ~/flathub/io.github.benjamimgois.goverlay
# Edit io.github.benjamimgois.goverlay.yml

# Commit and push
git add io.github.benjamimgois.goverlay.yml
git commit -m "Address review feedback: [describe changes]"
git push origin add-goverlay
```

## Step 10: After Approval and Merge

Once your PR is approved and merged:
1. A new repository is created: `https://github.com/flathub/io.github.benjamimgois.goverlay`
2. You'll receive an invitation to join as a collaborator
3. Your app will be built automatically
4. Published to Flathub within 24 hours
5. Users can install via: `flatpak install flathub io.github.benjamimgois.goverlay`

## Common Issues and Solutions

### Issue: Build Fails on Flathub
**Solution**: Check that all sources are publicly accessible. No local paths allowed.

### Issue: Permissions Too Broad
**Solution**: Replace `--filesystem=home` with specific paths:
```yaml
- --filesystem=xdg-config/MangoHud:create
- --filesystem=xdg-config/vkBasalt:create
- --filesystem=~/fgmod:create
```

### Issue: AppStream Validation Errors
**Solution**: Run validation locally:
```bash
appstreamcli validate data/io.github.benjamimgois.goverlay.metainfo.xml
desktop-file-validate data/io.github.benjamimgois.goverlay.desktop
```

### Issue: Missing Screenshots
**Solution**: Add screenshots to metainfo.xml with permanent URLs

### Issue: SHA256 Mismatch
**Solution**: Regenerate the hash from the exact source Flathub will download

## Additional Resources

- Flathub Documentation: https://docs.flathub.org/
- App Requirements: https://docs.flathub.org/docs/for-app-authors/requirements
- Manifest Guidelines: https://docs.flatpak.org/en/latest/manifests.html
- Flathub Review Checklist: https://github.com/flathub/flathub/wiki/App-Review-Checklist

## Quick Command Reference

```bash
# Test manifest locally
flatpak-builder --force-clean build-dir io.github.benjamimgois.goverlay.yml

# Validate AppStream metadata
appstreamcli validate data/io.github.benjamimgois.goverlay.metainfo.xml

# Validate desktop file
desktop-file-validate data/io.github.benjamimgois.goverlay.desktop

# Generate SHA256 for archive
sha256sum goverlay-1.6.3.tar.gz

# Install built app locally for testing
flatpak-builder --user --install --force-clean build-dir io.github.benjamimgois.goverlay.yml
```

## Next Steps

1. Create submission issue on https://github.com/flathub/flathub
2. Wait for Flathub to create your app repository
3. Fork the new repository
4. Update manifest with proper source URLs and SHA256
5. Test build locally
6. Submit pull request
7. Respond to review feedback
8. Celebrate when merged! 🎉
