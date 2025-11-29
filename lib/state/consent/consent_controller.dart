import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_shims/foundation_shims.dart' as fnd;

class ConsentState {
  final bool analytics;
  final bool crashReports;
  final bool backgroundLocation;
  final bool isLoaded;
  final String? error;

  const ConsentState({
    this.analytics = false,
    this.crashReports = false,
    this.backgroundLocation = false,
    this.isLoaded = false,
    this.error,
  });

  ConsentState copyWith({
    bool? analytics,
    bool? crashReports,
    bool? backgroundLocation,
    bool? isLoaded,
    String? error,
  }) => ConsentState(
    analytics: analytics ?? this.analytics,
    crashReports: crashReports ?? this.crashReports,
    backgroundLocation: backgroundLocation ?? this.backgroundLocation,
    isLoaded: isLoaded ?? this.isLoaded,
    error: error,
  );

  bool get isUnknown => !isLoaded;

  static const ConsentState initial = ConsentState();
}

class ConsentController extends StateNotifier<ConsentState> {
  ConsentController() : super(ConsentState.initial);

  Future<void> load() async {
    try {
      // Load consent settings from foundation_shims
      // For now, we'll use a simple approach - in production this would read from secure storage
      final analytics = fnd.TelemetryConsent.instance.isAllowed;
      final crashReports = fnd.TelemetryConsent.instance.isAllowed;
      const backgroundLocation = false; // Default to false for privacy

      state = ConsentState(
        analytics: analytics,
        crashReports: crashReports,
        backgroundLocation: backgroundLocation,
        isLoaded: true,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoaded: true);
    }
  }

  Future<void> setAnalytics(bool value) async {
    state = state.copyWith(analytics: value);
    await _updateTelemetryConsent();
  }

  Future<void> setCrashReports(bool value) async {
    state = state.copyWith(crashReports: value);
    await _updateTelemetryConsent();
  }

  Future<void> setBackgroundLocation(bool value) async {
    state = state.copyWith(backgroundLocation: value);
    // Background location consent would affect mobility_shims behavior
    // This is handled by the mobility system reading this state
  }

  Future<void> applyAndPersist() async {
    try {
      await _updateTelemetryConsent();
      // In production, this would persist to secure storage
      state = state.copyWith(error: null);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> _updateTelemetryConsent() async {
    // Update foundation_shims TelemetryConsent based on our settings
    // For simplicity, we use analytics OR crash reports as the overall consent
    final overallConsent = state.analytics || state.crashReports;

    if (overallConsent) {
      await fnd.TelemetryConsent.instance.grant();
    } else {
      await fnd.TelemetryConsent.instance.deny();
    }
  }

  Future<void> denyAll() async {
    state = const ConsentState(
      analytics: false,
      crashReports: false,
      backgroundLocation: false,
      isLoaded: true,
    );
    await fnd.TelemetryConsent.instance.deny();
  }

  Future<void> acceptLimited() async {
    // Limited acceptance: only analytics, no crash reports or background location
    state = const ConsentState(
      analytics: true,
      crashReports: false,
      backgroundLocation: false,
      isLoaded: true,
    );
    await _updateTelemetryConsent();
  }
}

final consentControllerProvider =
    StateNotifierProvider<ConsentController, ConsentState>((ref) {
      final controller = ConsentController();
      // Load consent on initialization
      controller.load();
      return controller;
    });

final consentUnknownProvider = Provider<bool>((ref) {
  final state = ref.watch(consentControllerProvider);
  return state.isUnknown;
});
