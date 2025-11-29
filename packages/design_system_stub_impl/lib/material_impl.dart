library design_system_stub_material_impl;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart' as ds;

class _AppButtonPrimary extends ds.AppButton {
  const _AppButtonPrimary({
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
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leadingIcon != null) ...[
          leadingIcon!,
          const SizedBox(width: 8),
        ],
        Text(label),
      ],
    );

    final buttonChild = loading
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : child;

    return SizedBox(
      width: expanded ? double.infinity : null,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        child: buttonChild,
      ),
    );
  }
}

class _AppCardStandard extends ds.AppCard {
  const _AppCardStandard({
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
    Widget card = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).colorScheme.surface,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        border: border,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      card = InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        child: card,
      );
    }

    if (margin != null) {
      card = Padding(padding: margin!, child: card);
    }

    return card;
  }
}

class _AppNoticeImpl extends StatelessWidget {
  const _AppNoticeImpl({
    super.key,
    required this.notice,
  });

  final ds.AppNotice notice;

  @override
  Widget build(BuildContext context) {
    // Get background color based on notice type
    late Color backgroundColor;
    late Color foregroundColor;
    late IconData icon;

    switch (notice.type) {
      case ds.AppNoticeType.success:
        backgroundColor = Colors.green.shade100;
        foregroundColor = Colors.green.shade800;
        icon = Icons.check_circle;
        break;
      case ds.AppNoticeType.error:
        backgroundColor = Colors.red.shade100;
        foregroundColor = Colors.red.shade800;
        icon = Icons.error;
        break;
      case ds.AppNoticeType.warning:
        backgroundColor = Colors.orange.shade100;
        foregroundColor = Colors.orange.shade800;
        icon = Icons.warning;
        break;
      case ds.AppNoticeType.info:
        backgroundColor = Colors.blue.shade100;
        foregroundColor = Colors.blue.shade800;
        icon = Icons.info;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: foregroundColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: foregroundColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              notice.message,
              style: TextStyle(
                color: foregroundColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (notice.action != null) ...[
            const SizedBox(width: 12),
            TextButton(
              onPressed: notice.action!.onPressed,
              style: TextButton.styleFrom(
                foregroundColor: foregroundColor,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              child: Text(notice.action!.label),
            ),
          ],
        ],
      ),
    );
  }
}

class MaterialAppTextField implements ds.AppTextField {
  const MaterialAppTextField();

  @override
  Widget build(BuildContext context, ds.AppTextFieldProps props) {
    return TextFormField(
      controller: props.controller,
      onChanged: props.onChanged,
      enabled: props.enabled,
      obscureText: props.obscureText,
      keyboardType: props.keyboardType,
      inputFormatters: props.inputFormatters,
      maxLines: props.maxLines,
      decoration: InputDecoration(
        labelText: props.label,
        hintText: props.hint,
        errorText: props.error,
        prefixIcon: props.prefixIcon,
        suffixIcon: props.suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class MaterialAppSwitch implements ds.AppSwitch {
  const MaterialAppSwitch();

  @override
  Widget build(BuildContext context, ds.AppSwitchProps props) {
    return SwitchListTile(
      value: props.value,
      onChanged: props.onChanged,
      title: props.label != null ? Text(props.label!) : null,
    );
  }
}

ds.AppButton _buildPrimary({
  Key? key,
  required String label,
  VoidCallback? onPressed,
  bool expanded = false,
  bool loading = false,
  Widget? leadingIcon,
}) =>
    _AppButtonPrimary(
      key: key,
      label: label,
      onPressed: onPressed,
      expanded: expanded,
      loading: loading,
      leadingIcon: leadingIcon,
    );

ds.AppCard _buildCard({
  Key? key,
  required Widget child,
  EdgeInsetsGeometry? padding,
  EdgeInsetsGeometry? margin,
  Color? backgroundColor,
  BorderRadius? borderRadius,
  BoxBorder? border,
  VoidCallback? onTap,
}) =>
    _AppCardStandard(
      key: key,
      child: child,
      padding: padding,
      margin: margin,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      border: border,
      onTap: onTap,
    );

Widget _buildNotice(ds.AppNotice notice) => _AppNoticeImpl(notice: notice);

final materialDesignOverrides = <Override>[
  ds.appThemeProvider.overrideWithValue(ds.AppThemeData.light()),
  ds.appTextFieldBuilderProvider
      .overrideWithValue(const MaterialAppTextField()),
  ds.appSwitchBuilderProvider.overrideWithValue(const MaterialAppSwitch()),
  ds.appButtonPrimaryResolverProvider.overrideWithValue(_buildPrimary),
  ds.appCardStandardResolverProvider.overrideWithValue(_buildCard),
  ds.appNoticeResolverProvider.overrideWithValue(_buildNotice),
];
