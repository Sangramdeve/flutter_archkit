import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:interact/interact.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:flutter_archkit/src/models/project_config.dart';
import 'package:flutter_archkit/src/cli/generators/templates/clean/clean_template_generator.dart';
import 'package:flutter_archkit/src/cli/generators/templates/mvvm/mvvm_template_generator.dart';
import 'package:flutter_archkit/src/cli/generators/templates/mvc/mvc_template_generator.dart';

class CreateFeatureCommand extends Command<int> {
  @override
  String get name => 'feature';

  @override
  List<String> get aliases => const ['f'];

  @override
  String get description => 'Generate a new feature module';

  CreateFeatureCommand() {
    argParser
      ..addOption('name', abbr: 'n', help: 'Feature name (e.g. auth, profile)')
      ..addOption('architecture', help: 'Architecture (Clean, MVVM, MVC)')
      ..addOption('state-management', help: 'State management (Bloc, Cubit, Riverpod, Provider, GetX)');
  }

  @override
  Future<int> run() async {
    final logger = Logger();

    logger.info('${lightGreen.wrap('✔')} Flutter Archkit Feature Generator\n');

    // 1. Feature Name
    String? featureName = argResults?['name'] as String?;
    if (featureName == null || featureName.isEmpty) {
      if (argResults?.rest.isNotEmpty == true) {
        featureName = argResults!.rest.first;
      }
    }

    if (featureName == null || featureName.trim().isEmpty) {
      featureName = Input(
        prompt: 'Feature Name',
        defaultValue: 'auth',
      ).interact().trim();
      if (featureName.isEmpty) {
        featureName = 'auth';
      }
    }

    logger.info('${'Feature Name'.padRight(18)}: $featureName');

    // 2. Architecture
    final archOption = argResults?['architecture'] as String?;
    String architecture;
    final archChoices = const ['Clean', 'MVVM', 'MVC'];
    if (archOption != null &&
        archChoices.map((e) => e.toLowerCase()).contains(archOption.toLowerCase())) {
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

    // 3. State Management
    final smOption = argResults?['state-management'] as String?;
    String stateManagement;
    final smChoices = const ['Bloc', 'Cubit', 'Riverpod', 'Provider', 'GetX'];
    if (smOption != null &&
        smChoices.map((e) => e.toLowerCase()).contains(smOption.toLowerCase())) {
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

    final config = ProjectConfig(
      name: featureName,
      architecture: architecture,
      stateManagement: stateManagement,
      organization: 'com.example',
      platforms: const ['android', 'ios'],
    );

    final projectPath = Directory.current.path;
    final progress = logger.progress('Generating feature \'$featureName\'...');

    final archLower = architecture.toLowerCase();
    if (archLower == 'clean') {
      await CleanTemplateGenerator().generate(config, projectPath, featureName: featureName);
    } else if (archLower == 'mvvm') {
      await MvvmTemplateGenerator().generate(config, projectPath, featureName: featureName);
    } else if (archLower == 'mvc') {
      await MvcTemplateGenerator().generate(config, projectPath, featureName: featureName);
    } else {
      await CleanTemplateGenerator().generate(config, projectPath, featureName: featureName);
    }

    progress.complete('Feature \'$featureName\' generated successfully!');

    logger.info('\n${lightGreen.wrap('✔')} Done!');
    return ExitCode.success.code;
  }
}
