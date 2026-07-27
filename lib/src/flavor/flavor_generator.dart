import 'dart:io';

import 'android/android_flavor_generator.dart';
import 'config/server_config_generator.dart';
import 'ide/vscode_launch_generator.dart';
import 'ios/ios_flavor_generator.dart';
import 'parser/flavor_config.dart';

/// Handles writing/updating flavor-related files in the consuming app:
/// - `android/app/build.gradle.kts`
/// - `ios/Runner/Info.plist`
/// - `lib/core/config/server_config.dart` configuration
/// - `.vscode/launch.json` configurations
class FlavorGenerator {
  final List<FlavorConfig> flavors;
  final String projectRoot;

  FlavorGenerator({required this.flavors, this.projectRoot = '.'});

  Future<void> run() async {
    // 1. Generate Android configurations
    final androidGen = AndroidFlavorGenerator(
      flavors: flavors,
      projectRoot: projectRoot,
    );
    await androidGen.run();

    // 2. Generate iOS configurations
    final iosGen = IosFlavorGenerator(
      flavors: flavors,
      projectRoot: projectRoot,
    );
    await iosGen.run();

    // 3. Generate ServerConfig (lib/core/config/server_config.dart)
    final serverConfigGen = ServerConfigGenerator(
      flavors: flavors,
      projectRoot: projectRoot,
    );
    await serverConfigGen.run();

    // 4. Update Dart main entry point
    await _updateMainEntryPoint();

    // 5. Generate VS Code launch configurations
    final vscodeGen = VscodeLaunchGenerator(
      flavors: flavors,
      projectRoot: projectRoot,
    );
    await vscodeGen.run();

    stdout.writeln(
      '✅ Flavor setup complete for: ${flavors.map((f) => f.name).join(', ')}',
    );
  }

  // ---------------------------------------------------------------------
  // lib/main.dart entry point update
  // ---------------------------------------------------------------------
  Future<void> _updateMainEntryPoint() async {
    final mainFile = File('$projectRoot/lib/main.dart');
    if (await mainFile.exists()) {
      var content = await mainFile.readAsString();

      if (!content.contains('ServerConfig();')) {
        content = content.replaceFirst(
          'WidgetsFlutterBinding.ensureInitialized();',
          '''WidgetsFlutterBinding.ensureInitialized();

  final serverConfig = ServerConfig();
  await serverConfig.init();
''',
        );
        await mainFile.writeAsString(content);
        stdout.writeln('✓ Updated lib/main.dart');
      }
    }
  }
}
