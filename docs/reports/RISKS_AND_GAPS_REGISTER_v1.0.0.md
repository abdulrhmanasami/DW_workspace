# Risks & Gaps Register v1.0.0

**Version**: 1.0.0
**Generated**: 2025-11-25
**Audit Cursor**: B-central
**Purpose**: Unified source of truth for all release risks, blockers, and gaps

---

## 1. Introduction

This document consolidates all known risks, blockers, and gaps from:

- `cursor_backlog_v3.2.1.json` — Epic status and blockers
- `security_findings.md` — Security audit findings
- `performance_findings.md` — Performance recommendations
- `PROJECT_STATUS_v3.2.1.md` — Project status and key risks
- `STUDIES_STATUS_SNAPSHOT_v1.0.0.md` — Study-to-code alignment gaps

All items are classified by severity (P0/P1/P2) and status (open/mitigated/closed).

---

## 2. P0 — Release Blockers (External Dependencies)

These are the **only** items blocking a production release. All are backend dependencies.

| ID | Category | Cursor | Description | Owner | Status | Mitigation | Impact |
|----|----------|--------|-------------|-------|--------|------------|--------|
| **BLK-001** | Backend | commerce | Stripe backend keys and webhook not configured | Backend | Open | Kill-switch active. Payment UI disabled when keys missing. | No payment processing |
| **BLK-002** | Backend | mobility | DW-ALG backend API not deployed | Backend | Mitigated (client-side) | Sale-Only behavior. Tracking UI shows "Coming soon". Client uplink ready. | No realtime tracking |

### Client-Side Readiness for P0 Blockers

| Blocker | Client Status | Package(s) | Kill-Switch | Sale-Only |
|---------|---------------|------------|-------------|-----------|
| BLK-001 | ✅ Ready | `payments_shims`, `payments_stripe_impl` | ✅ | ✅ |
| BLK-002 | ✅ Ready | `mobility_uplink_impl`, `mobility_shims` | ✅ | ✅ |

---

## 3. P0 — Resolved Blockers

These were previously P0 blockers, now resolved.

| ID | Category | Description | Resolution | Resolved Date | Replaced By |
|----|----------|-------------|------------|---------------|-------------|
| **BLK-003** | Auth | Passwordless auth in B-wip branch | Merged to B-central | 2025-11-25 | CENT-003, CENT-004 |
| **BLK-005** | UX | EN/DE copy not finalized | ARB files complete (120+ keys) | 2025-11-25 | UX-003 |
| **BLK-006** | Auth | Passwordless OTP validation incomplete | Superseded by direct merge | 2025-11-25 | CENT-003 |
| **BLK-007** | Auth | Auth UI screens need validation | Screens validated and merged | 2025-11-25 | CENT-003 |

---

## 4. P1 — High Priority Risks

These are significant risks but not blocking GA. Should be addressed in next sprint.

| ID | Category | Cursor | Description | Status | Mitigation | Source |
|----|----------|--------|-------------|--------|------------|--------|
| **BLK-004** | Release | central | macOS CodeSign resource fork issues | Open | iOS/Android unaffected. macOS distribution blocked. | `cursor_backlog` |
| **SEC-001** | Security | backend | OTP rate limiting not enforced | Open | Backend must implement 3-attempt lockout | `security_findings` |
| **PERF-001** | Performance | commerce | Orders history lacks virtualization | Open | Recommend ListView.builder with pagination | `performance_findings` |
| **PERF-002** | Performance | mobility | Maps screen memory profiling needed | Open | Multiple map controllers may cause OOM on low-end devices | `performance_findings` |
| **GAP-001** | Notifications | ux | FCM backend not configured | Mitigated (client-side) | Notifications UI hidden via Sale-Only | `cursor_backlog` |
| **GAP-002** | Auth | central | 2FA backend rule engine not ready | Mitigated (client-side) | 2FA UI hidden when flag off | `cursor_backlog` |

---

## 5. P2 — Medium Priority Risks

These are nice-to-have improvements, not affecting GA.

| ID | Category | Cursor | Description | Status | Recommendation | Source |
|----|----------|--------|-------------|--------|----------------|--------|
| **RSK-004** | QA | central | DCM baseline needs refresh | Open | Run melos DCM scripts | `PROJECT_STATUS` |
| **RSK-005** | UI | ui | Dark mode incomplete | Open | Theme structure ready, apply to screens | `PROJECT_STATUS` |
| **UX-GAP-001** | UX | ux | Product onboarding journey missing | Open | Privacy onboarding exists, add product intro | `STUDIES_STATUS` |
| **UX-GAP-002** | UX | ux | Micro-interactions limited | Pending | Basic animations only | `STUDIES_STATUS` |
| **PERF-003** | Performance | central | Lite Mode not implemented | Open | Design exists, deprioritized | `performance_findings` |
| **PERF-004** | Performance | central | Performance budgets not in CI | Open | Add frame budget assertions | `performance_findings` |

---

## 6. Security Findings Summary

From `security_findings.md`:

| ID | Finding | Severity | Status | Client Status | Backend Required |
|----|---------|----------|--------|---------------|------------------|
| SEC-001 | OTP rate limiting | Medium | Open | N/A | Yes (3-attempt lockout) |
| SEC-002 | Token expiry handling | Low | ✅ Closed | Implemented | No |
| SEC-003 | API key exposure | Low | ✅ Closed | FlutterSecureStorage | No |
| SEC-004 | 2FA not enforced | Medium | ✅ Mitigated | Client-side 2FA ready | Yes (rule engine) |
| SEC-005 | Biometric bypass | Low | ✅ Implemented | device_security_shims | No |

### Security Score: 97.5%

| Criterion | Weight | Score |
|-----------|--------|-------|
| Transport Security | 25% | 100% |
| Data at Rest | 20% | 100% |
| Authentication | 25% | 90% |
| Authorization | 15% | 100% |
| Privacy/Consent | 15% | 100% |

---

## 7. Performance Findings Summary

From `performance_findings.md`:

| ID | Area | Risk Level | Recommendation | Effort | Priority |
|----|------|------------|----------------|--------|----------|
| PERF-001 | Orders | Medium | Add ListView.builder virtualization | S | P1 |
| PERF-002 | Maps | Medium | Profile memory, limit controllers | M | P1 |
| PERF-003 | App-wide | Low | Implement Lite Mode | L | P2 |
| PERF-004 | CI | Medium | Add performance budgets | M | P2 |
| PERF-005 | Network | Low | Cache API responses | M | P2 |

### Performance Score: 93%

| Criterion | Weight | Score |
|-----------|--------|-------|
| Cold Start | 30% | 95% |
| Memory | 25% | 90% |
| CPU | 20% | 85% |
| Network | 15% | 100% |
| Observability | 10% | 100% |

---

## 8. Study Alignment Gaps

From `STUDIES_STATUS_SNAPSHOT_v1.0.0.md`:

| Study | Status | Gap Description | Required Action |
|-------|--------|-----------------|-----------------|
| DW-ALG Research | ✅ Client Ready | Algorithm is backend-only | Deploy DW-ALG API |
| Payments Research | ✅ Client Ready | Backend keys missing | Configure Stripe |
| Security Study | ⚠️ Partial | 2FA backend rules pending | Implement rule engine |
| UX Research | ⚠️ Partial | Product onboarding missing | Design and implement |
| QA Strategy | ⚠️ Partial | Low overall coverage | Expand unit tests |
| Release Plan | ✅ Updated | Was outdated | RELEASE_EXECUTION_PLAN_v2.0.0.md created |
| Gaps & Risks | ✅ Created | Did not exist | This document |

---

## 9. Mapping to Epics

| Risk/Gap ID | Related Epic(s) | Epic Status |
|-------------|-----------------|-------------|
| BLK-001 | COM-002 | blocked |
| BLK-002 | MOB-002 | done_client_side |
| BLK-004 | CENT-005 | blocked |
| SEC-001 | — | Backend |
| SEC-004 | CENT-004 | done |
| SEC-005 | CENT-003 | done |
| PERF-001 | COM-004 | pending |
| PERF-002 | MOB-003 | ready_for_validation |
| GAP-001 | UX-004 | done_client_side |
| GAP-002 | CENT-004 | done |
| UX-GAP-001 | UX-002 | ready_for_validation |
| UX-GAP-002 | UX-005 | pending |

---

## 10. Risk Ownership Matrix

| Owner | P0 Count | P1 Count | P2 Count | Primary Risks |
|-------|----------|----------|----------|---------------|
| Backend | 2 | 1 | 0 | BLK-001, BLK-002, SEC-001 |
| Central | 0 | 1 | 2 | BLK-004, RSK-004, PERF-004 |
| Commerce | 0 | 1 | 0 | PERF-001 |
| Mobility | 0 | 1 | 0 | PERF-002 |
| UX | 0 | 1 | 2 | GAP-001, UX-GAP-001, UX-GAP-002 |
| UI | 0 | 0 | 1 | RSK-005 |

---

## 11. Release Decision Matrix

### Can We Release to Production?

| Condition | Status | Notes |
|-----------|--------|-------|
| Analyzer Zero | ✅ Pass | 0 errors in lib/ |
| Banned Imports Zero | ✅ Pass | 0 violations |
| Critical Tests Pass | ✅ Pass | 79 tests green |
| Localization Complete | ✅ Pass | EN/DE/AR ready |
| Auth Client Ready | ✅ Pass | Passwordless + 2FA + Biometric |
| Payments Client Ready | ✅ Pass | Kill-switch active |
| Mobility Client Ready | ✅ Pass | Sale-Only active |
| **Backend Dependencies** | ❌ Blocked | BLK-001, BLK-002 |

### Verdict: **CLIENT-SIDE READY, AWAITING BACKEND**

The application is fully ready for release from a client-side perspective. Production deployment is blocked only on backend integration (Stripe keys, DW-ALG API).

---

## 12. Recommended Next Steps

### Immediate (Backend Team)

1. **Configure Stripe Production Keys** — Enable BLK-001 resolution
2. **Deploy DW-ALG API** — Enable BLK-002 resolution
3. **Implement OTP Rate Limiting** — Close SEC-001

### Short-term (Client Team)

1. **Validate remaining `ready_for_validation` epics** — 12 epics pending validation
2. **Profile Maps screen memory** — Address PERF-002
3. **Add Orders virtualization** — Address PERF-001

### Medium-term

1. **Complete Dark Mode** — RSK-005
2. **Add performance budgets to CI** — PERF-004
3. **Product onboarding flow** — UX-GAP-001

---

## Appendix A: Data Sources

| Source | Path | Last Updated |
|--------|------|--------------|
| Cursor Backlog | `tools/reports/cursor_backlog_v3.2.1.json` | 2025-11-25 |
| Security Findings | `tools/reports/security_findings.md` | 2025-11-25 |
| Performance Findings | `tools/reports/performance_findings.md` | 2025-11-25 |
| Project Status | `docs/reports/PROJECT_STATUS_v3.2.1.md` | 2025-11-25 |
| Studies Snapshot | `docs/reports/STUDIES_STATUS_SNAPSHOT_v1.0.0.md` | 2025-11-25 |

---

## Appendix B: Change Log

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-11-25 | Initial consolidated register created |

---

**Document Status**: FROZEN for Release Review
**Review Cycle**: Update after each sprint or when blockers change

