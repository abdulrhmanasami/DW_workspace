library design_system_shims;

// Applications must import this barrel only.
// Updated by: UX-DSHIMS-PHASE-02 - Canonical theme exports
export 'src/components.dart';
export 'src/providers.dart';
export 'src/theme/app_theme.dart'; // Canonical theme - single source of truth + interfaces
export 'src/colors.dart';
export 'src/feedback.dart';
export 'providers/theme_providers.dart';
export 'providers/components_providers.dart';
