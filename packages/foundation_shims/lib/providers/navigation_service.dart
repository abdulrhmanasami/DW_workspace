/// Navigation Service Riverpod Providers

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Navigator Key Provider
final navigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((_) {
  return GlobalKey<NavigatorState>();
});

/// Navigation Service Provider
final navigationServiceProvider = Provider<NavigationService>((ref) {
  final key = ref.watch(navigatorKeyProvider);
  return NavigationService(key);
});

/// Navigation Service Helper Class
class NavigationService {
  final GlobalKey<NavigatorState> key;

  NavigationService(this.key);

  NavigatorState? get nav => key.currentState;

  Future<T?> push<T>(Route<T> route) => nav?.push(route) ?? Future.value(null);

  void pop<T extends Object?>([T? result]) => nav?.pop(result);
}
