# Track C: Parcels & Food MVP Implementation

## Overview

This document outlines the implementation of Track C: Parcels & Food MVP. The goal is to either implement basic MVP features or hide these features behind feature flags to maintain a focused, production-ready experience.

## Strategy Decision

Given the scope of the project and the need to maintain all hard constraints, the recommended approach is:

1. **Parcels:** Implement a basic MVP with create, list, and detail views
2. **Food:** Hide behind a feature flag (can be enabled in future releases)

This approach allows us to:
- Provide a functional parcels service
- Keep the app focused on core features (Ride + Parcels)
- Maintain code quality and test coverage
- Enable food delivery in future releases without major refactoring

## Current State Analysis

### Existing Infrastructure

1. **Parcels Shims:** `packages/parcels_shims/` provides abstractions for parcel management
2. **Existing Screens:** Placeholder screens exist for both Parcels and Food
3. **Feature Flags:** System already in place for feature management

## Implementation Plan

### Phase 1: Create Parcels State Management

**File:** `lib/state/parcels/parcels_providers.dart`

Models:
- `Parcel` - Represents a parcel with pickup/delivery info
- `ParcelStatus` - Enum for parcel states (pending, picked up, in transit, delivered)
- `ParcelSize` - Enum for parcel sizes (small, medium, large)

Providers:
- `parcelsProvider` - List of user's parcels
- `parcelDetailProvider` - Single parcel details
- `createParcelProvider` - Create new parcel

### Phase 2: Create Parcels Screens

**Files:**
- `lib/screens/parcels/parcels_list_screen.dart` - List all parcels
- `lib/screens/parcels/parcel_detail_screen.dart` - View parcel details
- `lib/screens/parcels/create_parcel_screen.dart` - Create new parcel

### Phase 3: Create Food Feature Flag

**File:** `lib/config/feature_flags.dart` (update)

Add:
- `enableFoodDelivery` - Feature flag for food delivery

### Phase 4: Update Navigation

Update router to include:
- `/parcels` - Parcels list
- `/parcels/create` - Create parcel
- `/parcels/:id` - Parcel detail

### Phase 5: Update Home Screen

Add Parcels navigation to home screen quick actions.

## Implementation Details

### Parcels State Machine

```
Pending (awaiting pickup)
  ↓
PickedUp (parcel collected)
  ↓
InTransit (on delivery route)
  ↓
Delivered (delivered to recipient)
  ↓
Cancelled (optional)
```

### Parcels List Screen

Features:
- Display list of user's parcels
- Filter by status (pending, in transit, delivered)
- Search by tracking number
- Sort by date
- Pull-to-refresh
- Empty state when no parcels

### Create Parcel Screen

Features:
- Pickup location selection
- Delivery location selection
- Parcel size selection
- Weight input
- Description input
- Special instructions
- Estimated cost display
- Create button

### Parcel Detail Screen

Features:
- Parcel information
- Current status with timeline
- Pickup and delivery details
- Tracking number
- Estimated delivery time
- Parcel tracking map
- Contact sender/recipient
- Cancel parcel option

### Food Feature Flag

When disabled:
- Hide food option from home screen
- Redirect to home if user tries to access food routes
- Show "Coming Soon" message

When enabled (future):
- Show food option on home screen
- Enable food ordering flow

## UI Components

### Parcel Card
- Parcel ID
- Status badge
- Pickup and delivery addresses
- Estimated delivery time
- Status icon

### Parcel Status Timeline
- Pending → Picked Up → In Transit → Delivered
- Visual timeline with icons
- Timestamps for each status

### Create Parcel Form
- Location inputs with map preview
- Size selector
- Weight input
- Description textarea
- Cost breakdown

## Testing Strategy

1. **Unit Tests:** Test state management providers
2. **Widget Tests:** Test UI components
3. **Integration Tests:** Test parcel flow
4. **Mock Backend:** Use stub implementations

## Success Criteria

- ✅ Parcels list with filtering and search
- ✅ Create parcel flow
- ✅ Parcel detail view with tracking
- ✅ Food feature flag working
- ✅ All tests pass
- ✅ App builds successfully
- ✅ Uses parcels_shims (no direct SDK imports)

## Files to Create

1. `lib/state/parcels/parcels_providers.dart`
2. `lib/screens/parcels/parcels_list_screen.dart`
3. `lib/screens/parcels/parcel_detail_screen.dart`
4. `lib/screens/parcels/create_parcel_screen.dart`

## Files to Update

1. `lib/config/feature_flags.dart` - Add food feature flag
2. `lib/router/app_router.dart` - Add parcel routes
3. `lib/screens/home_screen.dart` - Update quick actions
4. `lib/screens/_placeholders.dart` - Update food placeholder

## Timeline

- **Phase 1:** 1-2 hours (State management)
- **Phase 2:** 2-3 hours (Screens)
- **Phase 3:** 30 minutes (Feature flags)
- **Phase 4:** 30 minutes (Navigation)
- **Phase 5:** 30 minutes (Home screen)
- **Testing:** 1-2 hours

**Total Estimated Time:** 6-9 hours

## Notes

- All changes maintain backward compatibility
- Uses existing parcels_shims abstractions
- No direct SDK imports
- Follows design system from Track A
- Implements proper error handling and loading states
- Food feature can be enabled in future releases
