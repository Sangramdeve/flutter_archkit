import 'package:path/path.dart' as p;
import '../../template_generator.dart';

class MvvmRiverpodTemplate {
  static void generate(TemplateGenerator generator, String libPath) {
    generator.writeFile(
      p.join(libPath, 'viewmodels', 'home_provider.dart'),
      '''
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/home_service.dart';

final homeServiceProvider = Provider((ref) => HomeService());

final homeDataProvider = FutureProvider<String>((ref) async {
  final service = ref.read(homeServiceProvider);
  return await service.fetchData();
});
''',
    );
  }
}
