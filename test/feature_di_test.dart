import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_archkit/src/models/project_config.dart';
import 'package:flutter_archkit/src/cli/generators/templates/clean/clean_template_generator.dart';
import 'package:flutter_archkit/src/cli/generators/project/pubspec_modifier.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('feature_di_test_');
    final pubspecFile = File(p.join(tempDir.path, 'pubspec.yaml'));
    pubspecFile.writeAsStringSync('''
name: test_app
description: Test app for feature DI

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

  test(
      'generates Clean Architecture feature with Dependency Injection (GetIt + Injectable)',
      () async {
    const config = ProjectConfig(
      name: 'auth',
      architecture: 'Clean',
      stateManagement: 'Bloc',
      organization: 'com.example',
      platforms: ['android', 'ios'],
      useDi: true,
    );

    final generator = CleanTemplateGenerator();
    final pubspecModifier = PubspecModifier();

    await generator.generate(config, tempDir.path, featureName: 'auth');
    await pubspecModifier.addDependencies(tempDir.path, config.stateManagement);
    await pubspecModifier.addDIDependencies(tempDir.path);

    final dsFile = File(p.join(tempDir.path, 'lib', 'features', 'auth', 'data',
        'data_sources', 'auth_remote_datasource_impl.dart'));
    final repoFile = File(p.join(tempDir.path, 'lib', 'features', 'auth',
        'data', 'repositories', 'auth_repository_impl.dart'));
    final usecaseFile = File(p.join(tempDir.path, 'lib', 'features', 'auth',
        'domain', 'usecases', 'auth_usecase.dart'));
    final blocFile = File(p.join(tempDir.path, 'lib', 'features', 'auth',
        'presentation', 'bloc', 'auth_bloc.dart'));
    final diFile = File(
        p.join(tempDir.path, 'lib', 'features', 'auth', 'di', 'auth_di.dart'));
    final pubspecFile = File(p.join(tempDir.path, 'pubspec.yaml'));

    expect(dsFile.existsSync(), isTrue);
    expect(repoFile.existsSync(), isTrue);
    expect(usecaseFile.existsSync(), isTrue);
    expect(blocFile.existsSync(), isTrue);
    expect(diFile.existsSync(), isTrue);

    final dsContent = dsFile.readAsStringSync();
    expect(dsContent, contains('@LazySingleton(as: AuthRemoteDataSource)'));

    final repoContent = repoFile.readAsStringSync();
    expect(repoContent, contains('@LazySingleton(as: AuthRepository)'));

    final usecaseContent = usecaseFile.readAsStringSync();
    expect(usecaseContent, contains('@lazySingleton'));

    final blocContent = blocFile.readAsStringSync();
    expect(blocContent, contains('@injectable'));

    final diContent = diFile.readAsStringSync();
    expect(diContent, contains('@InjectableInit('));
    expect(diContent, contains("initializerName: 'initAuthDi'"));
    expect(diContent, contains("generateForDir: ['lib/features/auth']"));

    final pubspecContent = pubspecFile.readAsStringSync();
    expect(pubspecContent, contains('get_it:'));
    expect(pubspecContent, contains('injectable:'));
    expect(pubspecContent, contains('injectable_generator:'));
    expect(pubspecContent, contains('build_runner:'));
  });

  test(
      'generates Clean Architecture feature without DI annotations when useDi is false',
      () async {
    const config = ProjectConfig(
      name: 'profile',
      architecture: 'Clean',
      stateManagement: 'Bloc',
      organization: 'com.example',
      platforms: ['android', 'ios'],
      useDi: false,
    );

    final generator = CleanTemplateGenerator();
    await generator.generate(config, tempDir.path, featureName: 'profile');

    final dsFile = File(p.join(tempDir.path, 'lib', 'features', 'profile',
        'data', 'data_sources', 'profile_remote_datasource_impl.dart'));
    final repoFile = File(p.join(tempDir.path, 'lib', 'features', 'profile',
        'data', 'repositories', 'profile_repository_impl.dart'));

    final dsContent = dsFile.readAsStringSync();
    expect(dsContent, isNot(contains('@LazySingleton')));

    final repoContent = repoFile.readAsStringSync();
    expect(repoContent, isNot(contains('@LazySingleton')));
  });
}
