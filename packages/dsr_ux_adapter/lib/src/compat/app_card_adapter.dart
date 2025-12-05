import 'package:design_system_shims/design_system_shims.dart' as ds;
import 'package:flutter/widgets.dart';

/// Legacy AppCard compatibility adapter
/// Bridges old AppCard API to the shimmed AppCard implementation
class AppCardAdapter {
  const AppCardAdapter._();

  /// Creates a standard AppCard (legacy API compatibility)
  static Widget standard({
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    return AppCard(padding: padding, margin: margin, child: child);
  }
}

/// Legacy AppCard widget for direct construction
/// Provides AppCard() constructor and AppCard.standard() compatibility
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding, this.margin});

  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  /// Standard AppCard factory (legacy API compatibility)
  static Widget standard({
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    return AppCard(padding: padding, margin: margin, child: child);
  }

  @override
  Widget build(BuildContext context) {
    return ds.AppCard.standard(
      padding: padding,
      margin: margin,
      child: child,
    );
  }
}
