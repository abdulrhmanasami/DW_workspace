#!/bin/bash
# DSR Audit Smoke Test Script
# Generates audit logs for three scenarios: Export Ready, Erasure Confirmed, Cancel
# Then validates the logs for PII leakage and proper sequences

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TOOLS_DIR="$PROJECT_ROOT/tools"
REPORTS_DIR="$TOOLS_DIR/reports"
QUALITY_DIR="$TOOLS_DIR/quality"

# Output files
SMOKE_LOG="$REPORTS_DIR/DSR02_audit_smoke.txt"
LEAK_CHECK_LOG="$REPORTS_DIR/DSR02_audit_leak_check.txt"
AUDIT_LOG="$PROJECT_ROOT/build/dsr_audit.log"

# Create reports directory if it doesn't exist
mkdir -p "$REPORTS_DIR"

echo "=== DSR Audit Smoke Test ===" | tee "$SMOKE_LOG"
echo "Started at: $(date)" | tee -a "$SMOKE_LOG"
echo "" | tee -a "$SMOKE_LOG"

# Clean previous audit log
rm -f "$AUDIT_LOG"

# Set environment for audit logging
export DSR_AUDIT_ENABLED=true
export DSR_AUDIT_LOG_PATH="$AUDIT_LOG"
export ENVIRONMENT=test

echo "1. Setting up test environment..." | tee -a "$SMOKE_LOG"
echo "   - Audit enabled: $DSR_AUDIT_ENABLED" | tee -a "$SMOKE_LOG"
echo "   - Audit log path: $AUDIT_LOG" | tee -a "$SMOKE_LOG"
echo "   - Environment: $ENVIRONMENT" | tee -a "$SMOKE_LOG"
echo "" | tee -a "$SMOKE_LOG"

# Create a simple Dart test program to generate audit events
TEST_PROGRAM="$PROJECT_ROOT/test_dsr_audit.dart"
cat > "$TEST_PROGRAM" << 'EOF'
import 'dart:io';
import 'package:accounts_shims/accounts_shims.dart';
import 'package:foundation_shims/foundation_shims.dart';

// Mock implementations for testing
class MockConfigManager implements ConfigManager {
  final Map<String, dynamic> _config = {
    'dsr_audit_enabled': true,
    'dsr_audit_log_path': 'build/dsr_audit.log',
    'environment': 'test',
    'accounts_base_url': 'https://api.test.com',
  };

  @override
  bool? getBool(String key) => _config[key] as bool?;

  @override
  String? getString(String key) => _config[key] as String?;

  @override
  int? getInt(String key) => _config[key] as int?;

  @override
  double? getDouble(String key) => _config[key] as double?;
}

class MockAccountsEndpoints implements AccountsEndpoints {
  @override
  Uri get baseUri => Uri.parse('https://api.test.com');

  @override
  Uri dsrCreateUri() => baseUri.resolve('/dsr/create');

  @override
  Uri dsrStatusUri(String requestId) => baseUri.resolve('/dsr/status/$requestId');

  @override
  Uri dsrCancelUri(String requestId) => baseUri.resolve('/dsr/cancel/$requestId');

  @override
  Uri dsrConfirmUri(String requestId) => baseUri.resolve('/dsr/confirm/$requestId');
}

class MockDsrClient implements DsrClient {
  final Map<String, DsrRequestSummary> _requests = {};
  int _nextId = 1;

  @override
  AccountsEndpoints endpoints;

  @override
  ConfigManager configManager;

  MockDsrClient({required this.endpoints, required this.configManager});

  @override
  Future<DsrRequestSummary> createRequest(DsrCreateRequest request) async {
    final id = 'test_req_${_nextId++}';
    final summary = DsrRequestSummary(
      id: DsrRequestId(id),
      type: request.type,
      status: DsrStatus.pending,
      createdAt: DateTime.now(),
    );
    _requests[id] = summary;
    return summary;
  }

  @override
  Future<DsrRequestSummary> getRequestStatus(DsrRequestId id) async {
    var summary = _requests[id.value];
    if (summary == null) {
      throw Exception('Request not found');
    }

    // Simulate status progression for testing
    final now = DateTime.now();
    final age = now.difference(summary.createdAt).inSeconds;

    if (summary.type == DsrRequestType.export && age > 5) {
      summary = DsrRequestSummary(
        id: summary.id,
        type: summary.type,
        status: DsrStatus.ready,
        createdAt: summary.createdAt,
        updatedAt: now,
        exportLink: DsrExportLink(
          url: Uri.parse('https://api.test.com/export/${summary.id.value}'),
          expiresAt: now.add(Duration(hours: 24)),
        ),
      );
      _requests[id.value] = summary;
    } else if (summary.type == DsrRequestType.erasure && age > 10) {
      summary = DsrRequestSummary(
        id: summary.id,
        type: summary.type,
        status: DsrStatus.ready,
        createdAt: summary.createdAt,
        updatedAt: now,
      );
      _requests[id.value] = summary;
    }

    return summary;
  }

  @override
  Future<void> cancelRequest(DsrRequestId id) async {
    final summary = _requests[id.value];
    if (summary != null) {
      _requests[id.value] = DsrRequestSummary(
        id: summary.id,
        type: summary.type,
        status: DsrStatus.canceled,
        createdAt: summary.createdAt,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> confirmErasure(DsrRequestId id) async {
    final summary = _requests[id.value];
    if (summary != null) {
      _requests[id.value] = DsrRequestSummary(
        id: summary.id,
        type: summary.type,
        status: DsrStatus.completed,
        createdAt: summary.createdAt,
        updatedAt: DateTime.now(),
      );
    }
  }
}

void main() async {
  print('Starting DSR Audit Smoke Test...');

  // Setup mock dependencies
  final configManager = MockConfigManager();
  final endpoints = MockAccountsEndpoints();
  final client = MockDsrClient(endpoints: endpoints, configManager: configManager);

  // Create file audit sink
  final auditSink = FileDsrAuditSink('build/dsr_audit.log');

  // Create service with audit logging
  final service = DsrServiceImpl(
    client: client,
    auditSink: auditSink,
    userId: 'test_user_123',
  );

  print('Test 1: Export Request Flow');
  try {
    // Create export request
    final exportReq = await service.requestExport(includePaymentsHistory: true);
    print('  Created export request: ${exportReq.id.value}');

    // Poll status a few times
    await Future.delayed(Duration(seconds: 1));
    var status = await service.getRequestStatus(exportReq.id);
    print('  Status poll 1: ${status.status}');

    await Future.delayed(Duration(seconds: 6)); // Wait for status change
    status = await service.getRequestStatus(exportReq.id);
    print('  Status poll 2: ${status.status} (should be ready)');
  } catch (e) {
    print('  Error in export test: $e');
  }

  print('');
  print('Test 2: Erasure Request Flow');
  try {
    // Create erasure request
    final erasureReq = await service.requestErasure();
    print('  Created erasure request: ${erasureReq.id.value}');

    // Poll status
    await Future.delayed(Duration(seconds: 1));
    var status = await service.getRequestStatus(erasureReq.id);
    print('  Status poll: ${status.status}');

    await Future.delayed(Duration(seconds: 12)); // Wait for status change
    status = await service.getRequestStatus(erasureReq.id);
    print('  Status poll: ${status.status} (should be ready)');

    // Confirm erasure
    await service.confirmErasure(erasureReq.id);
    print('  Confirmed erasure');
  } catch (e) {
    print('  Error in erasure test: $e');
  }

  print('');
  print('Test 3: Cancel Request Flow');
  try {
    // Create another export request
    final cancelReq = await service.requestExport();
    print('  Created export request for cancellation: ${cancelReq.id.value}');

    // Poll status once
    await Future.delayed(Duration(seconds: 1));
    final status = await service.getRequestStatus(cancelReq.id);
    print('  Status before cancel: ${status.status}');

    // Cancel request
    await service.cancelRequest(cancelReq.id);
    print('  Canceled request');
  } catch (e) {
    print('  Error in cancel test: $e');
  }

  print('');
  print('Audit logging test completed.');
  print('Check build/dsr_audit.log for generated events.');
}
EOF

echo "2. Running smoke test to generate audit events..." | tee -a "$SMOKE_LOG"

# Run the test program
cd "$PROJECT_ROOT"
if flutter pub get && dart run "$TEST_PROGRAM"; then
    echo "   ✅ Smoke test completed successfully" | tee -a "$SMOKE_LOG"
else
    echo "   ❌ Smoke test failed" | tee -a "$SMOKE_LOG"
    exit 1
fi

# Clean up test program
rm -f "$TEST_PROGRAM"

echo "" | tee -a "$SMOKE_LOG"
echo "3. Checking generated audit log..." | tee -a "$SMOKE_LOG"

if [ -f "$AUDIT_LOG" ]; then
    EVENT_COUNT=$(wc -l < "$AUDIT_LOG")
    echo "   ✅ Audit log created: $AUDIT_LOG" | tee -a "$SMOKE_LOG"
    echo "   📊 Events generated: $EVENT_COUNT" | tee -a "$SMOKE_LOG"
else
    echo "   ❌ Audit log not created" | tee -a "$SMOKE_LOG"
    exit 1
fi

echo "" | tee -a "$SMOKE_LOG"
echo "4. Running leak check validation..." | tee -a "$SMOKE_LOG"

# Run the leak check script
if python3 "$QUALITY_DIR/dsr_audit_leak_check.py" "$AUDIT_LOG" > "$LEAK_CHECK_LOG" 2>&1; then
    echo "   ✅ Leak check passed" | tee -a "$SMOKE_LOG"
else
    echo "   ❌ Leak check failed" | tee -a "$SMOKE_LOG"
    echo "   📋 Check $LEAK_CHECK_LOG for details" | tee -a "$SMOKE_LOG"
    exit 1
fi

echo "" | tee -a "$SMOKE_LOG"
echo "=== DSR Audit Smoke Test PASSED ===" | tee -a "$SMOKE_LOG"
echo "Completed at: $(date)" | tee -a "$SMOKE_LOG"

exit 0
