/// Component: BUiDesignSystemBinding
/// Created by: DW-UI-PHASE4-UI-RESOLVERS-APPBUTTON
/// Purpose: Centralized registration entry for B-ui design system resolvers
/// Last updated: 2025-11-25

library b_ui_design_system_binding;

import 'design_system/app_button_resolvers.dart';

bool _designSystemResolversRegistered = false;

/// Registers all currently available design system resolvers for B-ui.
void registerDesignSystemResolvers() {
  if (_designSystemResolversRegistered) {
    return;
  }

  registerAppButtonResolvers();
  _designSystemResolversRegistered = true;
}

