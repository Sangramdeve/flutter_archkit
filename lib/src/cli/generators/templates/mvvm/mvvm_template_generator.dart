import 'package:path/path.dart' as p;
import 'package:flutter_archkit/src/models/project_config.dart';
import '../template_generator.dart';
import 'bloc/mvvm_bloc_template.dart';
import 'cubit/mvvm_cubit_template.dart';
import 'riverpod/mvvm_riverpod_template.dart';
import 'provider/mvvm_provider_template.dart';
import 'getx/mvvm_getx_template.dart';

class MvvmTemplateGenerator extends TemplateGenerator {
  @override
  Future<void> generate(ProjectConfig config, String projectPath, {String featureName = 'home'}) async {
    final snake = featureName.toLowerCase();
    final pascal = featureName.toPascalCase();
    final lib = p.join(projectPath, 'lib');
    final targetDir = featureName == 'home' ? lib : p.join(lib, 'features', snake);
    final sm = config.stateManagement.toLowerCase();

    // Models
    writeFile(
      p.join(targetDir, 'models', '${snake}_model.dart'),
      '''
class ${pascal}Model {
  final String title;

  const ${pascal}Model({required this.title});
}
''',
    );

    // Services
    writeFile(
      p.join(targetDir, 'services', '${snake}_service.dart'),
      '''
class ${pascal}Service {
  Future<String> fetchData() async {
    return 'Data from ${pascal}Service';
  }
}
''',
    );

    // ViewModels
    switch (sm) {
      case 'bloc':
        MvvmBlocTemplate.generate(this, targetDir);
        break;
      case 'cubit':
        MvvmCubitTemplate.generate(this, targetDir);
        break;
      case 'riverpod':
        MvvmRiverpodTemplate.generate(this, targetDir);
        break;
      case 'provider':
        MvvmProviderTemplate.generate(this, targetDir);
        break;
      case 'getx':
      case 'get':
        MvvmGetXTemplate.generate(this, targetDir);
        break;
      default:
        MvvmProviderTemplate.generate(this, targetDir);
    }

    // Views
    writeFile(
      p.join(targetDir, 'views', '${snake}_view.dart'),
      '''
import 'package:flutter/material.dart';

class ${pascal}View extends StatelessWidget {
  const ${pascal}View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MVVM $pascal View'),
      ),
      body: Center(
        child: Text('MVVM $pascal Screen'),
      ),
    );
  }
}
''',
    );
  }
}
