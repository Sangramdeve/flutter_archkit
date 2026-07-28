import 'package:path/path.dart' as p;
import '../../template_generator.dart';

class MvcBlocTemplate {
  static void generate(
    TemplateGenerator generator,
    String libPath,
    String featureName,
  ) {
    final snake = featureName.toLowerCase();
    final pascal = featureName.toPascalCase();

    generator.writeFile(
      p.join(libPath, 'controllers', '${snake}_event.dart'),
      '''
abstract class ${pascal}Event {}
class Update${pascal}Data extends ${pascal}Event {}
''',
    );

    generator.writeFile(
      p.join(libPath, 'controllers', '${snake}_state.dart'),
      '''
abstract class ${pascal}State {}
class ${pascal}Initial extends ${pascal}State {}
class ${pascal}Updated extends ${pascal}State {
  final String data;
  ${pascal}Updated(this.data);
}
''',
    );

    generator.writeFile(
      p.join(libPath, 'controllers', '${snake}_bloc.dart'),
      '''
import 'package:flutter_bloc/flutter_bloc.dart';
import '${snake}_event.dart';
import '${snake}_state.dart';

class ${pascal}Bloc extends Bloc<${pascal}Event, ${pascal}State> {
  ${pascal}Bloc() : super(${pascal}Initial()) {
    on<Update${pascal}Data>((event, emit) {
      emit(${pascal}Updated('Updated MVC Data via Bloc'));
    });
  }
}
''',
    );
  }
}
