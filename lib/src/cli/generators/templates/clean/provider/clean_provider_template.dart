import 'package:path/path.dart' as p;
import '../../template_generator.dart';

class CleanProviderTemplate {
  static void generate(TemplateGenerator generator, String basePath, String featureName) {
    final snake = featureName.toLowerCase();
    final pascal = featureName.toPascalCase();

    generator.writeFile(
      p.join(basePath, 'presentation', 'provider', '${snake}_provider.dart'),
      '''
import 'package:flutter/material.dart';
import '../../domain/usecases/${snake}_usecase.dart';

class ${pascal}Notifier extends ChangeNotifier {
  final ${pascal}UseCase ${featureName}UseCase;
  String _data = '';
  bool _isLoading = false;

  ${pascal}Notifier({required this.${featureName}UseCase});

  String get data => _data;
  bool get isLoading => _isLoading;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();
    _data = await ${featureName}UseCase();
    _isLoading = false;
    notifyListeners();
  }
}
''',
    );
  }
}
