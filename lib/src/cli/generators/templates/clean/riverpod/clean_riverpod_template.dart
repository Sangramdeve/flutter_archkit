import 'package:path/path.dart' as p;
import '../../template_generator.dart';

class CleanRiverpodTemplate {
  static void generate(TemplateGenerator generator, String basePath) {
    generator.writeFile(
      p.join(basePath, 'presentation', 'riverpod', 'home_provider.dart'),
      '''
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../di/home_di.dart';

final homeDataProvider = FutureProvider<String>((ref) async {
  final useCase = HomeDI.provideHomeUseCase();
  return await useCase();
});
''',
    );
  }
}
