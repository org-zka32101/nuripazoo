#!/bin/bash

################################################################################
# Phase 9A: TestFlight Build Automation Script
# Purpose: Automate iOS Release build, code signing, and .ipa generation for TestFlight
# Usage: ./scripts/build_testflight.sh [--version X.Y.Z] [--build N] [--team TEAM_ID]
################################################################################

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IOS_DIR="${PROJECT_ROOT}/ios"
BUILD_DIR="${PROJECT_ROOT}/build/ios_build"
SCHEME="Runner"
CONFIGURATION="Release"

# Default values (override with environment variables or script arguments)
VERSION="${VERSION:-0.1.0}"
BUILD_NUMBER="${BUILD_NUMBER:-1}"
TEAM_ID="${TEAM_ID:-}"
EXPORT_TEAM_ID="${EXPORT_TEAM_ID:-}"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --version)
      VERSION="$2"
      shift 2
      ;;
    --build)
      BUILD_NUMBER="$2"
      shift 2
      ;;
    --team)
      TEAM_ID="$2"
      export TEAM_ID
      shift 2
      ;;
    --export-team)
      EXPORT_TEAM_ID="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

################################################################################
# Helper Functions
################################################################################

log_info() {
  echo -e "${BLUE}ℹ ${1}${NC}"
}

log_success() {
  echo -e "${GREEN}✓ ${1}${NC}"
}

log_error() {
  echo -e "${RED}✗ ${1}${NC}"
}

log_warning() {
  echo -e "${YELLOW}⚠ ${1}${NC}"
}

check_requirements() {
  log_info "Checking build requirements..."

  # Check Xcode
  if ! command -v xcode-select &> /dev/null; then
    log_error "Xcode is not installed"
    exit 1
  fi
  log_success "Xcode found: $(xcode-select -p)"

  # Check Flutter
  if ! command -v flutter &> /dev/null; then
    log_error "Flutter is not installed"
    exit 1
  fi
  log_success "Flutter found: $(flutter --version)"

  # Check CocoaPods
  if ! command -v pod &> /dev/null; then
    log_error "CocoaPods is not installed. Run: sudo gem install cocoapods"
    exit 1
  fi
  log_success "CocoaPods found: $(pod --version)"

  # Check provisioning profile and certificate
  if [ -z "$TEAM_ID" ]; then
    log_warning "TEAM_ID not set. Code signing will use automatic signing."
  else
    log_success "Team ID provided: $TEAM_ID"
  fi
}

clean_build() {
  log_info "Cleaning previous builds..."
  rm -rf "$BUILD_DIR"
  mkdir -p "$BUILD_DIR"
  log_success "Build directory cleaned"
}

flutter_get() {
  log_info "Running flutter pub get..."
  cd "$PROJECT_ROOT"
  flutter pub get
  log_success "Flutter dependencies resolved"
}

pod_install() {
  log_info "Running pod install..."
  cd "$IOS_DIR"
  pod install --repo-update
  log_success "CocoaPods dependencies installed"
}

build_flutter_ios() {
  log_info "Building Flutter iOS (Release mode)..."
  cd "$PROJECT_ROOT"

  flutter build ios \
    --release \
    --no-codesign \
    --verbose

  log_success "Flutter iOS build completed"
}

update_version_build() {
  log_info "Updating version and build number..."

  # Update Info.plist with version and build number
  /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" \
    "$IOS_DIR/Runner/Info.plist"
  /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BUILD_NUMBER" \
    "$IOS_DIR/Runner/Info.plist"

  log_success "Version: $VERSION, Build: $BUILD_NUMBER"
}

build_archive() {
  log_info "Building iOS archive for App Store..."

  local ARCHIVE_PATH="${BUILD_DIR}/Runner.xcarchive"

  if [ -n "$TEAM_ID" ]; then
    local TEAM_ARG="-developmentTeam=$TEAM_ID"
  else
    local TEAM_ARG=""
  fi

  xcodebuild \
    -workspace "${IOS_DIR}/Runner.xcworkspace" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -derivedDataPath "${BUILD_DIR}/derivedData" \
    -archivePath "$ARCHIVE_PATH" \
    -allowProvisioningUpdates \
    $TEAM_ARG \
    archive \
    -verbose

  log_success "Archive created: $ARCHIVE_PATH"
}

export_ipa() {
  log_info "Exporting .ipa for TestFlight..."

  local ARCHIVE_PATH="${BUILD_DIR}/Runner.xcarchive"
  local IPA_DIR="${BUILD_DIR}/ipa"
  local EXPORT_OPTIONS="${IOS_DIR}/ExportOptions.plist"

  # Update ExportOptions.plist with Team ID if provided
  if [ -n "$EXPORT_TEAM_ID" ]; then
    /usr/libexec/PlistBuddy -c "Set :teamID $EXPORT_TEAM_ID" "$EXPORT_OPTIONS"
    log_info "Updated ExportOptions.plist with Team ID: $EXPORT_TEAM_ID"
  fi

  mkdir -p "$IPA_DIR"

  xcodebuild \
    -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportOptionsPlist "$EXPORT_OPTIONS" \
    -exportPath "$IPA_DIR" \
    -verbose

  log_success "IPA exported: $IPA_DIR"

  # List generated files
  log_info "Generated files:"
  find "$IPA_DIR" -type f | while read -r file; do
    local size=$(du -h "$file" | cut -f1)
    echo "  - $(basename "$file") ($size)"
  done
}

verify_build() {
  log_info "Verifying build artifacts..."

  local IPA_FILE="${BUILD_DIR}/ipa/Runner.ipa"

  if [ ! -f "$IPA_FILE" ]; then
    log_error "IPA file not found: $IPA_FILE"
    exit 1
  fi

  local IPA_SIZE=$(du -h "$IPA_FILE" | cut -f1)
  log_success "IPA file verified: $IPA_SIZE"

  # Check if IPA size is reasonable (should be less than 1GB)
  local IPA_SIZE_MB=$(du -m "$IPA_FILE" | cut -f1)
  if [ "$IPA_SIZE_MB" -gt 1000 ]; then
    log_warning "IPA size is large: ${IPA_SIZE_MB}MB (expected < 1000MB)"
  fi
}

upload_testflight_info() {
  log_info "TestFlight upload instructions:"
  echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${GREEN}Next Steps:${NC}"
  echo -e "1. Open App Store Connect: https://appstoreconnect.apple.com/"
  echo -e "2. Navigate to: TestFlight > iOS Builds"
  echo -e "3. Click '+' to upload new build"
  echo -e "4. Select this IPA file:"
  echo -e "   ${BUILD_DIR}/ipa/Runner.ipa"
  echo -e "\n${GREEN}Build Information:${NC}"
  echo -e "  Version: $VERSION"
  echo -e "  Build Number: $BUILD_NUMBER"
  echo -e "  Configuration: $CONFIGURATION"
  echo -e "\n${GREEN}Release Notes Template:${NC}"
  cat << 'EOF'
  🎉 ぬりパズ動物園 v0.1.0 TestFlight Beta

  このテストビルドで確認してください:

  ✨ 新機能
  - パズル → 動物育成の完全フロー
  - なつき度 Lv1-4 システム
  - 群れボーナス演出

  🔧 設定
  - サウンド・アニメーション設定
  - ダークモード対応

  📊 ご協力ください
  - クラッシュ報告（詳細・再現手順）
  - パフォーマンス・動作確認
  - UI/UX フィードバック

  フィードバック連絡先: support@yourwish.dev
EOF
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

main() {
  log_info "Starting TestFlight Build Process"
  log_info "Version: $VERSION, Build: $BUILD_NUMBER"

  check_requirements
  clean_build
  flutter_get
  pod_install
  update_version_build
  build_flutter_ios
  build_archive
  export_ipa
  verify_build
  upload_testflight_info

  log_success "TestFlight build completed successfully!"
  log_info "IPA location: ${BUILD_DIR}/ipa/Runner.ipa"
}

# Run main function
main "$@"
