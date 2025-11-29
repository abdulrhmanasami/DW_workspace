enum CheckoutStatus { idle, processing, success, failure }

class CheckoutState {
  final CheckoutStatus status;
  final String? orderId; // معرف فقط، لا نموذج دوميني
  const CheckoutState({this.status = CheckoutStatus.idle, this.orderId});
  CheckoutState copyWith({CheckoutStatus? status, String? orderId}) =>
      CheckoutState(
        status: status ?? this.status,
        orderId: orderId ?? this.orderId,
      );
}
