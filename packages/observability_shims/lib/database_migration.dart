import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class DatabaseMigrationManager {
  Future<int> currentVersion();
  Future<void> migrate({required int targetVersion});
}

class NoopDatabaseMigrationManager implements DatabaseMigrationManager {
  int _version = 0;
  @override
  Future<int> currentVersion() async => _version;

  @override
  Future<void> migrate({required int targetVersion}) async {
    _version = targetVersion;
  }
}

final databaseMigrationManagerProvider = Provider<DatabaseMigrationManager>(
  (_) => NoopDatabaseMigrationManager(),
);
