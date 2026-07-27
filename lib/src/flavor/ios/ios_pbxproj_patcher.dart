import 'dart:io';

import 'package:dart_xcodeproj/dart_xcodeproj.dart';
import '../parser/flavor_config.dart';

/// Patches project.pbxproj to register build configurations and xcconfig file references for flavors.
class IosPbxprojPatcher {
  final List<FlavorConfig> flavors;
  final String projectRoot;

  IosPbxprojPatcher({required this.flavors, required this.projectRoot});

  Future<void> run() async {
    final xcodeprojPath = '$projectRoot/ios/Runner.xcodeproj';
    final pbxprojFile = File('$xcodeprojPath/project.pbxproj');

    if (!await pbxprojFile.exists()) {
      stderr.writeln('❌ Could not find ios/Runner.xcodeproj/project.pbxproj');
      return;
    }

    try {
      final project = await XcodeProject.open(xcodeprojPath);

      PBXGroup? flutterGroup;
      try {
        flutterGroup = project.groups.firstWhere((g) => g.name == 'Flutter');
      } catch (_) {
        flutterGroup = project.mainGroup;
      }

      final nativeTarget =
          project.targets.firstWhere(
                (t) => t is PBXNativeTarget,
                orElse: () => project.targets.first,
              )
              as PBXNativeTarget;

      for (final flavor in flavors) {
        for (final mode in ['Debug', 'Profile', 'Release']) {
          final configName = '$mode-${flavor.name}';
          final configType = mode == 'Debug'
              ? BuildConfigType.debug
              : BuildConfigType.release;

          final xcconfigPath = 'Flutter/$configName.xcconfig';

          PBXFileReference? fileRef = project.files
              .cast<PBXFileReference?>()
              .firstWhere(
                (f) =>
                    f?.path == xcconfigPath ||
                    f?.name == '$configName.xcconfig',
                orElse: () => null,
              );

          if (fileRef == null) {
            fileRef = project.newObject<PBXFileReference>(
              (g, u) => PBXFileReference(g, u),
            );
            fileRef.path = xcconfigPath;
            fileRef.name = '$configName.xcconfig';
            fileRef.sourceTree = '<group>';
            fileRef.lastKnownFileType = 'text.xcconfig';
            flutterGroup.children.add(fileRef);
          }

          final targetConfigList = nativeTarget.buildConfigurationList;
          if (targetConfigList != null) {
            var targetConfig = targetConfigList[configName];
            if (targetConfig == null) {
              targetConfig = project.newObject<XCBuildConfiguration>(
                (g, u) => XCBuildConfiguration(g, u),
              );
              targetConfig.name = configName;
              targetConfigList.buildConfigurations.add(targetConfig);
            }
            targetConfig.baseConfigurationReference = fileRef;
            targetConfig.buildSettings = {'PRODUCT_NAME': r'$(TARGET_NAME)'};
          }

          final baseConfig = project.buildConfigurations
              .cast<XCBuildConfiguration?>()
              .firstWhere((c) => c?.name == mode, orElse: () => null);

          final projectConfig = project.addBuildConfiguration(
            configName,
            configType,
          );
          projectConfig.baseConfigurationReference = fileRef;

          if (baseConfig != null) {
            projectConfig.buildSettings = {
              ...Map<String, dynamic>.from(baseConfig.buildSettings),
            };
          }
        }
      }

      await project.save();
      stdout.writeln(
        '✏️  Updated ios/Runner.xcodeproj/project.pbxproj using dart_xcodeproj',
      );
      return;
    } catch (e) {
      stderr.writeln(
        '⚠️ Failed to update project.pbxproj with dart_xcodeproj: $e. Falling back to regex patcher.',
      );
    }

    await _patchPbxprojRegex(pbxprojFile);
  }

  Future<void> _patchPbxprojRegex(File pbxprojFile) async {
    String content = await pbxprojFile.readAsString();

    final fileRefsBuffer = StringBuffer();
    final flutterGroupChildrenBuffer = StringBuffer();
    final Map<String, String> xcconfigFileRefs = {};

    for (final flavor in flavors) {
      for (final config in ['Debug', 'Profile', 'Release']) {
        final key = '$config-${flavor.name}';
        final fileRefId = _generatePbxId('FileRef-$key');
        xcconfigFileRefs[key] = fileRefId;

        fileRefsBuffer.writeln(
          '\t\t$fileRefId /* $config-${flavor.name}.xcconfig */ = {isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = text.xcconfig; name = "$config-${flavor.name}.xcconfig"; path = "Flutter/$config-${flavor.name}.xcconfig"; sourceTree = "<group>"; };',
        );
        flutterGroupChildrenBuffer.writeln(
          '\t\t\t\t$fileRefId /* $config-${flavor.name}.xcconfig */,',
        );
      }
    }

    const fileRefSectionStart = '/* Begin PBXFileReference section */\n';
    if (content.contains(fileRefSectionStart)) {
      content = content.replaceFirst(
        fileRefSectionStart,
        fileRefSectionStart + fileRefsBuffer.toString(),
      );
    }

    final flutterGroupRegExp = RegExp(
      r'(/\* Flutter \*/\s*=\s*\{\s*isa\s*=\s*PBXGroup;\s*children\s*=\s*\()',
      multiLine: true,
    );
    if (flutterGroupRegExp.hasMatch(content)) {
      content = content.replaceFirstMapped(
        flutterGroupRegExp,
        (m) =>
            '${m.group(1)}\n${flutterGroupChildrenBuffer.toString().trimRight()}',
      );
    }

    final buildConfigRegExp = RegExp(
      r'(\t\t([0-9A-F]{24}) /\* ([^*]+) \*/ = \{\s*isa = XCBuildConfiguration;(?:\s*baseConfigurationReference = [^;]+;)?\s*buildSettings = \{([\s\S]*?)\};\s*name = ([^;]+);\s*\};)',
      multiLine: true,
    );

    final List<Map<String, String>> existingConfigs = [];
    for (final match in buildConfigRegExp.allMatches(content)) {
      existingConfigs.add({
        'block': match.group(1)!,
        'id': match.group(2)!,
        'comment': match.group(3)!,
        'buildSettings': match.group(4)!,
        'name': match.group(5)!.replaceAll('"', '').trim(),
      });
    }

    final configListRegExp = RegExp(
      r'(\t\t([0-9A-F]{24}) /\* (Build configuration list for [^*]+) \*/ = \{\s*isa = XCConfigurationList;\s*buildConfigurations = \(([\s\S]*?)\);)',
      multiLine: true,
    );

    final newBuildConfigsBuffer = StringBuffer();
    final Map<String, List<String>> newConfigsForLists = {};

    for (final listMatch in configListRegExp.allMatches(content)) {
      final listId = listMatch.group(2)!;
      final configsText = listMatch.group(4)!;

      final List<String> listConfigIds = [];
      final idRegExp = RegExp(r'([0-9A-F]{24})\s*/\* ([^*]+) \*/');
      for (final idMatch in idRegExp.allMatches(configsText)) {
        listConfigIds.add(idMatch.group(1)!);
      }

      final listNewConfigLines = <String>[];

      for (final flavor in flavors) {
        for (final configType in ['Debug', 'Profile', 'Release']) {
          final baseConfig = existingConfigs.firstWhere(
            (c) => listConfigIds.contains(c['id']) && c['name'] == configType,
            orElse: () => <String, String>{},
          );

          if (baseConfig.isNotEmpty) {
            final newConfigName = '$configType-${flavor.name}';
            final newConfigId = _generatePbxId('Config-$listId-$newConfigName');
            final fileRefId = xcconfigFileRefs[newConfigName]!;

            listNewConfigLines.add(
              '\t\t\t\t$newConfigId /* $newConfigName */,',
            );

            newBuildConfigsBuffer.writeln(
              '\t\t$newConfigId /* $newConfigName */ = {\n'
              '\t\t\tisa = XCBuildConfiguration;\n'
              '\t\t\tbaseConfigurationReference = $fileRefId /* $configType-${flavor.name}.xcconfig */;\n'
              '\t\t\tbuildSettings = {${baseConfig['buildSettings']}\t\t\t};\n'
              '\t\t\tname = "$newConfigName";\n'
              '\t\t};',
            );
          }
        }
      }

      if (listNewConfigLines.isNotEmpty) {
        newConfigsForLists[listId] = listNewConfigLines;
      }
    }

    const buildConfigSectionStart =
        '/* Begin XCBuildConfiguration section */\n';
    if (content.contains(buildConfigSectionStart)) {
      content = content.replaceFirst(
        buildConfigSectionStart,
        buildConfigSectionStart + newBuildConfigsBuffer.toString(),
      );
    }

    for (final entry in newConfigsForLists.entries) {
      final listId = entry.key;
      final newLines = entry.value.join('\n');
      final specificListRegExp = RegExp(
        '($listId /\\* [^*]+ \\*/ = \\{\\s*isa = XCConfigurationList;\\s*buildConfigurations = \\()',
        multiLine: true,
      );
      content = content.replaceFirstMapped(
        specificListRegExp,
        (m) => '${m.group(1)}\n$newLines',
      );
    }

    await pbxprojFile.writeAsString(content);
    stdout.writeln(
      '✏️  Updated ios/Runner.xcodeproj/project.pbxproj with build configurations and file references for flavors.',
    );
  }

  String _generatePbxId(String seed) {
    final part1 = seed.hashCode.abs().toRadixString(16).padLeft(8, '0');
    final part2 = '${seed}part2'.hashCode
        .abs()
        .toRadixString(16)
        .padLeft(8, '0');
    final part3 = '${seed}part3'.hashCode
        .abs()
        .toRadixString(16)
        .padLeft(8, '0');
    return '$part1$part2$part3'.substring(0, 24).toUpperCase();
  }
}
