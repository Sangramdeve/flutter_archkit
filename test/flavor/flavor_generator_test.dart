import 'dart:io';
import 'package:flutter_archkit/src/flavor/parser/flavor_config.dart';
import 'package:flutter_archkit/src/flavor/parser/flavor_exceptions.dart';
import 'package:flutter_archkit/src/flavor/parser/flavor_yaml_loader.dart';
import 'package:flutter_archkit/src/flavor/flavor_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('flavor_generator_test_');
  });

  tearDown(() async {
    try {
      await tempDir.delete(recursive: true);
    } catch (_) {}
  });

  test('generates flavor files correctly', () async {
    // 1. Create mock directory structure for Android & iOS
    final androidAppDir = Directory('${tempDir.path}/android/app');
    await androidAppDir.create(recursive: true);

    final buildGradleFile = File('${androidAppDir.path}/build.gradle.kts');
    await buildGradleFile.writeAsString(
      '// Original build.gradle.kts content\n',
    );

    final iosFlutterDir = Directory('${tempDir.path}/ios/Flutter');
    await iosFlutterDir.create(recursive: true);

    final debugXcconfig = File('${iosFlutterDir.path}/Debug.xcconfig');
    await debugXcconfig.writeAsString('// Original Debug.xcconfig\n');

    final releaseXcconfig = File('${iosFlutterDir.path}/Release.xcconfig');
    await releaseXcconfig.writeAsString('// Original Release.xcconfig\n');

    final iosRunnerDir = Directory('${tempDir.path}/ios/Runner');
    await iosRunnerDir.create(recursive: true);

    final infoPlistFile = File('${iosRunnerDir.path}/Info.plist');
    await infoPlistFile.writeAsString('''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
</dict>
</plist>
''');

    final xcodeprojDir = Directory('${tempDir.path}/ios/Runner.xcodeproj');
    await xcodeprojDir.create(recursive: true);

    final pbxprojFile = File('${xcodeprojDir.path}/project.pbxproj');
    await pbxprojFile.writeAsString('''// !*UTF8*!
{
	objects = {
/* Begin PBXFileReference section */
		9740EEB21CF90195004384FC /* Debug.xcconfig */ = {isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = text.xcconfig; name = Debug.xcconfig; path = Flutter/Debug.xcconfig; sourceTree = "<group>"; };
		7AFA3C8E1D35360C0083082E /* Release.xcconfig */ = {isa = PBXFileReference; lastKnownFileType = text.xcconfig; name = Release.xcconfig; path = Flutter/Release.xcconfig; sourceTree = "<group>"; };
/* End PBXFileReference section */

/* Begin PBXGroup section */
		9740EEB11CF90186004384FC /* Flutter */ = {
			isa = PBXGroup;
			children = (
				9740EEB21CF90195004384FC /* Debug.xcconfig */,
				7AFA3C8E1D35360C0083082E /* Release.xcconfig */,
			);
			name = Flutter;
			sourceTree = "<group>";
		};
/* End PBXGroup section */

/* Begin XCBuildConfiguration section */
		97C147031CF9000F007C117D /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				PRODUCT_NAME = "\$(TARGET_NAME)";
			};
			name = Debug;
		};
		97C147041CF9000F007C117D /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				PRODUCT_NAME = "\$(TARGET_NAME)";
			};
			name = Release;
		};
		249021D3217E4FDB00AE95B9 /* Profile */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				PRODUCT_NAME = "\$(TARGET_NAME)";
			};
			name = Profile;
		};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		97C146E91CF9000F007C117D /* Build configuration list for PBXProject "Runner" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				97C147031CF9000F007C117D /* Debug */,
				97C147041CF9000F007C117D /* Release */,
				249021D3217E4FDB00AE95B9 /* Profile */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
/* End XCConfigurationList section */
	};
}
''');

    // 2. Instantiate and run FlavorGenerator
    final flavors = [
      FlavorConfig(
        name: 'dev',
        appName: 'MyApp Dev',
        applicationIdSuffix: '.dev',
        baseUrl: 'https://dev.api.example.com',
      ),
      FlavorConfig(
        name: 'prod',
        appName: 'MyApp',
        applicationIdSuffix: '',
        baseUrl: 'https://api.example.com',
      ),
    ];

    final generator = FlavorGenerator(
      flavors: flavors,
      projectRoot: tempDir.path,
    );

    await generator.run();

    // 3. Verify flavor.gradle.kts creation and contents
    final flavorGradleFile = File('${androidAppDir.path}/flavor.gradle.kts');
    expect(await flavorGradleFile.exists(), isTrue);
    final flavorGradleContent = await flavorGradleFile.readAsString();
    expect(flavorGradleContent, contains('create("dev")'));
    expect(flavorGradleContent, contains('create("prod")'));
    expect(flavorGradleContent, contains('applicationIdSuffix = ".dev"'));
    expect(flavorGradleContent, contains('applicationIdSuffix = ""'));

    // 4. Verify build.gradle.kts updates
    expect(await buildGradleFile.exists(), isTrue);
    final buildGradleContent = await buildGradleFile.readAsString();
    expect(
      buildGradleContent,
      contains(
        '// ----- BEGIN flavorDimensions (autogenerated by flutter_archkit) -----',
      ),
    );
    expect(buildGradleContent, contains('apply { from("flavor.gradle.kts") }'));
    expect(
      buildGradleContent,
      contains('// <<< autogenerated FLAVOR_CONFIG_END'),
    );

    // 5. Verify iOS flavor config files creation and contents
    final baseXcconfig = File('${iosFlutterDir.path}/Base.xcconfig');
    expect(await baseXcconfig.exists(), isTrue);

    final devDebugXcconfig = File('${iosFlutterDir.path}/Debug-dev.xcconfig');
    expect(await devDebugXcconfig.exists(), isTrue);
    final devDebugContent = await devDebugXcconfig.readAsString();
    expect(devDebugContent, contains('#include "Debug.xcconfig"'));
    expect(devDebugContent, contains('APP_NAME=MyApp Dev'));
    expect(devDebugContent, contains('BUNDLE_SUFFIX=.dev'));

    // 6. Verify iOS Scheme files creation
    final schemesDir = Directory(
      '${tempDir.path}/ios/Runner.xcodeproj/xcshareddata/xcschemes',
    );
    expect(await schemesDir.exists(), isTrue);

    final devSchemeFile = File('${schemesDir.path}/dev.xcscheme');
    expect(await devSchemeFile.exists(), isTrue);
    final devSchemeContent = await devSchemeFile.readAsString();
    expect(devSchemeContent, contains('buildConfiguration = "Debug-dev"'));
    expect(devSchemeContent, contains('buildConfiguration = "Release-dev"'));

    final prodSchemeFile = File('${schemesDir.path}/prod.xcscheme');
    expect(await prodSchemeFile.exists(), isTrue);

    // 7. Verify Info.plist updates
    final plistContent = await infoPlistFile.readAsString();
    expect(plistContent, contains('<key>CFBundleDisplayName</key>'));
    expect(plistContent, contains('<string>\$(APP_NAME)</string>'));
    expect(plistContent, contains('<key>BaseURL</key>'));
    expect(plistContent, contains('<string>\$(BASE_URL)</string>'));

    // 8. Verify project.pbxproj updates
    final pbxprojContent = await pbxprojFile.readAsString();
    expect(pbxprojContent, contains('Debug-dev.xcconfig'));
    expect(pbxprojContent, contains('Debug-dev */ = {'));
    expect(pbxprojContent, contains('name = "Debug-dev";'));
    expect(pbxprojContent, contains('/* Debug-dev */,'));

    // 9. Verify lib/main_<flavor>.dart creation
    for (final flavor in flavors) {
      final mainFile = File('${tempDir.path}/lib/main_${flavor.name}.dart');
      expect(await mainFile.exists(), isTrue);
      final mainContent = await mainFile.readAsString();
      expect(mainContent, contains("import 'main.dart' as app;"));
      expect(mainContent, contains("app.main();"));
    }

    // 10. Verify lib/core/config/server_config.dart creation
    final serverConfigFile = File(
      '${tempDir.path}/lib/core/config/server_config.dart',
    );
    expect(await serverConfigFile.exists(), isTrue);
    final serverConfigContent = await serverConfigFile.readAsString();
    expect(serverConfigContent, contains('class ServerConfig'));
    expect(serverConfigContent, contains('enum ServerEnvironment'));

    // 10. Verify .vscode/launch.json creation
    final vscodeLaunchFile = File('${tempDir.path}/.vscode/launch.json');
    expect(await vscodeLaunchFile.exists(), isTrue);
    final vscodeLaunchContent = await vscodeLaunchFile.readAsString();
    expect(vscodeLaunchContent, contains('"name": "dev (Debug)"'));
    expect(vscodeLaunchContent, contains('"program": "lib/main_dev.dart"'));
    expect(
      vscodeLaunchContent,
      contains('"args": [\n        "--flavor",\n        "dev"\n      ]'),
    );
  });

  test(
    'replaces existing gradle block on subsequent runs without duplication',
    () async {
      final androidAppDir = Directory('${tempDir.path}/android/app');
      await androidAppDir.create(recursive: true);

      final buildGradleFile = File('${androidAppDir.path}/build.gradle.kts');
      await buildGradleFile.writeAsString(
        '// Original build.gradle.kts content\n',
      );

      final flavors = [
        FlavorConfig(
          name: 'dev',
          appName: 'MyApp Dev',
          applicationIdSuffix: '.dev',
          baseUrl: 'https://dev.api.example.com',
        ),
      ];

      final generator = FlavorGenerator(
        flavors: flavors,
        projectRoot: tempDir.path,
      );

      // Run first time
      await generator.run();
      final content1 = await buildGradleFile.readAsString();

      // Run second time
      await generator.run();
      final content2 = await buildGradleFile.readAsString();

      expect(content1, content2);
      expect(
        '// ----- BEGIN flavorDimensions (autogenerated by flutter_archkit) -----'
            .allMatches(content2)
            .length,
        equals(1),
      );
    },
  );

  group('YAML Flavor Parsing & Loading', () {
    test('FlavorYamlLoader parses valid map format YAML correctly', () async {
      final yamlContent = '''
flavors:
  dev:
    appName: "YAML Map Dev"
    applicationIdSuffix: ".map.dev"
    baseUrl: "https://dev.api.example.com"
  prod:
    appName: "YAML Map Prod"
    applicationIdSuffix: ""
    baseUrl: "https://api.example.com"
''';
      final yamlFile = File('${tempDir.path}/flavor.yaml');
      await yamlFile.writeAsString(yamlContent);

      final loader = FlavorYamlLoader(
        projectRoot: tempDir.path,
        fileName: 'flavor.yaml',
      );
      final loaded = await loader.load();

      expect(loaded.length, equals(2));

      final devConfig = loaded.firstWhere((f) => f.name == 'dev');
      expect(devConfig.appName, equals('YAML Map Dev'));
      expect(devConfig.applicationIdSuffix, equals('.map.dev'));
      expect(devConfig.baseUrl, equals('https://dev.api.example.com'));

      final prodConfig = loaded.firstWhere((f) => f.name == 'prod');
      expect(prodConfig.appName, equals('YAML Map Prod'));
      expect(prodConfig.applicationIdSuffix, equals(''));
      expect(prodConfig.baseUrl, equals('https://api.example.com'));
    });

    test(
      'FlavorYamlLoader throws exception on missing or empty config',
      () async {
        final loader = FlavorYamlLoader(
          projectRoot: tempDir.path,
          fileName: 'flavor.yaml',
        );
        expect(() => loader.load(), throwsA(isA<FlavorConfigException>()));
      },
    );
  });
}
