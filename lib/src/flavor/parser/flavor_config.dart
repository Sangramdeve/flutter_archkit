/// Represents a single build flavor (dev, staging, prod, etc.)
class FlavorConfig {
  final String name; // e.g. "dev"
  final String appName; // e.g. "MyApp Dev"
  final String applicationIdSuffix; // e.g. ".dev" (empty string for prod)
  final String baseUrl; // e.g. "https://dev.api.example.com"

  const FlavorConfig({
    required this.name,
    required this.appName,
    required this.applicationIdSuffix,
    required this.baseUrl,
  });

  Map<String, String> toTemplateVars() => {
    'FLAVOR_NAME': name,
    'APP_NAME': appName,
    'APP_ID_SUFFIX': applicationIdSuffix,
    'BASE_URL': baseUrl,
  };
}
