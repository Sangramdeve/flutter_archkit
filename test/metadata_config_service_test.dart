import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_archkit/src/services/metadata_config_service.dart';

void main() {
  test('MetadataConfigService read and write test', () async {
    final tempDir = await Directory.systemTemp.createTemp('metadata_test_');
    final service = MetadataConfigService();

    // Write initial config
    service.writeConfig(
      tempDir.path,
      architecture: 'MVVM',
      stateManagement: 'Riverpod',
    );

    final config = service.readConfig(tempDir.path);
    expect(config, isNotNull);
    expect(config!.architecture, equals('MVVM'));
    expect(config.stateManagement, equals('Riverpod'));

    // Update config
    service.writeConfig(
      tempDir.path,
      architecture: 'Clean',
      stateManagement: 'Bloc',
    );
    final updatedConfig = service.readConfig(tempDir.path);
    expect(updatedConfig, isNotNull);
    expect(updatedConfig!.architecture, equals('Clean'));
    expect(updatedConfig.stateManagement, equals('Bloc'));

    await tempDir.delete(recursive: true);
  });
}
