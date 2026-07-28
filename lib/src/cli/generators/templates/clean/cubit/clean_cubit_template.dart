import 'package:path/path.dart' as p;
import '../../template_generator.dart';

class CleanCubitTemplate {
  static void generate(TemplateGenerator generator, String basePath) {
    generator.writeFile(
      p.join(basePath, 'presentation', 'cubit', 'home_state.dart'),
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
      p.join(basePath, 'presentation', 'cubit', 'home_cubit.dart'),
      '''
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/home_usecase.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeUseCase homeUseCase;

  HomeCubit({required this.homeUseCase}) : super(HomeInitial());

  Future<void> loadData() async {
    emit(HomeLoading());
    final result = await homeUseCase();
    emit(HomeLoaded(result));
  }
}
''',
    );
  }
}
