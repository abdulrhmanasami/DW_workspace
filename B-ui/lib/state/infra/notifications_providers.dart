import 'dart:async';
import 'dart:io' as io;
import 'dart:ui' as ui;

import 'package:auth_http_impl/auth_http_impl.dart';
import 'package:auth_shims/auth_shims.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:foundation_shims/foundation_shims.dart';
import 'package:notifications_shims/notifications_shims.dart';

import 'notifications_backend_client.dart';

const _deviceIdPrefsKey = 'notifications.device_id';

final authSessionRepositoryProvider = Provider<AuthSessionRepository>((ref) {
  return createAuthSessionRepository();
});

final authStateProvider = StreamProvider<AuthState>((ref) async* {
  final repository = ref.watch(authSessionRepositoryProvider);
  var current = await repository.loadAuthState();
  yield current;

  await for (final _ in Stream.periodic(const Duration(seconds: 15))) {
    final next = await repository.loadAuthState();
    if (next != current) {
      current = next;
      yield next;
    }
  }
});

final notificationsBackendClientProvider = Provider<NotificationsBackendClient>(
  (ref) {
    final configManager = ConfigManager.instance;
    final authRepository = ref.watch(authSessionRepositoryProvider);
    final httpClient = http.Client();

    ref.onDispose(httpClient.close);

    return NotificationsHttpBackendClient(
      configManager: configManager,
      httpClient: httpClient,
      authTokenProvider: () async {
        final authState = await authRepository.loadAuthState();
        return authState.session?.accessToken;
      },
    );
  },
);

final notificationDeviceIdProvider = FutureProvider<String>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final existing = prefs.getString(_deviceIdPrefsKey);
  if (existing != null && existing.isNotEmpty) {
    return existing;
  }

  const uuid = Uuid();
  final generated = uuid.v4();
  await prefs.setString(_deviceIdPrefsKey, generated);
  return generated;
});

final notificationDeviceMetadataProvider =
    FutureProvider<NotificationDeviceMetadata>((ref) async {
      final appInfo = await ref.watch(appInfoProvider.future);
      final deviceId = await ref.watch(notificationDeviceIdProvider.future);
      final authStateAsync = ref.watch(authStateProvider);
      final userId = authStateAsync.maybeWhen(
        data: (state) => state.session?.user.id,
        orElse: () => null,
      );

      final platform = switch (defaultTargetPlatform) {
        TargetPlatform.iOS => 'ios',
        TargetPlatform.android => 'android',
        TargetPlatform.macOS => 'macos',
        TargetPlatform.windows => 'windows',
        TargetPlatform.linux => 'linux',
        TargetPlatform.fuchsia => 'fuchsia',
      };

      final locale = ui.PlatformDispatcher.instance.locale;

      return NotificationDeviceMetadata(
        platform: platform,
        appVersion: appInfo.version,
        deviceId: deviceId,
        buildNumber: appInfo.buildNumber,
        locale: locale.toLanguageTag(),
        osVersion: io.Platform.operatingSystemVersion,
        userId: userId,
      );
    });

/// Provider for push notifications service.
final pushNotificationServiceProvider = Provider<PushNotificationService>((
  ref,
) {
  final consentGranted = TelemetryConsent.instance.isAllowed;
  if (!consentGranted) {
    return const NoOpPushNotificationService();
  }

  final backendClient = ref.watch(notificationsBackendClientProvider);
  final service = createFirebasePushNotificationService(
    backendClient: backendClient,
    metadataProvider: () => ref.read(notificationDeviceMetadataProvider.future),
  );

  ref.onDispose(service.dispose);
  return service;
});

/// Provider for notification preferences repository.
final notificationPreferencesRepositoryProvider =
    Provider<NotificationPreferencesRepository>((ref) {
      final backendClient = ref.watch(notificationsBackendClientProvider);
      return createNotificationPreferencesRepository(
        backendClient: backendClient,
      );
    });

final notificationTokenLifecycleProvider = Provider<void>((ref) {
  final service = ref.watch(pushNotificationServiceProvider);
  final backendClient = ref.watch(notificationsBackendClientProvider);

  ref.listen<AsyncValue<AuthState>>(authStateProvider, (prev, next) {
    next.whenData((state) {
      if (state.isAuthenticated) {
        unawaited(service.syncTokenWithBackend());
      } else if (prev?.value?.isAuthenticated == true) {
        unawaited(() async {
          final token = await service.getFcmToken();
          if (token == null) return;
          final metadata = await ref.read(
            notificationDeviceMetadataProvider.future,
          );
          await backendClient.unregisterDeviceToken(
            token: token,
            metadata: metadata,
          );
        }());
      }
    });
  });
});

/// Kickstarts push notifications initialization + permission flow.
final notificationsInitProvider = FutureProvider<void>((ref) async {
  ref.watch(notificationTokenLifecycleProvider);

  final service = ref.watch(pushNotificationServiceProvider);
  await service.init();
  await service.requestUserPermission();

  // Warm up preferences to avoid null states in UI.
  final prefsRepo = ref.watch(notificationPreferencesRepositoryProvider);
  final prefs = await prefsRepo.load();
  await prefsRepo.save(prefs);
});

/// Loads current notification preferences for UI consumers.
final notificationPreferencesProvider =
    FutureProvider<NotificationPreferences>((ref) async {
      final repository = ref.watch(notificationPreferencesRepositoryProvider);
      return repository.load();
    });

PushNotificationService createFirebasePushNotificationService({
  required NotificationsBackendClient backendClient,
  required Future<NotificationDeviceMetadata> Function() metadataProvider,
}) {
  return _LocalPushNotificationService(
    backendClient: backendClient,
    metadataProvider: metadataProvider,
  );
}

NotificationPreferencesRepository createNotificationPreferencesRepository({
  required NotificationsBackendClient backendClient,
}) {
  return _BackendSyncedNotificationPreferencesRepository(
    backendClient: backendClient,
  );
}

class _LocalPushNotificationService implements PushNotificationService {
  _LocalPushNotificationService({
    required NotificationsBackendClient backendClient,
    required Future<NotificationDeviceMetadata> Function() metadataProvider,
  })  : _backendClient = backendClient,
        _metadataProvider = metadataProvider,
        _foregroundController =
            StreamController<IncomingNotification>.broadcast(),
        _tapController = StreamController<IncomingNotification>.broadcast();

  final NotificationsBackendClient _backendClient;
  final Future<NotificationDeviceMetadata> Function() _metadataProvider;
  final StreamController<IncomingNotification> _foregroundController;
  final StreamController<IncomingNotification> _tapController;
  NotificationPermissionStatus _permission =
      NotificationPermissionStatus.notDetermined;
  String? _token;

  @override
  Future<void> init() async {
    _token ??= 'local-${DateTime.now().microsecondsSinceEpoch}';
  }

  @override
  Future<NotificationPermissionStatus> requestUserPermission() async {
    _permission = NotificationPermissionStatus.granted;
    await syncTokenWithBackend();
    return _permission;
  }

  @override
  Future<String?> getFcmToken() async => _token;

  @override
  Future<NotificationPermissionStatus> getPermissionStatus() async =>
      _permission;

  @override
  Future<bool> isSupported() async => true;

  @override
  Future<void> syncTokenWithBackend() async {
    final token = _token;
    if (token == null) return;
    final metadata = await _metadataProvider();
    await _backendClient.registerDeviceToken(
      token: token,
      metadata: metadata,
    );
  }

  @override
  Stream<IncomingNotification> get onForegroundNotification =>
      _foregroundController.stream;

  @override
  Stream<IncomingNotification> get onNotificationTap =>
      _tapController.stream;

  @override
  Future<void> dispose() async {
    await _foregroundController.close();
    await _tapController.close();
  }
}

class _BackendSyncedNotificationPreferencesRepository
    implements NotificationPreferencesRepository {
  _BackendSyncedNotificationPreferencesRepository({
    required NotificationsBackendClient backendClient,
  }) : _backendClient = backendClient;

  final NotificationsBackendClient _backendClient;
  NotificationPreferences _cache = const NotificationPreferences.defaults();

  @override
  Future<NotificationPreferences> load() async => _cache;

  @override
  Future<void> save(NotificationPreferences preferences) async {
    _cache = preferences;
    await _backendClient.updateUserNotificationPreferences(preferences);
  }

  @override
  Future<void> updateChannelPreference(
    NotificationChannel channel,
    bool enabled,
  ) async {
    switch (channel) {
      case NotificationChannel.orderUpdates:
        _cache = _cache.copyWith(orderStatusUpdatesEnabled: enabled);
        break;
      case NotificationChannel.promotions:
        _cache = _cache.copyWith(promotionsEnabled: enabled);
        break;
      case NotificationChannel.system:
        _cache = _cache.copyWith(systemAlertsEnabled: enabled);
        break;
    }
    await save(_cache);
  }

  @override
  Future<void> resetToDefaults() async {
    _cache = const NotificationPreferences.defaults();
    await save(_cache);
  }

  @override
  Future<bool> isChannelEnabled(NotificationChannel channel) async {
    return switch (channel) {
      NotificationChannel.orderUpdates => _cache.orderStatusUpdatesEnabled,
      NotificationChannel.promotions => _cache.promotionsEnabled,
      NotificationChannel.system => _cache.systemAlertsEnabled,
    };
  }
}
