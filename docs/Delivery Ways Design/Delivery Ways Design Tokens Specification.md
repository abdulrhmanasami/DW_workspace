# Delivery Ways Design Tokens Specification

This document outlines the foundational design tokens for the Delivery Ways Super-App, ensuring a consistent, scalable, and Flutter-implementable design system, benchmarked against the simplicity and professionalism of Uber and Bolt. All tokens are named with a clear hierarchy to facilitate direct translation into Flutter Theme data and design tool variables.

## 1. Color Palette

The color system is designed to be clear, accessible (WCAG AA compliant), and support both light and potential dark modes. The primary color should be distinctive and used for key interactive elements and branding accents.

| Token Name | Role | Hex Value (Light Mode) | Usage Notes |
| :--- | :--- | :--- | :--- |
| `color.primary.base` | Main brand color, used for primary CTAs and active states. | `#00A651` (A vibrant green, similar to Careem/Bolt for mobility/delivery) | The most prominent color in the application. |
| `color.primary.variant` | A darker shade for pressed/hover states or subtle accents. | `#008C44` | Used for depth and interaction feedback. |
| `color.secondary.base` | Used for secondary actions or complementary elements. | `#007BFF` (A clean blue for contrast) | Used sparingly to differentiate service types or secondary actions. |
| `color.background.default` | Main background for the app screens. | `#FFFFFF` | Pure white for maximum clarity and contrast. |
| `color.surface.default` | Background for cards, sheets, and containers. | `#FFFFFF` | Same as background, relying on elevation/shadow for separation. |
| `color.surface.elevated` | Background for modals, dialogs, or top app bars. | `#F8F8F8` | Slight off-white to distinguish elevated surfaces. |
| `color.text.primary` | Main text content (headings, body copy). | `#1A1A1A` | High contrast for readability. |
| `color.text.secondary` | Secondary information, labels, helper text. | `#666666` | Lower contrast for hierarchy. |
| `color.text.muted` | Placeholder text, disabled states, or subtle details. | `#AAAAAA` | Used for non-essential information. |
| `color.text.inverse` | Text on a primary or dark background. | `#FFFFFF` | Ensures readability on colored surfaces. |
| `color.state.error` | Used for validation errors, failed states. | `#D32F2F` | Standard red for urgency. |
| `color.state.warning` | Used for non-critical alerts or cautionary messages. | `#FFC107` | Amber/Yellow for attention. |
| `color.state.success` | Used for successful operations or completed tasks. | `#388E3C` | Standard green for confirmation. |

## 2. Typography

The typography scale is based on a clean, modern, and highly readable sans-serif font (assuming a system font or a standard, easily embeddable font like Roboto/Inter for Flutter feasibility). The scale follows a clear hierarchy.

| Token Name | Font Size (pt) | Font Weight | Usage Notes |
| :--- | :--- | :--- | :--- |
| `type.display.large` | 48 | Bold | Very large, used sparingly for splash screens or key moments. |
| `type.headline.h1` | 32 | Bold | Primary screen titles (e.g., Home Hub main greeting). |
| `type.headline.h2` | 24 | Bold | Section titles within a screen. |
| `type.headline.h3` | 20 | Medium | Sub-section titles or large card titles. |
| `type.title.default` | 18 | Medium | Component titles, list item primary text. |
| `type.subtitle.default` | 16 | Regular | Secondary information, subheadings. |
| `type.body.regular` | 14 | Regular | Standard body text, paragraph content. **Minimum size for body text.** |
| `type.body.medium` | 14 | Medium | Important body text, form input values. |
| `type.caption.default` | 12 | Regular | Smallest readable text, helper text, timestamps. |
| `type.label.button` | 16 | Medium | Text for primary and secondary buttons. |
| `type.label.overline` | 10 | Medium | Uppercase labels, small status tags. |

## 3. Spacing

A strict **8pt grid system** is used for all spacing, padding, and margins to ensure visual rhythm and consistency.

| Token Name | Value (pt) | Usage Notes |
| :--- | :--- | :--- |
| `space.xxs` | 4 | Extra-extra small, for tight internal component spacing. |
| `space.xs` | 8 | Extra small, standard small padding, icon-to-text spacing. |
| `space.sm` | 12 | Small, internal card padding, list item vertical spacing. |
| `space.md` | 16 | Medium, standard screen padding, main section separation. |
| `space.lg` | 24 | Large, major section breaks, large component margins. |
| `space.xl` | 32 | Extra large, vertical spacing on empty states or onboarding. |
| `space.xxl` | 40 | Extra-extra large, maximum vertical separation. |

## 4. Radius

A small, consistent set of border radii is used to maintain a modern, approachable aesthetic without being overly rounded.

| Token Name | Value (pt) | Usage Notes |
| :--- | :--- | :--- |
| `radius.xs` | 4 | Smallest radius, for inputs and small chips. |
| `radius.sm` | 8 | Standard radius, for cards and buttons. |
| `radius.md` | 12 | Medium radius, for larger containers or bottom sheets. |
| `radius.lg` | 24 | Large radius, for full-width banners or specific visual elements. |
| `radius.circle` | 999 | For circular elements (e.g., profile pictures, floating action buttons). |

## 5. Elevation and Shadows

Elevation is used to create visual hierarchy, primarily for floating elements like the Bottom Navigation Bar, Bottom Sheets, and Floating Action Buttons. The shadows should be subtle and modern.

| Token Name | Role | Shadow Properties (Color, Offset, Blur, Spread) | Usage Notes |
| :--- | :--- | :--- | :--- |
| `elevation.low` | Subtle lift for cards and surfaces. | Color: `rgba(0, 0, 0, 0.05)`, Offset: `0, 1`, Blur: `4`, Spread: `0` | Standard card elevation. |
| `elevation.medium` | Lift for buttons and Bottom Navigation Bar. | Color: `rgba(0, 0, 0, 0.1)`, Offset: `0, 4`, Blur: `8`, Spread: `0` | Used for persistent navigation elements. |
| `elevation.high` | Prominent lift for Modals and Bottom Sheets. | Color: `rgba(0, 0, 0, 0.15)`, Offset: `0, 8`, Blur: `16`, Spread: `0` | Used for elements that temporarily block the main content. |

---

## 6. Component Specifications

The following is a list of required components, detailing their structure and necessary states.

### 6.1 Buttons

All buttons must adhere to the `type.label.button` typography token and `radius.sm` radius. Touch targets must be at least 44x44px.

| Component Variant | Style | States Required | Usage |
| :--- | :--- | :--- | :--- |
| `Button/Primary` | Filled with `color.primary.base`. | Default, Hover/Pressed (`color.primary.variant`), Disabled, Loading. | Main call-to-action (e.g., "Request Ride", "Place Order"). |
| `Button/Secondary` | Outline with `color.primary.base` border. | Default, Hover/Pressed, Disabled, Loading. | Secondary actions, less emphasis. |
| `Button/Tertiary` | Text-only (Ghost) with `color.primary.base` text. | Default, Hover/Pressed, Disabled. | Least emphasis, often used in modals or footers. |
| `Button/Icon` | Circular or Square, with an icon. | Default, Pressed, Disabled. | Used for quick actions (e.g., Back button, Profile icon). |

### 6.2 Inputs

All inputs must support RTL/LTR alignment and include clear visual feedback for states.

| Component Variant | Elements | States Required | Usage |
| :--- | :--- | :--- | :--- |
| `Input/TextField` | Label, Placeholder, Input Area, Helper Text (optional). | Default, Focused, Error (`color.state.error`), Disabled, Filled. | Standard text entry (e.g., Name, Address). |
| `Input/SearchField` | Icon, Placeholder, Input Area, Clear Button. | Default, Focused, Active (with text). | Used for location search (Ride Flow) or restaurant search (Food Flow). |
| `Input/OTP` | 4-6 separate boxes for number entry. | Default, Focused, Error, Success. | Used in the Authentication flow. |

### 6.3 Cards

Cards are the primary way to group information and services. They use `color.surface.default` and `elevation.low`.

| Component Variant | Structure | Usage |
| :--- | :--- | :--- |
| `Card/Generic` | Title (`type.title.default`), Subtitle (`type.subtitle.default`), Trailing Element (e.g., icon, price). | Used for recent activity, payment methods. |
| `Card/Service` | Large visual area (icon/illustration), Title (`type.headline.h3`), Description. | Used on the Home Hub to select Ride, Parcels, or Food. |
| `Card/Order` | Service Icon, Route/Name, Status Chip, Date, Final Price. | Used in the Orders History screen. |

### 6.4 Navigation

Navigation components must be robust and clearly indicate the active service.

| Component Variant | Structure | Usage |
| :--- | :--- | :--- |
| `Navigation/AppBar` | Title (aligned to start, supports RTL), Optional Actions (icons on the end). | Top of most screens. Must be minimal and clean (Uber style). |
| `Navigation/BottomNav` | 4 Tabs: Home, Orders, Payments, Profile. | Active state (icon + label in `color.primary.base`), Inactive state (icon + label in `color.text.secondary`). Uses `elevation.medium`. | Main app navigation. |

### 6.5 Feedback & Utility

| Component Variant | Structure | States Required | Usage |
| :--- | :--- | :--- | :--- |
| `Feedback/Toast` | Small, non-intrusive message bar. | Info, Warning, Error, Success. | Temporary, non-blocking notifications (e.g., "Poor network"). |
| `Feedback/Modal` | Centered overlay, Title, Body, Primary/Secondary CTA buttons. | Default. | Critical user decisions or important information. |
| `Feedback/InlineNotice` | Full-width banner, Icon, Text, Optional Close Button. | Info, Warning, Error, Success. | Persistent, contextual alerts within a screen. |
| `Utility/Chip` | Small, rounded badge with text. | Status (e.g., Delivered, In Transit, Pending), Filter (Active/Inactive). | Used for order status or filtering. |
| `Utility/SkeletonLoader` | Animated gray shapes mimicking content structure. | Used for lists and map sections during loading state. |
| `Utility/EmptyState` | Large Icon/Illustration, Title (`type.headline.h2`), Description, Optional Primary CTA. | Used when a list or section has no content (e.g., "No orders yet"). |
