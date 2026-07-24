import 'parser/flavor_config.dart';
import 'android/android_flavor_generator.dart';
import 'ios/ios_flavor_generator.dart';
import 'ide/vscode_launch_generator.dart';
import 'config/server_config_generator.dart';

/// Handles writing/updating flavor-related files in the CONSUMING app:
/// - android/app/build.gradle.kts
/// - ios/Runner/Info.plist (optional, simpler var substitution)
/// - lib/core/config/server_config.dart configuration
/// - lib/main_<flavor>.dart entry points
/// - .vscode/launch.json configurations
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
    // final serverConfigGen = ServerConfigGenerator(
    //   flavors: flavors,
    //   projectRoot: projectRoot,
    // );
    // await serverConfigGen.run();

    // 4. Generate Dart main entry points
    // await _generateMainEntryPoints();

    // 5. Generate VS Code launch configurations
    final vscodeGen = VscodeLaunchGenerator(
      flavors: flavors,
      projectRoot: projectRoot,
    );
    await vscodeGen.run();

    print(
      '✅ Flavor setup complete for: ${flavors.map((f) => f.name).join(', ')}',
    );
  }

  //   // ---------------------------------------------------------------------
  //   // lib/main_<flavor>.dart entry points
  //   // ---------------------------------------------------------------------
  //   Future<void> _generateMainEntryPoints() async {
  //     final file = File('$projectRoot/lib/main.dart');

  //     if (!await file.exists()) return;

  //     var content = await file.readAsString();

  //     // Don't insert it twice.
  //     if (content.contains('ServerConfig();')) {
  //       print('✓ ServerConfig already exists in main.dart');
  //       return;
  //     }

  //     content = content.replaceFirst(
  //       'WidgetsFlutterBinding.ensureInitialized();',
  //       '''
  // WidgetsFlutterBinding.ensureInitialized();

  //   final serverConfig = ServerConfig();
  //   await serverConfig.init();
  // ''',
  //     );

  //     await file.writeAsString(content);

  //     print('✓ Updated lib/main.dart');
  //   }
}
