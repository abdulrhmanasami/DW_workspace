// lib/ui/ui.dart
/// Component: UI Module Barrel
/// Created by: DW-UI-UI-005
/// Purpose: Central export for B-ui components and design system bindings
/// Last updated: 2025-11-25

// helper بسيط للمسافات (بدون اعتماد خارجي)
import 'package:flutter/widgets.dart';

// Flutter widgets (selective)
export 'package:flutter/widgets.dart'
    show
        Widget,
        BuildContext,
        SizedBox,
        Center,
        Column,
        SingleChildScrollView,
        Navigator,
        Text;

// Flutter Material (selective)
export 'package:flutter/material.dart' show SelectableText, Scaffold, AppBar;

// Flutter Riverpod
export 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────────────────────────
// B-ui Components (UI-005: Reusable UI patterns)
// ─────────────────────────────────────────────────────────────────────────────

// Legacy components (simple versions)
export 'components/loading_view.dart' show LoadingView;
export 'components/error_view.dart' show ErrorView;
export 'components/empty_state.dart' show EmptyState;

// Buttons with loading states
export 'components/buttons.dart'
    show UiLoadingButtonContent, UiLoadingButton, UiSpinner;

// Skeleton loading placeholders
export 'components/skeletons.dart'
    show
        UiSkeletonShimmer,
        UiSkeletonLine,
        UiSkeletonCard,
        UiSkeletonList,
        UiSkeletonTile,
        UiSkeletonSettingsList;

// State containers (Empty/Error/Unavailable)
export 'components/state_containers.dart'
    show UiEmptyState, UiErrorState, UiUnavailableFeature, UiRetryButton;

// Animated transitions
export 'components/animated_transitions.dart'
    show
        UiAnimatedStateTransition,
        UiAnimatedFade,
        UiAnimatedScale,
        UiStaggeredList,
        UiAnimatedListItem;

// ─────────────────────────────────────────────────────────────────────────────
// تصدير واجهات السجل (بدون تصدير أي عناصر مادية/غير لازمة)
// ─────────────────────────────────────────────────────────────────────────────
export 'routes/registry.dart' show UiRoute, uiRouteSpecs, uiRoutes;

// ─────────────────────────────────────────────────────────────────────────────
// Design System Shims (App-level components)
// ─────────────────────────────────────────────────────────────────────────────
export 'package:design_system_shims/design_system_shims.dart'
    show AppCard, AppButton;

// ─────────────────────────────────────────────────────────────────────────────
// Design System Foundation (Tokens)
// ─────────────────────────────────────────────────────────────────────────────
export 'package:design_system_foundation/design_system_foundation.dart'
    show DwColors, DwSpacing, DwMotion;

// ─────────────────────────────────────────────────────────────────────────────
// Design System Components (Atoms)
// ─────────────────────────────────────────────────────────────────────────────
export 'package:design_system_components/design_system_components.dart'
    show
        DwText,
        DwTextVariant,
        DwButton,
        DwButtonVariant,
        DwButtonSize;

// ─────────────────────────────────────────────────────────────────────────────
// App Spacing Helper (Legacy compatibility)
// ─────────────────────────────────────────────────────────────────────────────
class AppSpacing {
  static Widget vertical(double v) => SizedBox(height: v);
  static Widget horizontal(double v) => SizedBox(width: v);

  // Loading component sizes (tokens for hardcoded values)
  static const double loadingSpinnerSize = 32.0;
  static const double loadingSpinnerSizeSmall = 24.0;
  static const Duration loadingAnimationDuration = Duration(milliseconds: 900);
  static const double loadingStrokeRatio = 0.1;
}
