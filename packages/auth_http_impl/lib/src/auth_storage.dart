// Auth Secure Storage Implementation
// Created by: CEN-AUTH001 Implementation
// Purpose: Secure storage abstraction for authentication data
// Last updated: 2025-11-25 (CENT-004: Removed unused imports)

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Abstract interface for secure storage operations
abstract class AuthSecureStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
  Future<void> deleteAll();
}

/// Flutter Secure Storage implementation
class FlutterSecureAuthStorage implements AuthSecureStorage {
  FlutterSecureAuthStorage({
    FlutterSecureStorage? secureStorage,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;

  static const _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  static const _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  );

  @override
  Future<String?> read(String key) async {
    try {
      return await _secureStorage.read(
        key: key,
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );
    } catch (e) {
      // Handle storage errors gracefully
      return null;
    }
  }

  @override
  Future<void> write(String key, String value) async {
    try {
      await _secureStorage.write(
        key: key,
        value: value,
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );
    } catch (e) {
      // Handle storage errors
      rethrow;
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      await _secureStorage.delete(
        key: key,
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );
    } catch (e) {
      // Handle storage errors gracefully
    }
  }

  @override
  Future<void> deleteAll() async {
    try {
      await _secureStorage.deleteAll(
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );
    } catch (e) {
      // Handle storage errors gracefully
    }
  }
}

/// Creates default secure storage instance
AuthSecureStorage createAuthSecureStorage() {
  return FlutterSecureAuthStorage();
}
