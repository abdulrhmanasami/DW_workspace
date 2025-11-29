# B-ux Cursor Workspace

## Role & Ownership
- **Focus:** UX/UI features (design system, formatting, barrels)
- **Packages:** `packages/design_system_shims`
- **Ownership:** UI components, styling, user experience consistency

## Setup Instructions
1. Run bootstrap: `./scripts/bootstrap_satellite.sh`
2. This copies shared configs from B-central
3. Start working on UX-related rewiring and contracts

## Week 1 Task Package 📦

### Phase 1: Design System Foundation (Day 1-2)
- [ ] Establish `design_system_shims` as Foundation package (tokens/typography/colors)
- [ ] Extract `tools/reports/rewrite_imports_plan.json` for design system imports
- [ ] Create centralized theme configuration and component library
- [ ] Implement consistent spacing, colors, and typography tokens

### Phase 2: Component Standardization (Day 3-4)
- [ ] Audit all UI components in `lib/widgets/` and `lib/screens/`
- [ ] Create reusable component contracts in `design_system_shims`
- [ ] Implement RBAC guard components and form elements
- [ ] Standardize button styles, input fields, and layout components

### Phase 3: Clean Barrels & Formatting (Day 5-6)
- [ ] Clean up all barrel exports (`index.dart` files)
- [ ] Apply consistent import organization across all UI files
- [ ] Run `dart fix` and `dart format` on entire codebase
- [ ] Ensure all UI code follows B-STYLE formatting rules

### Phase 4: Testing & Validation (Day 7)
- [ ] Run `flutter analyze` - ensure 0 errors
- [ ] Run `dart format --set-exit-if-changed .` - ensure clean
- [ ] Create `READY_REWIRE_IMPORTS`, `READY_CONTRACTS_AND_STUBS`, `READY_STYLE_BASELINE`
- [ ] Submit PR to `main` for B-central review

### Success Criteria ✅
- [ ] Centralized design system in `design_system_shims`
- [ ] Consistent component library across all screens
- [ ] Clean barrel exports and organized imports
- [ ] All formatting applied, analyzer clean, B-STYLE compliant

## Ready Signals
Create these files when ready:
- `READY_REWIRE_IMPORTS` - Import rewiring completed
- `READY_CONTRACTS_AND_STUBS` - Missing contracts implemented
- `READY_STYLE_BASELINE` - B-STYLE rules applied

## Communication
- Report progress in central `SYNC.md`
- PR to `main` branch for central merge review
- B-central enforces merge gates before accepting

## B-STYLE Rules (Zero-Import-Violations)
- No direct SDK imports in `app/lib`
- No `src/` imports from packages
- Use shims for all external dependencies
- Follow DCM rules from `analysis_options.yaml`
