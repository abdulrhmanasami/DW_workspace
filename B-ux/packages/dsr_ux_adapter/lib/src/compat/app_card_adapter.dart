import 'package:design_system_components/design_system_components.dart';
import 'package:flutter/widgets.dart';

/// Legacy AppCard compatibility adapter
/// Bridges old AppCard API to new DwCard component
class AppCardAdapter {
  const AppCardAdapter._();

  /// Creates a standard AppCard (legacy API compatibility)
  static Widget standard({
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    return DwCard(padding: padding, margin: margin, child: child);
  }
}
