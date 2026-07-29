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
        '       app:\n'
        '         name: "MyApp Dev"\n'
        '         baseUrl: "https://dev-api.example.com"\n'
        '       android:\n'
        '         applicationId: "com.example.myapp.dev"\n'
        '       ios:\n'
        '         bundleId: "com.example.myapp.dev"\n'
        '     prod:\n'
        '       app:\n'
        '         name: "MyApp"\n'
        '         baseUrl: "https://api.example.com"\n'
        '       android:\n'
        '         applicationId: "com.example.myapp"\n'
        '       ios:\n'
        '         bundleId: "com.example.myapp"\n',
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
