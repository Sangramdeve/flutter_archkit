import 'dart:io';

import '../parser/flavor_config.dart';

/// Generates per-flavor .xcconfig files in ios/Flutter directory.
class IosXcconfigGenerator {
  final List<FlavorConfig> flavors;
  final String projectRoot;

  IosXcconfigGenerator({required this.flavors, required this.projectRoot});

  Future<void> run() async {
    final flavorsDir = Directory('$projectRoot/ios/Flutter');
    if (!await flavorsDir.exists()) {
      await flavorsDir.create(recursive: true);
    }

    const configs = ['Debug', 'Profile', 'Release'];

    for (final flavor in flavors) {
      for (final config in configs) {
        final file = File('${flavorsDir.path}/$config-${flavor.name}.xcconfig');

        final content =
            '''
#include "$config.xcconfig"

FLUTTER_TARGET=lib/main.dart
APP_NAME=${flavor.appName}
BASE_URL=${flavor.baseUrl}
BUNDLE_SUFFIX=${flavor.applicationIdSuffix}
PRODUCT_BUNDLE_IDENTIFIER=\$(BASE_BUNDLE_ID)${flavor.applicationIdSuffix}
''';

        await file.writeAsString(content);
        stdout.writeln('Created ${file.path}');
      }
    }

    // Also write a shared base file
    final baseFile = File('${flavorsDir.path}/Base.xcconfig');
    if (!await baseFile.exists()) {
      await baseFile.writeAsString('''
// Shared base settings across all flavors.
// Set your real bundle id prefix here (must match what's in Xcode > Signing).
BASE_BUNDLE_ID=com.yourcompany.myapp
''');
      stdout.writeln(
        '✏️  Wrote ios/Flutter/Flavors/Base.xcconfig (edit BASE_BUNDLE_ID!)',
      );
    }
  }
}
