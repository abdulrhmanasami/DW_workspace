import 'package:delivery_ways_clean/state/infra/realtime_provider.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_shims/realtime_shims.dart';
import 'orders_state.dart';

class OrdersController extends StateNotifier<OrderState> {
  final RealtimeClient _client;
  RealtimeChannel? _channel;
  StreamSubscription<RealtimeEvent>? _sub;

  OrdersController(this._client) : super(const OrderState());

  Future<void> subscribe(String channelName, {String? orderId}) async {
    state = state.copyWith(orderId: orderId);
    await _client.connect();
    _channel = _client.channel(channelName);
    await _channel!.subscribe();
    _sub = _channel!.onEvent().listen(_handleEvent);
  }

  void _handleEvent(RealtimeEvent e) {
    switch (e.type) {
      case 'order_created':
        state = state.copyWith(status: OrderStatus.pending);
        break;
      case 'payment_confirmed':
        state = state.copyWith(status: OrderStatus.paid);
        break;
      case 'order_delivered':
        state = state.copyWith(status: OrderStatus.delivered);
        break;
      case 'order_failed':
        state = state.copyWith(status: OrderStatus.failed);
        break;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _channel?.unsubscribe();
    _client.disconnect();
    super.dispose();
  }
}

final ordersProvider = StateNotifierProvider<OrdersController, OrderState>((
  ref,
) {
  final client = ref.read(realtimeClientProvider);
  return OrdersController(client);
});
