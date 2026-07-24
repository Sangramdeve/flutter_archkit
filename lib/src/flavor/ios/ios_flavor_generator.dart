import '../parser/flavor_config.dart';
import 'ios_pbxproj_patcher.dart';
import 'ios_plist_patcher.dart';
import 'ios_scheme_generator.dart';
import 'ios_xcconfig_generator.dart';

/// Generates iOS flavor support by executing individual sub-generators:
/// - [IosXcconfigGenerator]: generates per-flavor .xcconfig files in ios/Flutter
/// - [IosSchemeGenerator]: generates .xcscheme files for Xcode
/// - [IosPlistPatcher]: patches Info.plist to read CFBundleDisplayName & BaseURL
/// - [IosPbxprojPatcher]: registers build configurations & xcconfig references in project.pbxproj
class IosFlavorGenerator {
  final List<FlavorConfig> flavors;
  final String projectRoot;

  IosFlavorGenerator({required this.flavors, this.projectRoot = '.'});

  Future<void> run() async {
    await IosXcconfigGenerator(
      flavors: flavors,
      projectRoot: projectRoot,
    ).run();
    await IosSchemeGenerator(flavors: flavors, projectRoot: projectRoot).run();
    await IosPlistPatcher(projectRoot: projectRoot).run();
    await IosPbxprojPatcher(flavors: flavors, projectRoot: projectRoot).run();
  }
}
