import 'dart:io';

import '../parser/flavor_config.dart';

/// Generates `lib/core/config/server_config.dart` in the consuming project.
class ServerConfigGenerator {
  final List<FlavorConfig> flavors;
  final String projectRoot;

  ServerConfigGenerator({required this.flavors, required this.projectRoot});

  Future<void> run() async {
    _validateFlavors();

    final configFile = File('$projectRoot/lib/core/config/server_config.dart');
    if (!await configFile.parent.exists()) {
      await configFile.parent.create(recursive: true);
    }

    final enumValues = flavors.map((f) => _toEnumName(f.name)).join(', ');

    final switchCases = flavors
        .map((f) {
          final enumName = _toEnumName(f.name);
          return '''      case '${f.name}':
        _currentEnv = ServerEnvironment.$enumName;
        break;''';
        })
        .join('\n');

    final baseUrlCases = flavors
        .map((f) {
          final enumName = _toEnumName(f.name);
          return '''      case ServerEnvironment.$enumName:
        return '${f.baseUrl}';''';
        })
        .join('\n');

    final defaultEnum = flavors.isNotEmpty
        ? _toEnumName(flavors.first.name)
        : 'dev';

    final content =
        '''
import 'dart:developer';
import 'package:flutter/services.dart';

enum ServerEnvironment { $enumValues }

class ServerConfig {
  static final ServerConfig _instance = ServerConfig._internal();

  ServerEnvironment _currentEnv = ServerEnvironment.$defaultEnum;

  factory ServerConfig() {
    return _instance;
  }

  ServerConfig._internal();

  Future<void> init() async {
    final flavor = appFlavor;

    switch (flavor) {
$switchCases
      default:
        _currentEnv = ServerEnvironment.$defaultEnum;
    }

    log(
      'ServerConfig initialized with environment: \${_currentEnv.name} (flavor: \$flavor)',
    );
  }

  ServerEnvironment get currentEnv => _currentEnv;

  String get baseUrl {
    switch (_currentEnv) {
$baseUrlCases
    }
  }
}
''';

    await configFile.writeAsString(content);
    stdout.writeln('✏️  Wrote lib/core/config/server_config.dart');
  }

  /// Ensures no two flavors collapse onto the same enum name (e.g. `prod`
  /// and `production` both mapping to `production`), and that every flavor
  /// has a non-empty base URL, before we generate invalid Dart.
  void _validateFlavors() {
    if (flavors.isEmpty) {
      throw ArgumentError(
        'ServerConfigGenerator requires at least one flavor to generate '
        'server_config.dart.',
      );
    }

    final seen = <String, String>{}; // enumName -> original flavor name
    for (final f in flavors) {
      final enumName = _toEnumName(f.name);

      final existing = seen[enumName];
      if (existing != null) {
        throw ArgumentError(
          "Flavor '${f.name}' maps to the same enum value '$enumName' as "
          "flavor '$existing'. Rename one of them so they don't collide "
          'in the generated ServerEnvironment enum.',
        );
      }
      seen[enumName] = f.name;

      if (f.baseUrl.trim().isEmpty) {
        throw ArgumentError(
          "Flavor '${f.name}' has an empty baseUrl. Every flavor needs a "
          'base URL to generate ServerConfig.baseUrl.',
        );
      }
    }
  }

  String _toEnumName(String flavorName) {
    if (flavorName == 'prod' || flavorName == 'production') {
      return 'production';
    }
    final sanitized = flavorName.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    if (RegExp(r'^[0-9]').hasMatch(sanitized)) {
      return 'flavor_$sanitized';
    }
    return sanitized;
  }
}
