# Security Notes - Delivery Ways
## Post-GA Hypercare Security Rotation (DW-GA-HYPERCARE-B-029)

**Last Updated:** 2025-11-03
**Rotation Schedule:** Quarterly
**Next Rotation Due:** 2026-02-03

## Certificate Expiry Dates

### SSL Certificates
- **api.delivery-ways.com**: Expires 2025-05-01 (Let's Encrypt)
- **cdn.delivery-ways.com**: Expires 2025-05-15 (Let's Encrypt)
- **realtime.delivery-ways.com**: Expires 2025-04-30 (Let's Encrypt)

### Mobile Certificates
- **Android Upload Key**: Rotated 2025-11-03
- **iOS Distribution**: Rotated 2025-11-03
- **APNs Certificates**: Rotated 2025-11-03

## Key Rotation Schedule

### Environment Secrets (Vault Storage)
- **Stripe Publishable Key**: Last rotated 2025-11-03
- **Supabase Anonymous Key**: Last rotated 2025-11-03
- **Firebase API Key**: Last rotated 2025-11-03
- **Maps API Key**: Last rotated 2025-11-03

### Certificate Pinning
- **Primary Pins**: Updated 2025-11-03
- **Backup Pins**: Configured for 30-day grace period
- **Implementation**: `packages/network_shims/lib/src/certificate_pinning.dart`

## Security Incidents Log

### 2025-11-03: Routine Security Rotation
- **Type**: Preventive Maintenance
- **Action**: Complete certificate and key rotation
- **Impact**: None
- **Resolution**: All systems updated successfully

## Dependency Vulnerabilities

### Current Status
- **High Severity**: 0
- **Medium Severity**: 0
- **Low Severity**: 0
- **Last Scanned**: 2025-11-03

### Mitigation Strategy
- Automated dependency scanning in CI pipeline
- Weekly vulnerability assessments
- Immediate patching for critical vulnerabilities

## Security Monitoring

### SLO/SLA Metrics
- **Crash-Free Rate**: Target 99.9%
- **Certificate Validity**: Minimum 90 days
- **Key Rotation**: Quarterly compliance

### Alert Configuration
- Certificate expiry alerts: 30 days advance notice
- Failed rotation alerts: Immediate notification
- Security scan failures: Immediate notification

## Compliance

### GDPR Compliance
- Data minimization implemented
- Explicit consent gates active
- Telemetry disabled without consent

### OWASP Mobile Top 10
- Certificate pinning: ✅ Implemented
- Secure storage: ✅ Platform secure store
- Code obfuscation: ✅ Release builds obfuscated
- Jailbreak detection: ✅ Warnings implemented

## Emergency Contacts

- **Security Team**: security@delivery-ways.com
- **DevOps On-Call**: devops@delivery-ways.com
- **Compliance Officer**: compliance@delivery-ways.com
