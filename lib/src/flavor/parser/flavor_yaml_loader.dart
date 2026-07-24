import 'dart:io';
import 'package:yaml/yaml.dart';
import 'flavor_config.dart';
import 'flavor_exceptions.dart';

/// Loads flavor definitions from a yaml file (default: flavor.yaml at the
/// project root) and converts them into a List<FlavorConfig>.
///
/// Expected file shape:
/// ```yaml
/// flavors:
///   dev:
///     appName: "MyApp Dev"
///     applicationIdSuffix: ".dev"
///     baseUrl: "https://dev.api.example.com"
///   prod:
///     appName: "MyApp"
///     applicationIdSuffix: ""
///     baseUrl: "https://api.example.com"
/// ```
class FlavorYamlLoader {
  final String projectRoot;
  final String fileName;

  FlavorYamlLoader({this.projectRoot = '.', this.fileName = 'flavor.yaml'});

  String get _path => '$projectRoot/$fileName';

  /// Reads and parses the yaml file.
  /// Throws [FlavorYamlNotFoundException], [FlavorYamlEmptyException],
  /// or [FlavorYamlParseException] on failure.
  Future<List<FlavorConfig>> load() async {
    final file = File(_path);

    if (!await file.exists()) {
      throw FlavorYamlNotFoundException(_path);
    }

    final raw = await file.readAsString();

    late final YamlDocument doc;
    try {
      doc = loadYamlDocument(raw);
    } on YamlException catch (e) {
      throw FlavorYamlParseException('invalid YAML syntax in "$_path" — $e');
    }

    final root = doc.contents.value;
    if (root is! YamlMap || !root.containsKey('flavors')) {
      throw FlavorYamlEmptyException(_path);
    }

    final flavorsNode = root['flavors'];
    if (flavorsNode is! YamlMap || flavorsNode.isEmpty) {
      throw FlavorYamlEmptyException(_path);
    }

    final result = <FlavorConfig>[];

    for (final entry in flavorsNode.entries) {
      final name = entry.key.toString();
      final value = entry.value;

      if (value is! YamlMap) {
        throw FlavorYamlParseException(
          'flavor "$name" must be a map with appName / applicationIdSuffix '
          '/ baseUrl keys',
        );
      }

      final appName = value['appName'];
      final baseUrl = value['baseUrl'];
      // applicationIdSuffix is optional (prod usually has none)
      final applicationIdSuffix = value['applicationIdSuffix'] ?? '';

      if (appName == null || appName is! String) {
        throw FlavorYamlParseException(
          'flavor "$name" is missing a required "appName" string',
        );
      }
      if (baseUrl == null || baseUrl is! String) {
        throw FlavorYamlParseException(
          'flavor "$name" is missing a required "baseUrl" string',
        );
      }
      if (applicationIdSuffix is! String) {
        throw FlavorYamlParseException(
          'flavor "$name" has a non-string "applicationIdSuffix"',
        );
      }

      result.add(
        FlavorConfig(
          name: name,
          appName: appName,
          applicationIdSuffix: applicationIdSuffix,
          baseUrl: baseUrl,
        ),
      );
    }

    return result;
  }
}
