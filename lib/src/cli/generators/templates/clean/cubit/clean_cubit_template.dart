import 'package:path/path.dart' as p;
import '../../template_generator.dart';

class CleanCubitTemplate {
  static void generate(TemplateGenerator generator, String basePath, String featureName, {bool useDi = false}) {
    final pascal = featureName.toPascalCase();
    final snake = featureName.toLowerCase();

    generator.writeFile(
      p.join(basePath, 'presentation', 'cubit', '${snake}_state.dart'),
      '''
abstract class ${pascal}State {}

class ${pascal}Initial extends ${pascal}State {}
class ${pascal}Loading extends ${pascal}State {}
class ${pascal}Loaded extends ${pascal}State {
  final String data;
  ${pascal}Loaded(this.data);
}
''',
    );

    final diImport = useDi ? "import 'package:injectable/injectable.dart';\n" : "";
    final diAnnotation = useDi ? "@injectable\n" : "";

    generator.writeFile(
      p.join(basePath, 'presentation', 'cubit', '${snake}_cubit.dart'),
      '''
import 'package:flutter_bloc/flutter_bloc.dart';
${diImport}import '../../domain/usecases/${snake}_usecase.dart';
import '${snake}_state.dart';

${diAnnotation}class ${pascal}Cubit extends Cubit<${pascal}State> {
  final ${pascal}UseCase ${featureName}UseCase;

  ${pascal}Cubit({required this.${featureName}UseCase}) : super(${pascal}Initial());

  Future<void> loadData() async {
    emit(${pascal}Loading());
    final result = await ${featureName}UseCase();
    emit(${pascal}Loaded(result));
  }
}
''',
    );
  }
}
