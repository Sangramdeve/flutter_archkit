import 'package:path/path.dart' as p;
import '../../template_generator.dart';

class MvvmGetXTemplate {
  static void generate(TemplateGenerator generator, String libPath) {
    generator.writeFile(
      p.join(libPath, 'viewmodels', 'home_controller.dart'),
      '''
import 'package:get/get.dart';
import '../services/home_service.dart';

class HomeController extends GetxController {
  final HomeService service = HomeService();
  var data = ''.obs;

  Future<void> loadData() async {
    data.value = await service.fetchData();
  }
}
''',
    );
  }
}
