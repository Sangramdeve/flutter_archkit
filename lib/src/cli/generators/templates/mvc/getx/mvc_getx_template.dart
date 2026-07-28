import 'package:path/path.dart' as p;
import '../../template_generator.dart';

class MvcGetXTemplate {
  static void generate(TemplateGenerator generator, String libPath) {
    generator.writeFile(
      p.join(libPath, 'controllers', 'home_controller.dart'),
      '''
import 'package:get/get.dart';

class HomeController extends GetxController {
  var data = 'Initial MVC Data'.obs;

  void updateData(String newData) {
    data.value = newData;
  }
}
''',
    );
  }
}
