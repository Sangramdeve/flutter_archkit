import 'package:path/path.dart' as p;
import '../../template_generator.dart';

class MvvmProviderTemplate {
  static void generate(TemplateGenerator generator, String libPath, String featureName) {
    final snake = featureName.toLowerCase();
    final pascal = featureName.toPascalCase();

    generator.writeFile(
      p.join(libPath, 'viewmodels', '${snake}_viewmodel.dart'),
      '''
import 'package:flutter/foundation.dart';
import '../services/${snake}_service.dart';

class ${pascal}ViewModel extends ChangeNotifier {
  final ${pascal}Service _service = ${pascal}Service();
  String _data = '';

  String get data => _data;

  Future<void> loadData() async {
    _data = await _service.fetchData();
    notifyListeners();
  }
}
''',
    );
  }
}
