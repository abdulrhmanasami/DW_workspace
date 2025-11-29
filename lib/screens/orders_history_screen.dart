/// Component: OrdersHistoryScreen
/// Created by: Cursor (UX-005: List virtualization + Loading states)
/// Purpose: Display historical orders with fail-closed policy and enhanced UX
/// Last updated: 2025-11-25

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/config_manager.dart';
import '../l10n/generated/app_localizations.dart';
import '../state/orders_history/providers.dart';
import '../state/orders_history/orders_history_state.dart';
import '../widgets/in_app_hint_banner.dart';
import 'package:b_ui/ui_components.dart';
import 'package:b_ux/guidance_ux.dart';

class OrdersHistoryScreen extends ConsumerStatefulWidget {
  const OrdersHistoryScreen({super.key});

  @override
  ConsumerState<OrdersHistoryScreen> createState() => _OrdersHistoryScreenState();
}

class _OrdersHistoryScreenState extends ConsumerState<OrdersHistoryScreen> {
  bool _isLoading = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Simulate initial loading delay for UX
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    // Trigger provider refresh
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() => _isRefreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Fail-closed: Check backend availability
    if (!AppConfig.canUseBackendFeature()) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n?.ordersHistoryTitle ?? 'Order History')),
        body: UiUnavailableFeature(
          title: l10n?.ordersHistoryUnavailableTitle ?? 'Orders Unavailable',
          message: AppConfig.backendPolicyMessage,
          icon: Icons.history_outlined,
        ),
      );
    }

    final ordersHistory = ref.watch(ordersHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.ordersHistoryTitle ?? 'Order History'),
        actions: [
          IconButton(
            icon: _isRefreshing
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.onSurface,
                    ),
                  )
                : const Icon(Icons.refresh),
            onPressed: _isRefreshing ? null : _handleRefresh,
            tooltip: l10n?.retry ?? 'Refresh',
          ),
        ],
      ),
      body: UiAnimatedStateTransition(
        child: _buildBody(context, ordersHistory, l10n),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    OrdersHistoryState ordersHistory,
    AppLocalizations? l10n,
  ) {
    // Loading state with skeleton
    if (_isLoading) {
      return const _OrdersHistoryLoadingSkeleton(key: ValueKey('loading'));
    }

    // Empty state
    if (ordersHistory.events.isEmpty) {
      return _buildEmptyState(context, l10n);
    }

    // List with virtualization (ListView.builder already provides this)
    return _buildOrdersList(context, ordersHistory, l10n);
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations? l10n) {
    // Show orders empty hint
    final hint = OrderHints.emptyState;
    
    return Column(
      key: const ValueKey('empty'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Empty state hint with CTA
        InAppHintBanner(
          hint: hint,
          onPrimaryCta: () {
            // Navigate to browse/home to place first order
            Navigator.of(context).pushNamed('/');
          },
        ),
        const SizedBox(height: 24),
        UiEmptyState(
          icon: Icons.receipt_long_outlined,
          title: l10n?.ordersHistoryEmptyTitle ?? 'No orders yet',
          subtitle: l10n?.ordersHistoryEmptySubtitle ?? 
              'Your order history will appear here once you place an order.',
        ),
      ],
    );
  }

  Widget _buildOrdersList(
    BuildContext context,
    OrdersHistoryState ordersHistory,
    AppLocalizations? l10n,
  ) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView.separated(
        key: ValueKey('list_${ordersHistory.events.length}'),
        padding: const EdgeInsets.all(16),
        itemCount: ordersHistory.events.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        // Using ListView.separated for virtualization
        itemBuilder: (context, index) {
          final event = ordersHistory.events[index];
          return _OrderEventCard(
            event: event,
            onTap: () {
              // TODO: Navigate to order details
            },
          );
        },
      ),
    );
  }
}

/// Order event card widget
class _OrderEventCard extends StatelessWidget {
  const _OrderEventCard({
    required this.event,
    required this.onTap,
  });

  final OrderEvent event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getEventIcon(event.type),
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatEventType(event.type),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDateTime(event.ts),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getEventIcon(String type) {
    switch (type) {
      case 'order_created':
        return Icons.add_shopping_cart;
      case 'payment_confirmed':
        return Icons.payment;
      case 'order_delivered':
        return Icons.check_circle;
      case 'order_failed':
        return Icons.error;
      default:
        return Icons.receipt;
    }
  }

  String _formatEventType(String type) {
    switch (type) {
      case 'order_created':
        return 'Order Created';
      case 'payment_confirmed':
        return 'Payment Confirmed';
      case 'order_delivered':
        return 'Order Delivered';
      case 'order_failed':
        return 'Order Failed';
      default:
        return type.replaceAll('_', ' ').split(' ').map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1);
        }).join(' ');
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}

/// Skeleton loading state for orders history
class _OrdersHistoryLoadingSkeleton extends StatelessWidget {
  const _OrdersHistoryLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const UiSkeletonList(
      itemCount: 5,
      itemHeight: 88,
      spacing: 12,
    );
  }
}
