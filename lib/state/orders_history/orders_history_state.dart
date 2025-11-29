import 'package:delivery_ways_clean/state/orders/orders_state.dart';

class OrderEvent {
  final String type;
  final DateTime ts;
  const OrderEvent(this.type, this.ts);
}

class OrdersHistoryState {
  final String? selectedOrderId;
  final List<OrderEvent> events;
  final OrderStatus status;
  const OrdersHistoryState({
    this.selectedOrderId,
    this.events = const [],
    this.status = OrderStatus.pending,
  });
  OrdersHistoryState copyWith({
    String? selectedOrderId,
    List<OrderEvent>? events,
    OrderStatus? status,
  }) => OrdersHistoryState(
    selectedOrderId: selectedOrderId ?? this.selectedOrderId,
    events: events ?? this.events,
    status: status ?? this.status,
  );
}
