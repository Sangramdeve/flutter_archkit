import 'package:path/path.dart' as p;
import '../../template_generator.dart';

class MvcRiverpodTemplate {
  static void generate(TemplateGenerator generator, String libPath) {
    generator.writeFile(
      p.join(libPath, 'controllers', 'home_controller.dart'),
      '''
import 'package:flutter_riverpod/flutter_riverpod.dart';

final homeControllerProvider = StateProvider<String>((ref) => 'Initial MVC Data');
''',
    );
  }
}
