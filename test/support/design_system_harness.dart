// Design System Test Harness
// Created by: Cursor A
// Purpose: Register stub resolvers for design system components in tests
// Last updated: 2025-11-26

import 'package:flutter/material.dart';
import 'package:design_system_shims/src/components.dart';

bool _designSystemWiredForTests = false;

/// Ensures stub resolvers are registered for design system components.
/// Call this once in setUpAll() before any pumpWidget() calls.
void ensureDesignSystemStubsForTests() {
  if (_designSystemWiredForTests) return;
  _designSystemWiredForTests = true;

  // Register AppCard.standard resolver
  registerAppCardStandardResolver(_StubAppCard.new);

  // Register AppButton.primary resolver
  registerAppButtonPrimaryResolver(_StubAppButton.new);
}

/// Stub implementation of AppCard for tests
class _StubAppCard extends AppCard {
  const _StubAppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.border,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Widget content = child;

    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    return Card(
      margin: margin ?? EdgeInsets.zero,
      color: backgroundColor,
      shape: borderRadius != null
          ? RoundedRectangleBorder(borderRadius: borderRadius!)
          : null,
      child: onTap != null
          ? InkWell(onTap: onTap, child: content)
          : content,
    );
  }
}

/// Stub implementation of AppButton for tests
class _StubAppButton extends AppButton {
  const _StubAppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.expanded = false,
    this.loading = false,
    this.leadingIcon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expanded;
  final bool loading;
  final Widget? leadingIcon;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      child: Row(
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (leadingIcon != null) ...[
            leadingIcon!,
            const SizedBox(width: 8),
          ],
          if (loading)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Text(label),
        ],
      ),
    );
  }
}

