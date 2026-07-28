import 'package:path/path.dart' as p;
import '../../template_generator.dart';

class MvvmBlocTemplate {
  static void generate(TemplateGenerator generator, String libPath, String featureName) {
    final snake = featureName.toLowerCase();
    final pascal = featureName.toPascalCase();

    generator.writeFile(
      p.join(libPath, 'viewmodels', '${snake}_event.dart'),
      '''
abstract class ${pascal}Event {}
class Fetch${pascal}Data extends ${pascal}Event {}
''',
    );

    generator.writeFile(
      p.join(libPath, 'viewmodels', '${snake}_state.dart'),
      '''
abstract class ${pascal}State {}
class ${pascal}Initial extends ${pascal}State {}
class ${pascal}Loaded extends ${pascal}State {
  final String data;
  ${pascal}Loaded(this.data);
}
''',
    );

    generator.writeFile(
      p.join(libPath, 'viewmodels', '${snake}_bloc.dart'),
      '''
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/${snake}_service.dart';
import '${snake}_event.dart';
import '${snake}_state.dart';

class ${pascal}Bloc extends Bloc<${pascal}Event, ${pascal}State> {
  final ${pascal}Service service;

  ${pascal}Bloc({required this.service}) : super(${pascal}Initial()) {
    on<Fetch${pascal}Data>((event, emit) async {
      final res = await service.fetchData();
      emit(${pascal}Loaded(res));
    });
  }
}
''',
    );
  }
}
