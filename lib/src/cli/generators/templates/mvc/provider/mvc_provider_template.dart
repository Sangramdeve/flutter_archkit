import 'package:path/path.dart' as p;
import '../../template_generator.dart';

class MvcProviderTemplate {
  static void generate(TemplateGenerator generator, String libPath, String featureName) {
    final snake = featureName.toLowerCase();
    final pascal = featureName.toPascalCase();

    generator.writeFile(
      p.join(libPath, 'controllers', '${snake}_controller.dart'),
      '''
import 'package:flutter/material.dart';

class ${pascal}Controller extends ChangeNotifier {
  String _data = 'Initial MVC Data';

  String get data => _data;

  void updateData(String newData) {
    _data = newData;
    notifyListeners();
  }
}
''',
    );
  }
}
