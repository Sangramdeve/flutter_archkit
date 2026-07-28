import 'package:flutter_archkit/src/models/project_config.dart';
import 'package:flutter_archkit/src/services/process_service.dart';

class FlutterCreator {
  final ProcessService _processService;

  FlutterCreator({ProcessService? processService})
      : _processService = processService ?? ProcessService();

  Future<bool> create(ProjectConfig config, {String? targetDir}) async {
    final result = await _processService.runFlutterCreate(
      name: config.name,
      organization: config.organization,
      platforms: config.platforms,
      workingDirectory: targetDir,
    );
    return result.exitCode == 0;
  }
}
