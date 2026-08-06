import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_archkit/src/cli/generators/storage/storage_generator.dart';

void main() {
  group('StorageGenerator Test', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('storage_test_');
      final pubspecFile = File(p.join(tempDir.path, 'pubspec.yaml'));
      pubspecFile.writeAsStringSync('''
name: test_storage_app
description: A test Flutter app for storage
dependencies:
  flutter:
    sdk: flutter
''');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('generates Hive setup correctly', () async {
      final generator = StorageGenerator();
      await generator.generate(tempDir.path, 'Hive');

      final hiveFile = File(
        p.join(tempDir.path, 'lib', 'core', 'storage', 'hive_storage_service.dart'),
      );
      expect(hiveFile.existsSync(), isTrue);
      expect(hiveFile.readAsStringSync(), contains('class HiveStorageService'));

      final pubspecFile = File(p.join(tempDir.path, 'pubspec.yaml'));
      expect(pubspecFile.readAsStringSync(), contains('hive: ^2.2.3'));
    });

    test('generates SQLite setup correctly', () async {
      final generator = StorageGenerator();
      await generator.generate(tempDir.path, 'SQLite');

      final sqliteFile = File(
        p.join(tempDir.path, 'lib', 'core', 'storage', 'database_helper.dart'),
      );
      expect(sqliteFile.existsSync(), isTrue);
      expect(sqliteFile.readAsStringSync(), contains('class DatabaseHelper'));

      final pubspecFile = File(p.join(tempDir.path, 'pubspec.yaml'));
      expect(pubspecFile.readAsStringSync(), contains('sqflite: ^2.3.2'));
    });

    test('generates Drift setup correctly', () async {
      final generator = StorageGenerator();
      await generator.generate(tempDir.path, 'Drift');

      final driftFile = File(
        p.join(tempDir.path, 'lib', 'core', 'storage', 'app_database.dart'),
      );
      expect(driftFile.existsSync(), isTrue);
      expect(driftFile.readAsStringSync(), contains('class AppDatabase'));

      final pubspecFile = File(p.join(tempDir.path, 'pubspec.yaml'));
      expect(pubspecFile.readAsStringSync(), contains('drift: ^2.16.0'));
    });

    test('generates ObjectBox setup correctly', () async {
      final generator = StorageGenerator();
      await generator.generate(tempDir.path, 'ObjectBox');

      final objectboxFile = File(
        p.join(tempDir.path, 'lib', 'core', 'storage', 'objectbox_store.dart'),
      );
      expect(objectboxFile.existsSync(), isTrue);
      expect(objectboxFile.readAsStringSync(), contains('class ObjectBoxStore'));

      final pubspecFile = File(p.join(tempDir.path, 'pubspec.yaml'));
      expect(pubspecFile.readAsStringSync(), contains('objectbox: ^4.0.0'));
    });
  });
}
