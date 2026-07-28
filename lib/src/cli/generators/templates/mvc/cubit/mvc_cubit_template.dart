import 'package:path/path.dart' as p;
import '../../template_generator.dart';

class MvcCubitTemplate {
  static void generate(TemplateGenerator generator, String libPath) {
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
      p.join(libPath, 'controllers', 'home_cubit.dart'),
      '''
import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  void updateData(String newData) {
    emit(HomeUpdated(newData));
  }
}
''',
    );
  }
}
