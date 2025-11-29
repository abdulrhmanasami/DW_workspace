import 'package:flutter/widgets.dart';
import '../ui.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: DwText('No data available', variant: DwTextVariant.body),
    );
  }
}
