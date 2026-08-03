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
}
