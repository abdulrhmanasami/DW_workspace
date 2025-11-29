# Delivery Ways Design System: Flutter Handoff Notes

This document serves as the technical bridge between the Figma design file and the Flutter implementation, specifically guiding the translation of the Design Tokens into the existing `DWTheme / Tokens` structure.

## 1. Translation of Design Tokens to Flutter ThemeData

The token naming convention (`category.type.variant`) is designed to map directly to Dart constants or Flutter's `ThemeData` properties.

### 1.1 Color Tokens

The color tokens should be implemented as a custom `ColorScheme` or as static constants within the `DWTheme`.

| Design Token | Flutter Equivalent (Example) | Notes |
| :--- | :--- | :--- |
| `color.primary.base` | `ThemeData.colorScheme.primary` | Used for primary actions and branding. |
| `color.primary.variant` | `ThemeData.colorScheme.primaryContainer` | Used for hover/pressed states or secondary primary elements. |
| `color.surface.default` | `ThemeData.colorScheme.surface` | Base for cards and containers. |
| `color.background.default` | `ThemeData.colorScheme.background` | Base screen background. |
| `color.text.primary` | `ThemeData.textTheme.bodyLarge.color` | High-contrast text. |
| `color.state.error` | `ThemeData.colorScheme.error` | Standard error color. |

**Implementation Recommendation:** Define a custom `DWColorScheme` class that extends `ColorScheme` or is used to initialize it, ensuring all defined tokens are available consistently.

### 1.2 Typography Tokens

The typography scale should be defined using Flutter's `TextTheme`. Font weights are critical for maintaining the visual hierarchy.

| Design Token | Flutter Equivalent (Example) | Notes |
| :--- | :--- | :--- |
| `type.headline.h1` | `ThemeData.textTheme.headlineLarge` | Font Size 32pt, Weight Bold. |
| `type.title.default` | `ThemeData.textTheme.titleMedium` | Font Size 18pt, Weight Medium. |
| `type.body.regular` | `ThemeData.textTheme.bodyMedium` | Font Size 14pt, Weight Regular. **Minimum body size.** |
| `type.label.button` | `ThemeData.textTheme.labelLarge` | Font Size 16pt, Weight Medium. |

**Implementation Recommendation:** Use the `TextStyle` properties within `ThemeData.textTheme` to set the specific font size and weight for each token.

### 1.3 Spacing, Radius, and Elevation Tokens

These tokens should be implemented as static constants or custom theme extensions for easy access across all widgets.

| Design Token | Flutter Equivalent (Example) | Notes |
| :--- | :--- | :--- |
| `space.md` (16pt) | `const double kSpaceMd = 16.0;` | Used for `Padding` and `Margin`. |
| `radius.sm` (8pt) | `const BorderRadius kRadiusSm = BorderRadius.circular(8.0);` | Used for `BorderRadius` in buttons and cards. |
| `elevation.medium` | `ThemeData.cardTheme.elevation` | Maps to standard elevation values for shadows. |

## 2. Component Usage and Variants

All components are built as reusable Flutter Widgets, leveraging the defined tokens. Developers must ensure all required states (Disabled, Loading, Error, Empty) are implemented for robustness.

| Component | Key Variants/States | Implementation Notes |
| :--- | :--- | :--- |
| **Buttons** | Primary (Filled), Secondary (Outline), Tertiary (Text). | Use `DWButton.primary()`, `DWButton.secondary()`, etc. Ensure the `loading` state replaces the text with a `CircularProgressIndicator`. |
| **Inputs** | TextField, SearchField, OTP. | Must implement the `error` state using `color.state.error` for the border/label. The OTP input must handle LTR/RTL number entry correctly. |
| **Cards** | Service Card, Order Card. | Service Cards on the Home Hub should be highly responsive to touch, leading directly to the respective service flow. Order Cards must clearly display the `Utility/Chip` status. |
| **BottomNav** | 4 Tabs (Home, Orders, Payments, Profile). | Must be a persistent widget using `elevation.medium`. The active tab icon/label must use `color.primary.base`. |
| **Empty State** | `Utility/EmptyState` | A dedicated widget for empty lists. Must include a large icon/illustration and a primary CTA to guide the user. |

## 3. Interaction and Animation Notes

To achieve the "seamless experience" benchmarked by Uber, animations should be subtle, fast, and functional.

| Interaction | Animation/Transition | Duration/Easing | Notes |
| :--- | :--- | :--- | :--- |
| **Screen Transition** | Standard platform transition (e.g., slide from right). | 300ms, `Curves.easeOut` | Standard navigation between full screens. |
| **Bottom Sheet Entry** | Slide up from bottom. | 250ms, `Curves.easeOutCubic` | Used for Ride input and Cart summary. Should feel quick and responsive. |
| **Button Press** | Color change to `variant` and slight scale down. | 100ms, `Curves.easeInOut` | Provides immediate visual feedback on interaction. |
| **Skeleton Loader** | Subtle pulsing/shimmer effect. | 1500ms loop, linear | Used for map sections and lists during data fetching. |
| **Toast/Snackbar** | Fade in/out from top/bottom edge. | 200ms in, 150ms out. | Non-blocking, temporary feedback. |

## 4. RTL/LTR and Accessibility Mandates

The implementation must adhere to the following non-negotiable requirements:

1.  **RTL Mirroring:** All layouts must be automatically mirrored when the device language is set to Arabic (RTL). This includes:
    *   Text alignment (Start becomes End).
    *   Icon placement (e.g., back button moves from left to right).
    *   List item sequence (elements within a row are reversed).
2.  **Accessibility:**
    *   **Contrast:** Verify all color combinations meet WCAG AA (4.5:1).
    *   **Touch Targets:** Ensure all interactive widgets (buttons, list tiles) have a minimum tappable area of 44x44 logical pixels.
    *   **Semantic Labels:** All icons and non-text elements must have clear `Semantics` labels for screen readers.
