# Quality Gates System - P-QG-01

Automatic production quality gates with promotion blocking and rollback procedures.

## Overview

This system enforces quality standards before and after production rollouts by monitoring:
- Crash-free sessions rate
- ANR (Application Not Responding) rate
- Fatal crash rate
- Cold start performance regression

## Architecture

```
tools/quality/
├── quality_gates.json          # Gate thresholds and configuration
├── check_quality_gates.py      # Main gate checker
├── compute_cold_start_regression.py  # Startup performance analysis
├── generate_rollback_plan.py   # Auto-rollback plan generator
├── README.md                   # This documentation
└── providers/
    ├── play_reporting.py       # Google Play Vitals API client
    └── crashlytics.py          # Firebase Crashlytics API client
```

## Prerequisites

### Environment Variables

```bash
# Google Play Developer API
export PLAY_SERVICE_ACCOUNT_JSON='{"type":"service_account",...}'

# Firebase Crashlytics
export FIREBASE_PROJECT_ID='your-project-id'
export FIREBASE_APP_ID='1:123456789:android:abc123...'

# Production Signing (for CI/CD)
export PRODUCTION_KEYSTORE_PASSWORD='...'
export PRODUCTION_KEY_ALIAS='...'
export PRODUCTION_KEY_PASSWORD='...'
```

### Dependencies

```bash
pip install requests google-auth google-auth-oauthlib google-auth-httplib2
```

## Local Testing

### 1. Setup Environment

```bash
export PLAY_SERVICE_ACCOUNT_JSON='...'
export FIREBASE_PROJECT_ID='...'
export FIREBASE_APP_ID='...'
```

### 2. Run Individual Providers

```bash
# Fetch Play Vitals metrics
python tools/quality/providers/play_reporting.py \
  --versionCode 100 \
  --package com.example.delivery_ways_clean

# Fetch Crashlytics metrics
python tools/quality/providers/crashlytics.py \
  --app 1:123456789:android:abc123

# Compute startup regression
python tools/quality/compute_cold_start_regression.py \
  --baseline last_rc \
  --versionCode 100
```

### 3. Run Full Quality Check

```bash
python tools/quality/check_quality_gates.py \
  --versionCode 100
```

### 4. Check Results

```bash
# View summary report
cat tools/reports/PQG_summary.md

# View detailed JSON results
cat tools/reports/PQG_result.json
```

## CI/CD Integration

### GitHub Actions Workflow

The system integrates with `.github/workflows/production_quality_gates.yml`:

1. **Quality Gates Check Job:**
   - Fetches metrics from Play & Crashlytics
   - Computes cold start regression
   - Runs quality gates check
   - Blocks/fails if gates don't pass

2. **Promote Rollout Job:**
   - Only runs if quality check passes
   - Updates rollout percentage in Play Store
   - Generates success artifacts

3. **Rollback Plan Job:**
   - Runs if quality check fails
   - Auto-generates rollback ticket and plan

### Usage in CI

```yaml
- name: Check Quality Gates (10% → 50%)
  run: |
    python tools/quality/providers/play_reporting.py --versionCode 100 --package com.example.app
    python tools/quality/providers/crashlytics.py --app ${{ secrets.FIREBASE_APP_ID }}
    python tools/quality/compute_cold_start_regression.py --baseline last_rc --versionCode 100
    python tools/quality/check_quality_gates.py --versionCode 100

- name: Promote to 50% (only if gates pass)
  run: |
    ./gradlew :app:publishReleaseBundle -Ptrack=production -ProlloutFraction=0.50
```

## Quality Gates Configuration

Edit `tools/quality/quality_gates.json`:

```json
{
  "window_days": 1,
  "thresholds": {
    "crash_free_sessions_pct_min": 99.5,
    "anr_rate_pct_max": 0.30,
    "fatal_rate_pct_max": 0.30,
    "cold_start_regression_pct_max": 15.0
  },
  "comparison_baseline": "last_rc"
}
```

## Rollout Phases

### 10% → 50% Expansion
- Monitoring window: 24 hours
- Auto-blocking: Disabled (requires manual approval)
- Failure action: Pause rollout, investigate

### 50% → 100% Expansion
- Monitoring window: 48 hours
- Auto-blocking: Enabled
- Failure action: Generate rollback plan, notify stakeholders

## Output Files

All reports are saved to `tools/reports/`:

- `PQG_play_metrics.json` - Play Vitals data
- `PQG_crashlytics_metrics.json` - Crashlytics data
- `PQG_startup_regression.json` - Cold start analysis
- `PQG_result.json` - Quality check results
- `PQG_summary.md` - Human-readable summary
- `PQG_violation_ticket.md` - Auto-generated on failure
- `PQG_rollback_plan.md` - Rollback procedures

## Troubleshooting

### Common Issues

1. **Missing Metrics Files**
   ```
   ERROR: Missing required metrics files
   ```
   Solution: Run provider scripts first before quality check

2. **API Authentication Failed**
   ```
   ERROR: Failed to fetch Play Vitals metrics
   ```
   Solution: Check PLAY_SERVICE_ACCOUNT_JSON credentials

3. **No Baseline Data**
   ```
   ERROR: Unknown baseline type
   ```
   Solution: Use "last_rc", "last_prod", or "manual"

### Manual Testing

For testing without real APIs, the providers include simulation mode that generates realistic sample data.

## Security Notes

- Service account keys should be stored as GitHub secrets
- Never commit credentials to version control
- Use principle of least privilege for API access
- Rotate keys regularly

## Support

For issues with the quality gates system:
1. Check CI logs for detailed error messages
2. Review generated reports in `tools/reports/`
3. Verify API credentials and permissions
4. Test locally with sample data first
