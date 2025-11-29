import 'package:flutter/widgets.dart';
import 'legacy/aliases.dart' show MapController;

class MapWidget extends StatelessWidget {
  final MapController controller;
  const MapWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) => const SizedBox.expand(); // Noop view
}
