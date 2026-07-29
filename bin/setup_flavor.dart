import 'dart:io';

import 'package:flutter_archkit/src/flavor/flavor_generator.dart';
import 'package:flutter_archkit/src/flavor/parser/flavor_exceptions.dart';
import 'package:flutter_archkit/src/flavor/parser/flavor_yaml_loader.dart';

/// Usage:
///   dart run flutter_archkit:setup_flavor
///   dart run flutter_archkit:setup_flavor --config=custom_flavor.yaml
///   dart run flutter_archkit:setup_flavor --validate
///   dart run flutter_archkit:setup_flavor --init
Future<void> main(List<String> args) async {
  if (args.contains('--init')) {
    final defaultFile = File('flavor.yaml');
    if (await defaultFile.exists()) {
      stdout.writeln('⚠️ flavor.yaml already exists at project root.');
      return;
    }
    await defaultFile.writeAsString('''flavors:
  dev:
    app:
      name: "Example Dev"
      baseUrl: "https://dev-api.example.com"
    android:
      applicationId: "com.example.app.dev"
    ios:
      bundleId: "com.example.app.dev"

  prod:
    app:
      name: "Example"
      baseUrl: "https://api.example.com"
    android:
      applicationId: "com.example.app"
    ios:
      bundleId: "com.example.app"
''');
    stdout.writeln('✨ Created sample flavor.yaml at project root.');
    return;
  }

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

    stdout.writeln(
      '🚀 Loaded ${flavors.length} flavor(s) from $fileName: '
      '${flavors.map((f) => f.name).join(', ')}',
    );

    if (args.contains('--validate')) {
      stdout.writeln('✅ Configuration in $fileName is valid!');
      return;
    }

    final generator = FlavorGenerator(
      flavors: flavors,
      projectRoot: projectRoot,
    );

    await generator.run();
  } on FlavorConfigException catch (e) {
    stderr.writeln(e.toString());
    exit(1);
  } catch (e, stack) {
    stderr.writeln('❌ Unexpected error while setting up flavors: $e');
    stderr.writeln(stack);
    exit(1);
  }
}
