import 'package:path/path.dart' as p;
import '../../template_generator.dart';

class MvcProviderTemplate {
  static void generate(TemplateGenerator generator, String libPath) {
    generator.writeFile(
      p.join(libPath, 'controllers', 'home_controller.dart'),
      '''
import 'package:flutter/material.dart';

class HomeController extends ChangeNotifier {
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
