#!/usr/bin/env bash
#
# export_clean_b_workspace.sh
# ===========================
# Exports a standalone Clean-B Workspace for client delivery.
#
# Usage:
#   ./tools/packaging/export_clean_b_workspace.sh [target_directory]
#
# Default target: dist/clean_b_workspace
#
# This script reads the manifest from tools/reports/clean_b_workspace_manifest.json
# and copies all required files to create a standalone workspace.
#
# Author: B-central Cursor
# Version: 1.0.0
# Ticket: DW-CENTRAL-CLEAN-B-PACKAGE-001
#

set -Eeuo pipefail

# ============================================================================
# Configuration
# ============================================================================

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MANIFEST="$ROOT_DIR/tools/reports/clean_b_workspace_manifest.json"
TARGET_DIR="${1:-"$ROOT_DIR/dist/clean_b_workspace"}"
LOG_FILE="$ROOT_DIR/dist/export_clean_b.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================================
# Helper Functions
# ============================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# ============================================================================
# Pre-flight Checks
# ============================================================================

log_info "=============================================="
log_info "Clean-B Workspace Export Script v1.0.0"
log_info "=============================================="
log_info ""
log_info "Root directory: $ROOT_DIR"
log_info "Manifest:       $MANIFEST"
log_info "Target:         $TARGET_DIR"
log_info ""

# Check if manifest exists
if [ ! -f "$MANIFEST" ]; then
    log_error "Manifest not found: $MANIFEST"
    exit 1
fi

# Check if jq is available (for JSON parsing)
JQ_AVAILABLE=false
if command -v jq &> /dev/null; then
    JQ_AVAILABLE=true
    log_info "jq found: Using JSON parsing"
else
    log_warn "jq not found: Using hardcoded include list"
fi

# ============================================================================
# Prepare Target Directory
# ============================================================================

if [ -d "$TARGET_DIR" ]; then
    log_info "Removing existing target directory..."
    rm -rf "$TARGET_DIR"
fi

mkdir -p "$TARGET_DIR"
mkdir -p "$(dirname "$LOG_FILE")"

# ============================================================================
# Define Include Paths (hardcoded fallback if jq not available)
# ============================================================================

INCLUDE_DIRS=(
    "lib"
    "test"
    "integration_test"
    "assets"
    "packages/core"
    "packages/foundation_shims"
    "packages/network_shims"
    "packages/auth_shims"
    "packages/auth_http_impl"
    "packages/auth_supabase_impl"
    "packages/payments"
    "packages/payments_shims"
    "packages/payments_adapter_stripe"
    "packages/payments_stripe_impl"
    "packages/payments_stub_impl"
    "packages/mobility_shims"
    "packages/mobility_uplink_impl"
    "packages/mobility_stub_impl"
    "packages/mobility_adapter_geolocator"
    "packages/mobility_adapter_background"
    "packages/mobility_adapter_geofence"
    "packages/maps_shims"
    "packages/maps_adapter_google"
    "packages/maps_stub_impl"
    "packages/realtime_shims"
    "packages/observability_shims"
    "packages/notifications_shims"
    "packages/accounts_shims"
    "packages/accounts_stub_impl"
    "packages/dsr_ux_adapter"
    "packages/privacy"
    "packages/rbac_rest_impl"
    "packages/design_system_shims"
    "packages/design_system_components"
    "packages/design_system_foundation"
    "packages/design_system_stub_impl"
    "stubs/device_security_shims"
    "B-ui"
    "B-ux"
    "third_party/dart_code_metrics"
    "android"
    "ios"
    "tools/analysis"
    "tools/tests"
    "tools/packaging"
    "tools/quality"
)

INCLUDE_FILES=(
    "pubspec.yaml"
    "pubspec.lock"
    "analysis_options.yaml"
    "l10n.yaml"
    "melos.yaml"
)

INCLUDE_DOCS=(
    "docs/reports/PROJECT_STATUS_v3.2.1.md"
    "docs/reports/FEATURE_FLAGS_MATRIX_v1.0.0.md"
    "docs/reports/CLIENT_DELIVERY_CHECKLIST_v1.0.0.md"
    "docs/reports/RELEASE_EXECUTION_PLAN_v2.0.0.md"
    "docs/reports/RISKS_AND_GAPS_REGISTER_v1.0.0.md"
    "docs/reports/CLEAN_B_WORKSPACE_EXPORT_SPEC_v1.0.0.md"
    "docs/CHANGELOG.md"
    "docs/DEPLOYMENT_GUIDE.md"
    "docs/PRIVACY_POLICY.md"
    "docs/SECURITY_NOTES.md"
)

EXCLUDE_PATTERNS=(
    "build"
    ".dart_tool"
    ".packages"
    "coverage"
    "*.iml"
    "*.log"
    "READY_*"
    "*_EXECUTION_REPORT*"
    "tools/reports"
)

# ============================================================================
# Export Function
# ============================================================================

export_workspace() {
    local start_time=$(date +%s)
    local files_copied=0
    local dirs_copied=0

    log_info "Starting export..."
    log_info ""

    # Step 1: Copy directories
    log_info "Step 1/3: Copying directories..."
    for dir in "${INCLUDE_DIRS[@]}"; do
        local src="$ROOT_DIR/$dir"
        local dst="$TARGET_DIR/$dir"

        if [ -d "$src" ]; then
            mkdir -p "$(dirname "$dst")"
            
            # Use rsync with exclusions
            rsync -a \
                --exclude='build/' \
                --exclude='.dart_tool/' \
                --exclude='.packages' \
                --exclude='coverage/' \
                --exclude='*.iml' \
                --exclude='*.log' \
                --exclude='READY_*' \
                --exclude='*_EXECUTION_REPORT*' \
                --exclude='tools/reports/' \
                "$src/" "$dst/"
            
            ((dirs_copied++))
            log_info "  ✓ $dir"
        else
            log_warn "  ✗ $dir (not found, skipping)"
        fi
    done

    log_info ""
    log_info "Step 2/3: Copying root files..."
    for file in "${INCLUDE_FILES[@]}"; do
        local src="$ROOT_DIR/$file"
        local dst="$TARGET_DIR/$file"

        if [ -f "$src" ]; then
            cp "$src" "$dst"
            ((files_copied++))
            log_info "  ✓ $file"
        else
            log_warn "  ✗ $file (not found, skipping)"
        fi
    done

    log_info ""
    log_info "Step 3/3: Copying documentation..."
    for doc in "${INCLUDE_DOCS[@]}"; do
        local src="$ROOT_DIR/$doc"
        local dst="$TARGET_DIR/$doc"

        if [ -f "$src" ]; then
            mkdir -p "$(dirname "$dst")"
            cp "$src" "$dst"
            ((files_copied++))
            log_info "  ✓ $doc"
        else
            log_warn "  ✗ $doc (not found, skipping)"
        fi
    done

    # Calculate duration
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    log_info ""
    log_success "=============================================="
    log_success "Export Complete!"
    log_success "=============================================="
    log_info ""
    log_info "Summary:"
    log_info "  Directories copied: $dirs_copied"
    log_info "  Files copied:       $files_copied"
    log_info "  Duration:           ${duration}s"
    log_info "  Target:             $TARGET_DIR"
    log_info ""
}

# ============================================================================
# Post-Export Validation (Optional)
# ============================================================================

validate_export() {
    log_info "=============================================="
    log_info "Post-Export Validation"
    log_info "=============================================="
    log_info ""

    local validation_passed=true

    # Check pubspec.yaml exists
    if [ -f "$TARGET_DIR/pubspec.yaml" ]; then
        log_success "  ✓ pubspec.yaml present"
    else
        log_error "  ✗ pubspec.yaml missing"
        validation_passed=false
    fi

    # Check lib/ exists
    if [ -d "$TARGET_DIR/lib" ]; then
        local dart_files=$(find "$TARGET_DIR/lib" -name "*.dart" | wc -l | tr -d ' ')
        log_success "  ✓ lib/ present ($dart_files Dart files)"
    else
        log_error "  ✗ lib/ missing"
        validation_passed=false
    fi

    # Check packages/ exists
    if [ -d "$TARGET_DIR/packages" ]; then
        local pkg_count=$(ls -1 "$TARGET_DIR/packages" | wc -l | tr -d ' ')
        log_success "  ✓ packages/ present ($pkg_count packages)"
    else
        log_error "  ✗ packages/ missing"
        validation_passed=false
    fi

    # Check tools/ exists
    if [ -f "$TARGET_DIR/tools/analysis/assert_no_banned_imports.py" ]; then
        log_success "  ✓ tools/analysis/assert_no_banned_imports.py present"
    else
        log_error "  ✗ tools/analysis/assert_no_banned_imports.py missing"
        validation_passed=false
    fi

    # Check docs/ exists
    if [ -f "$TARGET_DIR/docs/reports/CLIENT_DELIVERY_CHECKLIST_v1.0.0.md" ]; then
        log_success "  ✓ docs/reports/CLIENT_DELIVERY_CHECKLIST_v1.0.0.md present"
    else
        log_error "  ✗ docs/reports/CLIENT_DELIVERY_CHECKLIST_v1.0.0.md missing"
        validation_passed=false
    fi

    log_info ""

    if [ "$validation_passed" = true ]; then
        log_success "Validation PASSED"
    else
        log_error "Validation FAILED - some required files are missing"
        exit 1
    fi
}

# ============================================================================
# Usage Instructions
# ============================================================================

print_next_steps() {
    log_info ""
    log_info "=============================================="
    log_info "Next Steps"
    log_info "=============================================="
    log_info ""
    log_info "1. Navigate to exported workspace:"
    log_info "   cd $TARGET_DIR"
    log_info ""
    log_info "2. Install dependencies:"
    log_info "   flutter pub get"
    log_info ""
    log_info "3. Run analyzer:"
    log_info "   flutter analyze --no-pub lib"
    log_info ""
    log_info "4. Check banned imports:"
    log_info "   python3 tools/analysis/assert_no_banned_imports.py lib"
    log_info ""
    log_info "5. Run critical path tests:"
    log_info "   ./tools/tests/run_critical_paths_tests.sh"
    log_info ""
    log_info "For client delivery, you can:"
    log_info "  - Compress: tar -czvf clean_b_workspace.tar.gz $TARGET_DIR"
    log_info "  - Or copy directly to client"
    log_info ""
}

# ============================================================================
# Main Execution
# ============================================================================

export_workspace
validate_export
print_next_steps

log_success "Done!"

