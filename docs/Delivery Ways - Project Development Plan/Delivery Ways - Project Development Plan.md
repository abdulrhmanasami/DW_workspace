# Delivery Ways - Project Development Plan

This plan outlines the steps to elevate the Delivery Ways Flutter mono-repo from a prototype to a production-ready "Uber-level" application, as detailed in the project specification. The plan is structured around the four main development tracks (A, B, C, D) and strictly adheres to the provided hard constraints.

## Hard Constraints Summary

The following architectural and quality constraints **MUST** be maintained throughout the development process:

1.  **Testing:** All 158 existing tests must pass (`flutter test`), or be updated to maintain the same level of coverage.
2.  **Architecture:** The existing shims/packages structure (`mobility_shims`, `payments`, `foundation_shims`, etc.) must be preserved.
3.  **No Direct SDK Imports:** No direct imports of third-party SDKs (e.g., Stripe, Geolocator) are allowed within `app/lib`. All third-party integration logic must reside under `packages/` and be accessed via shims.
4.  **Build Integrity:** The project must remain buildable and runnable with the following commands:
    *   `flutter pub get`
    *   `flutter test`
    *   `flutter build apk --debug`
    *   `flutter build ios --no-codesign`

## Development Tracks and Phased Implementation

The work will be executed in four main tracks, with an initial focus on the foundational elements (Track A) and a final quality assurance phase.

| Phase ID | Track | Focus Area | Key Deliverables |
| :---: | :---: | :--- | :--- |
| 2 | **A** | **Design System & App Shell** | Full activation of `DWTheme`. Unified `AppShell`, `BottomNav`, `AppBars`, and core components. Adherence to 8pt grid and typography scale. |
| 3 | **B** | **Ride Vertical (MVP)** | Complete Ride flow (Home to Trip Completed). UI connected to `mobility_shims` and `maps_shims`. Real-time tracking UI (using shims). Fare estimate UI. |
| 4 | **C** | **Parcels & Food** | **Option 1 (Preferred):** Simple MVP for Parcels (create + list + detail) and Food (simple browsing with mock data). **Option 2:** Hide both verticals behind feature flags. **Crucially:** Removal of all `demo/coming soon` texts. |
| 5 | **D** | **Onboarding, Auth, & DSR** | Activation of Onboarding flow (3-4 screens). Implementation of a professional Auth/OTP flow UI (connected to a backend stub/shim). Implementation of DSR screens (export/erasure) using `accounts_shims` and `dsr_ux_adapter`. |
| 6 | **Final** | **Polish & Verification** | Implementation of smart Empty States and unified Error States. Addition of animations and smooth transitions (Hero, etc.). Final verification of all hard constraints (tests, builds, architecture). |

---

## Detailed Phase Breakdown

### Phase 2: Implement Design System and App Shell Improvements (Track A)

This phase focuses on achieving visual consistency and a professional "polish" across the entire application, which is a prerequisite for the other tracks.

1.  **Full `DWTheme` Activation:** Ensure all existing screens (Home, Orders, Payments, Profile) are using `DWTheme`, `DwColors`, `DWTypography`, and `DwSpacing` from `packages/design_system_foundation`.
2.  **Component Unification:** Refactor and unify the implementation of core UI components:
    *   `AppShell`/`Scaffold`
    *   `BottomNav`
    *   `AppBars`
    *   `Buttons` and `Cards`
3.  **Design Polish:** Apply 8pt grid system and ensure WCAG basics are respected for typography and color contrast.

### Phase 3: Implement Ride Vertical MVP (Track B)

This is the core functional MVP. The focus is on a complete, end-to-end user experience for booking a ride.

1.  **Location Selection UI:** Implement a professional UI for selecting pickup and destination locations, connected to the `maps_shims` abstraction.
2.  **Fare Estimation:** Implement the UI for displaying a fare estimate, connected to the defined backend mock/contract.
3.  **Trip Flow UI:** Implement the complete ride journey UI with clear states:
    *   `Searching`
    *   `Driver Assigned`
    *   `Driver Arriving`
    *   `Trip In Progress`
    *   `Completed`
4.  **Map Tracking:** Integrate the map view for real-time tracking using `mobility_shims` and `maps_shims` to display the driver's location and the trip route.

### Phase 4: Implement Parcels & Food MVP or hide features (Track C)

This phase addresses the secondary verticals, ensuring they do not present a "demo" or "coming soon" experience.

1.  **Parcels MVP:** Implement a simple, end-to-end flow for Parcels: `Create Parcel` (form), `List Parcels`, and `Parcel Detail` (using mock data/backend stub).
2.  **Food Vertical:** Implement a simple `Food Browsing` interface with mock data, or implement a feature flag to hide the Food tab/entry point completely if time/scope is a constraint.
3.  **Cleanup:** Remove all instances of `demo` or `coming soon` text from the final build.

### Phase 5: Implement Onboarding, Auth, and Empty States (Track D)

This phase finalizes the user account and quality-of-life features.

1.  **Onboarding Flow:** Implement the 3-4 screen Onboarding flow based on the UX studies (which are not yet available but the structure will be built).
2.  **Authentication Flow:** Implement a professional UI for the Auth/OTP flow, connected to the `auth_shims` and a backend stub.
3.  **DSR Screens:** Implement the UI for Data Subject Rights (DSR) screens (export/erasure), ensuring they correctly trigger flows via `accounts_shims` and `dsr_ux_adapter`.
4.  **Empty/Error States:** Design and implement smart Empty States for all key screens (Home, Orders, Payments, Tracking) and a unified Error State UI for network/server/permissions issues.

### Phase 6: Final Polish, Testing, and Constraint Verification

The final quality assurance and sign-off phase.

1.  **Experience Polish:** Implement final animations (Hero, smooth transitions) and ensure button feedback is polished.
2.  **Test Execution:** Run all tests (`flutter test`) and ensure all 158+ tests pass.
3.  **Build Verification:** Confirm successful debug builds for Android and iOS (`flutter build apk --debug` and `flutter build ios --no-codesign`).
4.  **Constraint Check:** Final review to ensure no direct SDK imports were introduced and the shims architecture remains intact.

This structured approach ensures all user requirements are met sequentially, starting with the foundation and moving to core features, while rigorously maintaining the project's architectural integrity.
