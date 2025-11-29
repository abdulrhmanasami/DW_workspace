/// Integration test for SQLite migration safety
/// BL-102-005: SQLite Migration Failures mitigation test
/// Component: Database Migration Test
/// Created by: Cursor (auto-generated)
/// Purpose: Verify safe migration handling and idempotent operations
/// Last updated: 2025-11-04

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foundation_shims/foundation_shims.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as path_utils;
import 'package:sqflite/sqflite.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('SQLite Migration Safety', () {
    late Database database;
    late DatabaseMigrationManager migrationManager;
    late String dbPath;

    setUpAll(() async {
      // Create test database
      final dbDir = await getDatabasesPath();
      dbPath = path_utils.join(dbDir, 'test_migration.db');

      // Ensure clean state
      if (await databaseExists(dbPath)) {
        await deleteDatabase(dbPath);
      }

      database = await openDatabase(
        dbPath,
        version: 1,
        onCreate: (db, version) async {
          // Initial schema
          await db.execute('''
            CREATE TABLE users (
              id INTEGER PRIMARY KEY,
              name TEXT NOT NULL,
              email TEXT UNIQUE
            )
          ''');
        },
      );

      // Create NoOpTelemetry for testing
      final telemetry = NoOpTelemetry();
      migrationManager = DatabaseMigrationManager(database, telemetry);

      await migrationManager.initialize();
    });

    tearDownAll(() async {
      await database.close();
      if (await databaseExists(dbPath)) {
        await deleteDatabase(dbPath);
      }
    });

    testWidgets('Migration manager initializes correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));

      final status = await migrationManager.getMigrationStatus();

      expect(status['latest_version'], equals(0));
      expect(status['applied_count'], equals(0));
      expect(status['applied_versions'], isEmpty);
    });

    testWidgets('Idempotent migrations work correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));

      // Define test migration
      final migration = Migration(
        version: 1,
        description: 'Add age column to users table',
        up: (txn) async {
          await MigrationHelpers.addColumnIfNotExists(
            txn,
            'users',
            'age',
            'INTEGER DEFAULT 0',
          );
        },
        down: (txn) async {
          await txn.execute('ALTER TABLE users DROP COLUMN age');
        },
        requiredTables: ['users'],
      );

      // Apply migration first time
      await migrationManager.applyMigrations([migration]);

      // Verify migration was applied
      final status1 = await migrationManager.getMigrationStatus();
      expect(status1['latest_version'], equals(1));
      expect(status1['applied_count'], equals(1));

      // Check that column was added
      final columns = await database.rawQuery('PRAGMA table_info(users)');
      final columnNames = columns.map((col) => col['name'] as String).toList();
      expect(columnNames, contains('age'));

      // Apply same migration again (should be idempotent)
      await migrationManager.applyMigrations([migration]);

      // Verify still only one application
      final status2 = await migrationManager.getMigrationStatus();
      expect(status2['latest_version'], equals(1));
      expect(status2['applied_count'], equals(1));
    });

    testWidgets('Migration validation works', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));

      // Migration that requires non-existent table
      final failingMigration = Migration(
        version: 2,
        description: 'Test migration with missing table',
        up: (txn) async {
          await txn.execute('CREATE TABLE test_table (id INTEGER PRIMARY KEY)');
        },
        requiredTables: ['non_existent_table'], // This should fail validation
      );

      // This should fail pre-validation
      expect(
        () => migrationManager.applyMigrations([failingMigration]),
        throwsException,
      );
    });

    testWidgets('Migration helpers work correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));

      await database.transaction((txn) async {
        // Test createTableIfNotExists (idempotent)
        await MigrationHelpers.createTableIfNotExists(
          txn,
          'test_table',
          'id INTEGER PRIMARY KEY, name TEXT',
        );

        // Verify table was created
        final tables = await txn.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='test_table'",
        );
        expect(tables.length, equals(1));

        // Try to create same table again (should not fail)
        await MigrationHelpers.createTableIfNotExists(
          txn,
          'test_table',
          'id INTEGER PRIMARY KEY, name TEXT',
        );

        // Test addColumnIfNotExists (idempotent)
        await MigrationHelpers.addColumnIfNotExists(
          txn,
          'test_table',
          'email',
          'TEXT',
        );

        // Verify column was added
        final columns = await txn.rawQuery('PRAGMA table_info(test_table)');
        final columnNames = columns
            .map((col) => col['name'] as String)
            .toList();
        expect(columnNames, contains('email'));

        // Try to add same column again (should not fail)
        await MigrationHelpers.addColumnIfNotExists(
          txn,
          'test_table',
          'email',
          'TEXT',
        );
      });
    });

    testWidgets('Complex migration with data migration', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));

      await database.transaction((txn) async {
        // Insert test data
        await txn.insert('users', {
          'name': 'John Doe',
          'email': 'john@example.com',
        });

        // Create new table
        await MigrationHelpers.createTableIfNotExists(
          txn,
          'user_profiles',
          'id INTEGER PRIMARY KEY, user_id INTEGER, bio TEXT, FOREIGN KEY (user_id) REFERENCES users(id)',
        );

        // Migrate data safely
        await MigrationHelpers.migrateDataSafely(
          txn,
          'users',
          'user_profiles',
          {'id': 'user_id'},
        );

        // Verify data was migrated
        final migratedData = await txn.query('user_profiles');
        expect(migratedData.length, equals(1));
        expect(migratedData.first['user_id'], equals(1));
      });
    });

    testWidgets('Migration rollback works', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));

      // Migration that will succeed then we test rollback mechanism
      final reversibleMigration = Migration(
        version: 3,
        description: 'Add test table for rollback test',
        up: (txn) async {
          await MigrationHelpers.createTableIfNotExists(
            txn,
            'rollback_test',
            'id INTEGER PRIMARY KEY, data TEXT',
          );
        },
        down: (txn) async {
          await txn.execute('DROP TABLE IF EXISTS rollback_test');
        },
      );

      await migrationManager.applyMigrations([reversibleMigration]);

      // Verify table exists
      final tables = await database.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='rollback_test'",
      );
      expect(tables.length, equals(1));

      // Test rollback by deleting migration record and re-applying
      // (simulating what happens in rollback)
      await database.transaction((txn) async {
        await reversibleMigration.down!(txn);
      });

      // Verify table was dropped
      final tablesAfter = await database.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='rollback_test'",
      );
      expect(tablesAfter.length, equals(0));
    });
  });
}

/// NoOp Telemetry for testing
class NoOpTelemetry implements Telemetry {
  @override
  Future<void> logEvent(
    String eventName, [
    Map<String, dynamic>? parameters,
  ]) async {
    // No-op for testing
  }

  @override
  Future<void> error(String message, {Map<String, dynamic>? context}) async {
    // No-op for testing
  }

  @override
  Future<void> setUserId(String? userId) async {
    // No-op for testing
  }

  @override
  Future<TelemetrySpan> startTrace(String name) async {
    return NoOpTelemetrySpan(name, DateTime.now());
  }

  @override
  Future<void> setUserProperty(String name, dynamic value) async {
    // No-op for testing
  }
}

class NoOpTelemetrySpan implements TelemetrySpan {
  @override
  final String name;

  @override
  final DateTime startTime;

  NoOpTelemetrySpan(this.name, this.startTime);

  @override
  Future<void> setAttributes(Map<String, String> attributes) async {
    // No-op for testing
  }

  @override
  Future<void> setStatus(String status, [String? description]) async {
    // No-op for testing
  }

  @override
  Future<void> stop() async {
    // No-op for testing
  }
}
