import 'package:path/path.dart' as p;
import '../../template_generator.dart';

class CleanGetXTemplate {
  static void generate(TemplateGenerator generator, String basePath) {
    generator.writeFile(
      p.join(basePath, 'presentation', 'controllers', 'home_controller.dart'),
      '''
import 'package:get/get.dart';
import '../../domain/usecases/home_usecase.dart';

class HomeController extends GetxController {
  final HomeUseCase homeUseCase;
  var data = ''.obs;
  var isLoading = false.obs;

  HomeController({required this.homeUseCase});

  Future<void> loadData() async {
    isLoading.value = true;
    data.value = await homeUseCase();
    isLoading.value = false;
  }
}
''',
    );
  }
}
