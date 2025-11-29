// Path Provider Stub for Testing
// Created by: Cursor A
// Purpose: Fake path_provider implementation for tests
// Last updated: 2025-11-26

import 'dart:io';

import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class FakePathProviderPlatform extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  String? _tempPath;

  @override
  Future<String?> getApplicationDocumentsPath() async {
    _tempPath ??= (await Directory.systemTemp.createTemp('dw_tests_docs')).path;
    return _tempPath;
  }

  @override
  Future<String?> getTemporaryPath() async {
    return Directory.systemTemp.path;
  }

  @override
  Future<String?> getApplicationSupportPath() async {
    _tempPath ??= (await Directory.systemTemp.createTemp('dw_tests_support')).path;
    return _tempPath;
  }

  @override
  Future<String?> getLibraryPath() async {
    return Directory.systemTemp.path;
  }

  @override
  Future<String?> getApplicationCachePath() async {
    return Directory.systemTemp.path;
  }

  @override
  Future<String?> getExternalStoragePath() async {
    return Directory.systemTemp.path;
  }

  @override
  Future<List<String>?> getExternalCachePaths() async {
    return [Directory.systemTemp.path];
  }

  @override
  Future<List<String>?> getExternalStoragePaths({StorageDirectory? type}) async {
    return [Directory.systemTemp.path];
  }

  @override
  Future<String?> getDownloadsPath() async {
    return Directory.systemTemp.path;
  }
}

bool _pathProviderStubbed = false;

/// Sets up fake path_provider for tests.
/// Call this in setUpAll() before any tests that use path_provider.
void ensurePathProviderStubForTests() {
  if (_pathProviderStubbed) return;
  _pathProviderStubbed = true;
  PathProviderPlatform.instance = FakePathProviderPlatform();
}

