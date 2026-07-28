import 'dart:io';
import 'package:flutter_archkit/src/models/project_config.dart';

abstract class TemplateGenerator {
  Future<void> generate(ProjectConfig config, String projectPath, {String featureName = 'home'});

  void writeFile(String filePath, String content) {
    final file = File(filePath);
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(content);
  }
}

extension StringCasingExtension on String {
  String toCapitalized() => isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';

  String toPascalCase() {
    return split('_').map((str) => str.toCapitalized()).join();
  }
}

