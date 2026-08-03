import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:interact/interact.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:flutter_archkit/src/services/metadata_config_service.dart';
import 'package:flutter_archkit/src/services/process_service.dart';
import 'package:flutter_archkit/src/cli/generators/project/pubspec_modifier.dart';
import 'package:flutter_archkit/src/cli/generators/route/route_generator.dart';

class RouteCommand extends Command<int> {
  @override
  String get name => 'route';

  @override
  List<String> get aliases => const ['r', 'setup-route'];

  @override
  String get description => 'Setup route system for the Flutter project';

  final MetadataConfigService _metadataConfigService;
  final PubspecModifier _pubspecModifier;
  final RouteGenerator _routeGenerator;
  final ProcessService _processService;

  RouteCommand({
    MetadataConfigService? metadataConfigService,
    PubspecModifier? pubspecModifier,
    RouteGenerator? routeGenerator,
    ProcessService? processService,
  })  : _metadataConfigService =
            metadataConfigService ?? MetadataConfigService(),
        _pubspecModifier = pubspecModifier ?? PubspecModifier(),
        _routeGenerator = routeGenerator ?? RouteGenerator(),
        _processService = processService ?? ProcessService() {
    argParser
      ..addOption(
        'type',
        abbr: 't',
        help:
            'Route system (Navigator 1.0, Navigator 2.0, Go Router, Auto Route, GetX Routing)',
      )
      ..addOption(
        'router',
        abbr: 'r',
        help: 'Route system alias for --type',
      );
  }

  @override
  Future<int> run() async {
    final logger = Logger();

    logger.info('${lightGreen.wrap('✔')} Flutter Archkit Route Setup\n');

    final routerChoices = const [
      'Navigator 1.0',
      'Navigator 2.0',
      'Go Router',
      'Auto Route',
      'GetX Routing',
    ];

    String? routerOption =
        argResults?['type'] as String? ?? argResults?['router'] as String?;
    String selectedRouter;

    if (routerOption != null && routerOption.isNotEmpty) {
      final matched = routerChoices.firstWhere(
        (choice) => _matchesOption(choice, routerOption),
        orElse: () => routerOption,
      );
      selectedRouter = matched;
    } else {
      final routerIndex = Select(
        prompt: 'Select Route System',
        options: routerChoices,
        initialIndex: 0,
      ).interact();
      selectedRouter = routerChoices[routerIndex];
    }

    logger.info('${'Route System'.padRight(18)}: $selectedRouter\n');

    final projectPath = Directory.current.path;
    final progress =
        logger.progress('Setting up route system ($selectedRouter)...');

    await _routeGenerator.generate(projectPath, selectedRouter);
    await _pubspecModifier.addRouterDependencies(projectPath, selectedRouter);

    final savedConfig = _metadataConfigService.readConfig(projectPath);
    _metadataConfigService.writeConfig(
      projectPath,
      architecture: savedConfig?.architecture ?? 'Clean',
      stateManagement: savedConfig?.stateManagement ?? 'Bloc',
      router: selectedRouter,
    );

    await _processService.runFlutterPubGet(projectPath: projectPath);

    progress.complete('Route system ($selectedRouter) setup successfully!');
    logger.info('${lightGreen.wrap('✔')} Done!\n');

    return ExitCode.success.code;
  }

  bool _matchesOption(String choice, String input) {
    final c = choice.toLowerCase().replaceAll(' ', '').replaceAll('_', '');
    final i = input.toLowerCase().replaceAll(' ', '').replaceAll('_', '');
    return c.contains(i) || i.contains(c);
  }
}
