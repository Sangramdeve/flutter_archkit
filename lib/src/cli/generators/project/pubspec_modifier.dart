import 'dart:io';
import 'package:path/path.dart' as p;

class PubspecModifier {
  Future<void> addDependencies(
    String projectPath,
    String stateManagement,
  ) async {
    final pubspecFile = File(p.join(projectPath, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) return;

    final content = pubspecFile.readAsStringSync();
    final depsMap = <String, String>{};

    switch (stateManagement.toLowerCase()) {
      case 'bloc':
      case 'cubit':
        depsMap['flutter_bloc'] = '^8.1.3';
        depsMap['equatable'] = '^2.0.5';
        break;
      case 'riverpod':
        depsMap['flutter_riverpod'] = '^2.5.1';
        break;
      case 'provider':
        depsMap['provider'] = '^6.1.2';
        break;
      case 'getx':
      case 'get':
        depsMap['get'] = '^4.6.6';
        break;
    }

    if (depsMap.isEmpty) return;

    final lines = content.split('\n');
    final newLines = <String>[];

    for (var line in lines) {
      newLines.add(line);
      if (line.trim() == 'dependencies:') {
        for (var entry in depsMap.entries) {
          if (!content.contains('${entry.key}:')) {
            newLines.add('  ${entry.key}: ${entry.value}');
          }
        }
      }
    }

    pubspecFile.writeAsStringSync(newLines.join('\n'));
  }

  Future<void> addRouterDependencies(
    String projectPath,
    String router,
  ) async {
    final pubspecFile = File(p.join(projectPath, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) return;

    var content = pubspecFile.readAsStringSync();
    final depsMap = <String, String>{};
    final devDepsMap = <String, String>{};

    final r = router.toLowerCase();
    if (r.contains('go_router') || r.contains('go router')) {
      depsMap['go_router'] = '^14.2.0';
    } else if (r.contains('auto_route') || r.contains('auto route')) {
      depsMap['auto_route'] = '^9.0.0';
      devDepsMap['auto_route_generator'] = '^9.0.0';
      devDepsMap['build_runner'] = '^2.4.0';
    } else if (r.contains('getx') || r.contains('get')) {
      depsMap['get'] = '^4.6.6';
    }

    if (depsMap.isEmpty && devDepsMap.isEmpty) return;

    var lines = content.split('\n');
    var newLines = <String>[];

    for (var line in lines) {
      newLines.add(line);
      if (line.trim() == 'dependencies:') {
        for (var entry in depsMap.entries) {
          if (!content.contains('${entry.key}:')) {
            newLines.add('  ${entry.key}: ${entry.value}');
          }
        }
      }
    }
    content = newLines.join('\n');

    if (devDepsMap.isNotEmpty) {
      lines = content.split('\n');
      newLines = <String>[];
      var hasDevDeps = lines.any((l) => l.trim() == 'dev_dependencies:');

      if (!hasDevDeps) {
        newLines.addAll(lines);
        newLines.add('');
        newLines.add('dev_dependencies:');
        for (var entry in devDepsMap.entries) {
          newLines.add('  ${entry.key}: ${entry.value}');
        }
      } else {
        for (var line in lines) {
          newLines.add(line);
          if (line.trim() == 'dev_dependencies:') {
            for (var entry in devDepsMap.entries) {
              if (!content.contains('${entry.key}:')) {
                newLines.add('  ${entry.key}: ${entry.value}');
              }
            }
          }
        }
      }
      content = newLines.join('\n');
    }

    pubspecFile.writeAsStringSync(content);
  }

  Future<void> addDIDependencies(String projectPath) async {
    final pubspecFile = File(p.join(projectPath, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) return;

    var content = pubspecFile.readAsStringSync();
    final depsMap = <String, String>{
      'get_it': '^7.6.0',
      'injectable': '^2.3.2',
    };
    final devDepsMap = <String, String>{
      'injectable_generator': '^2.4.1',
      'build_runner': '^2.4.8',
    };

    var lines = content.split('\n');
    var newLines = <String>[];

    for (var line in lines) {
      newLines.add(line);
      if (line.trim() == 'dependencies:') {
        for (var entry in depsMap.entries) {
          if (!content.contains('${entry.key}:')) {
            newLines.add('  ${entry.key}: ${entry.value}');
          }
        }
      }
    }
    content = newLines.join('\n');

    lines = content.split('\n');
    newLines = <String>[];
    var hasDevDeps = lines.any((l) => l.trim() == 'dev_dependencies:');

    if (!hasDevDeps) {
      newLines.addAll(lines);
      newLines.add('');
      newLines.add('dev_dependencies:');
      for (var entry in devDepsMap.entries) {
        newLines.add('  ${entry.key}: ${entry.value}');
      }
    } else {
      for (var line in lines) {
        newLines.add(line);
        if (line.trim() == 'dev_dependencies:') {
          for (var entry in devDepsMap.entries) {
            if (!content.contains('${entry.key}:')) {
              newLines.add('  ${entry.key}: ${entry.value}');
            }
          }
        }
      }
    }
    content = newLines.join('\n');

    pubspecFile.writeAsStringSync(content);
  }

  Future<void> addNetworkDependencies(String projectPath) async {
    final pubspecFile = File(p.join(projectPath, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) return;

    var content = pubspecFile.readAsStringSync();
    final depsMap = <String, String>{
      'dio': '^5.4.3',
    };

    var lines = content.split('\n');
    var newLines = <String>[];

    for (var line in lines) {
      newLines.add(line);
      if (line.trim() == 'dependencies:') {
        for (var entry in depsMap.entries) {
          if (!content.contains('${entry.key}:')) {
            newLines.add('  ${entry.key}: ${entry.value}');
          }
        }
      }
    }
    content = newLines.join('\n');
    pubspecFile.writeAsStringSync(content);
  }

  Future<void> addStorageDependencies(
    String projectPath,
    String storageType,
  ) async {
    final pubspecFile = File(p.join(projectPath, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) return;

    var content = pubspecFile.readAsStringSync();
    final depsMap = <String, String>{};
    final devDepsMap = <String, String>{};

    final type = storageType.toLowerCase();
    if (type.contains('hive')) {
      depsMap['hive'] = '^2.2.3';
      depsMap['hive_flutter'] = '^1.1.0';
      devDepsMap['hive_generator'] = '^2.0.1';
      devDepsMap['build_runner'] = '^2.4.8';
    } else if (type.contains('sqlite') || type.contains('sqflite')) {
      depsMap['sqflite'] = '^2.3.2';
      depsMap['path'] = '^1.9.0';
    } else if (type.contains('drift')) {
      depsMap['drift'] = '^2.16.0';
      depsMap['sqlite3_flutter_libs'] = '^0.5.20';
      depsMap['path_provider'] = '^2.1.2';
      depsMap['path'] = '^1.9.0';
      devDepsMap['drift_dev'] = '^2.16.0';
      devDepsMap['build_runner'] = '^2.4.8';
    } else if (type.contains('objectbox')) {
      depsMap['objectbox'] = '^4.0.0';
      depsMap['objectbox_flutter_libs'] = '^4.0.0';
      depsMap['path_provider'] = '^2.1.2';
      devDepsMap['objectbox_generator'] = '^4.0.0';
      devDepsMap['build_runner'] = '^2.4.8';
    }

    if (depsMap.isEmpty) return;

    var lines = content.split('\n');
    var newLines = <String>[];

    for (var line in lines) {
      newLines.add(line);
      if (line.trim() == 'dependencies:') {
        for (var entry in depsMap.entries) {
          if (!content.contains('${entry.key}:')) {
            newLines.add('  ${entry.key}: ${entry.value}');
          }
        }
      }
    }
    content = newLines.join('\n');

    if (devDepsMap.isNotEmpty) {
      lines = content.split('\n');
      newLines = <String>[];
      var hasDevDeps = lines.any((l) => l.trim() == 'dev_dependencies:');

      if (!hasDevDeps) {
        newLines.addAll(lines);
        newLines.add('');
        newLines.add('dev_dependencies:');
        for (var entry in devDepsMap.entries) {
          newLines.add('  ${entry.key}: ${entry.value}');
        }
      } else {
        for (var line in lines) {
          newLines.add(line);
          if (line.trim() == 'dev_dependencies:') {
            for (var entry in devDepsMap.entries) {
              if (!content.contains('${entry.key}:')) {
                newLines.add('  ${entry.key}: ${entry.value}');
              }
            }
          }
        }
      }
      content = newLines.join('\n');
    }

    pubspecFile.writeAsStringSync(content);
  }
}
