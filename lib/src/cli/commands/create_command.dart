import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:interact/interact.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_archkit/src/models/project_config.dart';
import 'package:flutter_archkit/src/cli/generators/project/project_generator.dart';

class CreateCommand extends Command<int> {
  @override
  String get name => 'create';

  @override
  String get description => 'Create a new Flutter project';

  final ProjectGenerator _projectGenerator;

  CreateCommand({ProjectGenerator? projectGenerator})
      : _projectGenerator = projectGenerator ?? ProjectGenerator() {
    argParser
      ..addOption('org', help: 'Organization identifier (e.g. com.example)')
      ..addOption('architecture', help: 'Architecture (Clean, MVVM, MVC)')
      ..addOption(
        'state-management',
        help: 'State management (Bloc, Riverpod, Provider, GetX)',
      )
      ..addOption(
        'platforms',
        help: 'Comma-separated platforms (android,ios,web,windows,macos,linux)',
      );
  }

  @override
  Future<int> run() async {
    final logger = Logger();

    logger.info('${lightGreen.wrap('✔')} Flutter Archkit\n');

    // 1. Project Name
    String? projectName;
    if (argResults?.rest.isNotEmpty == true) {
      projectName = argResults!.rest.first;
      logger.info('${'Project Name'.padRight(18)}: $projectName\n');
    } else {
      projectName = Input(
        prompt: 'Project Name',
        defaultValue: 'my_app',
      ).interact().trim();
      if (projectName.isEmpty) {
        projectName = 'my_app';
      }
    }

    // 2. Select Architecture
    final archOption = argResults?['architecture'] as String?;
    String architecture;
    final archChoices = const ['Clean', 'MVVM', 'MVC'];
    if (archOption != null &&
        archChoices
            .map((e) => e.toLowerCase())
            .contains(archOption.toLowerCase())) {
      architecture = archChoices.firstWhere(
        (e) => e.toLowerCase() == archOption.toLowerCase(),
      );
    } else {
      final archIndex = Select(
        prompt: 'Select Architecture',
        options: archChoices,
        initialIndex: 0,
      ).interact();
      architecture = archChoices[archIndex];
    }

    // 3. Select State Management
    final smOption = argResults?['state-management'] as String?;
    String stateManagement;
    final smChoices = const ['Bloc', 'Cubit', 'Riverpod', 'Provider', 'GetX'];
    if (smOption != null &&
        smChoices
            .map((e) => e.toLowerCase())
            .contains(smOption.toLowerCase())) {
      stateManagement = smChoices.firstWhere(
        (e) => e.toLowerCase() == smOption.toLowerCase(),
      );
    } else {
      final smIndex = Select(
        prompt: 'Select State Management',
        options: smChoices,
        initialIndex: 0,
      ).interact();
      stateManagement = smChoices[smIndex];
    }

    // 4. Organization Identifier
    final orgOption = argResults?['org'] as String?;
    String org;
    if (orgOption != null && orgOption.isNotEmpty) {
      org = orgOption;
    } else {
      org = Input(
        prompt: 'Organization Identifier',
        defaultValue: 'com.example',
      ).interact().trim();
      if (org.isEmpty) {
        org = 'com.example';
      }
    }

    // 5. Platforms
    final platformOption = argResults?['platforms'] as String?;
    List<String> selectedPlatforms;
    final platformList = const [
      'Android',
      'iOS',
      'Web',
      'Windows',
      'macOS',
      'Linux',
    ];

    if (platformOption != null && platformOption.isNotEmpty) {
      selectedPlatforms =
          platformOption.split(',').map((e) => e.trim().toLowerCase()).toList();
    } else {
      final platformIndices = MultiSelect(
        prompt: 'Platforms',
        options: platformList,
        defaults: const [true, true, false, false, false, false],
      ).interact();

      selectedPlatforms =
          platformIndices.map((i) => platformList[i].toLowerCase()).toList();
    }

    final config = ProjectConfig(
      name: projectName,
      architecture: architecture,
      stateManagement: stateManagement,
      organization: org,
      platforms: selectedPlatforms,
    );

    final projectPath = p.join(Directory.current.path, projectName);

    // Creating Flutter project...
    final progress1 = logger.progress('Creating Flutter project...');
    final created = await _projectGenerator.createFlutterProject(config);
    if (created) {
      progress1.complete('Creating Flutter project...');
    } else {
      progress1.fail(
        'Creating Flutter project failed. Please verify that Flutter or FVM is installed and available in your PATH.',
      );
      return ExitCode.cantCreate.code;
    }

    // Applying template...
    final progress2 = logger.progress('Applying template...');
    await _projectGenerator.applyTemplate(config, projectPath: projectPath);
    progress2.complete('Applying template...');

    // Installing dependencies...
    final progress3 = logger.progress('Installing dependencies...');
    await _projectGenerator.installDependencies(
      config,
      projectPath: projectPath,
    );
    progress3.complete('Installing dependencies...');

    logger.info('${lightGreen.wrap('✔')} Done!\n');

    logger.info('Next Steps:');
    logger.info('cd $projectName');

    return ExitCode.success.code;
  }
}
