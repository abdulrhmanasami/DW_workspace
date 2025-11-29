# Delivery Ways High-Fidelity Mockups

This document details the high-fidelity design for the core application screens, adhering to the established Design Tokens and Component Specifications. The designs prioritize simplicity, clarity, and the Uber/Bolt benchmark experience.

## 1. Onboarding Flow (3 Screens)

The onboarding flow is designed to quickly communicate the value proposition (Ride, Parcels, Food) with minimal friction.

### Screen 1: Ride - Get Moving

| Element | Component/Token | Description |
| :--- | :--- | :--- |
| **Visual** | Custom Illustration/Visual | Abstract, friendly visual representing mobility (e.g., a car icon moving quickly). |
| **Title** | `type.headline.h1` (`color.text.primary`) | **Get a Ride, Instantly.** (احصل على رحلة، فورًا.) |
| **Body** | `type.subtitle.default` (`color.text.secondary`) | Tap, ride, and arrive. Fast, reliable, and affordable transport at your fingertips. |
| **Progress** | Dots/Progress Bar | 1 of 3 (Dot 1: Primary, Dots 2, 3: Muted) |
| **CTA** | `Button/Primary` | Continue (استمر) |

### Screen 2: Parcels - Send Anything, Anywhere

| Element | Component/Token | Description |
| :--- | :--- | :--- |
| **Visual** | Custom Illustration/Visual | Abstract, friendly visual representing delivery (e.g., a package icon with an arrow). |
| **Title** | `type.headline.h1` (`color.text.primary`) | **Deliver Anything, Effortlessly.** (أرسل أي شيء، بسهولة.) |
| **Body** | `type.subtitle.default` (`color.text.secondary`) | From documents to gifts, send and track your parcels with ease and confidence. |
| **Progress** | Dots/Progress Bar | 2 of 3 (Dot 2: Primary) |
| **CTA** | `Button/Primary` | Continue (استمر) |

### Screen 3: Food - Your Next Meal

| Element | Component/Token | Description |
| :--- | :--- | :--- |
| **Visual** | Custom Illustration/Visual | Abstract, friendly visual representing food (e.g., a simple food icon/bowl). |
| **Title** | `type.headline.h1` (`color.text.primary`) | **Your Favorite Food, Delivered.** (طعامك المفضل، إليك.) |
| **Body** | `type.subtitle.default` (`color.text.secondary`) | Explore local restaurants and enjoy fast delivery right to your door. |
| **Progress** | Dots/Progress Bar | 3 of 3 (Dot 3: Primary) |
| **CTA** | `Button/Primary` | Get Started (ابدأ الآن) |

---

## 2. Authentication Flow (Login + OTP)

The Auth flow is minimal, focusing on phone number input for a quick, Uber-like experience. It must support RTL/LTR.

### Screen 4: Login (Phone Number)

| Element | Component/Token | LTR (English) | RTL (Arabic) |
| :--- | :--- | :--- | :--- |
| **AppBar** | `Navigation/AppBar` | Back Button (Left), Title "Welcome" (Center/Left) | Back Button (Right), Title "مرحباً" (Center/Right) |
| **Input** | `Input/TextField` | Phone Number Input (Left-aligned text) | Phone Number Input (Right-aligned text) |
| **Helper Text** | `type.caption.default` | "We'll send a verification code to this number." (Left-aligned) | "سنرسل رمز تحقق إلى هذا الرقم." (Right-aligned) |
| **Privacy Link** | `type.caption.default` | Link to "Privacy Policy & Terms" (Centered) | Link to "سياسة الخصوصية والشروط" (Centered) |
| **CTA** | `Button/Primary` | Continue (Bottom, Full-width) | استمر (Bottom, Full-width) |

**RTL/LTR Note:** The entire layout is mirrored. The back button moves from the top-left (LTR) to the top-right (RTL). Text alignment for all elements is mirrored (Left-to-Right vs. Right-to-Left).

### Screen 5: OTP Verification

| Element | Component/Token | LTR (English) | RTL (Arabic) |
| :--- | :--- | :--- | :--- |
| **Title** | `type.headline.h2` | "Enter 4-digit code" | "أدخل الرمز المكون من 4 أرقام" |
| **Input** | `Input/OTP` | 4-6 separate boxes (Left-to-Right entry) | 4-6 separate boxes (Right-to-Left entry) |
| **Timer** | `type.subtitle.default` | "Resend code in 0:59" (Centered) | "إعادة إرسال الرمز خلال 0:59" (Centered) |
| **Error State** | `Feedback/InlineNotice` (Error) | "Invalid code. Please try again." (Below OTP input) | "رمز غير صالح. يرجى المحاولة مرة أخرى." (Below OTP input) |
| **CTA** | `Button/Primary` | Verify (Bottom, Full-width) | تحقق (Bottom, Full-width) |

---

## 3. Home Hub (Super-App Entry)

The Home Hub is the core of the super-app, designed for immediate action and clear service selection, following the map-centric Uber/Bolt style.

### Screen 6: Home Hub (Default State)

| Section | Element | Component/Token | Description |
| :--- | :--- | :--- | :--- |
| **Top Bar** | Location/Profile | Location Display (`type.title.default`), Profile Icon (`Button/Icon`) | User's current location/selected address is prominent. |
| **Map Area** | Map Snapshot | Large area (approx. 50% of screen height) | Shows user location and nearby service vehicles/delivery zones. |
| **Service Selection** | Service Cards | 3 x `Card/Service` | **Ride**, **Parcels**, **Food**. Prominent, distinct visuals. |
| **Action Area** | Search Input | `Input/SearchField` | "Where to?" or "What are you looking for?" (Contextual placeholder). |
| **Bottom Nav** | `Navigation/BottomNav` | Home (Active), Orders, Payments, Profile. | Persistent navigation at the bottom. |

### Screen 7: Home Hub (Active Trip/Order State)

When a user has an active service, a persistent card is displayed prominently.

| Section | Element | Component/Token | Description |
| :--- | :--- | :--- | :--- |
| **Top Bar** | Location/Profile | Unchanged. | |
| **Map Area** | Map Snapshot | Reduced height (approx. 30% of screen height) | Map focuses on the active trip/delivery route. |
| **Active Card** | `Card/Generic` (Elevated) | Title: "Driver is 2 min away", Subtitle: "To [Destination]", CTA: "View Trip" | Sits above the service selection, demanding immediate attention. |
| **Service Selection** | Service Cards | Reduced visibility/scrollable below the Active Card. | Still accessible, but secondary to the active service. |
| **Bottom Nav** | `Navigation/BottomNav` | Unchanged. | |

---

## 4. Ride Flow

The Ride flow is a multi-step process focused on map interaction and clear pricing.

### Screen 8: Ride - Destination Input

| Element | Component/Token | Description |
| :--- | :--- | :--- |
| **Map Area** | Map Snapshot | Full screen background. | |
| **Input Sheet** | Bottom Sheet (Modal) | Sits on top of the map, minimal height. | |
| **Pick-up Input** | `Input/TextField` | "Current Location" (Pre-filled, non-editable) | |
| **Destination Input** | `Input/SearchField` | "Where to?" (Focused, opens full-screen search) | |
| **Recent Locations** | List of `Card/Generic` | Home, Work, Recent Addresses. | Quick selection for frequent destinations. |

### Screen 9: Ride - Trip Confirmation

| Element | Component/Token | Description |
| :--- | :--- | :--- |
| **Map Area** | Map Snapshot | Shows the route between Pick-up and Destination. | |
| **Vehicle Options** | List of `Card/Service` (small) | Economy, XL, Premium. Includes ETA and Fare Estimate. | Clear, vertically stacked options. |
| **Payment Method** | `Card/Generic` (small) | Shows selected payment method (e.g., Visa **4242). | Allows quick change of payment method. |
| **CTA** | `Button/Primary` | Request Ride (Full-width, prominent) | Final confirmation button. |

### Screen 10: Ride - Active Trip

| Element | Component/Token | Description |
| :--- | :--- | :--- |
| **Map Area** | Map Snapshot | Shows driver and rider location, route. | |
| **Driver Card** | `Card/Generic` (Elevated) | Driver Name, Photo, Rating, Car Model, License Plate. | Prominent card at the bottom of the screen. |
| **Status/ETA** | `type.headline.h2` | "Arriving in 3 min" (Large, clear text). | |
| **Actions** | `Button/Tertiary` | Contact Driver, Share Trip Status, Cancel Ride. | Subtle, text-based actions below the driver card. |

---

## 5. Parcels Flow (MVP)

### Screen 11: Parcels - Create Shipment

| Element | Component/Token | Description |
| :--- | :--- | :--- |
| **AppBar** | `Navigation/AppBar` | Title: "New Shipment" | |
| **Sender/Receiver** | `Input/TextField` Group | Separate sections for Sender Info (Name, Phone, Address) and Receiver Info. | Clear, structured form. |
| **Parcel Details** | `Input/TextField` Group | Weight, Size (dropdown/chip), Notes. | Simple inputs for package information. |
| **Service Type** | `Utility/Chip` Group | Express (Active), Standard (Inactive). | Simple selection mechanism. |
| **CTA** | `Button/Primary` | Get Estimate (Bottom, Full-width) | |

### Screen 12: Parcels - Shipments List

| Element | Component/Token | Description |
| :--- | :--- | :--- |
| **AppBar** | `Navigation/AppBar` | Title: "My Shipments", Action: "+" (New Shipment) | |
| **List** | `Card/Order` | List of all shipments. Status Chip is key (Created, In Transit, Delivered). | |
| **Empty State** | `Utility/EmptyState` | Icon, Title: "No Shipments Yet", Description, CTA: "Create First Shipment". | Displayed when the list is empty. |

---

## 6. Food Flow (MVP)

### Screen 13: Food - Restaurants List

| Element | Component/Token | Description |
| :--- | :--- | :--- |
| **AppBar** | `Navigation/AppBar` | Title: "Food Delivery", Action: Search Icon. | |
| **Search/Filter** | `Input/SearchField` + Chips | Search bar for restaurants, horizontal scrollable chips for categories (e.g., Burgers, Italian). | |
| **List** | `Card/Generic` (Restaurant) | Image Banner, Name (`type.title.default`), Cuisine, Rating (Icon + Number). | Clear, visually appealing cards. |
| **Empty State** | `Utility/EmptyState` | Icon, Title: "No Restaurants Found", Description. | |

### Screen 14: Food - Cart / Summary

| Element | Component/Token | Description |
| :--- | :--- | :--- |
| **AppBar** | `Navigation/AppBar` | Title: "Your Cart" | |
| **Items List** | List of Items | Item Name, Quantity Selector, Price. | Clear breakdown of selected items. |
| **Summary** | `Card/Generic` | Subtotal, Delivery Fee, Tax, **Total**. | Fixed section at the bottom. |
| **CTA** | `Button/Primary` | Place Order (Full-width, shows Total Price) | |

---

## 7. Orders History

### Screen 15: Orders History

| Element | Component/Token | Description |
| :--- | :--- | :--- |
| **AppBar** | `Navigation/AppBar` | Title: "My Orders" | |
| **Filter** | Segmented Control (Custom) | All (Active), Rides, Parcels, Food. | Allows quick filtering of order types. |
| **List** | `Card/Order` | Unified list of all past services. | Each card uses the appropriate service icon. |
| **Empty State** | `Utility/EmptyState` | Icon, Title: "No History Yet". | |

---

## 8. Payments

### Screen 16: Payments - Payment Methods

| Element | Component/Token | Description |
| :--- | :--- | :--- |
| **AppBar** | `Navigation/AppBar` | Title: "Payments" | |
| **List** | `Card/Generic` | List of saved payment methods (e.g., Visa **4242, Cash). | Includes generic iconography for card types. |
| **CTA** | `Button/Secondary` | Add New Payment Method (Full-width) | |
| **Empty State** | `Utility/EmptyState` | Icon, Title: "No Payment Methods Saved". | |

---

## 9. Profile / Settings

### Screen 17: Profile / Settings

| Element | Component/Token | Description |
| :--- | :--- | :--- |
| **AppBar** | `Navigation/AppBar` | Title: "Profile" | |
| **User Info** | `Card/Generic` | User Photo, Name, Phone Number. | Prominent display of user identity. |
| **Settings List** | List of `Card/Generic` (minimal) | Personal Info, Ride Preferences, Notifications, Help & Support, Logout. | Standard list items for navigation. |
| **DSR/Privacy** | `Card/Generic` (minimal) | "Export My Data", "Erase My Data". | Clear, separate entries for DSR requests. |

---

## 10. Accessibility and RTL/LTR Notes

*   **Touch Targets:** All interactive elements (buttons, list items, icons) are designed to meet the minimum 44x44px touch target size.
*   **Contrast:** The color palette ensures a minimum contrast ratio of 4.5:1 for all text against its background, meeting WCAG AA standards.
*   **RTL Implementation:** In the Figma file, all screens will have an LTR (English) version and an RTL (Arabic) version to demonstrate mirroring of:
    *   Text alignment (Left-aligned in LTR, Right-aligned in RTL).
    *   Iconography (e.g., the Back button icon will point left in LTR and right in RTL).
    *   Layout sequence (e.g., list items will start from the right in RTL).
