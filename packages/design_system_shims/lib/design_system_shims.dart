library design_system_shims;

// Applications must import this barrel only.
// Updated by: UX-DSHIMS-PHASE-02 - Canonical theme exports
// Updated by: Ticket #25 - DWButton component
// Updated by: Track A - Ticket #30 - DWTheme unified design tokens
// Updated by: Ticket #35 - DWTextField component
export 'src/components.dart';
export 'src/components/dw_button.dart'; // Ticket #25: Unified button component
export 'src/components/dw_text_field.dart'; // Ticket #35: Unified text field component
export 'src/providers.dart';
export 'src/theme/app_theme.dart'; // Canonical theme - single source of truth + interfaces
export 'src/theme/dw_theme.dart'; // Track A - Ticket #30: DWTheme + DWSpacing + DWRadius + DWElevation
export 'src/colors.dart';
export 'src/feedback.dart';
export 'providers/theme_providers.dart';
export 'providers/components_providers.dart';
