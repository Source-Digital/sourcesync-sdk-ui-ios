# CI/CD Documentation

This document describes the Continuous Integration and Continuous Deployment pipeline for the SourceSync SDK UI iOS project.

## Overview

**Status**: ✅ Fully Implemented

The project uses GitHub Actions for automated building, testing, and publishing to CocoaPods. The CI/CD pipeline is triggered on:

- **Push to tags** matching pattern `v*` (e.g., `v0.3.27`)
- **Manual workflow dispatch** with custom version input

## Pipeline Architecture

```
┌─────────────────┐
│  Git Tag Push   │
│  or Manual Run  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Get Version    │
│  Extract from   │
│  tag or input   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Update Podspec  │
│    Version      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│Validate Podspec │
│  pod spec lint  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Publish to    │
│   CocoaPods     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Create GitHub   │
│    Release      │
└─────────────────┘
```

## Workflow Configuration

### File Location
```
.github/workflows/ios-ci-cd.yml
```

### Workflow Name
```yaml
name: Publish to CocoaPods
```

### Trigger Events

#### 1. Automatic Trigger (Tag Push)
```yaml
on:
  push:
    tags:
      - 'v*'
```

**Example**: Pushing `v0.3.27` automatically triggers build and publish

#### 2. Manual Trigger (Workflow Dispatch)
```yaml
on:
  workflow_dispatch:
    inputs:
      tag_version:
        description: 'Tag version to build (e.g., v1.0.0)'
        required: true
        type: string
```

**Usage**: Go to Actions tab → Select workflow → Run workflow → Enter version

### Required Permissions
```yaml
permissions:
  contents: write      # Create releases
  packages: write      # Publish packages
```

### Environment Variables
```yaml
env:
  DEVELOPER_DIR: /Applications/Xcode_16.2.app/Contents/Developer
```

## Jobs

### Job 1: Get Version

**Purpose**: Extract version number from git tag or manual input

**Steps**:
1. Determine event type (push or manual)
2. Extract version number (removes `v` prefix)
3. Set as output for downstream jobs

**Output**: `version` (e.g., `0.3.27`)

**Example Logic**:
```bash
if [ "${{ github.event_name }}" = "push" ]; then
  # Extract from tag: refs/tags/v0.3.27 → 0.3.27
  VERSION="${GITHUB_REF#refs/tags/}"
  VERSION="${VERSION#v}"
else
  # Use manual input: v0.3.27 → 0.3.27
  VERSION="${{ inputs.tag_version }}"
  VERSION=${VERSION#v}
fi
```

### Job 2: Validate and Publish

**Purpose**: Update podspec, validate, and publish to CocoaPods

**Dependencies**: Requires `get-version` job completion

**Environment**:
- **Runner**: `macos-14`
- **Xcode**: 16.2.0
- **CocoaPods**: Latest stable

**Steps**:

#### 1. Checkout Repository
```yaml
- uses: actions/checkout@v4
  with:
    fetch-depth: 0
    ref: ${{ github.event_name == 'workflow_dispatch' && 
             format('v{0}', needs.get-version.outputs.version) || 
             github.ref }}
```

Checks out the specific tag version for building.

#### 2. Setup Build Environment
```yaml
- name: Setup Xcode
  uses: maxim-lobanov/setup-xcode@v1
  with:
    xcode-version: '16.2.0'

- name: Install CocoaPods
  run: |
    sudo gem install cocoapods
    pod --version
```

#### 3. Find and Update Podspec Version

The workflow searches for the podspec in multiple locations:

```bash
SEARCH_PATHS=(
  "SourceSyncSDK/SourceSyncSDK.podspec"
  "sourcesync-sdk-ui-ios/SourceSyncSDK.podspec"
  "SourceSyncSDK.podspec"
)
```

Then updates the version:
```bash
sed -i '' "s/spec\.version[[:space:]]*=[[:space:]]*['\"][^'\"]*['\"]/spec.version = \"$VERSION\"/" "$PODSPEC_FILE"
```

#### 4. Validate Podspec
```bash
pod spec lint "$PODSPEC_FILE" --allow-warnings --verbose
```

This validates:
- ✅ Correct podspec syntax
- ✅ Source files exist
- ✅ Dependencies are valid
- ✅ Deployment target compatibility

#### 5. Publish to CocoaPods
```bash
pod trunk push "$PODSPEC_FILE" --allow-warnings --verbose
```

This single command:
- Uploads the podspec to CocoaPods Trunk
- Validates the framework
- Makes it available on CocoaPods

#### 6. Create GitHub Release
```bash
gh release create v$VERSION \
  --title "v$VERSION" \
  --notes "Release notes..."
```

Creates a GitHub release with installation instructions.

## Required Secrets

The following secrets must be configured in GitHub repository settings:

### CocoaPods Credentials

| Secret Name | Description | How to Obtain |
|------------|-------------|---------------|
| `COCOAPODS_TRUNK_TOKEN` | CocoaPods trunk authentication token | [CocoaPods Account](https://cocoapods.org/login) |

#### Generating CocoaPods Token

```bash
# Register with CocoaPods (one time)
pod trunk register your-email@example.com 'Your Name'

# Check for email confirmation
# After confirmation, get your token
cat ~/.netrc
# Look for token after cocoapods.org entry
```

## Release Process

### Automated Release (Recommended)

#### Step 1: Prepare Release
```bash
# Ensure you're on main branch
git checkout main
git pull origin main

# Ensure all tests pass
xcodebuild test -scheme SourceSyncSDK \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# Commit any final changes
git add .
git commit -m "chore: prepare release v0.3.27"
git push
```

#### Step 2: Create and Push Tag
```bash
# Create annotated tag
git tag -a v0.3.27 -m "Release version 0.3.27"

# Push tag to trigger workflow
git push origin v0.3.27
```

#### Step 3: Monitor Workflow
1. Go to [Actions tab](https://github.com/Source-Digital/sourcesync-sdk-ui-ios/actions)
2. Watch "Publish to CocoaPods" workflow progress
3. Verify each job completes successfully

#### Step 4: Verify Publication
1. Check [CocoaPods](https://cocoapods.org/pods/SourceSyncSDK) (may take 15-30 minutes)
2. Search for: `pod search SourceSyncSDK`
3. Verify version is available

### Manual Release

If automated release fails or you need to release from a specific commit:

#### Using Workflow Dispatch

1. Go to **Actions** → **Publish to CocoaPods**
2. Click **Run workflow**
3. Enter version (e.g., `v0.3.27` or `0.3.27`)
4. Click **Run workflow**

#### Manual Publishing (Emergency)

If GitHub Actions is unavailable:

```bash
# Set version in podspec manually
# Edit SourceSyncSDK.podspec, update spec.version = "0.3.27"

# Validate podspec
pod spec lint SourceSyncSDK.podspec --allow-warnings

# Publish to CocoaPods
pod trunk push SourceSyncSDK.podspec --allow-warnings

# Create GitHub release manually
gh release create v0.3.27 \
  --title "v0.3.27" \
  --notes "Manual release"
```

## Versioning Strategy

### Version Format
```
MAJOR.MINOR.PATCH[-PRERELEASE]
```

Following [Semantic Versioning 2.0.0](https://semver.org/):

- **MAJOR**: Breaking API changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)
- **PRERELEASE**: Alpha, beta, or release candidate

### Examples
- `0.3.27` - Current stable release
- `1.0.0` - Major version with breaking changes
- `0.4.0` - New features added
- `0.3.28` - Bug fixes
- `1.0.0-beta.1` - Pre-release version

### Pre-release Versions
```
1.0.0-alpha.1
1.0.0-beta.1
1.0.0-rc.1
```

Pre-release tags can be pushed but CocoaPods will mark them appropriately.

## CocoaPods Publishing

### Publication Coordinates
```ruby
Pod::Spec.new do |spec|
  spec.name         = "SourceSyncSDK"
  spec.version      = "0.3.27"
  spec.summary      = "A framework for handling activation details in iOS apps."
  spec.homepage     = "https://github.com/Source-Digital/sourcesync-sdk-ui-ios"
end
```

### Publishing Process
The workflow uses `pod trunk push` which:

1. **Uploads** podspec to CocoaPods Trunk
2. **Validates** framework structure and dependencies
3. **Indexes** in CocoaPods search
4. **Makes available** for `pod install`

### Sync Time
- **CocoaPods Trunk**: Immediate
- **CocoaPods Search**: 15-30 minutes
- **CDN Propagation**: 1-2 hours

## Build Artifacts

### Generated Files
- **Framework**: `SourceSyncSDK.framework`
- **Podspec**: `SourceSyncSDK.podspec` (updated version)
- **Release Notes**: Auto-generated for GitHub

### Artifact Validation
Before release, artifacts are validated for:
- ✅ Correct podspec syntax
- ✅ Valid source files
- ✅ Dependencies resolution
- ✅ Deployment targets
- ✅ Swift version compatibility

## Troubleshooting

### Workflow Fails at Validation

**Symptom**: `pod spec lint` fails

**Common Causes**:
1. Invalid podspec syntax
2. Missing source files
3. Dependency version conflicts
4. Deployment target issues

**Solution**:
```bash
# Test locally first
pod spec lint SourceSyncSDK.podspec --allow-warnings --verbose

# Check specific issues
pod lib lint --verbose
```

### Version Already Published

**Symptom**: `Version 0.3.27 already exists`

**Solution**: CocoaPods doesn't allow re-publishing same version
- Increment version (e.g., `0.3.28`)
- Or use pre-release suffix (e.g., `0.3.27-1`)

### Tag Already Exists

**Symptom**: `tag 'v0.3.27' already exists`

**Solution**:
```bash
# Delete local tag
git tag -d v0.3.27

# Delete remote tag
git push origin :refs/tags/v0.3.27

# Recreate and push
git tag -a v0.3.27 -m "Release version 0.3.27"
git push origin v0.3.27
```

### Podspec Not Found

**Symptom**: Workflow can't find SourceSyncSDK.podspec

**Solution**: Ensure podspec is in one of these locations:
- `SourceSyncSDK/SourceSyncSDK.podspec`
- `sourcesync-sdk-ui-ios/SourceSyncSDK.podspec`
- `SourceSyncSDK.podspec` (root)

### CocoaPods Authentication Failed

**Symptom**: `Invalid token` or authentication errors

**Solution**:
1. Verify `COCOAPODS_TRUNK_TOKEN` secret is set
2. Check token hasn't expired
3. Generate new token if needed

## Best Practices

1. **Test Before Tagging**: Always run tests before creating release tag
2. **Use Annotated Tags**: Include release notes in tag annotation
3. **Monitor Workflows**: Watch Actions tab during releases
4. **Verify Publications**: Check CocoaPods after each release
5. **Update Changelog**: Document changes before releases
6. **Version Bumping**: Follow semantic versioning strictly

## Related Documentation

- [Setup Guide](setup.md) - Development environment
- [Dependencies](dependencies.md) - Library dependencies
- [Architecture](architecture.md) - System design

## Support

For CI/CD issues:
- Check [GitHub Actions](https://github.com/Source-Digital/sourcesync-sdk-ui-ios/actions)
- Review [workflow logs](https://github.com/Source-Digital/sourcesync-sdk-ui-ios/actions/workflows/ios-ci-cd.yml)
- Open [issue](https://github.com/Source-Digital/sourcesync-sdk-ui-ios/issues) with workflow run link