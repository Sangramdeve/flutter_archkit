import 'package:path/path.dart' as p;
import '../../template_generator.dart';

class CleanGetXTemplate {
  static void generate(TemplateGenerator generator, String basePath, String featureName) {
    final snake = featureName.toLowerCase();
    final pascal = featureName.toPascalCase();

    generator.writeFile(
      p.join(basePath, 'presentation', 'controllers', '${snake}_controller.dart'),
      '''
import 'package:get/get.dart';
import '../../domain/usecases/${snake}_usecase.dart';

class ${pascal}Controller extends GetxController {
  final ${pascal}UseCase ${featureName}UseCase;
  var data = ''.obs;
  var isLoading = false.obs;

  ${pascal}Controller({required this.${featureName}UseCase});

  Future<void> loadData() async {
    isLoading.value = true;
    data.value = await ${featureName}UseCase();
    isLoading.value = false;
  }
}
''',
    );
  }
}
