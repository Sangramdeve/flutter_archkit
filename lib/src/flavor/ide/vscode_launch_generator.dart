import 'dart:convert';
import 'dart:io';

import '../parser/flavor_config.dart';

/// Generates `.vscode/launch.json` containing debug/profile/release configurations for each flavor.
class VscodeLaunchGenerator {
  final List<FlavorConfig> flavors;
  final String projectRoot;

  VscodeLaunchGenerator({required this.flavors, required this.projectRoot});

  Future<void> run() async {
    final vscodeDir = Directory('$projectRoot/.vscode');
    if (!await vscodeDir.exists()) {
      await vscodeDir.create(recursive: true);
    }

    final launchFile = File('${vscodeDir.path}/launch.json');

    final configurations = <Map<String, dynamic>>[];

    for (final flavor in flavors) {
      final mainPath = 'lib/main_${flavor.name}.dart';

      // 1. Debug mode configuration
      configurations.add({
        'name': '${flavor.name} (Debug)',
        'request': 'launch',
        'type': 'dart',
        'program': mainPath,
        'args': ['--flavor', flavor.name],
      });

      // 2. Profile mode configuration
      configurations.add({
        'name': '${flavor.name} (Profile)',
        'request': 'launch',
        'type': 'dart',
        'flutterMode': 'profile',
        'program': mainPath,
        'args': ['--flavor', flavor.name],
      });

      // 3. Release mode configuration
      configurations.add({
        'name': '${flavor.name} (Release)',
        'request': 'launch',
        'type': 'dart',
        'flutterMode': 'release',
        'program': mainPath,
        'args': ['--flavor', flavor.name],
      });
    }

    final launchData = {'version': '0.2.0', 'configurations': configurations};

    final encoder = JsonEncoder.withIndent('  ');
    await launchFile.writeAsString('${encoder.convert(launchData)}\n');
    stdout.writeln('✏️  Wrote .vscode/launch.json with flavor configurations');
  }
}
