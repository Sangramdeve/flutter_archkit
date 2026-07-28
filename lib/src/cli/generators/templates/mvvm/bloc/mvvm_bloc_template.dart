import 'package:path/path.dart' as p;
import '../../template_generator.dart';

class MvvmBlocTemplate {
  static void generate(TemplateGenerator generator, String libPath) {
    generator.writeFile(
      p.join(libPath, 'viewmodels', 'home_event.dart'),
      '''
abstract class HomeEvent {}
class FetchHomeData extends HomeEvent {}
''',
    );

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
      p.join(libPath, 'viewmodels', 'home_bloc.dart'),
      '''
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/home_service.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeService service;

  HomeBloc({required this.service}) : super(HomeInitial()) {
    on<FetchHomeData>((event, emit) async {
      final res = await service.fetchData();
      emit(HomeLoaded(res));
    });
  }
}
''',
    );
  }
}
