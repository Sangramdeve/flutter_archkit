import 'dart:io';

import 'package:dart_xcodeproj/dart_xcodeproj.dart';
import '../parser/flavor_config.dart';

const _testProductTypes = {
  'com.apple.product-type.bundle.unit-test',
  'com.apple.product-type.bundle.ui-testing',
};

/// Generates Xcode schemes (.xcscheme) for each flavor under
/// ios/Runner.xcodeproj/xcshareddata/xcschemes using `dart_xcodeproj`.
class IosSchemeGenerator {
  final List<FlavorConfig> flavors;
  final String projectRoot;

  IosSchemeGenerator({required this.flavors, required this.projectRoot});

  Future<void> run() async {
    final xcodeprojPath = '$projectRoot/ios/Runner.xcodeproj';
    final xcodeprojFile = File('$xcodeprojPath/project.pbxproj');

    if (await xcodeprojFile.exists()) {
      try {
        final project = await XcodeProject.open(xcodeprojPath);
        final targets = project.targets.whereType<PBXNativeTarget>().toList();
        final target = targets.isNotEmpty ? targets.first : null;

        for (final flavor in flavors) {
          final scheme = XCScheme.create();
          scheme.launchAction.buildConfiguration = 'Debug-${flavor.name}';
          scheme.testAction.buildConfiguration = 'Debug-${flavor.name}';
          scheme.profileAction.buildConfiguration = 'Profile-${flavor.name}';
          scheme.analyzeAction.buildConfiguration = 'Debug-${flavor.name}';
          scheme.archiveAction.buildConfiguration = 'Release-${flavor.name}';

          if (target != null) {
            final ref = BuildableReference();
            ref.setReferenceTarget(
              target.uuid,
              '${target.productName ?? target.name}.app',
              target.name ?? 'Runner',
              'container:${project.name}.xcodeproj',
            );
            final runnable = BuildableProductRunnable();
            runnable.runnableDebuggingMode = '0';
            runnable.buildableReference = ref;
            scheme.launchAction.buildableProductRunnable = runnable;
            scheme.profileAction.buildableProductRunnable = runnable;

            final macroExpansion = MacroExpansion();
            macroExpansion.setBuildableReference(ref);
            scheme.testAction.addMacroExpansion(macroExpansion);

            final testTargets = project.targets
                .whereType<PBXNativeTarget>()
                .where((t) => _testProductTypes.contains(t.productType));

            for (final testTarget in testTargets) {
              final testRef = BuildableReference()
                ..setReferenceTarget(
                  testTarget.uuid,
                  '${testTarget.productName ?? testTarget.name}.xctest',
                  testTarget.name!,
                  'container:${project.name}.xcodeproj',
                );
              final testable = TestableReference()
                ..skipped = false
                ..parallelizable = false
                ..addBuildableReference(testRef);
              scheme.testAction.addTestable(testable);
            }
          }

          final schemesDir = Directory('$xcodeprojPath/xcshareddata/xcschemes');
          if (!await schemesDir.exists()) {
            await schemesDir.create(recursive: true);
          }

          final schemePath = '${schemesDir.path}/${flavor.name}.xcscheme';
          await scheme.saveAs(schemePath);
          print('Created $schemePath');
        }
        return;
      } catch (e) {
        stderr.writeln(
          '⚠️ Failed to generate scheme using dart_xcodeproj: $e. Falling back to template XML generation.',
        );
      }
    }

    await _generateFallbackSchemes();
  }

  Future<void> _generateFallbackSchemes() async {
    final schemesDir = Directory(
      '$projectRoot/ios/Runner.xcodeproj/xcshareddata/xcschemes',
    );
    if (!await schemesDir.exists()) {
      await schemesDir.create(recursive: true);
    }

    for (final flavor in flavors) {
      final file = File('${schemesDir.path}/${flavor.name}.xcscheme');
      final content =
          '''<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "1510"
   version = "1.3">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "97C146ED1CF9000F007C117D"
               BuildableName = "Runner.app"
               BlueprintName = "Runner"
               ReferencedContainer = "container:Runner.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug-${flavor.name}"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      customLLDBInitFile = "\$(SRCROOT)/Flutter/ephemeral/flutter_lldbinit"
      shouldUseLaunchSchemeArgsEnv = "YES">
      <MacroExpansion>
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "97C146ED1CF9000F007C117D"
            BuildableName = "Runner.app"
            BlueprintName = "Runner"
            ReferencedContainer = "container:Runner.xcodeproj">
         </BuildableReference>
      </MacroExpansion>
      <Testables>
      </Testables>
   </TestAction>
   <LaunchAction
      buildConfiguration = "Debug-${flavor.name}"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      customLLDBInitFile = "\$(SRCROOT)/Flutter/ephemeral/flutter_lldbinit"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "97C146ED1CF9000F007C117D"
            BuildableName = "Runner.app"
            BlueprintName = "Runner"
            ReferencedContainer = "container:Runner.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Profile-${flavor.name}"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useCustomWorkingDirectory = "NO"
      debugDocumentVersioning = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "97C146ED1CF9000F007C117D"
            BuildableName = "Runner.app"
            BlueprintName = "Runner"
            ReferencedContainer = "container:Runner.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug-${flavor.name}">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release-${flavor.name}"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>
''';

      await file.writeAsString(content);
      print('Created ${file.path}');
    }
  }
}
