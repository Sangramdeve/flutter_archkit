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

    final configurations = <Map<String, dynamic>>[];

    for (final flavor in flavors) {
      configurations.add({
        'name': flavor.name,
        'type': 'dart',
        'request': 'launch',
        'args': ['--flavor', flavor.name],
      });
    }

    final launchData = {'version': '0.2.0', 'configurations': configurations};

    final encoder = JsonEncoder.withIndent('    ');
    await launchFile.writeAsString('${encoder.convert(launchData)}\n');
    stdout.writeln('✏️  Wrote .vscode/launch.json with flavor configurations');
  }
}
