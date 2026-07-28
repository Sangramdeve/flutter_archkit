import 'package:path/path.dart' as p;
import '../../template_generator.dart';

class MvvmGetXTemplate {
  static void generate(TemplateGenerator generator, String libPath, String featureName) {
    final snake = featureName.toLowerCase();
    final pascal = featureName.toPascalCase();

    generator.writeFile(
      p.join(libPath, 'viewmodels', '${snake}_controller.dart'),
      '''
import 'package:get/get.dart';
import '../services/${snake}_service.dart';

class ${pascal}Controller extends GetxController {
  final ${pascal}Service service = ${pascal}Service();
  var data = ''.obs;

  Future<void> loadData() async {
    data.value = await service.fetchData();
  }
}
''',
    );
  }
}
