import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_archkit/src/models/project_config.dart';

void main() {
  test('ProjectConfig model initialization test', () {
    const config = ProjectConfig(
      name: 'my_app',
      architecture: 'Clean',
      stateManagement: 'Bloc',
      organization: 'com.example',
      platforms: ['android', 'ios'],
    );

    expect(config.name, equals('my_app'));
    expect(config.architecture, equals('Clean'));
    expect(config.stateManagement, equals('Bloc'));
    expect(config.organization, equals('com.example'));
    expect(config.platforms, equals(['android', 'ios']));
  });
}
