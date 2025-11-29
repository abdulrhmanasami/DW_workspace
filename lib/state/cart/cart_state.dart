class CartState {
  final int itemCount;
  final double total;
  final String currency;
  const CartState({
    this.itemCount = 0,
    this.total = 0.0,
    this.currency = 'USD',
  });
  CartState copyWith({int? itemCount, double? total, String? currency}) =>
      CartState(
        itemCount: itemCount ?? this.itemCount,
        total: total ?? this.total,
        currency: currency ?? this.currency,
      );
}
