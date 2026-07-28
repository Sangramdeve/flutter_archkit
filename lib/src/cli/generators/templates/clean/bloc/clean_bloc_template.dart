import 'package:path/path.dart' as p;
import '../../template_generator.dart';

class CleanBlocTemplate {
  static void generate(TemplateGenerator generator, String basePath) {
    generator.writeFile(
      p.join(basePath, 'presentation', 'bloc', 'home_event.dart'),
      '''
abstract class HomeEvent {}

class LoadHomeDataEvent extends HomeEvent {}
''',
    );

    generator.writeFile(
      p.join(basePath, 'presentation', 'bloc', 'home_state.dart'),
      '''
abstract class HomeState {}

class HomeInitial extends HomeState {}
class HomeLoading extends HomeState {}
class HomeLoaded extends HomeState {
  final String data;
  HomeLoaded(this.data);
}
''',
    );

    generator.writeFile(
      p.join(basePath, 'presentation', 'bloc', 'home_bloc.dart'),
      '''
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/home_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeUseCase homeUseCase;

  HomeBloc({required this.homeUseCase}) : super(HomeInitial()) {
    on<LoadHomeDataEvent>((event, emit) async {
      emit(HomeLoading());
      final result = await homeUseCase();
      emit(HomeLoaded(result));
    });
  }
}
''',
    );
  }
}
