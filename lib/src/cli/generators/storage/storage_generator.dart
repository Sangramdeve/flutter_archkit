import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:flutter_archkit/src/cli/generators/project/pubspec_modifier.dart';
import 'package:flutter_archkit/src/cli/generators/templates/storage/storage_templates.dart';

class StorageGenerator {
  final PubspecModifier _pubspecModifier;

  StorageGenerator({PubspecModifier? pubspecModifier})
      : _pubspecModifier = pubspecModifier ?? PubspecModifier();

  Future<void> generate(
    String projectPath,
    String storageType, {
    bool override = true,
  }) async {
    final packageName = _getPackageName(projectPath);
    final storageDir = p.join(projectPath, 'lib', 'core', 'storage');

    final type = storageType.toLowerCase();

    if (type.contains('hive')) {
      _writeFile(
        p.join(storageDir, 'hive_storage_service.dart'),
        StorageTemplates.hiveServiceTemplate(),
        override: override,
      );
    } else if (type.contains('sqlite') || type.contains('sqflite')) {
      _writeFile(
        p.join(storageDir, 'database_helper.dart'),
        StorageTemplates.sqliteHelperTemplate(),
        override: override,
      );
    } else if (type.contains('drift')) {
      _writeFile(
        p.join(storageDir, 'app_database.dart'),
        StorageTemplates.driftDatabaseTemplate(packageName),
        override: override,
      );
    } else if (type.contains('objectbox')) {
      _writeFile(
        p.join(storageDir, 'objectbox_store.dart'),
        StorageTemplates.objectBoxStoreTemplate(packageName),
        override: override,
      );
    }

    await _pubspecModifier.addStorageDependencies(projectPath, storageType);
  }

  String _getPackageName(String projectPath) {
    final pubspecFile = File(p.join(projectPath, 'pubspec.yaml'));
    if (pubspecFile.existsSync()) {
      final content = pubspecFile.readAsStringSync();
      final match =
          RegExp(r'^name:\s*([a-z0-9_]+)', multiLine: true).firstMatch(content);
      if (match != null && match.group(1) != null) {
        return match.group(1)!;
      }
    }
    return 'my_app';
  }

  void _writeFile(String filePath, String content, {bool override = true}) {
    final file = File(filePath);
    if (!override && file.existsSync()) return;
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(content);
  }
}
