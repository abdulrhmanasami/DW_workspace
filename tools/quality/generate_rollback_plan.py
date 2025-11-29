#!/usr/bin/env python3

"""
Rollback Plan Generator - P-QG-01

Automatically generates rollback plans and hotfix tickets when quality gates fail.
"""

import json
import sys
import argparse
import os
from typing import Dict, Any
from datetime import datetime

def load_violations() -> Dict[str, Any]:
    """Load quality gate violations from the result file."""
    result_file = "tools/reports/PQG_result.json"
    if not os.path.exists(result_file):
        return {"violations": [], "versionCode": 0}

    with open(result_file, 'r') as f:
        return json.load(f)

def generate_hotfix_version(current_version: int) -> int:
    """Generate next hotfix version code."""
    return current_version + 1

def create_violation_ticket(violations_data: Dict[str, Any], phase: str) -> str:
    """Create a detailed violation ticket for stakeholders."""
    version_code = violations_data.get("versionCode", 0)
    violations = violations_data.get("violations", [])
    metrics = violations_data.get("metrics", {})

    hotfix_version = generate_hotfix_version(version_code)

    ticket_lines = [
        "# 🚨 Quality Gates Violation Ticket - P-QG-01\n",
        f"**Generated:** {datetime.utcnow().isoformat()}Z\n",
        f"**Version:** {version_code}\n",
        f"**Rollout Phase:** {phase}\n",
        f"**Status:** BLOCKED - Quality Gates Failed\n",
        "\n## Violation Summary\n",
        f"Found {len(violations)} quality gate violations:\n"
    ]

    for i, violation in enumerate(violations, 1):
        ticket_lines.extend([
            f"### {i}. {violation['gate'].replace('_', ' ').title()}\n",
            f"- **Threshold:** {violation['threshold']}\n",
            f"- **Actual:** {violation['actual']}\n",
            f"- **Message:** {violation['message']}\n",
            f"- **Severity:** {violation['severity']}\n\n"
        ])

    ticket_lines.extend([
        "\n## Current Metrics\n",
        "| Metric | Value | Status |\n",
        "|--------|-------|--------|\n",
        f"| Crash-free Sessions | {metrics.get('crash_free_sessions_pct', 'N/A')}% | {'❌' if any(v['gate'] == 'crash_free_sessions' for v in violations) else '✅'} |\n",
        f"| ANR Rate | {metrics.get('anr_rate_pct', 'N/A')}% | {'❌' if any(v['gate'] == 'anr_rate' for v in violations) else '✅'} |\n",
        f"| Fatal Crash Rate | {metrics.get('fatal_rate_pct', 'N/A')}% | {'❌' if any(v['gate'] == 'fatal_rate' for v in violations) else '✅'} |\n",
        f"| Cold Start Regression | {abs(metrics.get('cold_start_regression_pct', 0))}% | {'❌' if any(v['gate'] == 'cold_start_regression' for v in violations) else '✅'} |\n",
        "\n## Immediate Actions Required\n",
        "\n### 1. Stop Rollout Expansion\n",
        "**Play Console:** Navigate to Release > Production > Manage\n",
        f"- Set rollout fraction to 0% to pause current deployment\n",
        f"- Or use Gradle: `./gradlew :app:publishReleaseBundle -Ptrack=production -ProlloutFraction=0.0`\n",
        "\n### 2. Assess Impact\n",
        "- Check user reports in Play Console and support channels\n",
        "- Review Crashlytics for new crash patterns\n",
        "- Evaluate if rollback to previous version is needed\n",
        "\n### 3. Create Hotfix Branch\n",
        f"```bash\n",
        f"git checkout -b hotfix/{hotfix_version}\n",
        f"# Update pubspec.yaml version to {hotfix_version // 100}.{hotfix_version % 100}.{hotfix_version % 10}\n",
        f"```\n",
        "\n## Hotfix Development Plan\n",
        "\n### Root Cause Analysis\n"
    ])

    # Add specific RCA guidance based on violations
    for violation in violations:
        if violation['gate'] == 'crash_free_sessions':
            ticket_lines.extend([
                "- **Crash-free Sessions Issue:** Review recent Crashlytics reports for new crash patterns\n",
                "- Check if crashes are device/OS specific\n",
                "- Verify error handling in recently modified features\n"
            ])
        elif violation['gate'] == 'anr_rate':
            ticket_lines.extend([
                "- **ANR Rate Issue:** Check for blocking operations on main thread\n",
                "- Review recent changes to UI rendering or data loading\n",
                "- Profile app startup and main thread performance\n"
            ])
        elif violation['gate'] == 'fatal_rate':
            ticket_lines.extend([
                "- **Fatal Crash Rate Issue:** Immediate investigation required\n",
                "- Check for null pointer exceptions or memory issues\n",
                "- Review recent native code changes\n"
            ])
        elif violation['gate'] == 'cold_start_regression':
            ticket_lines.extend([
                "- **Cold Start Regression:** Optimize app initialization\n",
                "- Review added dependencies and their initialization time\n",
                "- Consider lazy loading for non-critical features\n"
            ])

    ticket_lines.extend([
        "\n### Testing Requirements\n",
        "- Run full integration test suite\n",
        "- Validate on devices similar to crash reports\n",
        "- Test cold start performance on low-end devices\n",
        "- Verify crash-free sessions > 99.5% in staging\n",
        "\n### Deployment Plan\n",
        f"1. Create hotfix version {hotfix_version}\n",
        "2. Test hotfix in staging environment\n",
        "3. Deploy to 10% rollout for validation\n",
        "4. Monitor for 48 hours\n",
        "5. Expand to 100% if gates pass\n",
        "\n## Communication Plan\n",
        "- Notify development team immediately\n",
        "- Inform product stakeholders of delay\n",
        "- Prepare user communication if rollback needed\n",
        "\n## Timeline\n",
        "- **T=0:** Rollout paused\n",
        "- **T=2h:** Root cause identified\n",
        "- **T=4h:** Hotfix implemented and tested\n",
        "- **T=6h:** Hotfix deployed to 10%\n",
        "- **T=48h:** Full rollout if successful\n",
        "\n---\n",
        "*Auto-generated by P-QG-01 Quality Gates System*"
    ])

    return "".join(ticket_lines)

def create_rollback_plan(violations_data: Dict[str, Any], phase: str) -> str:
    """Create a detailed rollback plan."""
    version_code = violations_data.get("versionCode", 0)
    current_rollout = "10%" if "10" in phase else "50%" if "50" in phase else "100%"

    plan_lines = [
        "# Rollback Plan - Quality Gates Failure\n",
        f"**Generated:** {datetime.utcnow().isoformat()}Z\n",
        f"**Current Version:** {version_code}\n",
        f"**Current Rollout:** {current_rollout}\n",
        f"**Failure Phase:** {phase}\n",
        "\n## Rollback Scenarios\n",
        "\n### Scenario A: Pause Current Rollout (Recommended)\n",
        "1. **Play Console:** Release > Production > Manage\n",
        "2. Set rollout percentage to 0%\n",
        "3. Users will receive previous version on next app update\n",
        "4. Monitor user feedback for 24-48 hours\n",
        "\n### Scenario B: Immediate Rollback to Previous Version\n",
        "1. Publish previous version (versionCode: {}) to 100%\n".format(version_code - 1),
        "2. Communicate rollback to users via app notification\n",
        "3. Provide timeline for fix deployment\n",
        "\n## Recovery Steps\n",
        "1. Fix identified issues in hotfix branch\n",
        "2. Test thoroughly in staging\n",
        "3. Deploy hotfix with 10% rollout\n",
        "4. Monitor quality gates for 48 hours\n",
        "5. Expand to 100% if successful\n",
        "\n## Success Criteria for Recovery\n",
        "- Crash-free sessions ≥ 99.5%\n",
        "- ANR rate ≤ 0.30%\n",
        "- Fatal crash rate ≤ 0.30%\n",
        "- Cold start regression ≤ 15%\n",
        "- No new critical user reports\n"
    ]

    return "".join(plan_lines)

def main():
    parser = argparse.ArgumentParser(description="Generate rollback plan for quality gate violations")
    parser.add_argument("--versionCode", type=int, required=True, help="Current app version code")
    parser.add_argument("--phase", type=str, required=True, help="Rollout phase that failed")

    args = parser.parse_args()

    try:
        # Load violations data
        violations_data = load_violations()

        # Generate violation ticket
        ticket_content = create_violation_ticket(violations_data, args.phase)
        os.makedirs("tools/reports", exist_ok=True)

        with open("tools/reports/PQG_violation_ticket.md", 'w') as f:
            f.write(ticket_content)

        # Generate rollback plan
        plan_content = create_rollback_plan(violations_data, args.phase)

        with open("tools/reports/PQG_rollback_plan.md", 'w') as f:
            f.write(plan_content)

        print("✅ Rollback plan and violation ticket generated")
        print("📋 Check tools/reports/PQG_violation_ticket.md")
        print("📋 Check tools/reports/PQG_rollback_plan.md")

    except Exception as e:
        print(f"ERROR: Failed to generate rollback plan: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
