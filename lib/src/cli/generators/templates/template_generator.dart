import 'dart:io';
import 'package:flutter_archkit/src/models/project_config.dart';

abstract class TemplateGenerator {
  Future<void> generate(ProjectConfig config, String projectPath);

  void writeFile(String filePath, String content) {
    final file = File(filePath);
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(content);
  }
}
