import 'package:flutter_archkit/src/models/project_config.dart';
import 'package:flutter_archkit/src/services/process_service.dart';
import 'package:flutter_archkit/src/cli/generators/project/flutter_creator.dart';
import 'package:flutter_archkit/src/cli/generators/project/template_applier.dart';
import 'package:flutter_archkit/src/cli/generators/project/pubspec_modifier.dart';

class ProjectGenerator {
  final FlutterCreator _flutterCreator;
  final TemplateApplier _templateApplier;
  final PubspecModifier _pubspecModifier;
  final ProcessService _processService;

  ProjectGenerator({
    FlutterCreator? flutterCreator,
    TemplateApplier? templateApplier,
    PubspecModifier? pubspecModifier,
    ProcessService? processService,
  })  : _flutterCreator = flutterCreator ?? FlutterCreator(),
        _templateApplier = templateApplier ?? TemplateApplier(),
        _pubspecModifier = pubspecModifier ?? PubspecModifier(),
        _processService = processService ?? ProcessService();

  Future<bool> createFlutterProject(ProjectConfig config, {String? targetDir}) async {
    return _flutterCreator.create(config, targetDir: targetDir);
  }

  Future<void> applyTemplate(ProjectConfig config, {required String projectPath}) async {
    await _templateApplier.apply(config, projectPath: projectPath);
  }

  Future<void> installDependencies(ProjectConfig config, {required String projectPath}) async {
    await _pubspecModifier.addDependencies(projectPath, config.stateManagement);
    await _processService.runFlutterPubGet(projectPath: projectPath);
  }
}
