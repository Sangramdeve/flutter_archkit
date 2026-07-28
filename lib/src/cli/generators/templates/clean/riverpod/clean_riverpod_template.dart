import 'package:path/path.dart' as p;
import '../../template_generator.dart';

class CleanRiverpodTemplate {
  static void generate(TemplateGenerator generator, String basePath, String featureName) {
    final snake = featureName.toLowerCase();
    final pascal = featureName.toPascalCase();

    generator.writeFile(
      p.join(basePath, 'presentation', 'riverpod', '${snake}_provider.dart'),
      '''
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../di/${snake}_di.dart';

final ${featureName}DataProvider = FutureProvider<String>((ref) async {
  final useCase = ${pascal}DI.provide${pascal}UseCase();
  return await useCase();
});
''',
    );
  }
}
