import 'package:flutter/widgets.dart';
import '../ui.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: DwText('Error occurred', variant: DwTextVariant.body),
    );
  }
}
