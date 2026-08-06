import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:interact/interact.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_archkit/src/cli/generators/storage/storage_generator.dart';

class StorageCommand extends Command<int> {
  @override
  String get name => 'storage';

  @override
  List<String> get aliases => const ['db', 'database'];

  @override
  String get description =>
      'Generate local database storage solution (Hive, SQLite, Drift, ObjectBox)';

  final StorageGenerator _storageGenerator;

  StorageCommand({StorageGenerator? storageGenerator})
      : _storageGenerator = storageGenerator ?? StorageGenerator() {
    argParser
      ..addOption(
        'type',
        abbr: 't',
        help: 'Local database type (Hive, SQLite, Drift, ObjectBox)',
      )
      ..addOption(
        'path',
        abbr: 'p',
        help: 'Target project path (defaults to current directory)',
      )
      ..addFlag(
        'override',
        help: 'Overwrite existing storage files if present',
        defaultsTo: true,
      );
  }

  @override
  Future<int> run() async {
    final logger = Logger();

    logger.info('${lightGreen.wrap('✔')} Flutter Archkit Storage Generator\n');

    final targetPath = argResults?['path'] as String? ?? Directory.current.path;
    final projectPath = p.canonicalize(targetPath);
    final pubspecFile = File(p.join(projectPath, 'pubspec.yaml'));

    if (!pubspecFile.existsSync()) {
      logger.err(
        'No pubspec.yaml found at $projectPath. Please run this command inside a Flutter project directory.',
      );
      return ExitCode.noInput.code;
    }

    final typeOption = argResults?['type'] as String?;
    String selectedStorage;
    final storageChoices = const [
      'Hive',
      'SQLite (sqflite)',
      'Drift',
      'ObjectBox',
    ];

    if (typeOption != null && typeOption.isNotEmpty) {
      final normalized = typeOption.toLowerCase();
      selectedStorage = storageChoices.firstWhere(
        (e) => e.toLowerCase().contains(normalized),
        orElse: () => typeOption,
      );
    } else {
      final index = Select(
        prompt: 'Select Local Database',
        options: storageChoices,
        initialIndex: 0,
      ).interact();
      selectedStorage = storageChoices[index];
    }

    logger.info('${'Selected Database'.padRight(18)}: $selectedStorage\n');

    final shouldOverride = argResults?['override'] as bool? ?? true;

    final progress = logger.progress('Generating $selectedStorage setup...');
    try {
      await _storageGenerator.generate(
        projectPath,
        selectedStorage,
        override: shouldOverride,
      );
      progress.complete('$selectedStorage storage setup generated successfully!');

      logger.info('\n${lightGreen.wrap('✔')} Done! Run "flutter pub get" (and "dart run build_runner build" if needed) to complete setup.');
      return ExitCode.success.code;
    } catch (e) {
      progress.fail('Failed to generate storage setup: $e');
      return ExitCode.software.code;
    }
  }
}
