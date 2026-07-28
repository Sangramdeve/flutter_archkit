import 'package:path/path.dart' as p;
import '../../template_generator.dart';

class MvcGetXTemplate {
  static void generate(TemplateGenerator generator, String libPath, String featureName) {
    final snake = featureName.toLowerCase();
    final pascal = featureName.toPascalCase();

    generator.writeFile(
      p.join(libPath, 'controllers', '${snake}_controller.dart'),
      '''
import 'package:get/get.dart';

class ${pascal}Controller extends GetxController {
  var data = 'Initial MVC Data'.obs;

  void updateData(String newData) {
    data.value = newData;
  }
}
''',
    );
  }
}
