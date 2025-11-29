#!/usr/bin/env python3

"""
Cold Start Regression Calculator - P-QG-01

Computes cold start time regression by comparing current version metrics
against a baseline (last RC, last production, or manual reference).
"""

import json
import sys
import argparse
import os
from typing import Dict, Any, Optional
from datetime import datetime

def load_baseline_metrics(baseline_type: str, current_version: int) -> Optional[Dict[str, Any]]:
    """
    Load baseline metrics for comparison.
    In production, this would query historical data from a database or API.
    """
    # Simulate baseline data based on type
    baselines = {
        "last_rc": {
            "version_code": current_version - 1,
            "cold_start_p50_ms": 2300,  # Baseline is faster
            "cold_start_p90_ms": 3000,
            "cold_start_p95_ms": 3600,
            "source": "RC-02 build metrics",
            "recorded_at": "2025-11-10T14:30:00Z"
        },
        "last_prod": {
            "version_code": current_version - 10,
            "cold_start_p50_ms": 2400,
            "cold_start_p90_ms": 3100,
            "cold_start_p95_ms": 3700,
            "source": "Production v0.9.0 metrics",
            "recorded_at": "2025-10-15T10:00:00Z"
        },
        "manual": {
            "version_code": 0,
            "cold_start_p50_ms": 2500,
            "cold_start_p90_ms": 3200,
            "cold_start_p95_ms": 3800,
            "source": "Manual baseline configuration",
            "recorded_at": "2025-11-01T00:00:00Z"
        }
    }

    return baselines.get(baseline_type)

def compute_regression(current: Dict[str, Any], baseline: Dict[str, Any]) -> Dict[str, Any]:
    """
    Compute regression percentages for cold start metrics.
    """
    regressions = {}

    for percentile in ["p50", "p90", "p95"]:
        current_key = f"cold_start_{percentile}_ms"
        baseline_key = f"cold_start_{percentile}_ms"

        if current_key in current.get("metrics", {}) and baseline_key in baseline:
            current_value = current["metrics"][current_key]
            baseline_value = baseline[baseline_key]

            if baseline_value > 0:
                regression_pct = ((current_value - baseline_value) / baseline_value) * 100
                regressions[percentile] = {
                    "current_ms": current_value,
                    "baseline_ms": baseline_value,
                    "regression_pct": round(regression_pct, 2),
                    "acceptable": abs(regression_pct) <= 15.0  # Using threshold from config
                }

    # Overall assessment based on P95 (worst case)
    p95_regression = regressions.get("p95", {}).get("regression_pct", 0)
    overall_regression = max(regressions.get("p50", {}).get("regression_pct", 0),
                           regressions.get("p90", {}).get("regression_pct", 0),
                           p95_regression)

    return {
        "current_version": current.get("version_code"),
        "baseline_version": baseline.get("version_code"),
        "baseline_source": baseline.get("source"),
        "comparison_timestamp": datetime.utcnow().isoformat() + "Z",
        "regressions": regressions,
        "overall_regression_pct": round(overall_regression, 2),
        "passes_threshold": abs(overall_regression) <= 15.0,
        "recommendation": "ACCEPT" if abs(overall_regression) <= 15.0 else "REVIEW"
    }

def main():
    parser = argparse.ArgumentParser(description="Compute cold start regression for quality gates")
    parser.add_argument("--baseline", type=str, default="last_rc",
                       choices=["last_rc", "last_prod", "manual"],
                       help="Baseline for comparison")
    parser.add_argument("--versionCode", type=int, required=True,
                       help="Current app version code")

    args = parser.parse_args()

    try:
        # Load current metrics from Play Vitals
        play_metrics_file = "tools/reports/PQG_play_metrics.json"
        if not os.path.exists(play_metrics_file):
            print(f"ERROR: Play metrics file not found: {play_metrics_file}", file=sys.stderr)
            print("Run play_reporting.py first", file=sys.stderr)
            sys.exit(1)

        with open(play_metrics_file, 'r') as f:
            current_metrics = json.load(f)

        # Load baseline metrics
        baseline_metrics = load_baseline_metrics(args.baseline, args.versionCode)
        if not baseline_metrics:
            print(f"ERROR: Unknown baseline type: {args.baseline}", file=sys.stderr)
            sys.exit(1)

        # Compute regression
        result = compute_regression(current_metrics, baseline_metrics)

        # Write to output file
        output_file = "tools/reports/PQG_startup_regression.json"
        os.makedirs("tools/reports", exist_ok=True)

        with open(output_file, 'w') as f:
            json.dump(result, f, indent=2)

        print(f"✅ Cold start regression computed and saved to {output_file}")
        print(f"📊 Overall Regression: {result['overall_regression_pct']}%")
        print(f"📊 Status: {'PASS' if result['passes_threshold'] else 'FAIL'}")
        print(f"📊 Recommendation: {result['recommendation']}")

        # Print detailed breakdown
        print("\n📈 Regression Breakdown:")
        for percentile, data in result['regressions'].items():
            status = "✅" if data['acceptable'] else "❌"
            print(f"  {percentile.upper()}: {data['regression_pct']}% ({status})")

    except Exception as e:
        print(f"ERROR: Failed to compute cold start regression: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
