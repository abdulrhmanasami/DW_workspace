import 'package:delivery_ways_clean/state/infra/realtime_provider.dart';
import 'package:delivery_ways_clean/state/orders/orders_state.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_shims/realtime_shims.dart';
import 'orders_history_state.dart';

class OrdersHistoryController extends StateNotifier<OrdersHistoryState> {
  final RealtimeClient _client;
  RealtimeChannel? _ch;
  StreamSubscription<RealtimeEvent>? _sub;

  OrdersHistoryController(this._client) : super(const OrdersHistoryState());

  Future<void> selectOrder(String orderId) async {
    state = state.copyWith(selectedOrderId: orderId);
  }

  Future<void> subscribe() async {
    await _client.connect();
    _ch = _client.channel('orders');
    await _ch!.subscribe();
    _sub = _ch!.onEvent().listen((e) {
      final ev = OrderEvent(e.type, e.timestamp);
      final list = List<OrderEvent>.from(state.events)..add(ev);
      state = state.copyWith(events: list, status: _mapEventToStatus(e.type));
    });
  }

  OrderStatus _mapEventToStatus(String t) {
    switch (t) {
      case 'order_created':
        return OrderStatus.pending;
      case 'payment_confirmed':
        return OrderStatus.paid;
      case 'order_delivered':
        return OrderStatus.delivered;
      case 'order_failed':
        return OrderStatus.failed;
      default:
        return state.status;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _ch?.unsubscribe();
    _client.disconnect();
    super.dispose();
  }
}

final ordersHistoryProvider =
    StateNotifierProvider<OrdersHistoryController, OrdersHistoryState>((ref) {
      final client = ref.read(realtimeClientProvider);
      return OrdersHistoryController(client);
    });
