import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/src/theme/app_theme.dart';

/// Unified theme provider for the application
/// Created by: CENT-SHIMS-CONSISTENCY-GATE-02
/// Purpose: Single source of truth for app theme
/// Last updated: 2025-11-17

final appThemeProvider = Provider<AppThemeData>((_) => AppThemeData.light());
