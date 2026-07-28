import 'dart:io';

class ProcessService {
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

    return Process.run(
      'flutter',
      args,
      workingDirectory: workingDirectory,
      runInShell: true,
    );
  }

  Future<ProcessResult> runFlutterPubGet({
    required String projectPath,
  }) async {
    return Process.run(
      'flutter',
      ['pub', 'get'],
      workingDirectory: projectPath,
      runInShell: true,
    );
  }
}
