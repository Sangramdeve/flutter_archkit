import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:flutter_archkit/src/models/project_config.dart';

class TemplateApplier {
  Future<void> apply(ProjectConfig config, {required String projectPath}) async {
    final libDir = Directory(p.join(projectPath, 'lib'));
    if (!libDir.existsSync()) {
      libDir.createSync(recursive: true);
    }

    final arch = config.architecture.toLowerCase();

    if (arch == 'clean') {
      _createCleanArchitecture(projectPath, config);
    } else if (arch == 'mvvm') {
      _createMvvmArchitecture(projectPath, config);
    } else if (arch == 'mvc') {
      _createMvcArchitecture(projectPath, config);
    }

    _generateMainDart(projectPath, config);
  }

  void _createCleanArchitecture(String projectPath, ProjectConfig config) {
    final dirs = [
      p.join(projectPath, 'lib', 'core', 'constants'),
      p.join(projectPath, 'lib', 'core', 'theme'),
      p.join(projectPath, 'lib', 'features', 'home', 'data'),
      p.join(projectPath, 'lib', 'features', 'home', 'domain'),
      p.join(projectPath, 'lib', 'features', 'home', 'presentation'),
    ];
    for (var dirPath in dirs) {
      Directory(dirPath).createSync(recursive: true);
    }
  }

  void _createMvvmArchitecture(String projectPath, ProjectConfig config) {
    final dirs = [
      p.join(projectPath, 'lib', 'core'),
      p.join(projectPath, 'lib', 'models'),
      p.join(projectPath, 'lib', 'views'),
      p.join(projectPath, 'lib', 'viewmodels'),
      p.join(projectPath, 'lib', 'services'),
    ];
    for (var dirPath in dirs) {
      Directory(dirPath).createSync(recursive: true);
    }
  }

  void _createMvcArchitecture(String projectPath, ProjectConfig config) {
    final dirs = [
      p.join(projectPath, 'lib', 'core'),
      p.join(projectPath, 'lib', 'models'),
      p.join(projectPath, 'lib', 'views'),
      p.join(projectPath, 'lib', 'controllers'),
    ];
    for (var dirPath in dirs) {
      Directory(dirPath).createSync(recursive: true);
    }
  }

  void _generateMainDart(String projectPath, ProjectConfig config) {
    final mainFile = File(p.join(projectPath, 'lib', 'main.dart'));
    final code = '''
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '${config.name}',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('${config.name} (${config.architecture} + ${config.stateManagement})'),
        ),
        body: Center(
          child: Text(
            'Welcome to ${config.name}!',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ),
    );
  }
}
''';
    mainFile.writeAsStringSync(code);
  }
}
