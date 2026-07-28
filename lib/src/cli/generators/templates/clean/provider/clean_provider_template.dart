import 'package:path/path.dart' as p;
import '../../template_generator.dart';

class CleanProviderTemplate {
  static void generate(TemplateGenerator generator, String basePath) {
    generator.writeFile(
      p.join(basePath, 'presentation', 'provider', 'home_provider.dart'),
      '''
import 'package:flutter/material.dart';
import '../../domain/usecases/home_usecase.dart';

class HomeNotifier extends ChangeNotifier {
  final HomeUseCase homeUseCase;
  String _data = '';
  bool _isLoading = false;

  HomeNotifier({required this.homeUseCase});

  String get data => _data;
  bool get isLoading => _isLoading;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();
    _data = await homeUseCase();
    _isLoading = false;
    notifyListeners();
  }
}
''',
    );
  }
}
