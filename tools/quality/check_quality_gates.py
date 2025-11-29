#!/usr/bin/env python3

"""
Unified Quality Gates Checker - P-QG-01

Combines metrics from Play Vitals, Crashlytics, and startup regression
to determine if quality gates pass or fail for production rollouts.
"""

import json
import sys
import argparse
import os
from typing import Dict, Any, List, Tuple
from datetime import datetime

class QualityGateChecker:
    def __init__(self, gates_config: Dict[str, Any]):
        self.config = gates_config
        self.thresholds = gates_config["thresholds"]
        self.violations: List[Dict[str, Any]] = []
        self.metrics: Dict[str, Any] = {}

    def load_metrics(self) -> bool:
        """Load all required metrics files."""
        required_files = [
            "tools/reports/PQG_play_metrics.json",
            "tools/reports/PQG_crashlytics_metrics.json",
            "tools/reports/PQG_startup_regression.json"
        ]

        missing_files = []
        for file_path in required_files:
            if not os.path.exists(file_path):
                missing_files.append(file_path)

        if missing_files:
            self.violations.append({
                "type": "configuration_error",
                "message": f"Missing required metrics files: {', '.join(missing_files)}",
                "severity": "critical"
            })
            return False

        try:
            # Load Play metrics
            with open("tools/reports/PQG_play_metrics.json", 'r') as f:
                play_data = json.load(f)
                self.metrics.update({
                    "anr_rate_pct": play_data["metrics"]["anr_rate"],
                    "crash_rate": play_data["metrics"]["crash_rate"]
                })

            # Load Crashlytics metrics
            with open("tools/reports/PQG_crashlytics_metrics.json", 'r') as f:
                crash_data = json.load(f)
                self.metrics.update({
                    "crash_free_sessions_pct": crash_data["metrics"]["crash_free_sessions_pct"],
                    "fatal_rate_pct": crash_data["metrics"]["fatal_crash_rate_pct"]
                })

            # Load startup regression
            with open("tools/reports/PQG_startup_regression.json", 'r') as f:
                startup_data = json.load(f)
                self.metrics.update({
                    "cold_start_regression_pct": startup_data["overall_regression_pct"]
                })

            return True

        except Exception as e:
            self.violations.append({
                "type": "data_error",
                "message": f"Failed to load metrics data: {e}",
                "severity": "critical"
            })
            return False

    def check_crash_free_sessions(self) -> bool:
        """Check crash-free sessions threshold."""
        actual = self.metrics.get("crash_free_sessions_pct", 0)
        threshold = self.thresholds["crash_free_sessions_pct_min"]

        if actual < threshold:
            self.violations.append({
                "type": "quality_gate_failure",
                "gate": "crash_free_sessions",
                "threshold": threshold,
                "actual": actual,
                "message": f"Crash-free sessions {actual}% below threshold {threshold}%",
                "severity": "high"
            })
            return False
        return True

    def check_anr_rate(self) -> bool:
        """Check ANR rate threshold."""
        actual = self.metrics.get("anr_rate_pct", float('inf'))
        threshold = self.thresholds["anr_rate_pct_max"]

        if actual > threshold:
            self.violations.append({
                "type": "quality_gate_failure",
                "gate": "anr_rate",
                "threshold": f"≤{threshold}%",
                "actual": f"{actual}%",
                "message": f"ANR rate {actual}% exceeds threshold {threshold}%",
                "severity": "high"
            })
            return False
        return True

    def check_fatal_rate(self) -> bool:
        """Check fatal crash rate threshold."""
        actual = self.metrics.get("fatal_rate_pct", float('inf'))
        threshold = self.thresholds["fatal_rate_pct_max"]

        if actual > threshold:
            self.violations.append({
                "type": "quality_gate_failure",
                "gate": "fatal_rate",
                "threshold": threshold,
                "actual": actual,
                "message": f"Fatal crash rate {actual}% exceeds threshold {threshold}%",
                "severity": "high"
            })
            return False
        return True

    def check_cold_start_regression(self) -> bool:
        """Check cold start regression threshold."""
        actual = abs(self.metrics.get("cold_start_regression_pct", float('inf')))
        threshold = self.thresholds["cold_start_regression_pct_max"]

        if actual > threshold:
            self.violations.append({
                "type": "quality_gate_failure",
                "gate": "cold_start_regression",
                "threshold": threshold,
                "actual": actual,
                "message": f"Cold start regression {actual}% exceeds threshold {threshold}%",
                "severity": "medium"
            })
            return False
        return True

    def run_all_checks(self) -> bool:
        """Run all quality gate checks."""
        checks = [
            self.check_crash_free_sessions,
            self.check_anr_rate,
            self.check_fatal_rate,
            self.check_cold_start_regression
        ]

        all_passed = True
        for check in checks:
            if not check():
                all_passed = False

        return all_passed

    def generate_reports(self, version_code: int):
        """Generate human-readable and JSON reports."""
        ok = len(self.violations) == 0

        # Generate JSON result
        result_data = {
            "versionCode": version_code,
            "ok": ok,
            "violations": self.violations,
            "metrics": self.metrics,
            "checked_at": datetime.utcnow().isoformat() + "Z",
            "gates_config": {
                "window_days": self.config["window_days"],
                "thresholds": self.thresholds
            }
        }

        os.makedirs("tools/reports", exist_ok=True)

        with open("tools/reports/PQG_result.json", 'w') as f:
            json.dump(result_data, f, indent=2)

        # Generate human-readable summary
        summary_lines = [
            "# Quality Gates Check Summary - P-QG-01\n",
            f"**Version Code:** {version_code}\n",
            f"**Status:** {'✅ PASS' if ok else '❌ FAIL'}\n",
            f"**Checked At:** {result_data['checked_at']}\n",
            "\n## Quality Metrics\n",
            "| Metric | Threshold | Actual | Status |",
            "|--------|-----------|--------|--------|",
            f"| Crash-free Sessions | ≥{self.thresholds['crash_free_sessions_pct_min']}% | {self.metrics.get('crash_free_sessions_pct', 'N/A')}% | {'✅' if self.metrics.get('crash_free_sessions_pct', 0) >= self.thresholds['crash_free_sessions_pct_min'] else '❌'} |",
            f"| ANR Rate | ≤{self.thresholds['anr_rate_pct_max']}% | {self.metrics.get('anr_rate_pct', 'N/A')}% | {'✅' if self.metrics.get('anr_rate_pct', float('inf')) <= self.thresholds['anr_rate_pct_max'] else '❌'} |",
            f"| Fatal Crash Rate | ≤{self.thresholds['fatal_rate_pct_max']}% | {self.metrics.get('fatal_rate_pct', 'N/A')}% | {'✅' if self.metrics.get('fatal_rate_pct', float('inf')) <= self.thresholds['fatal_rate_pct_max'] else '❌'} |",
            f"| Cold Start Regression | ≤{self.thresholds['cold_start_regression_pct_max']}% | {abs(self.metrics.get('cold_start_regression_pct', 0))}% | {'✅' if abs(self.metrics.get('cold_start_regression_pct', 0)) <= self.thresholds['cold_start_regression_pct_max'] else '❌'} |",
        ]

        if self.violations:
            summary_lines.extend([
                "\n## Violations\n",
                f"Found {len(self.violations)} quality gate violations:\n"
            ])
            for violation in self.violations:
                summary_lines.append(f"- **{violation['gate']}**: {violation['message']}")

        summary_lines.extend([
            "\n## Recommendations\n",
            "✅ **PASS**: Proceed with rollout expansion" if ok else "❌ **FAIL**: Stop rollout and investigate violations",
            "\n---\n*Generated by P-QG-01 Quality Gates Checker*"
        ])

        with open("tools/reports/PQG_summary.md", 'w') as f:
            f.write("\n".join(summary_lines))

def main():
    parser = argparse.ArgumentParser(description="Check quality gates for production rollout")
    parser.add_argument("--versionCode", type=int, required=True, help="App version code to check")

    args = parser.parse_args()

    try:
        # Load quality gates configuration
        with open("tools/quality/quality_gates.json", 'r') as f:
            gates_config = json.load(f)

        # Initialize checker
        checker = QualityGateChecker(gates_config)

        # Load metrics
        if not checker.load_metrics():
            print("❌ Failed to load required metrics", file=sys.stderr)
            checker.generate_reports(args.versionCode)
            sys.exit(1)

        # Run checks
        ok = checker.run_all_checks()

        # Generate reports
        checker.generate_reports(args.versionCode)

        # Print summary to stdout
        print(f"Quality Gates Check Result: {'PASS' if ok else 'FAIL'}")
        print(f"Version Code: {args.versionCode}")
        print(f"Violations: {len(checker.violations)}")

        if not ok:
            print("\nViolations:")
            for violation in checker.violations:
                print(f"  - {violation['gate']}: {violation['message']}")

        # Exit with appropriate code
        sys.exit(0 if ok else 1)

    except Exception as e:
        print(f"ERROR: Quality gates check failed: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
