import 'dart:io';

class ProcessService {
  /// Runs a Flutter CLI command, trying `flutter` first, and falling back to `fvm flutter`
  /// if `flutter` is not found or fails in an FVM-only environment.
  Future<ProcessResult> _runFlutterCommand({
    required List<String> flutterArgs,
    String? workingDirectory,
  }) async {
    // 1. Try standard 'flutter' executable
    try {
      final result = await Process.run(
        'flutter',
        flutterArgs,
        workingDirectory: workingDirectory,
        runInShell: true,
      );
      if (result.exitCode == 0) {
        return result;
      }
    } catch (_) {}

    // 2. Fallback to 'fvm flutter' for FVM environments
    try {
      final fvmResult = await Process.run(
        'fvm',
        ['flutter', ...flutterArgs],
        workingDirectory: workingDirectory,
        runInShell: true,
      );
      if (fvmResult.exitCode == 0) {
        return fvmResult;
      }
    } catch (_) {}

    // 3. Final attempt using standard 'flutter' to capture exitCode & output
    return Process.run(
      'flutter',
      flutterArgs,
      workingDirectory: workingDirectory,
      runInShell: true,
    );
  }

  Future<ProcessResult> runFlutterCreate({
    required String name,
    required String organization,
    required List<String> platforms,
    String? workingDirectory,
  }) async {
    final args = [
      'create',
      '--org',
      organization,
    ];
    if (platforms.isNotEmpty) {
      args.addAll(['--platforms', platforms.join(',')]);
    }
    args.add(name);

    return _runFlutterCommand(
      flutterArgs: args,
      workingDirectory: workingDirectory,
    );
  }

  Future<ProcessResult> runFlutterPubGet({
    required String projectPath,
  }) async {
    return _runFlutterCommand(
      flutterArgs: ['pub', 'get'],
      workingDirectory: projectPath,
    );
  }
}
