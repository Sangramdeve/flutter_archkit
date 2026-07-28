import 'package:path/path.dart' as p;
import '../../template_generator.dart';

class CleanBlocTemplate {
  static void generate(TemplateGenerator generator, String basePath, String featureName) {
    final pascal = featureName.toPascalCase();
    final snake = featureName.toLowerCase();

    generator.writeFile(
      p.join(basePath, 'presentation', 'bloc', '${snake}_event.dart'),
      '''
abstract class ${pascal}Event {}

class Load${pascal}DataEvent extends ${pascal}Event {}
''',
    );

    generator.writeFile(
      p.join(basePath, 'presentation', 'bloc', '${snake}_state.dart'),
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

    generator.writeFile(
      p.join(basePath, 'presentation', 'bloc', '${snake}_bloc.dart'),
      '''
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/${snake}_usecase.dart';
import '${snake}_event.dart';
import '${snake}_state.dart';

class ${pascal}Bloc extends Bloc<${pascal}Event, ${pascal}State> {
  final ${pascal}UseCase ${featureName}UseCase;

  ${pascal}Bloc({required this.${featureName}UseCase}) : super(${pascal}Initial()) {
    on<Load${pascal}DataEvent>((event, emit) async {
      emit(${pascal}Loading());
      final result = await ${featureName}UseCase();
      emit(${pascal}Loaded(result));
    });
  }
}
''',
    );
  }
}
