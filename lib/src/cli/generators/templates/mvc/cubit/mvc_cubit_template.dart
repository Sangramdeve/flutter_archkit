import 'package:path/path.dart' as p;
import '../../template_generator.dart';

class MvcCubitTemplate {
  static void generate(TemplateGenerator generator, String libPath, String featureName) {
    final snake = featureName.toLowerCase();
    final pascal = featureName.toPascalCase();

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
      p.join(libPath, 'controllers', '${snake}_cubit.dart'),
      '''
import 'package:flutter_bloc/flutter_bloc.dart';
import '${snake}_state.dart';

class ${pascal}Cubit extends Cubit<${pascal}State> {
  ${pascal}Cubit() : super(${pascal}Initial());

  void updateData(String newData) {
    emit(${pascal}Updated(newData));
  }
}
''',
    );
  }
}
