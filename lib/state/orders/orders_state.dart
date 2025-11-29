enum OrderStatus { pending, paid, failed, delivered, canceled }

class OrderState {
  final String? orderId;
  final OrderStatus status;
  const OrderState({this.orderId, this.status = OrderStatus.pending});
  OrderState copyWith({String? orderId, OrderStatus? status}) => OrderState(
    orderId: orderId ?? this.orderId,
    status: status ?? this.status,
  );
}
