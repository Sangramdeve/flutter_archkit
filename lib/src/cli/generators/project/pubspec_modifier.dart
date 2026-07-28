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
}
