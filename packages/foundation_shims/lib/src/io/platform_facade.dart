/// PlatformFacade — compile‑ready (no SDK logic)
library;

abstract class PlatformFacade {
  const PlatformFacade();

  bool get isAndroid => false;
  bool get isIOS => false;
  String get operatingSystem => 'unknown';
}
