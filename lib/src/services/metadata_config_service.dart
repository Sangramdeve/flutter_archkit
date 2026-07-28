import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

class MetadataConfig {
  final String architecture;
  final String stateManagement;

  const MetadataConfig({
    required this.architecture,
    required this.stateManagement,
  });
}

class MetadataConfigService {
  MetadataConfig? readConfig(String projectPath) {
    var dir = Directory(projectPath);
    while (dir.path != dir.parent.path) {
      final metadataFile = File(p.join(dir.path, '.metadata'));
      if (metadataFile.existsSync()) {
        try {
          final content = metadataFile.readAsStringSync();
          final yaml = loadYaml(content);
          if (yaml is Map && yaml.containsKey('archkit')) {
            final archkitNode = yaml['archkit'];
            if (archkitNode is Map) {
              final arch = archkitNode['architecture']?.toString();
              final sm = archkitNode['state_management']?.toString();
              if (arch != null && arch.isNotEmpty && sm != null && sm.isNotEmpty) {
                return MetadataConfig(
                  architecture: arch,
                  stateManagement: sm,
                );
              }
            }
          }
        } catch (_) {}
      }
      dir = dir.parent;
    }
    return null;
  }

  void writeConfig(
    String projectPath, {
    required String architecture,
    required String stateManagement,
  }) {
    final metadataFile = File(p.join(projectPath, '.metadata'));
    var content = metadataFile.existsSync() ? metadataFile.readAsStringSync() : '';

    final archkitBlock = '''

archkit:
  architecture: $architecture
  state_management: $stateManagement
''';

    if (content.contains('archkit:')) {
      final lines = content.split('\n');
      final newLines = <String>[];
      var inArchkit = false;

      for (var line in lines) {
        if (line.trim().startsWith('archkit:')) {
          inArchkit = true;
          continue;
        }
        if (inArchkit) {
          if (line.startsWith('  ') || line.trim().isEmpty) {
            continue;
          } else {
            inArchkit = false;
          }
        }
        newLines.add(line);
      }
      content = '${newLines.join('\n').trimRight()}$archkitBlock';
    } else {
      content = '${content.trimRight()}$archkitBlock';
    }

    metadataFile.writeAsStringSync(content);
  }
}
