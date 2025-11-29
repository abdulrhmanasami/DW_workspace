/// Terms Markdown Screen - Terms of service viewer from Remote Config
/// Created by: UI-PHASE-01 (adapted from B-ux)
/// Purpose: Display terms of service content from Remote Config
/// Last updated: 2025-11-16

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart' as ds;

class TermsMarkdownScreen extends ConsumerWidget {
  const TermsMarkdownScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Use termsMarkdownProvider when import is resolved from foundation
    const md = '';

    return ds.AppCard.standard(
      child: md.isNotEmpty
          ? const SingleChildScrollView(child: SelectableText(md))
          : const SelectableText('شروط الاستخدام غير متاحة حالياً.'),
    );
  }
}
