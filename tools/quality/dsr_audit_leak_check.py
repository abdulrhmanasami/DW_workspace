#!/usr/bin/env python3
"""
DSR Audit Leak Check Script
Validates DSR audit logs for PII leakage and proper event sequences.

Usage: python3 dsr_audit_leak_check.py [audit_log_file]

Reads JSONL audit log and checks for:
1. No PII leakage (emails, phones, names, sensitive URIs)
2. Proper event sequences for each request
3. Required confirmation for erasure requests

Exits with code 0 on success, 1 on failure.
"""

import json
import sys
import re
from pathlib import Path
from collections import defaultdict
from typing import List, Dict, Set


class DsrAuditLeakChecker:
    """Validates DSR audit logs for compliance and correctness."""

    # PII patterns to check for
    PII_PATTERNS = {
        'email': re.compile(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'),
        # US-like 10-digit forms; we will only scan string fields (not numerics) to avoid ts false-positives
        'phone': re.compile(r'\b(\+?\d{1,3}[-.\s]?)?\(?(\d{3})\)?[-.\s]?(\d{3})[-.\s]?(\d{4})\b'),
        'name': re.compile(r'\b(?:[A-Z][a-z]+(?:\s+[A-Z][a-z]+)+)\b'),  # Simple name pattern
    }

    # Sensitive URI parameters
    SENSITIVE_PARAMS = {
        'password', 'token', 'secret', 'key', 'auth', 'api_key', 'session',
        'bearer', 'authorization', 'credentials'
    }

    def __init__(self, audit_log_path: str):
        self.audit_log_path = Path(audit_log_path)
        self.errors: List[str] = []
        self.warnings: List[str] = []

    def check_file_exists(self) -> bool:
        """Check if audit log file exists."""
        if not self.audit_log_path.exists():
            self.errors.append(f"Audit log file not found: {self.audit_log_path}")
            return False
        return True

    def load_audit_events(self) -> List[Dict]:
        """Load and parse audit events from JSONL file."""
        events = []
        try:
            with open(self.audit_log_path, 'r', encoding='utf-8') as f:
                for line_num, line in enumerate(f, 1):
                    line = line.strip()
                    if not line:
                        continue
                    try:
                        event = json.loads(line)
                        event['_line_num'] = line_num
                        events.append(event)
                    except json.JSONDecodeError as e:
                        self.errors.append(f"Invalid JSON at line {line_num}: {e}")
        except Exception as e:
            self.errors.append(f"Failed to read audit log: {e}")

        return events

    def check_pii_leakage(self, events: List[Dict]) -> None:
        """Check for PII leakage in audit events."""
        for event in events:
            line_num = event.get('_line_num', 'unknown')
            # Only scan string-valued fields to avoid matching numeric timestamps as phone numbers
            def scan_string(value: str) -> None:
                if self.PII_PATTERNS['email'].search(value):
                    self.errors.append(f"Email pattern found at line {line_num}")
                if self.PII_PATTERNS['phone'].search(value):
                    self.errors.append(f"Phone pattern found at line {line_num}")
                if self.PII_PATTERNS['name'].search(value):
                    self.errors.append(f"Name pattern found at line {line_num}")

            for k, v in event.items():
                if k == 'meta':
                    continue  # handled below
                if isinstance(v, str):
                    scan_string(v)

            # Check URI parameters for sensitive data
            if 'meta' in event and isinstance(event['meta'], dict):
                for key, value in event['meta'].items():
                    if isinstance(value, str):
                        try:
                            from urllib.parse import urlparse, parse_qs
                            parsed = urlparse(value)
                            if parsed.query:
                                params = parse_qs(parsed.query)
                                for param_name in params.keys():
                                    if any(sensitive in param_name.lower() for sensitive in self.SENSITIVE_PARAMS):
                                        self.errors.append(
                                            f"Sensitive URI parameter '{param_name}' found at line {line_num}"
                                        )
                        except:
                            pass  # Not a valid URI, skip

    def check_event_sequences(self, events: List[Dict]) -> None:
        """Check that events follow proper sequences for each request."""
        # Group events by request_id
        requests: Dict[str, List[Dict]] = defaultdict(list)
        for event in events:
            req_id = event.get('request_id')
            if req_id:
                requests[req_id].append(event)

        for req_id, req_events in requests.items():
            self._check_single_request_sequence(req_id, req_events)

    def _check_single_request_sequence(self, req_id: str, events: List[Dict]) -> None:
        """Check sequence for a single request."""
        if not events:
            return

        # Sort events by timestamp
        events.sort(key=lambda e: e.get('ts', ''))

        # Normalize actions/statuses to canonical internal forms
        for e in events:
            e['action_norm'] = self._normalize_action(e.get('action'))
            e['status_norm'] = self._normalize_status(e.get('status'))

        first_event = events[0]
        req_type = first_event.get('request_type')

        # Check that first event is a create
        if first_event.get('action_norm') != 'create':
            self.errors.append(f"Request {req_id}: First event should be 'create', got '{first_event.get('action')}'")

        # Check erasure confirmation requirement
        if req_type == 'erasure':
            has_confirm = any(e.get('action_norm') == 'confirm' for e in events)
            if not has_confirm:
                self.errors.append(f"Request {req_id}: Erasure request missing 'confirm' action")

        # Check for proper status progression
        status_sequence = [e.get('status_norm') for e in events]
        self._validate_status_progression(req_id, status_sequence)

    def _validate_status_progression(self, req_id: str, statuses: List[str]) -> None:
        """Validate that status changes follow allowed transitions."""
        # Define allowed status transitions
        allowed_transitions = {
            'pending': {'inProgress', 'ready', 'completed', 'failed', 'canceled'},
            'inProgress': {'ready', 'completed', 'failed', 'canceled'},
            'ready': {'completed', 'failed', 'canceled'},
            'completed': set(),  # Terminal state
            'failed': set(),     # Terminal state
            'canceled': set(),   # Terminal state
        }

        previous_status = None
        for status in statuses:
            if previous_status and status != previous_status:
                if status not in allowed_transitions.get(previous_status, set()):
                    self.errors.append(
                        f"Request {req_id}: Invalid status transition {previous_status} -> {status}"
                    )
            previous_status = status

    def check_required_fields(self, events: List[Dict]) -> None:
        """Check that all events have required fields."""
        required_fields = {'ts', 'user_id_hash', 'request_id', 'request_type', 'status', 'action'}

        for event in events:
            line_num = event.get('_line_num', 'unknown')
            missing = required_fields - set(event.keys())
            if missing:
                self.errors.append(f"Event at line {line_num} missing required fields: {missing}")

            # ts must be epoch milliseconds (>= 10^12)
            ts_value = event.get('ts')
            if not isinstance(ts_value, int) or ts_value < 1000000000000:
                self.errors.append(f"Event at line {line_num}: ts must be epoch milliseconds")

            # Check user_id_hash is not raw user ID (should be hash)
            user_id_hash = event.get('user_id_hash', '')
            if user_id_hash and len(user_id_hash) < 32:  # SHA-256 is 64 chars hex
                self.warnings.append(f"Event at line {line_num}: user_id_hash looks suspiciously short")

    @staticmethod
    def _normalize_action(action: str) -> str:
        """Map external action enums to canonical internal forms."""
        if not isinstance(action, str):
            return action
        mapping = {
            'submitted': 'create',
            'confirmed': 'confirm',
            # passthroughs
            'create': 'create',
            'queued': 'queued',
            'processing': 'processing',
            'ready': 'ready',
            'failed': 'failed',
            'confirm': 'confirm',
        }
        return mapping.get(action, action)

    @staticmethod
    def _normalize_status(status: str) -> str:
        """Map external status enums to canonical internal forms."""
        if not isinstance(status, str):
            return status
        mapping = {
            'started': 'pending',
            'processing': 'inProgress',
            'completed': 'completed',
            'failed': 'failed',
            'pending': 'pending',
            'inProgress': 'inProgress',
            'ready': 'ready',
            'canceled': 'canceled',
        }
        return mapping.get(status, status)

    def run_checks(self) -> bool:
        """Run all validation checks."""
        if not self.check_file_exists():
            return False

        events = self.load_audit_events()

        if not events:
            self.errors.append("No audit events found in log file")
            return False

        print(f"Loaded {len(events)} audit events from {self.audit_log_path}")

        self.check_required_fields(events)
        self.check_pii_leakage(events)
        self.check_event_sequences(events)

        return len(self.errors) == 0

    def report_results(self) -> None:
        """Print validation results."""
        if self.errors:
            print(f"\n❌ FOUND {len(self.errors)} ERRORS:")
            for error in self.errors:
                print(f"  - {error}")
        else:
            print("\n✅ NO ERRORS FOUND")

        if self.warnings:
            print(f"\n⚠️  FOUND {len(self.warnings)} WARNINGS:")
            for warning in self.warnings:
                print(f"  - {warning}")


def main():
    """Main entry point."""
    if len(sys.argv) != 2:
        print("Usage: python3 dsr_audit_leak_check.py <audit_log_file>")
        print("Default audit log path: build/dsr_audit.log")
        audit_log = "build/dsr_audit.log"
    else:
        audit_log = sys.argv[1]

    checker = DsrAuditLeakChecker(audit_log)

    success = checker.run_checks()
    checker.report_results()

    if success:
        print("\n✅ DSR AUDIT LEAK CHECK PASSED")
        sys.exit(0)
    else:
        print(f"\n❌ DSR AUDIT LEAK CHECK FAILED ({len(checker.errors)} errors)")
        sys.exit(1)


if __name__ == "__main__":
    main()
