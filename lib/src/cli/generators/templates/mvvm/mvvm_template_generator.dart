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

    // Services
    writeFile(
      p.join(lib, 'services', 'home_service.dart'),
      '''
class HomeService {
  Future<String> fetchData() async {
    return 'Data from HomeService';
  }
}
''',
    );

    // ViewModels (State Management)
    switch (sm) {
      case 'bloc':
        MvvmBlocTemplate.generate(this, lib);
        break;
      case 'cubit':
        MvvmCubitTemplate.generate(this, lib);
        break;
      case 'riverpod':
        MvvmRiverpodTemplate.generate(this, lib);
        break;
      case 'provider':
        MvvmProviderTemplate.generate(this, lib);
        break;
      case 'getx':
      case 'get':
        MvvmGetXTemplate.generate(this, lib);
        break;
      default:
        MvvmProviderTemplate.generate(this, lib);
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
        title: const Text('MVVM Home View'),
      ),
      body: const Center(
        child: Text('MVVM Architecture Screen'),
      ),
    );
  }
}
''',
    );
  }
}
