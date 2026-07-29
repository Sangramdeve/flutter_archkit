import 'dart:convert';
import 'dart:io';

import '../parser/flavor_config.dart';

/// Generates `.vscode/launch.json` containing flavor launch configurations.
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

    List<dynamic> existingConfigurations = [];
    if (await launchFile.exists()) {
      try {
        final content = await launchFile.readAsString();
        final decoded = jsonDecode(content);
        if (decoded is Map<String, dynamic> && decoded['configurations'] is List) {
          existingConfigurations = List.from(decoded['configurations']);
        }
      } catch (_) {
        // If file is invalid JSON, we'll recreate clean
      }
    }

    // Retain any non-flavor configurations manually added by user
    final flavorNames = flavors.map((f) => f.name).toSet();
    final retainedConfigurations = existingConfigurations.where((c) {
      if (c is Map<String, dynamic>) {
        return !flavorNames.contains(c['name']);
      }
      return true;
    }).toList();

    final flavorConfigurations = <Map<String, dynamic>>[];
    for (final flavor in flavors) {
      flavorConfigurations.add({
        'name': flavor.name,
        'type': 'dart',
        'request': 'launch',
        'args': ['--flavor', flavor.name],
      });
    }

    final combinedConfigurations = [
      ...flavorConfigurations,
      ...retainedConfigurations,
    ];

    final launchData = {
      'version': '0.2.0',
      'configurations': combinedConfigurations,
    };

    final encoder = JsonEncoder.withIndent('    ');
    await launchFile.writeAsString('${encoder.convert(launchData)}\n');
    stdout.writeln('✏️  Wrote .vscode/launch.json with flavor configurations');
  }
}
