import 'package:path/path.dart' as p;
import 'package:flutter_archkit/src/models/project_config.dart';
import '../template_generator.dart';
import 'bloc/clean_bloc_template.dart';
import 'cubit/clean_cubit_template.dart';
import 'riverpod/clean_riverpod_template.dart';
import 'provider/clean_provider_template.dart';
import 'getx/clean_getx_template.dart';

class CleanTemplateGenerator extends TemplateGenerator {
  @override
  Future<void> generate(ProjectConfig config, String projectPath, {String featureName = 'home'}) async {
    final snake = featureName.toLowerCase();
    final pascal = featureName.toPascalCase();
    final base = p.join(projectPath, 'lib', 'features', snake);
    final sm = config.stateManagement.toLowerCase();

    final useDi = config.useDi;

    // Data layer
    writeFile(
      p.join(base, 'data', 'data_sources', '${snake}_remote_datasource.dart'),
      '''
abstract class ${pascal}RemoteDataSource {
  Future<String> get${pascal}Data();
}
''',
    );

    final dsDiImport = useDi ? "import 'package:injectable/injectable.dart';\n" : "";
    final dsDiAnnotation = useDi ? "@LazySingleton(as: ${pascal}RemoteDataSource)\n" : "";

    writeFile(
      p.join(base, 'data', 'data_sources', '${snake}_remote_datasource_impl.dart'),
      '''
${dsDiImport}import '${snake}_remote_datasource.dart';

${dsDiAnnotation}class ${pascal}RemoteDataSourceImpl implements ${pascal}RemoteDataSource {
  @override
  Future<String> get${pascal}Data() async {
    return 'Data loaded from ${pascal}RemoteDataSource';
  }
}
''',
    );

    writeFile(
      p.join(base, 'data', 'models', '${snake}_model.dart'),
      '''
class ${pascal}Model {
  final String title;

  const ${pascal}Model({required this.title});

  factory ${pascal}Model.fromJson(Map<String, dynamic> json) {
    return ${pascal}Model(title: json['title'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'title': title};
  }
}
''',
    );

    final repoDiImport = useDi ? "import 'package:injectable/injectable.dart';\n" : "";
    final repoDiAnnotation = useDi ? "@LazySingleton(as: ${pascal}Repository)\n" : "";

    writeFile(
      p.join(base, 'data', 'repositories', '${snake}_repository_impl.dart'),
      '''
${repoDiImport}import '../../domain/repositories/${snake}_repository.dart';
import '../data_sources/${snake}_remote_datasource.dart';

${repoDiAnnotation}class ${pascal}RepositoryImpl implements ${pascal}Repository {
  final ${pascal}RemoteDataSource remoteDataSource;

  ${pascal}RepositoryImpl({required this.remoteDataSource});

  @override
  Future<String> get${pascal}Data() async {
    return await remoteDataSource.get${pascal}Data();
  }
}
''',
    );

    // DI layer
    if (useDi) {
      writeFile(
        p.join(base, 'di', '${snake}_di.dart'),
        '''
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '${snake}_di.config.dart';

@InjectableInit(
  initializerName: 'init${pascal}Di',
  preferRelativeImports: true,
  asExtension: false,
  generateForDir: ['lib/features/$snake'],
)
void configure${pascal}Dependencies() => init${pascal}Di(GetIt.instance);
''',
      );

      writeFile(
        p.join(base, 'di', '${snake}_di.config.dart'),
        '''
// Auto-generated DI configuration file for $pascal feature
''',
      );
    } else {
      writeFile(
        p.join(base, 'di', '${snake}_di.dart'),
        '''
import '../data/data_sources/${snake}_remote_datasource.dart';
import '../data/data_sources/${snake}_remote_datasource_impl.dart';
import '../data/repositories/${snake}_repository_impl.dart';
import '../domain/repositories/${snake}_repository.dart';
import '../domain/usecases/${snake}_usecase.dart';

class ${pascal}DI {
  static ${pascal}UseCase provide${pascal}UseCase() {
    final remoteDataSource = ${pascal}RemoteDataSourceImpl();
    final repository = ${pascal}RepositoryImpl(remoteDataSource: remoteDataSource);
    return ${pascal}UseCase(repository: repository);
  }
}
''',
      );

      writeFile(
        p.join(base, 'di', '${snake}_di.config.dart'),
        '''
// Auto-generated or manual DI configuration file for $pascal feature
''',
      );
    }

    // Domain layer
    writeFile(
      p.join(base, 'domain', 'repositories', '${snake}_repository.dart'),
      '''
abstract class ${pascal}Repository {
  Future<String> get${pascal}Data();
}
''',
    );

    final usecaseDiImport = useDi ? "import 'package:injectable/injectable.dart';\n" : "";
    final usecaseDiAnnotation = useDi ? "@lazySingleton\n" : "";

    writeFile(
      p.join(base, 'domain', 'usecases', '${snake}_usecase.dart'),
      '''
${usecaseDiImport}import '../repositories/${snake}_repository.dart';

${usecaseDiAnnotation}class ${pascal}UseCase {
  final ${pascal}Repository repository;

  ${pascal}UseCase({required this.repository});

  Future<String> call() async {
    return await repository.get${pascal}Data();
  }
}
''',
    );

    // Presentation layer (State Management)
    switch (sm) {
      case 'bloc':
        CleanBlocTemplate.generate(this, base, featureName, useDi: useDi);
        break;
      case 'cubit':
        CleanCubitTemplate.generate(this, base, featureName, useDi: useDi);
        break;
      case 'riverpod':
        CleanRiverpodTemplate.generate(this, base, featureName);
        break;
      case 'provider':
        CleanProviderTemplate.generate(this, base, featureName);
        break;
      case 'getx':
      case 'get':
        CleanGetXTemplate.generate(this, base, featureName);
        break;
      default:
        CleanBlocTemplate.generate(this, base, featureName, useDi: useDi);
    }

    // Page view
    writeFile(
      p.join(base, 'presentation', 'page', '${snake}_page.dart'),
      '''
import 'package:flutter/material.dart';

class ${pascal}Page extends StatelessWidget {
  const ${pascal}Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clean Architecture $pascal'),
      ),
      body: Center(
        child: Text('$pascal Page View'),
      ),
    );
  }
}
''',
    );
  }
}
