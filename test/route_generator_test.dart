import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_archkit/src/cli/generators/route/route_generator.dart';
import 'package:flutter_archkit/src/cli/generators/project/pubspec_modifier.dart';
import 'package:flutter_archkit/src/services/metadata_config_service.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('route_generator_test_');
    final pubspecFile = File(p.join(tempDir.path, 'pubspec.yaml'));
    pubspecFile.writeAsStringSync('''
name: test_app
description: Test app for route generator

dependencies:
  flutter:
    sdk: flutter
''');
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('generates Navigator 1.0 setup correctly', () async {
    final generator = RouteGenerator();
    await generator.generate(tempDir.path, 'Navigator 1.0');

    final routerFile = File(p.join(tempDir.path, 'lib', 'core', 'router', 'app_router.dart'));
    final mainFile = File(p.join(tempDir.path, 'lib', 'main.dart'));

    expect(routerFile.existsSync(), isTrue);
    expect(mainFile.existsSync(), isTrue);

    final routerContent = routerFile.readAsStringSync();
    expect(routerContent, contains('class AppRoutes'));
    expect(routerContent, contains('static Route<dynamic>? onGenerateRoute'));

    final mainContent = mainFile.readAsStringSync();
    expect(mainContent, contains('initialRoute: AppRoutes.home'));
    expect(mainContent, contains('onGenerateRoute: AppRouter.onGenerateRoute'));
  });

  test('generates Navigator 2.0 setup correctly', () async {
    final generator = RouteGenerator();
    await generator.generate(tempDir.path, 'Navigator 2.0');

    final routerFile = File(p.join(tempDir.path, 'lib', 'core', 'router', 'app_router.dart'));
    final mainFile = File(p.join(tempDir.path, 'lib', 'main.dart'));

    expect(routerFile.existsSync(), isTrue);
    expect(mainFile.existsSync(), isTrue);

    final routerContent = routerFile.readAsStringSync();
    expect(routerContent, contains('class AppRoutePath'));
    expect(routerContent, contains('class AppRouterDelegate'));

    final mainContent = mainFile.readAsStringSync();
    expect(mainContent, contains('MaterialApp.router'));
    expect(mainContent, contains('routerDelegate: _routerDelegate'));
  });

  test('generates Go Router setup and adds pubspec dependencies correctly', () async {
    final generator = RouteGenerator();
    final pubspecModifier = PubspecModifier();

    await generator.generate(tempDir.path, 'Go Router');
    await pubspecModifier.addRouterDependencies(tempDir.path, 'Go Router');

    final routerFile = File(p.join(tempDir.path, 'lib', 'core', 'router', 'app_router.dart'));
    final mainFile = File(p.join(tempDir.path, 'lib', 'main.dart'));
    final pubspecFile = File(p.join(tempDir.path, 'pubspec.yaml'));

    expect(routerFile.existsSync(), isTrue);
    expect(mainFile.existsSync(), isTrue);

    final routerContent = routerFile.readAsStringSync();
    expect(routerContent, contains('package:go_router/go_router.dart'));
    expect(routerContent, contains('GoRouter'));

    final mainContent = mainFile.readAsStringSync();
    expect(mainContent, contains('routerConfig: AppRouter.router'));

    final pubspecContent = pubspecFile.readAsStringSync();
    expect(pubspecContent, contains('go_router:'));
  });

  test('generates Auto Route setup and adds pubspec dependencies correctly', () async {
    final generator = RouteGenerator();
    final pubspecModifier = PubspecModifier();

    await generator.generate(tempDir.path, 'Auto Route');
    await pubspecModifier.addRouterDependencies(tempDir.path, 'Auto Route');

    final routerFile = File(p.join(tempDir.path, 'lib', 'core', 'router', 'app_router.dart'));
    final mainFile = File(p.join(tempDir.path, 'lib', 'main.dart'));
    final pubspecFile = File(p.join(tempDir.path, 'pubspec.yaml'));

    expect(routerFile.existsSync(), isTrue);
    expect(mainFile.existsSync(), isTrue);

    final routerContent = routerFile.readAsStringSync();
    expect(routerContent, contains('package:auto_route/auto_route.dart'));
    expect(routerContent, contains('@AutoRouterConfig()'));

    final mainContent = mainFile.readAsStringSync();
    expect(mainContent, contains('routerConfig: _appRouter.config()'));

    final pubspecContent = pubspecFile.readAsStringSync();
    expect(pubspecContent, contains('auto_route:'));
    expect(pubspecContent, contains('auto_route_generator:'));
    expect(pubspecContent, contains('build_runner:'));
  });

  test('generates GetX Routing setup and adds pubspec dependencies correctly', () async {
    final generator = RouteGenerator();
    final pubspecModifier = PubspecModifier();

    await generator.generate(tempDir.path, 'GetX Routing');
    await pubspecModifier.addRouterDependencies(tempDir.path, 'GetX Routing');

    final routerFile = File(p.join(tempDir.path, 'lib', 'core', 'router', 'app_router.dart'));
    final mainFile = File(p.join(tempDir.path, 'lib', 'main.dart'));
    final pubspecFile = File(p.join(tempDir.path, 'pubspec.yaml'));

    expect(routerFile.existsSync(), isTrue);
    expect(mainFile.existsSync(), isTrue);

    final routerContent = routerFile.readAsStringSync();
    expect(routerContent, contains('package:get/get.dart'));
    expect(routerContent, contains('class AppPages'));

    final mainContent = mainFile.readAsStringSync();
    expect(mainContent, contains('GetMaterialApp'));
    expect(mainContent, contains('getPages: AppPages.routes'));

    final pubspecContent = pubspecFile.readAsStringSync();
    expect(pubspecContent, contains('get:'));
  });

  test('MetadataConfigService stores and retrieves router configuration', () async {
    final service = MetadataConfigService();
    service.writeConfig(
      tempDir.path,
      architecture: 'Clean',
      stateManagement: 'Bloc',
      router: 'Go Router',
    );

    final config = service.readConfig(tempDir.path);
    expect(config, isNotNull);
    expect(config!.architecture, equals('Clean'));
    expect(config.stateManagement, equals('Bloc'));
    expect(config.router, equals('Go Router'));
  });
}
