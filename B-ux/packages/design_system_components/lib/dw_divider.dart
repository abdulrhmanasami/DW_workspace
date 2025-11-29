import 'package:design_system_foundation/design_system_foundation.dart';
import 'package:flutter/material.dart';

class DwDivider extends StatelessWidget {
  const DwDivider({super.key, this.padding});

  final EdgeInsets? padding;

  static final DwColors _colors = DwColors();

  @override
  Widget build(BuildContext context) {
    final divider = Divider(color: _colors.divider, thickness: 1, height: 1);

    if (padding == null) {
      return divider;
    }

    return Padding(padding: padding!, child: divider);
  }
}
