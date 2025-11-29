# Track A: Design System & App Shell Implementation

## Overview

This document outlines the implementation of Track A: Design System and App Shell improvements. The goal is to activate the existing `DWTheme` across all screens and create a unified, professional app shell that serves as the foundation for all other tracks.

## Current State Analysis

### Existing Design System Infrastructure

1. **Theme Foundation:** `AppThemeData` with light/dark presets
   - Primary color: `#0066FF` (Blue)
   - Background: `#F7F7F7` (Light Gray)
   - Surface: `#FFFFFF` (White)
   - Error: `#D32F2F` (Red)

2. **Typography:** 11 text styles (headline1-6, subtitle1-2, body1-2, button, caption)
   - Font sizes: 32px (headline1) to 12px (caption)
   - Proper line heights and letter spacing

3. **Spacing:** 8pt grid system
   - xs: 4px, sm: 8px, md: 16px, lg: 24px, xl: 32px, xxl: 48px
   - Border radius: 8px (medium), 12px (large)

4. **Components:** B-UI provides loading buttons, skeletons, state containers, and animations

### Current Issues

1. **Theme Activation:** Main app uses basic `ColorScheme.fromSeed()` instead of `AppThemeData`
2. **Component Inconsistency:** Screens use different styling approaches
3. **Missing AppShell:** No unified app shell/scaffold with consistent navigation
4. **Typography Inconsistency:** Not all screens use the design system typography

## Implementation Plan

### Phase 1: Create Unified AppShell Component

**File:** `lib/widgets/app_shell.dart`

The AppShell will provide:
- Unified Scaffold with Material3 design
- Consistent AppBar styling
- Bottom navigation with proper theming
- Safe area handling
- Consistent padding/spacing

**Key Features:**
- Responsive navigation (BottomNav on mobile, Rail on tablet)
- Consistent AppBar with proper elevation and styling
- Built-in support for floating action buttons
- Proper theme application

### Phase 2: Create Core UI Components

**Files:**
- `lib/widgets/app_button_unified.dart` - Unified button component
- `lib/widgets/app_card_unified.dart` - Unified card component
- `lib/widgets/app_app_bar.dart` - Unified AppBar component
- `lib/widgets/app_bottom_nav.dart` - Unified BottomNav component

**Features:**
- Consistent sizing and spacing
- Proper theme color application
- Accessibility support (WCAG basics)
- Loading states and feedback

### Phase 3: Update Main App Theme

**File:** `lib/main.dart`

Replace the current `MaterialApp` theme with:
```dart
theme: ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: theme.colors.primary,
    brightness: theme.brightness,
  ),
  textTheme: _buildTextTheme(theme),
  scaffoldBackgroundColor: theme.colors.background,
  appBarTheme: _buildAppBarTheme(theme),
  bottomNavigationBarTheme: _buildBottomNavTheme(theme),
  cardTheme: _buildCardTheme(theme),
  elevatedButtonTheme: _buildButtonTheme(theme),
)
```

### Phase 4: Update All Screens

Update the following screens to use the unified AppShell and theme:
1. `lib/screens/orders_screen.dart`
2. `lib/screens/orders_history_screen.dart`
3. `lib/screens/payment_screen.dart`
4. `lib/screens/order_tracking_screen.dart`
5. `lib/screens/tracking_map_screen.dart`
6. `lib/screens/mobility/tracking_screen.dart`
7. `lib/screens/auth/phone_login_screen.dart`
8. `lib/screens/auth/otp_verification_screen.dart`
9. `lib/screens/auth/two_factor_screen.dart`
10. `lib/screens/onboarding/onboarding_root_screen.dart`
11. `lib/screens/settings/privacy_consent_screen.dart`
12. `lib/screens/settings/privacy_data_screen.dart`

**Changes:**
- Replace basic Scaffold with AppShell
- Apply theme colors and typography consistently
- Use unified button and card components
- Ensure proper spacing using `theme.spacing`

### Phase 5: Create Home Screen

**File:** `lib/screens/home_screen.dart`

A new professional home screen with:
- Welcome message
- Quick action cards (Ride, Parcels, Food)
- Recent activity section
- Notifications badge
- Consistent theming

### Phase 6: Update Navigation

**File:** `lib/ui/ui.dart` and `lib/router/app_router.dart`

Update routes to use the new home screen and ensure all screens use AppShell.

## Implementation Details

### Theme Application Pattern

All screens should follow this pattern:

```dart
class MyScreen extends ConsumerWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    
    return AppShell(
      title: 'Screen Title',
      body: Padding(
        padding: EdgeInsets.all(theme.spacing.md),
        child: Column(
          children: [
            Text('Content', style: theme.typography.body1),
          ],
        ),
      ),
    );
  }
}
```

### Color Usage Guidelines

- **Primary:** Main actions, highlights
- **Surface:** Cards, containers
- **Background:** Screen background
- **Error:** Error messages, destructive actions
- **OnSurface/OnBackground:** Text colors
- **Grey shades:** Dividers, disabled states

### Typography Usage Guidelines

- **headline1-3:** Screen titles
- **headline4-6:** Section headers
- **body1-2:** Main content
- **subtitle1-2:** Secondary content
- **button:** Button labels
- **caption:** Helper text, timestamps

## Testing Strategy

1. **Visual Testing:** Compare screens against design system
2. **Theme Testing:** Verify colors and typography
3. **Spacing Testing:** Check 8pt grid adherence
4. **Responsive Testing:** Test on different screen sizes
5. **Accessibility Testing:** Verify WCAG basics (contrast, touch targets)

## Success Criteria

- ✅ All screens use AppShell
- ✅ All screens use `appThemeProvider` for theming
- ✅ All text uses design system typography
- ✅ All spacing uses `theme.spacing`
- ✅ All colors use `theme.colors`
- ✅ All tests pass
- ✅ App builds successfully for Android and iOS
- ✅ No direct Material3 theme usage in screens

## Files to Create

1. `lib/widgets/app_shell.dart` - Main shell component
2. `lib/widgets/app_button_unified.dart` - Unified button
3. `lib/widgets/app_card_unified.dart` - Unified card
4. `lib/widgets/app_app_bar.dart` - Unified AppBar
5. `lib/widgets/app_bottom_nav.dart` - Unified BottomNav
6. `lib/screens/home_screen.dart` - New home screen

## Files to Update

1. `lib/main.dart` - Apply theme to MaterialApp
2. `lib/ui/ui.dart` - Update routes
3. `lib/router/app_router.dart` - Add home route
4. All screen files (12 screens listed above)

## Timeline

- **Phase 1-2:** 2-3 hours (Create components)
- **Phase 3:** 1 hour (Update main theme)
- **Phase 4:** 3-4 hours (Update all screens)
- **Phase 5:** 1-2 hours (Create home screen)
- **Phase 6:** 1 hour (Update navigation)
- **Testing:** 1-2 hours

**Total Estimated Time:** 9-14 hours

## Notes

- All changes maintain backward compatibility with existing tests
- No direct SDK imports are introduced
- Architecture remains clean with proper use of shims
- All changes follow the existing code style and patterns
