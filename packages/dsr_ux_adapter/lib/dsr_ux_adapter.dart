/// DSR-UX Adapter - Compatibility Layer
/// Created by: Cursor B-ux
/// Purpose: Bridge legacy App* components to new Dw* design system
/// Last updated: 2025-11-24

library dsr_ux_adapter;

// Legacy App* component adapters
export 'src/compat/adapters_registry.dart';
export 'src/compat/app_theme_data_adapter.dart';
export 'src/compat/app_button_adapter.dart';
export 'src/compat/app_card_adapter.dart';
export 'src/compat/dw_compat_wrappers.dart';

// DSR domain + controllers
export 'src/dsr_models.dart';
export 'src/dsr_state.dart';
