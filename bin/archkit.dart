import 'package:flutter_archkit/src/cli/command_runner.dart';

Future<void> main(List<String> arguments) async {
  await FlutterArchkitCommandRunner().run(arguments);
}
