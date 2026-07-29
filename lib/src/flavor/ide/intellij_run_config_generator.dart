import 'dart:io';

import '../parser/flavor_config.dart';

/// Generates `.run/<flavor>.run.xml` run configurations for Android Studio / IntelliJ IDEA.
class IntellijRunConfigGenerator {
  final List<FlavorConfig> flavors;
  final String projectRoot;

  IntellijRunConfigGenerator({
    required this.flavors,
    required this.projectRoot,
  });

  Future<void> run() async {
    final runDir = Directory('$projectRoot/.run');
    if (!await runDir.exists()) {
      await runDir.create(recursive: true);
    }

    for (final flavor in flavors) {
      final file = File('${runDir.path}/${flavor.name}.run.xml');
      final xmlContent = '''<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="${flavor.name}" type="FlutterRunConfigurationType" factoryName="Flutter">
    <option name="additionalArgs" value="--flavor ${flavor.name}" />
    <option name="filePath" value="\$PROJECT_DIR\$/lib/main.dart" />
    <method v="2" />
  </configuration>
</component>
''';

      await file.writeAsString(xmlContent);
      stdout.writeln('✏️  Wrote .run/${flavor.name}.run.xml for Android Studio');
    }
  }
}
