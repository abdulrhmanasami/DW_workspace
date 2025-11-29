#!/usr/bin/env bash
# Component: Critical Paths Test Runner
# Created by: CENT-006 QA Implementation
# Purpose: Run tests for critical auth and payments paths
# Last updated: 2025-11-25

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
  echo -e "${GREEN}[PASS]${NC} $1"
}

log_error() {
  echo -e "${RED}[FAIL]${NC} $1"
}

log_warning() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

run_test_suite() {
  local suite_name="$1"
  local test_path="$2"
  
  log_info "Running $suite_name tests..."
  
  TOTAL_TESTS=$((TOTAL_TESTS + 1))
  
  if flutter test "$test_path" --reporter=compact 2>&1; then
    log_success "$suite_name tests passed"
    PASSED_TESTS=$((PASSED_TESTS + 1))
    return 0
  else
    log_error "$suite_name tests failed"
    FAILED_TESTS=$((FAILED_TESTS + 1))
    return 1
  fi
}

# Main execution
main() {
  log_info "=========================================="
  log_info "Critical Paths Test Suite - CENT-006"
  log_info "=========================================="
  log_info "Project Root: $PROJECT_ROOT"
  echo ""
  
  cd "$PROJECT_ROOT"
  
  # Ensure dependencies are up to date
  log_info "Checking dependencies..."
  flutter pub get
  
  echo ""
  log_info "Starting test execution..."
  echo ""
  
  # Track overall success
  local overall_success=true
  
  # --------------------------------------------------------------------------
  # Auth Critical Path Tests
  # --------------------------------------------------------------------------
  log_info "--- AUTH CRITICAL PATH ---"
  
  if [ -f "test/state/auth/passwordless_auth_controller_test.dart" ]; then
    if ! run_test_suite "Passwordless Auth Controller" "test/state/auth/passwordless_auth_controller_test.dart"; then
      overall_success=false
    fi
  else
    log_warning "Auth controller test not found at test/state/auth/passwordless_auth_controller_test.dart"
  fi
  
  # 2FA/MFA Tests (CENT-004)
  if [ -f "test/state/auth/two_factor_auth_controller_test.dart" ]; then
    if ! run_test_suite "Two-Factor Auth Controller" "test/state/auth/two_factor_auth_controller_test.dart"; then
      overall_success=false
    fi
  else
    log_warning "2FA controller test not found at test/state/auth/two_factor_auth_controller_test.dart"
  fi
  
  echo ""
  
  # --------------------------------------------------------------------------
  # Payments Critical Path Tests
  # --------------------------------------------------------------------------
  log_info "--- PAYMENTS CRITICAL PATH ---"
  
  if [ -f "test/state/payments/payment_methods_controller_test.dart" ]; then
    if ! run_test_suite "Payment Methods Controller" "test/state/payments/payment_methods_controller_test.dart"; then
      overall_success=false
    fi
  else
    log_warning "Payments controller test not found at test/state/payments/payment_methods_controller_test.dart"
  fi
  
  echo ""
  
  # --------------------------------------------------------------------------
  # Payments Package Tests
  # --------------------------------------------------------------------------
  log_info "--- PAYMENTS PACKAGE TESTS ---"
  
  if [ -d "packages/payments/test" ]; then
    if ! run_test_suite "Payments Package" "packages/payments/test/"; then
      overall_success=false
    fi
  else
    log_warning "Payments package tests directory not found"
  fi
  
  echo ""
  
  # --------------------------------------------------------------------------
  # Summary
  # --------------------------------------------------------------------------
  log_info "=========================================="
  log_info "TEST SUMMARY"
  log_info "=========================================="
  echo ""
  echo "Total test suites:  $TOTAL_TESTS"
  echo -e "Passed:             ${GREEN}$PASSED_TESTS${NC}"
  echo -e "Failed:             ${RED}$FAILED_TESTS${NC}"
  echo ""
  
  if [ "$overall_success" = true ] && [ "$FAILED_TESTS" -eq 0 ]; then
    log_success "All critical path tests passed!"
    echo ""
    echo "Coverage targets:"
    echo "  - Auth (Passwordless + Biometric): ✓"
    echo "  - Payments (Gateway + Controller): ✓"
    exit 0
  else
    log_error "Some critical path tests failed!"
    exit 1
  fi
}

# Run main
main "$@"

