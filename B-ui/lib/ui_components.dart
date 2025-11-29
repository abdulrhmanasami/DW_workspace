/// Component: UI Components Barrel
/// Created by: DW-UI-UI-005
/// Purpose: Single import entry point for B-ui components
/// Last updated: 2025-11-25
///
/// Usage from app:
/// ```dart
/// import 'package:b_ui/ui_components.dart';
///
/// // Use components
/// UiLoadingButton(label: 'Save', isLoading: true, onPressed: () {});
/// UiSkeletonList(itemCount: 3);
/// UiEmptyState(title: 'No data', subtitle: 'Add some items');
/// UiAnimatedStateTransition(child: content);
/// ```

library ui_components;

// ─────────────────────────────────────────────────────────────────────────────
// Buttons
// ─────────────────────────────────────────────────────────────────────────────
export 'ui/components/buttons.dart'
    show UiLoadingButtonContent, UiLoadingButton, UiSpinner;

// ─────────────────────────────────────────────────────────────────────────────
// Skeletons
// ─────────────────────────────────────────────────────────────────────────────
export 'ui/components/skeletons.dart'
    show
        UiSkeletonShimmer,
        UiSkeletonLine,
        UiSkeletonCard,
        UiSkeletonList,
        UiSkeletonTile,
        UiSkeletonSettingsList;

// ─────────────────────────────────────────────────────────────────────────────
// State Containers
// ─────────────────────────────────────────────────────────────────────────────
export 'ui/components/state_containers.dart'
    show UiEmptyState, UiErrorState, UiUnavailableFeature, UiRetryButton;

// ─────────────────────────────────────────────────────────────────────────────
// Animated Transitions
// ─────────────────────────────────────────────────────────────────────────────
export 'ui/components/animated_transitions.dart'
    show
        UiAnimatedStateTransition,
        UiAnimatedFade,
        UiAnimatedScale,
        UiStaggeredList,
        UiAnimatedListItem;

// ─────────────────────────────────────────────────────────────────────────────
// Legacy Components (for backward compatibility)
// ─────────────────────────────────────────────────────────────────────────────
export 'ui/components/loading_view.dart' show LoadingView;
export 'ui/components/error_view.dart' show ErrorView;
export 'ui/components/empty_state.dart' show EmptyState;

