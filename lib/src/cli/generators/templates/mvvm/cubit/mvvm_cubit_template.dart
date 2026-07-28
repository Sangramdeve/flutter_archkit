import 'package:path/path.dart' as p;
import '../../template_generator.dart';

class MvvmCubitTemplate {
  static void generate(TemplateGenerator generator, String libPath) {
    generator.writeFile(
      p.join(libPath, 'viewmodels', 'home_state.dart'),
      '''
abstract class HomeState {}
class HomeInitial extends HomeState {}
class HomeLoaded extends HomeState {
  final String data;
  HomeLoaded(this.data);
}
''',
    );

    generator.writeFile(
      p.join(libPath, 'viewmodels', 'home_cubit.dart'),
      '''
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/home_service.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeService service;

  HomeCubit({required this.service}) : super(HomeInitial());

  Future<void> loadData() async {
    final res = await service.fetchData();
    emit(HomeLoaded(res));
  }
}
''',
    );
  }
}
