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
  Future<void> generate(ProjectConfig config, String projectPath) async {
    final lib = p.join(projectPath, 'lib');
    final sm = config.stateManagement.toLowerCase();

    // Models
    writeFile(
      p.join(lib, 'models', 'home_model.dart'),
      '''
class HomeModel {
  final String title;

  const HomeModel({required this.title});
}
''',
    );

    // Controllers (State Management)
    switch (sm) {
      case 'bloc':
        MvcBlocTemplate.generate(this, lib);
        break;
      case 'cubit':
        MvcCubitTemplate.generate(this, lib);
        break;
      case 'riverpod':
        MvcRiverpodTemplate.generate(this, lib);
        break;
      case 'provider':
        MvcProviderTemplate.generate(this, lib);
        break;
      case 'getx':
      case 'get':
        MvcGetXTemplate.generate(this, lib);
        break;
      default:
        MvcProviderTemplate.generate(this, lib);
    }

    // Views
    writeFile(
      p.join(lib, 'views', 'home_view.dart'),
      '''
import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MVC Home View'),
      ),
      body: const Center(
        child: Text('MVC Architecture Screen'),
      ),
    );
  }
}
''',
    );
  }
}
