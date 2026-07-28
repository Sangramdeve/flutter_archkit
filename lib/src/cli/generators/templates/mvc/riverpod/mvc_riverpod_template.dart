import 'package:path/path.dart' as p;
import '../../template_generator.dart';

class MvcRiverpodTemplate {
  static void generate(TemplateGenerator generator, String libPath, String featureName) {
    final snake = featureName.toLowerCase();
    final pascal = featureName.toPascalCase();

    generator.writeFile(
      p.join(libPath, 'controllers', '${snake}_controller.dart'),
      '''
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ${featureName}ControllerProvider = StateProvider<String>((ref) => 'Initial MVC $pascal Data');
''',
    );
  }
}
