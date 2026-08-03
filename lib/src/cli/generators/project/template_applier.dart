import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:flutter_archkit/src/models/project_config.dart';
import 'package:flutter_archkit/src/services/metadata_config_service.dart';
import 'package:flutter_archkit/src/cli/generators/templates/clean/clean_template_generator.dart';
import 'package:flutter_archkit/src/cli/generators/templates/mvvm/mvvm_template_generator.dart';
import 'package:flutter_archkit/src/cli/generators/templates/mvc/mvc_template_generator.dart';

import 'package:flutter_archkit/src/cli/generators/route/route_generator.dart';

class TemplateApplier {
  final MetadataConfigService _metadataConfigService;

  TemplateApplier({MetadataConfigService? metadataConfigService})
      : _metadataConfigService = metadataConfigService ?? MetadataConfigService();

  Future<void> apply(ProjectConfig config, {required String projectPath}) async {
    final libDir = Directory(p.join(projectPath, 'lib'));
    if (!libDir.existsSync()) {
      libDir.createSync(recursive: true);
    }

    final arch = config.architecture.toLowerCase();

    if (arch == 'clean') {
      await CleanTemplateGenerator().generate(config, projectPath);
    } else if (arch == 'mvvm') {
      await MvvmTemplateGenerator().generate(config, projectPath);
    } else if (arch == 'mvc') {
      await MvcTemplateGenerator().generate(config, projectPath);
    } else {
      await CleanTemplateGenerator().generate(config, projectPath);
    }

    if (config.router != null && config.router!.isNotEmpty) {
      await RouteGenerator().generate(projectPath, config.router!);
    } else {
      _generateMainDart(projectPath, config);
    }

    _metadataConfigService.writeConfig(
      projectPath,
      architecture: config.architecture,
      stateManagement: config.stateManagement,
      router: config.router,
    );
  }

  void _generateMainDart(String projectPath, ProjectConfig config) {
    final mainFile = File(p.join(projectPath, 'lib', 'main.dart'));
    final arch = config.architecture.toLowerCase();

    String homeImport;
    String homeWidget;

    if (arch == 'clean') {
      homeImport = "import 'features/home/presentation/page/home_page.dart';";
      homeWidget = "const HomePage()";
    } else if (arch == 'mvvm') {
      homeImport = "import 'views/home_view.dart';";
      homeWidget = "const HomeView()";
    } else {
      homeImport = "import 'views/home_view.dart';";
      homeWidget = "const HomeView()";
    }

    final code = '''
import 'package:flutter/material.dart';
$homeImport

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '${config.name}',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: $homeWidget,
    );
  }
}
''';
    mainFile.writeAsStringSync(code);
  }
}


