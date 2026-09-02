#!/bin/bash

################################################################################
# Phase 9A Environment Setup Verification Script
# Purpose: Verify all Phase 9A prerequisites before attempting TestFlight build
# Usage: ./scripts/verify_phase9a_setup.sh
################################################################################

set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Counters
PASSED=0
FAILED=0
WARNINGS=0

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

################################################################################
# Helper Functions
################################################################################

print_header() {
  echo ""
  echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BLUE}📋 ${1}${NC}"
  echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

check_pass() {
  echo -e "${GREEN}✓${NC} $1"
  ((PASSED++))
}

check_fail() {
  echo -e "${RED}✗${NC} $1"
  ((FAILED++))
}

check_warn() {
  echo -e "${YELLOW}⚠${NC} $1"
  ((WARNINGS++))
}

print_summary() {
  echo ""
  echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BLUE}📊 Summary${NC}"
  echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "  ${GREEN}Passed:${NC}  $PASSED"
  echo -e "  ${YELLOW}Warnings:${NC} $WARNINGS"
  echo -e "  ${RED}Failed:${NC}   $FAILED"
  echo ""

  if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ Phase 9A setup is ready!${NC}"
    return 0
  else
    echo -e "${RED}✗ Phase 9A setup has issues. Please resolve before building.${NC}"
    return 1
  fi
}

################################################################################
# Checks
################################################################################

check_xcode() {
  print_header "Xcode & Command Line Tools"

  if command -v xcode-select &> /dev/null; then
    local xcode_path=$(xcode-select -p)
    check_pass "Xcode is installed at: $xcode_path"
  else
    check_fail "Xcode is not installed"
    return
  fi

  if xcode-select --install 2>&1 | grep -q "xcode-select: error"; then
    check_pass "Command Line Tools are installed"
  else
    check_pass "Command Line Tools available"
  fi

  # Check Xcode version
  if command -v xcodebuild &> /dev/null; then
    local xcode_version=$(xcodebuild -version | head -n1)
    if [[ "$xcode_version" == *"14."* ]] || [[ "$xcode_version" == *"15."* ]]; then
      check_pass "Xcode version is compatible: $xcode_version"
    else
      check_warn "Xcode version might be old: $xcode_version (recommend 14.0+)"
    fi
  fi
}

check_flutter() {
  print_header "Flutter & Dart"

  if command -v flutter &> /dev/null; then
    local flutter_version=$(flutter --version 2>&1 | head -n1)
    check_pass "Flutter is installed: $flutter_version"
  else
    check_fail "Flutter is not installed. Install from: https://flutter.dev"
    return
  fi

  if flutter --version | grep -q "Flutter 3"; then
    check_pass "Flutter 3.x is available"
  elif flutter --version | grep -q "Flutter 2"; then
    check_warn "Flutter 2.x detected (recommend Flutter 3.x)"
  fi

  # Check Dart
  if command -v dart &> /dev/null; then
    local dart_version=$(dart --version)
    check_pass "Dart is available: $dart_version"
  else
    check_fail "Dart is not found in PATH"
  fi
}

check_cocoapods() {
  print_header "CocoaPods (Dependency Manager)"

  if command -v pod &> /dev/null; then
    local pod_version=$(pod --version)
    check_pass "CocoaPods is installed: version $pod_version"
  else
    check_fail "CocoaPods is not installed. Install: sudo gem install cocoapods"
    return
  fi

  # Check if Podfile exists
  if [ -f "$PROJECT_ROOT/ios/Podfile" ]; then
    check_pass "Podfile exists: ios/Podfile"
  else
    check_fail "Podfile not found: ios/Podfile"
  fi
}

check_project_files() {
  print_header "Project Files"

  # Check pubspec.yaml
  if [ -f "$PROJECT_ROOT/pubspec.yaml" ]; then
    check_pass "pubspec.yaml exists"
  else
    check_fail "pubspec.yaml not found"
    return
  fi

  # Check iOS build files
  if [ -f "$PROJECT_ROOT/ios/Runner.xcworkspace/contents.xcworkspacedata" ]; then
    check_pass "iOS workspace exists: ios/Runner.xcworkspace"
  else
    check_fail "iOS workspace not found. Run: flutter create --platforms=ios ."
  fi

  # Check Info.plist
  if [ -f "$PROJECT_ROOT/ios/Runner/Info.plist" ]; then
    check_pass "Info.plist exists: ios/Runner/Info.plist"
  else
    check_warn "Info.plist not found (will be created during build)"
  fi

  # Check ExportOptions.plist
  if [ -f "$PROJECT_ROOT/ios/ExportOptions.plist" ]; then
    check_pass "ExportOptions.plist exists: ios/ExportOptions.plist"
  else
    check_fail "ExportOptions.plist not found. Run: Phase 9A implementation"
  fi

  # Check build scripts
  if [ -f "$PROJECT_ROOT/scripts/build_testflight.sh" ]; then
    if [ -x "$PROJECT_ROOT/scripts/build_testflight.sh" ]; then
      check_pass "build_testflight.sh is executable"
    else
      check_fail "build_testflight.sh exists but is not executable. Run: chmod +x scripts/build_testflight.sh"
    fi
  else
    check_fail "build_testflight.sh not found"
  fi
}

check_ios_signing() {
  print_header "iOS Code Signing"

  # Check for certificates in Keychain
  if security find-certificate -c "Apple Distribution" &> /dev/null; then
    check_pass "Apple Distribution certificate found in Keychain"
  else
    check_warn "Apple Distribution certificate not found in Keychain"
    echo "   → Expected in Apple Developer Portal > Certificates"
    echo "   → Download and open to import into Keychain"
  fi

  # Check for provisioning profiles
  local profile_dir="$HOME/Library/MobileDevice/Provisioning Profiles"
  if [ -d "$profile_dir" ]; then
    local profile_count=$(find "$profile_dir" -name "*.mobileprovision" 2>/dev/null | wc -l)
    if [ "$profile_count" -gt 0 ]; then
      check_pass "Found $profile_count provisioning profile(s)"
    else
      check_warn "No provisioning profiles found in: $profile_dir"
    fi
  else
    check_warn "Provisioning profiles directory not found. Will be created on first sync."
  fi
}

check_environment_variables() {
  print_header "Environment Variables"

  if [ -f "$PROJECT_ROOT/.env.testflight" ]; then
    check_pass ".env.testflight file exists"

    # Check required variables
    source "$PROJECT_ROOT/.env.testflight" 2>/dev/null || true

    if [ -n "${APPLE_TEAM_ID:-}" ]; then
      check_pass "APPLE_TEAM_ID is set: ${APPLE_TEAM_ID:0:4}...${APPLE_TEAM_ID: -4}"
    else
      check_warn "APPLE_TEAM_ID not set in .env.testflight"
    fi

    if [ -n "${APP_BUNDLE_ID:-}" ]; then
      check_pass "APP_BUNDLE_ID is set: $APP_BUNDLE_ID"
    else
      check_fail "APP_BUNDLE_ID not set in .env.testflight"
    fi

    if [ -n "${FIREBASE_PROJECT_ID_PROD:-}" ]; then
      check_pass "Firebase production project configured"
    else
      check_warn "FIREBASE_PROJECT_ID_PROD not set"
    fi

    if [ -n "${REVENUE_CAT_API_KEY_PROD:-}" ]; then
      check_pass "RevenueCat production key configured"
    else
      check_warn "REVENUE_CAT_API_KEY_PROD not set"
    fi

    if [ -n "${ADMOB_APP_ID_PROD:-}" ]; then
      check_pass "AdMob production app ID configured"
    else
      check_warn "ADMOB_APP_ID_PROD not set"
    fi
  else
    check_fail ".env.testflight not found. Run: cp .env.testflight.example .env.testflight"
  fi
}

check_github_actions() {
  print_header "GitHub Actions CI/CD"

  if [ -d "$PROJECT_ROOT/.github/workflows" ]; then
    check_pass "GitHub workflows directory exists"
    local workflow_count=$(ls -1 "$PROJECT_ROOT/.github/workflows"/*.yml 2>/dev/null | wc -l)
    echo "   Found $workflow_count workflow(s)"
  else
    check_warn "GitHub workflows directory not found"
  fi
}

check_storage_space() {
  print_header "Storage Space"

  local available=$(df "$PROJECT_ROOT" | awk 'NR==2 {print $4}')
  local available_gb=$((available / 1024 / 1024))

  if [ "$available_gb" -gt 10 ]; then
    check_pass "Available storage: ${available_gb}GB (sufficient for builds)"
  elif [ "$available_gb" -gt 5 ]; then
    check_warn "Available storage: ${available_gb}GB (tight, but buildable)"
  else
    check_fail "Available storage: ${available_gb}GB (not enough for builds)"
  fi
}

check_network() {
  print_header "Network Connectivity"

  if command -v curl &> /dev/null; then
    if curl -s -I https://api.github.com &> /dev/null; then
      check_pass "Network connectivity to GitHub verified"
    else
      check_warn "Cannot reach GitHub (might be behind proxy)"
    fi

    if curl -s -I https://pub.dev &> /dev/null; then
      check_pass "Network connectivity to pub.dev verified"
    else
      check_warn "Cannot reach pub.dev (might be behind proxy)"
    fi

    if curl -s -I https://appstoreconnect.apple.com &> /dev/null; then
      check_pass "Network connectivity to App Store Connect verified"
    else
      check_warn "Cannot reach App Store Connect (might be behind proxy)"
    fi
  fi
}

################################################################################
# Main Execution
################################################################################

main() {
  clear

  echo -e "${PURPLE}"
  cat << "EOF"
╔══════════════════════════════════════════════════════════════════════════╗
║                    Phase 9A Setup Verification                          ║
║                TestFlight Build Environment Checklist                    ║
╚══════════════════════════════════════════════════════════════════════════╝
EOF
  echo -e "${NC}"

  check_xcode
  check_flutter
  check_cocoapods
  check_project_files
  check_ios_signing
  check_environment_variables
  check_github_actions
  check_storage_space
  check_network

  print_summary
}

main "$@"
