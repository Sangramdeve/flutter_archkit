class ProjectConfig {
  final String name;
  final String architecture;
  final String stateManagement;
  final String organization;
  final List<String> platforms;
  final String? router;
  final bool useDi;

  const ProjectConfig({
    required this.name,
    required this.architecture,
    required this.stateManagement,
    required this.organization,
    required this.platforms,
    this.router,
    this.useDi = false,
  });
}
