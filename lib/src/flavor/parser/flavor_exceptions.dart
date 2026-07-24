/// Base type for all flavor-config-related failures.
sealed class FlavorConfigException implements Exception {
  final String message;
  const FlavorConfigException(this.message);

  @override
  String toString() => message;
}

/// Thrown when no flavor.yaml (or custom path) exists in the project.
class FlavorYamlNotFoundException extends FlavorConfigException {
  final String path;

  FlavorYamlNotFoundException(this.path)
    : super(
        '❌ Flavor config file not found at "$path".\n'
        '   Create one at the root of your Flutter project, e.g.:\n\n'
        '   flavors:\n'
        '     dev:\n'
        '       appName: "MyApp Dev"\n'
        '       applicationIdSuffix: ".dev"\n'
        '       baseUrl: "https://dev.api.example.com"\n'
        '     prod:\n'
        '       appName: "MyApp"\n'
        '       applicationIdSuffix: ""\n'
        '       baseUrl: "https://api.example.com"\n',
      );
}

/// Thrown when flavor.yaml exists but is empty, has no `flavors:` root key,
/// or the root key is not a map.
class FlavorYamlEmptyException extends FlavorConfigException {
  FlavorYamlEmptyException(String path)
    : super(
        '❌ "$path" was found but has no usable `flavors:` section.\n'
        '   Make sure the file has a top-level `flavors:` map with at '
        'least one entry.',
      );
}

/// Thrown when the yaml is malformed (bad syntax) or a specific flavor
/// entry is missing required fields.
class FlavorYamlParseException extends FlavorConfigException {
  FlavorYamlParseException(String details)
    : super('❌ Failed to parse flavor config: $details');
}
