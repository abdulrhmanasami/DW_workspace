// Component: Legacy Auth Placeholder
// Created by: CENT-003 Implementation
// Purpose: Fallback widget when passwordless auth is disabled
// Last updated: 2025-11-25

import 'package:flutter/material.dart';

/// Simple fallback widget used when passwordless auth is disabled.
class LegacyAuthPlaceholder extends StatelessWidget {
  const LegacyAuthPlaceholder({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Passwordless auth is disabled. Supabase legacy flow remains active.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

