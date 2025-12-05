# Delivery Ways - Super App 🚀

A comprehensive Flutter super-app for delivery services including ride-hailing, parcels, and food ordering.

## 📦 Version
**v1.0.0+1** - First Release Candidate

## ✅ Feature Status

| Feature | Status | Track |
|---------|--------|-------|
| 🏠 App Shell & Navigation | ✅ Complete | Track A |
| 🚗 Ride Booking | ✅ Complete | Track B |
| 📦 Parcel Sending | ✅ Complete | Track C |
| 🍔 Food Ordering | ✅ Complete | Track C |
| 🔐 Authentication | ✅ Complete | Track D |
| 👤 Identity Controller | ✅ Complete | Track D |
| 🔒 DSR (Data Subject Rights) | ✅ Complete | Track D |
| 💳 Payment Methods | ✅ Complete | Track E |
| 🧪 E2E Test Suite | ✅ All Passed (43/43) | Track F |

## 🛠️ Prerequisites

- Flutter SDK `>=3.8.0 <4.0.0`
- Dart SDK `>=3.8.0 <4.0.0`
- [Melos](https://melos.invertase.dev/) for monorepo management

## 🚀 Getting Started

### 1. Install Dependencies

```bash
# Install melos globally (if not already installed)
dart pub global activate melos

# Bootstrap all packages
melos bootstrap
```

### 2. Run the App

```bash
flutter run
```

### 3. Run Tests

```bash
# Run E2E Smoke Tests (Recommended)
flutter test test/e2e_full_flow_test.dart

# Run all tests
flutter test

# Run specific track tests
flutter test test/ui/mobility/          # Track B tests
flutter test test/ui/payments/          # Track E tests
```

## 📁 Project Structure

```
DW_workspace/
├── lib/
│   ├── app_shell/          # Navigation & App Shell (Track A)
│   ├── screens/            # UI Screens
│   │   ├── auth/           # Authentication screens
│   │   ├── mobility/       # Ride booking screens (Track B)
│   │   ├── parcels/        # Parcel screens (Track C)
│   │   ├── food/           # Food ordering screens (Track C)
│   │   ├── payments/       # Payment screens (Track E)
│   │   ├── profile/        # Profile & Settings
│   │   └── settings/       # DSR screens (Track D)
│   ├── state/              # State management (Riverpod)
│   ├── router/             # App routing
│   └── l10n/               # Localization
├── packages/               # Shared packages
│   ├── auth_shims/         # Authentication abstractions
│   ├── design_system_shims/ # Design system
│   ├── mobility_shims/     # Mobility abstractions
│   ├── maps_shims/         # Maps abstractions
│   ├── payments/           # Payments abstractions
│   └── ...
├── test/
│   ├── e2e_full_flow_test.dart  # E2E Smoke Tests ⭐
│   ├── support/            # Test utilities
│   └── ui/                 # Widget tests
└── docs/
    └── reports/            # Project reports
```

## 🧪 Testing

The project includes a comprehensive E2E test suite that validates all major user journeys:

- **Scenario 1-4**: Auth, Ride Booking, Parcels, Food
- **Scenario 5-6**: Payments, Logout
- **Scenario 7-8**: Integration, Error Handling
- **Scenario 9-11**: Profile, AppShell, Identity
- **Scenario 12-13**: DSR, Payment Methods
- **Scenario 14-15**: Complete Journey, Feature Flags

```bash
# Run E2E tests with verbose output
flutter test test/e2e_full_flow_test.dart --reporter expanded
```

## 🌐 Localization

Supported languages:
- 🇺🇸 English (en)
- 🇩🇪 German (de)
- 🇸🇦 Arabic (ar)

## 📜 License

Proprietary - All rights reserved.

## 👥 Contributors

- Track A: App Shell & Navigation Team
- Track B: Mobility Team
- Track C: Parcels & Food Team
- Track D: Auth & Privacy Team
- Track E: Payments Team
- Track F: Integration & QA Team

---

**Build Status**: ✅ All Tests Passing  
**Last Updated**: December 5, 2025

