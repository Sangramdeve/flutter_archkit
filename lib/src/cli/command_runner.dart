import 'package:args/command_runner.dart';
import 'package:flutter_archkit/src/cli/commands/create_command.dart';

class FlutterArchkitCommandRunner extends CommandRunner<int> {
  FlutterArchkitCommandRunner()
    : super('flutter_archkit', 'Flutter Architecture Generator') {
    addCommand(CreateCommand());
  }
}
