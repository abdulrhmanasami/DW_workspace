import '../services/rbac_service.dart';
import '../widgets/rbac_guard.dart';
import '../config/config_manager.dart';
import '../state/infra/navigation_service.dart';
import 'package:core/rbac/rbac_models.dart';
import 'package:design_system_shims/design_system_shims.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Component: Admin Panel Screen
/// Created by: Cursor B-ux
/// Purpose: شاشة لوحة التحكم محمية بـ RBAC للمدراء والمشغلين فقط
/// Last updated: 2025-11-12

class AdminPanelScreen extends ConsumerStatefulWidget {
  const AdminPanelScreen({
    super.key,
    required this.userId,
    required this.userRole,
  });

  final String userId;
  final UserRole userRole;

  @override
  ConsumerState<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends ConsumerState<AdminPanelScreen> {
  @override
  void initState() {
    super.initState();
    _logAccessAttempt();
  }

  void _logAccessAttempt() {
    // final RBACDecision decision = RBACService.instance.checkAdminAccess(widget.userId, widget.userRole); // Removed unused variable

    if (kDebugMode) {
      // TODO: Replace with proper logging: unawaited(print('🔐 Admin Panel Access: ${RBACService.instance.checkAdminAccess(widget.userId, widget.userRole).allowed ? 'GRANTED' : 'DENIED'}');)
      // TODO: Replace with proper logging: unawaited(print('User: ${widget.userId}, Role: ${widget.userRole.name}');)
      // TODO: Replace with proper logging: unawaited(print('Reason: ${RBACService.instance.checkAdminAccess(widget.userId, widget.userRole).reason}');)
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);

    // Fail-closed: Check backend availability for admin features
    if (!AppConfig.canUseBackendFeature()) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin Panel')),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(theme.spacing.md),
            child: Text(
              AppConfig.backendPolicyMessage,
              textAlign: TextAlign.center,
              style: theme.typography.body1,
            ),
          ),
        ),
      );
    }

    // Fail-closed: Check telemetry availability for admin analytics
    if (!AppConfig.canUseTelemetryFeature()) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin Panel')),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(theme.spacing.md),
            child: Text(
              AppConfig.telemetryPolicyMessage,
              textAlign: TextAlign.center,
              style: theme.typography.body1,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: RbacGuard(
        userId: widget.userId,
        userRole: widget.userRole,
        requiredPermission: const RBACPermission(
          resource: RBACResource.adminUsers,
          action: RBACAction.read,
        ),
        fallback: _buildAccessDeniedScreen(),
        child: _buildAdminContent(),
      ),
    );
  }

  Widget _buildAdminContent() {
    final theme = ref.watch(appThemeProvider);
    return SingleChildScrollView(
      padding: EdgeInsets.all(theme.spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // معلومات المستخدم والدور
          Card(
            child: Padding(
              padding: EdgeInsets.all(theme.spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('معلومات المستخدم', style: theme.typography.headline5),
                  const SizedBox(height: 8),
                  Text('المستخدم: ${widget.userId}'),
                  Text('الدور: ${widget.userRole.name}'),
                  Text(
                    'الحالة: ${RBACService.instance.shouldApplyRBAC(widget.userId) ? 'خاضع لـ RBAC' : 'غير خاضع لـ RBAC'}',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // قسم إدارة المستخدمين (يتطلب صلاحية محددة)
          RbacGuard(
            userId: widget.userId,
            userRole: widget.userRole,
            requiredPermission: const RBACPermission(
              resource: RBACResource.adminUsers,
              action: RBACAction.read,
            ),
            fallback: _buildAccessDeniedScreen(),
            child: _buildUserManagementSection(),
          ),

          const SizedBox(height: 16),

          // قسم التحليلات (يتطلب صلاحية محددة)
          RbacGuard(
            userId: widget.userId,
            userRole: widget.userRole,
            requiredPermission: const RBACPermission(
              resource: RBACResource.opsAnalytics,
              action: RBACAction.read,
            ),
            fallback: _buildAccessDeniedScreen(),
            child: _buildAnalyticsSection(),
          ),

          const SizedBox(height: 16),

          // قسم مراقبة النظام
          _buildSystemMonitoringSection(),

          const SizedBox(height: 16),

          // قسم إحصائيات RBAC
          _buildRBACStatsSection(),
        ],
      ),
    );
  }

  Widget _buildUserManagementSection() {
    final theme = ref.watch(appThemeProvider);
    return Card(
      child: Padding(
        padding: EdgeInsets.all(theme.spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('إدارة المستخدمين', style: theme.typography.headline5),
            const SizedBox(height: 8),
            Text(
              'لديك صلاحية قراءة بيانات المستخدمين',
              style: theme.typography.body2,
            ),
            const SizedBox(height: 16),
            AppButton.primary(
              label: 'عرض المستخدمين',
              expanded: true,
              onPressed: () {
                final AppNoticePresenter presenter =
                    ref.read(appNoticePresenterProvider);
                presenter(
                  AppNotice.info(
                    message: 'جارِ تحميل قائمة المستخدمين...',
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsSection() {
    final theme = ref.watch(appThemeProvider);
    return Card(
      child: Padding(
        padding: EdgeInsets.all(theme.spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('التحليلات والتقارير', style: theme.typography.headline5),
            const SizedBox(height: 8),
            Text('لديك صلاحية الوصول للتحليلات', style: theme.typography.body2),
            const SizedBox(height: 16),
            AppButton.primary(
              label: 'عرض التقارير',
              expanded: true,
              onPressed: () {
                final AppNoticePresenter presenter =
                    ref.read(appNoticePresenterProvider);
                presenter(
                  AppNotice.info(
                    message: 'جارِ تحميل التقارير...',
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemMonitoringSection() {
    final theme = ref.watch(appThemeProvider);
    return Card(
      child: Padding(
        padding: EdgeInsets.all(theme.spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('مراقبة النظام', style: theme.typography.headline5),
            const SizedBox(height: 8),
            Text(
              'لديك صلاحيات كاملة لمراقبة النظام',
              style: theme.typography.body2,
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: AppButton.primary(
                    label: 'فحص الحالة',
                    onPressed: () {
                      final AppNoticePresenter presenter =
                          ref.read(appNoticePresenterProvider);
                      presenter(
                        AppNotice.info(
                          message: 'جارِ فحص حالة النظام...',
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: theme.spacing.sm),
                Expanded(
                  child: AppButton.primary(
                    label: 'عرض السجلات',
                    onPressed: () {
                      final AppNoticePresenter presenter =
                          ref.read(appNoticePresenterProvider);
                      presenter(
                        AppNotice.info(
                          message: 'جارِ عرض السجلات...',
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRBACStatsSection() {
    final theme = ref.watch(appThemeProvider);
    final Map<String, dynamic> stats = RBACService.instance.getStats();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(theme.spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('إحصائيات RBAC', style: theme.typography.headline5),
            const SizedBox(height: 8),
            Text('الحالة: ${stats['enforced'] == true ? 'مفعّل' : 'معطّل'}'),
            Text('نسبة الـ Canary: ${stats['canary_percentage']}%'),
            Text(
              'سياسة الرفض الافتراضي: ${stats['deny_by_default'] == true ? 'مفعّلة' : 'معطّلة'}',
            ),
            Text('عدد الأدوار: ${stats['roles_count']}'),
            Text('إجمالي الصلاحيات: ${stats['total_permissions']}'),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessDeniedScreen() {
    final theme = ref.watch(appThemeProvider);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(theme.spacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.admin_panel_settings,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'الوصول محظور',
              style: theme.typography.headline6.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'ليس لديك صلاحية الوصول إلى لوحة التحكم.\nيُرجى التواصل مع مدير النظام.',
              style: theme.typography.body1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppButton.primary(
              label: 'العودة',
              expanded: true,
              onPressed: () {
                ref.read(navigationServiceProvider).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
