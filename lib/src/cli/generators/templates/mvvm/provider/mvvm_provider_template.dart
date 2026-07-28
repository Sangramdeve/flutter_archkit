import 'package:path/path.dart' as p;
import '../../template_generator.dart';

class MvvmProviderTemplate {
  static void generate(TemplateGenerator generator, String libPath) {
    generator.writeFile(
      p.join(libPath, 'viewmodels', 'home_viewmodel.dart'),
      '''
import 'package:flutter/foundation.dart';
import '../services/home_service.dart';

class HomeViewModel extends ChangeNotifier {
  final HomeService _service = HomeService();
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
