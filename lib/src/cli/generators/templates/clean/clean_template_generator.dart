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
  Future<void> generate(ProjectConfig config, String projectPath) async {
    final base = p.join(projectPath, 'lib', 'features', 'home');
    final sm = config.stateManagement.toLowerCase();

    // Data layer
    writeFile(
      p.join(base, 'data', 'data_sources', 'home_remote_datasource.dart'),
      '''
abstract class HomeRemoteDataSource {
  Future<String> getHomeData();
}
''',
    );

    writeFile(
      p.join(base, 'data', 'data_sources', 'home_remote_datasource_impl.dart'),
      '''
import 'home_remote_datasource.dart';

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  @override
  Future<String> getHomeData() async {
    return 'Data loaded from HomeRemoteDataSource';
  }
}
''',
    );

    writeFile(
      p.join(base, 'data', 'models', 'home_model.dart'),
      '''
class HomeModel {
  final String title;

  const HomeModel({required this.title});

  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return HomeModel(title: json['title'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'title': title};
  }
}
''',
    );

    writeFile(
      p.join(base, 'data', 'repositories', 'home_repository_impl.dart'),
      '''
import '../../domain/repositories/home_repository.dart';
import '../data_sources/home_remote_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<String> getHomeData() async {
    return await remoteDataSource.getHomeData();
  }
}
''',
    );

    // DI layer
    writeFile(
      p.join(base, 'di', 'home_di.dart'),
      '''
import '../data/data_sources/home_remote_datasource.dart';
import '../data/data_sources/home_remote_datasource_impl.dart';
import '../data/repositories/home_repository_impl.dart';
import '../domain/repositories/home_repository.dart';
import '../domain/usecases/home_usecase.dart';

class HomeDI {
  static HomeUseCase provideHomeUseCase() {
    final remoteDataSource = HomeRemoteDataSourceImpl();
    final repository = HomeRepositoryImpl(remoteDataSource: remoteDataSource);
    return HomeUseCase(repository: repository);
  }
}
''',
    );

    writeFile(
      p.join(base, 'di', 'home_di.config.dart'),
      '''
// Auto-generated or manual DI configuration file for Home feature
''',
    );

    // Domain layer
    writeFile(
      p.join(base, 'domain', 'repositories', 'home_repository.dart'),
      '''
abstract class HomeRepository {
  Future<String> getHomeData();
}
''',
    );

    writeFile(
      p.join(base, 'domain', 'usecases', 'home_usecase.dart'),
      '''
import '../repositories/home_repository.dart';

class HomeUseCase {
  final HomeRepository repository;

  HomeUseCase({required this.repository});

  Future<String> call() async {
    return await repository.getHomeData();
  }
}
''',
    );

    // Presentation layer (State Management)
    switch (sm) {
      case 'bloc':
        CleanBlocTemplate.generate(this, base);
        break;
      case 'cubit':
        CleanCubitTemplate.generate(this, base);
        break;
      case 'riverpod':
        CleanRiverpodTemplate.generate(this, base);
        break;
      case 'provider':
        CleanProviderTemplate.generate(this, base);
        break;
      case 'getx':
      case 'get':
        CleanGetXTemplate.generate(this, base);
        break;
      default:
        CleanBlocTemplate.generate(this, base);
    }

    // Page view
    writeFile(
      p.join(base, 'presentation', 'page', 'home_page.dart'),
      '''
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clean Architecture Home'),
      ),
      body: const Center(
        child: Text('Home Page View'),
      ),
    );
  }
}
''',
    );
  }
}
