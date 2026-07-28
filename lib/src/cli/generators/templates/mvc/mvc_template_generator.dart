import 'package:path/path.dart' as p;
import 'package:flutter_archkit/src/models/project_config.dart';
import '../template_generator.dart';
import 'bloc/mvc_bloc_template.dart';
import 'cubit/mvc_cubit_template.dart';
import 'riverpod/mvc_riverpod_template.dart';
import 'provider/mvc_provider_template.dart';
import 'getx/mvc_getx_template.dart';

class MvcTemplateGenerator extends TemplateGenerator {
  @override
  Future<void> generate(ProjectConfig config, String projectPath, {String featureName = 'home'}) async {
    final snake = featureName.toLowerCase();
    final pascal = featureName.toPascalCase();
    final targetDir = p.join(projectPath, 'lib');
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

    // Controllers
    switch (sm) {
      case 'bloc':
        MvcBlocTemplate.generate(this, targetDir, featureName);
        break;
      case 'cubit':
        MvcCubitTemplate.generate(this, targetDir, featureName);
        break;
      case 'riverpod':
        MvcRiverpodTemplate.generate(this, targetDir, featureName);
        break;
      case 'provider':
        MvcProviderTemplate.generate(this, targetDir, featureName);
        break;
      case 'getx':
      case 'get':
        MvcGetXTemplate.generate(this, targetDir, featureName);
        break;
      default:
        MvcProviderTemplate.generate(this, targetDir, featureName);
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
        title: Text('MVC $pascal View'),
      ),
      body: Center(
        child: Text('MVC $pascal Screen'),
      ),
    );
  }
}
''',
    );
  }
}
