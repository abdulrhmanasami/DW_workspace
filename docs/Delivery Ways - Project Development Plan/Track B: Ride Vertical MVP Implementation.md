# Track B: Ride Vertical MVP Implementation

## Overview

This document outlines the implementation of Track B: Ride Vertical MVP. The goal is to create a complete, end-to-end user experience for booking and tracking a ride, similar to Uber/Bolt.

## Current State Analysis

### Existing Infrastructure

1. **Mobility Shims:** `packages/mobility_shims/` provides abstractions for:
   - Trip management
   - Driver tracking
   - Location services
   - Real-time updates

2. **Maps Shims:** `packages/maps_shims/` provides:
   - Map display abstractions
   - Location selection
   - Route visualization

3. **Existing Screens:**
   - `lib/screens/mobility/tracking_screen.dart` - Trip tracking
   - `lib/screens/tracking_map_screen.dart` - Map view
   - `lib/screens/order_tracking_screen.dart` - Order tracking

### Current Issues

1. **Incomplete Flow:** No complete ride booking flow
2. **Missing Location Selection:** No UI for pickup/destination selection
3. **No Fare Estimation:** Missing fare calculation UI
4. **Limited Trip States:** Incomplete trip state management

## Implementation Plan

### Phase 1: Create Location Selection Screen

**File:** `lib/screens/mobility/location_selection_screen.dart`

Features:
- Search input for pickup location
- Search input for destination
- Map preview showing locations
- Recent locations list
- Current location button
- Fare estimate display

### Phase 2: Create Ride Booking Screen

**File:** `lib/screens/mobility/ride_booking_screen.dart`

Features:
- Display selected locations
- Show ride options (Standard, Premium, etc.)
- Fare breakdown
- Estimated arrival time
- Book ride button
- Payment method selection

### Phase 3: Create Trip Tracking Screen

**File:** `lib/screens/mobility/trip_tracking_screen.dart`

Features:
- Real-time map with driver location
- Trip status display (Searching, Driver Assigned, etc.)
- Driver information card
- Estimated arrival time
- Trip details (distance, fare, etc.)
- Cancel trip button
- Contact driver button

### Phase 4: Create Trip Completion Screen

**File:** `lib/screens/mobility/trip_completion_screen.dart`

Features:
- Trip summary (pickup, destination, fare)
- Driver rating
- Feedback option
- Receipt/invoice
- Share trip option
- Rate driver button

### Phase 5: Create Ride State Management

**File:** `lib/state/mobility/ride_providers.dart`

Providers:
- `rideBookingProvider` - Current ride booking state
- `tripStateProvider` - Current trip state
- `driverLocationProvider` - Real-time driver location
- `estimatedFareProvider` - Fare estimation
- `tripHistoryProvider` - Past trips

### Phase 6: Update Navigation

Update router to include:
- `/mobility/location-selection` - Location selection
- `/mobility/ride-booking` - Ride booking
- `/mobility/trip-tracking` - Trip tracking
- `/mobility/trip-completion` - Trip completion

## Implementation Details

### Trip State Machine

```
Idle
  ↓
Searching (waiting for driver)
  ↓
DriverAssigned (driver accepted)
  ↓
DriverArriving (driver on the way)
  ↓
TripInProgress (passenger in vehicle)
  ↓
Completed (trip finished)
  ↓
Cancelled (trip cancelled)
```

### Location Selection Flow

1. User enters pickup location (auto-filled with current location)
2. User enters destination
3. System shows available ride options
4. User selects ride type
5. System calculates fare estimate
6. User confirms and books ride

### Real-Time Tracking

1. After booking, show map with driver location
2. Update driver location in real-time using mobility_shims
3. Show estimated arrival time
4. Show trip progress on map
5. Update trip status as driver progresses

### Fare Estimation

1. Calculate based on distance and time
2. Show base fare, distance fare, and time fare
3. Display surge pricing if applicable
4. Show total estimated fare

## UI Components

### Location Input Card
- Search input with autocomplete
- Recent locations dropdown
- Current location button
- Map preview

### Ride Option Card
- Ride type (Standard, Premium, etc.)
- Estimated time
- Estimated fare
- Vehicle type icon
- Select button

### Trip Status Card
- Current status
- Driver information
- Estimated arrival time
- Trip progress

### Driver Information Card
- Driver photo
- Driver name
- Driver rating
- Vehicle information
- License plate

## Testing Strategy

1. **Unit Tests:** Test state management providers
2. **Widget Tests:** Test UI components
3. **Integration Tests:** Test complete ride flow
4. **Mock Backend:** Use stub implementations for testing

## Success Criteria

- ✅ Complete ride booking flow
- ✅ Location selection with map preview
- ✅ Fare estimation display
- ✅ Real-time driver tracking
- ✅ Trip status updates
- ✅ Trip completion with rating
- ✅ All tests pass
- ✅ App builds successfully for Android and iOS
- ✅ Uses mobility_shims and maps_shims (no direct SDK imports)

## Files to Create

1. `lib/screens/mobility/location_selection_screen.dart`
2. `lib/screens/mobility/ride_booking_screen.dart`
3. `lib/screens/mobility/trip_tracking_screen.dart`
4. `lib/screens/mobility/trip_completion_screen.dart`
5. `lib/state/mobility/ride_providers.dart`
6. `lib/widgets/location_input_card.dart`
7. `lib/widgets/ride_option_card.dart`
8. `lib/widgets/trip_status_card.dart`
9. `lib/widgets/driver_info_card.dart`

## Files to Update

1. `lib/router/app_router.dart` - Add ride routes
2. `lib/screens/home_screen.dart` - Add ride booking button
3. `lib/screens/mobility/tracking_screen.dart` - Integrate with new flow

## Timeline

- **Phase 1:** 2-3 hours (Location selection)
- **Phase 2:** 2-3 hours (Ride booking)
- **Phase 3:** 2-3 hours (Trip tracking)
- **Phase 4:** 1-2 hours (Trip completion)
- **Phase 5:** 1-2 hours (State management)
- **Phase 6:** 1 hour (Navigation)
- **Testing:** 2-3 hours

**Total Estimated Time:** 11-17 hours

## Notes

- All changes maintain backward compatibility with existing tests
- Uses existing mobility_shims and maps_shims abstractions
- No direct SDK imports
- Follows design system from Track A
- Implements proper error handling and loading states
