import 'dart:io';

import '../parser/flavor_config.dart';

/// Generates `lib/core/config/server_config.dart` in the consuming project.
class ServerConfigGenerator {
  final List<FlavorConfig> flavors;
  final String projectRoot;

  ServerConfigGenerator({required this.flavors, required this.projectRoot});

  Future<void> run() async {
    final configFile = File('$projectRoot/lib/core/config/server_config.dart');
    if (!await configFile.parent.exists()) {
      await configFile.parent.create(recursive: true);
    }

    final enumValues = flavors.map((f) => _toEnumName(f.name)).join(', ');

    final envCases = flavors
        .map((f) {
          final enumName = _toEnumName(f.name);
          return '''
    } else if (flavor == '${f.name}') {
      _currentEnv = ServerEnvironment.$enumName;''';
        })
        .join('');

    final baseUrlCases = flavors
        .map((f) {
          final enumName = _toEnumName(f.name);
          return '''
      case ServerEnvironment.$enumName:
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

    if (flavor == null || flavor.isEmpty) {
      _currentEnv = ServerEnvironment.$defaultEnum;
    }$envCases
    } else {
      _currentEnv = ServerEnvironment.$defaultEnum; // Default fallback
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

  String _toEnumName(String flavorName) {
    if (flavorName == 'prod' || flavorName == 'production') {
      return 'production';
    }
    return flavorName;
  }
}
