import 'package:path/path.dart' as p;
import '../../template_generator.dart';

class MvvmRiverpodTemplate {
  static void generate(TemplateGenerator generator, String libPath, String featureName) {
    final snake = featureName.toLowerCase();
    final pascal = featureName.toPascalCase();

    generator.writeFile(
      p.join(libPath, 'viewmodels', '${snake}_provider.dart'),
      '''
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/${snake}_service.dart';

final ${featureName}ServiceProvider = Provider((ref) => ${pascal}Service());

final ${featureName}DataProvider = FutureProvider<String>((ref) async {
  final service = ref.read(${featureName}ServiceProvider);
  return await service.fetchData();
});
''',
    );
  }
}
