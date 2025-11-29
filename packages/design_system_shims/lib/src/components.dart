import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

typedef AppButtonPrimaryResolver =
    AppButton Function({
      Key? key,
      required String label,
      VoidCallback? onPressed,
      bool expanded,
      bool loading,
      Widget? leadingIcon,
    });

AppButtonPrimaryResolver? _appButtonPrimaryResolver;

void registerAppButtonPrimaryResolver(AppButtonPrimaryResolver resolver) {
  _appButtonPrimaryResolver = resolver;
}

typedef AppCardStandardResolver =
    AppCard Function({
      Key? key,
      required Widget child,
      EdgeInsetsGeometry? padding,
      EdgeInsetsGeometry? margin,
      Color? backgroundColor,
      BorderRadius? borderRadius,
      BoxBorder? border,
      VoidCallback? onTap,
    });

AppCardStandardResolver? _appCardStandardResolver;

void registerAppCardStandardResolver(AppCardStandardResolver resolver) {
  _appCardStandardResolver = resolver;
}

Never _unregisteredToken(String token) => throw UnimplementedError(
  '$token has no registered resolver. Ensure a stub implementation is wired.',
);

abstract class AppButton extends StatelessWidget {
  const AppButton({super.key});

  factory AppButton.primary({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    bool expanded = false,
    bool loading = false,
    Widget? leadingIcon,
  }) {
    final resolver = _appButtonPrimaryResolver ?? _missingButtonPrimaryResolver;
    return resolver(
      key: key,
      label: label,
      onPressed: onPressed,
      expanded: expanded,
      loading: loading,
      leadingIcon: leadingIcon,
    );
  }
}

AppButtonPrimaryResolver _missingButtonPrimaryResolver =
    ({
      Key? key,
      required String label,
      VoidCallback? onPressed,
      bool expanded = false,
      bool loading = false,
      Widget? leadingIcon,
    }) => _unregisteredToken('AppButton.primary');

abstract class AppCard extends StatelessWidget {
  const AppCard({super.key});

  factory AppCard.standard({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? backgroundColor,
    BorderRadius? borderRadius,
    BoxBorder? border,
    VoidCallback? onTap,
  }) {
    final resolver = _appCardStandardResolver ?? _missingCardStandardResolver;
    return resolver(
      key: key,
      child: child,
      padding: padding,
      margin: margin,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      border: border,
      onTap: onTap,
    );
  }
}

AppCardStandardResolver _missingCardStandardResolver =
    ({
      Key? key,
      required Widget child,
      EdgeInsetsGeometry? padding,
      EdgeInsetsGeometry? margin,
      Color? backgroundColor,
      BorderRadius? borderRadius,
      BoxBorder? border,
      VoidCallback? onTap,
    }) => _unregisteredToken('AppCard.standard');

abstract class AppTextFieldProps {
  const AppTextFieldProps();

  String? get label;
  String? get hint;
  String? get error;
  TextEditingController? get controller;
  ValueChanged<String>? get onChanged;
  bool get enabled;
  bool get obscureText;
  TextInputType get keyboardType;
  List<TextInputFormatter>? get inputFormatters;
  Widget? get prefixIcon;
  Widget? get suffixIcon;
  int? get maxLines;
}

abstract class AppTextField {
  const AppTextField();
  Widget build(BuildContext context, AppTextFieldProps props);
}

abstract class AppSwitchProps {
  const AppSwitchProps();
  bool get value;
  ValueChanged<bool> get onChanged;
  String? get label;
}

abstract class AppSwitch {
  const AppSwitch();
  Widget build(BuildContext context, AppSwitchProps props);
}

typedef AppNoticeResolver = Widget Function(AppNotice notice);

AppNoticeResolver? _appNoticeResolver;

void registerAppNoticeResolver(AppNoticeResolver resolver) {
  _appNoticeResolver = resolver;
}

Never _unregisteredNoticeResolver(String token) => throw UnimplementedError(
  '$token has no registered resolver. Ensure a stub implementation is wired.',
);

/// Types of notices/feedback that can be shown to users
enum AppNoticeType { info, success, warning, error }

/// Action that can be taken on a notice
class AppNoticeAction {
  final String label;
  final VoidCallback onPressed;
  const AppNoticeAction(this.label, this.onPressed);
}

/// Function signature for presenting notices to the user
typedef AppNoticePresenter = void Function(AppNotice notice);

class AppNotice extends StatelessWidget {
  const AppNotice._({
    super.key,
    required this.message,
    required this.type,
    required this.duration,
    this.action,
  });

  factory AppNotice.success({
    Key? key,
    required String message,
    Duration? duration,
    AppNoticeAction? action,
  }) {
    return AppNotice._(
      key: key,
      message: message,
      type: AppNoticeType.success,
      duration: duration ?? const Duration(seconds: 3),
      action: action,
    );
  }

  factory AppNotice.error({
    Key? key,
    required String message,
    Duration? duration,
    AppNoticeAction? action,
  }) {
    return AppNotice._(
      key: key,
      message: message,
      type: AppNoticeType.error,
      duration: duration ?? const Duration(seconds: 4),
      action: action,
    );
  }

  factory AppNotice.warning({
    Key? key,
    required String message,
    Duration? duration,
    AppNoticeAction? action,
  }) {
    return AppNotice._(
      key: key,
      message: message,
      type: AppNoticeType.warning,
      duration: duration ?? const Duration(seconds: 4),
      action: action,
    );
  }

  factory AppNotice.info({
    Key? key,
    required String message,
    Duration? duration,
    AppNoticeAction? action,
  }) {
    return AppNotice._(
      key: key,
      message: message,
      type: AppNoticeType.info,
      duration: duration ?? const Duration(seconds: 3),
      action: action,
    );
  }

  final String message;
  final AppNoticeType type;
  final Duration duration;
  final AppNoticeAction? action;

  @override
  Widget build(BuildContext context) {
    final resolver = _appNoticeResolver ?? _missingNoticeResolver;
    return resolver(this);
  }
}

Widget _missingNoticeResolver(AppNotice notice) =>
    _unregisteredNoticeResolver('AppNotice.${notice.type}');
