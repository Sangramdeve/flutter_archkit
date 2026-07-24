import 'dart:io';

import 'package:flutter_archkit/src/flavor/flavor_generator.dart';
import 'package:flutter_archkit/src/flavor/parser/flavor_exceptions.dart';
import 'package:flutter_archkit/src/flavor/parser/flavor_yaml_loader.dart';

/// Usage:
///   dart run flutter_archkit:setup_flavor
///   dart run flutter_archkit:setup_flavor --config=custom_flavor.yaml
Future<void> main(List<String> args) async {
  final configArg = args.firstWhere(
    (a) => a.startsWith('--config='),
    orElse: () => '',
  );
  final fileName = configArg.isNotEmpty
      ? configArg.split('=').last
      : 'flavor.yaml';

  final projectRoot = Directory.current.path;
  final loader = FlavorYamlLoader(projectRoot: projectRoot, fileName: fileName);

  try {
    final flavors = await loader.load();

    print(
      '🚀 Loaded ${flavors.length} flavor(s) from $fileName: '
      '${flavors.map((f) => f.name).join(', ')}',
    );

    final generator = FlavorGenerator(
      flavors: flavors,
      projectRoot: projectRoot,
    );

    await generator.run();
  } on FlavorConfigException catch (e) {
    // Friendly, expected failures (missing file, bad yaml, etc.)
    stderr.writeln(e.toString());
    exit(1);
  } catch (e, stack) {
    // Anything unexpected — surface it plainly rather than swallowing it.
    stderr.writeln('❌ Unexpected error while setting up flavors: $e');
    stderr.writeln(stack);
    exit(1);
  }
}
