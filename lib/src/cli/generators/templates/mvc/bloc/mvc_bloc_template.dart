import 'package:path/path.dart' as p;
import '../../template_generator.dart';

class MvcBlocTemplate {
  static void generate(TemplateGenerator generator, String libPath) {
    generator.writeFile(
      p.join(libPath, 'controllers', 'home_event.dart'),
      '''
abstract class HomeEvent {}
class UpdateHomeData extends HomeEvent {}
''',
    );

    generator.writeFile(
      p.join(libPath, 'controllers', 'home_state.dart'),
      '''
abstract class HomeState {}
class HomeInitial extends HomeState {}
class HomeUpdated extends HomeState {
  final String data;
  HomeUpdated(this.data);
}
''',
    );

    generator.writeFile(
      p.join(libPath, 'controllers', 'home_bloc.dart'),
      '''
import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<UpdateHomeData>((event, emit) {
      emit(HomeUpdated('Updated MVC Data via Bloc'));
    });
  }
}
''',
    );
  }
}
