/// Represents a single build flavor (dev, staging, prod, etc.)
class FlavorConfig {
  final String name; // e.g. "dev"
  final String appName; // e.g. "MyApp Dev"
  final String applicationId; // e.g. "com.example.app.dev"
  final String bundleId; // e.g. "com.example.app.dev"
  final String baseUrl; // e.g. "https://dev.api.example.com"

  const FlavorConfig({
    required this.name,
    required this.appName,
    required this.applicationId,
    required this.bundleId,
    required this.baseUrl,
  });

  Map<String, String> toTemplateVars() => {
    'FLAVOR_NAME': name,
    'APP_NAME': appName,
    'APPLICATION_ID': applicationId,
    'BUNDLE_ID': bundleId,
    'BASE_URL': baseUrl,
  };
}
