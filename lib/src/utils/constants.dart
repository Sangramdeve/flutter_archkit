class K {
  static String androidAppPath = 'android/app';

  static String androidSrcPath = '$androidAppPath/src';

  static String androidIconPath =
      '$androidAppPath/src/%s/res/%s/ic_launcher.png';

  static String androidAdaptiveIconBackgroundPath =
      '$androidAppPath/src/%s/res/%s/ic_launcher_background.png';

  static String androidAdaptiveIconForegroundPath =
      '$androidAppPath/src/%s/res/%s/ic_launcher_foreground.png';

  static String androidAdaptiveIconMonochromePath =
      '$androidAppPath/src/%s/res/%s/ic_launcher_monochrome.png';

  static String androidAdaptiveIconXmlPath =
      '$androidAppPath/src/%s/res/mipmap-anydpi-v26/ic_launcher.xml';

  static String androidManifestPath =
      '$androidSrcPath/main/AndroidManifest.xml';

  static String androidBuildKotlinPath = '$androidAppPath/build.gradle.kts';
  static String androidBuildLegacyPath = '$androidAppPath/build.gradle';

  static String androidFlavorizrLegacyName = 'flavorizr.gradle';
  static String androidFlavorizrKotlinName = 'flavorizr.gradle.kts';

  static String androidFlavorizrLegacyPath =
      '$androidAppPath/$androidFlavorizrLegacyName';
  static String androidFlavorizrKotlinPath =
      '$androidAppPath/$androidFlavorizrKotlinName';

  static String darwinAppIconContentsFileName = 'Contents.json';

  static String flutterPath = 'lib';

  static String flutterFlavorPath = '$flutterPath/flavors.dart';

  static String flutterAppPath = '$flutterPath/app.dart';

  static String flutterMainPath = '$flutterPath/main.dart';

  static String flutterPagesPath = '$flutterPath/pages';

  static String flutterMainPagePath = '$flutterPagesPath/my_home_page.dart';

  static String iOSPath = 'ios';

  static String iOSFlutterPath = '$iOSPath/Flutter';

  static String iOSRunnerPath = '$iOSPath/Runner';

  static String iOSRunnerProjectPath = '$iOSPath/Runner.xcodeproj';

  static String iOSPodfilePath = '$iOSPath/Podfile';

  static String iOSPListPath = '$iOSRunnerPath/Info.plist';

  static String iOSAssetsPath = '$iOSRunnerPath/Assets.xcassets';

  static String iOSAppIconPath = '$iOSAssetsPath/AppIcon-%s.appiconset/%s';

  static String iOSFirebaseScriptPath = '$iOSPath/firebaseScript.sh';

  static String assetsZipPath = 'assets.tmp.zip';

  static String tempPath = '.tmp';

  static String tempAndroidPath = '$tempPath/android';

  static String tempAndroidResPath = '$tempAndroidPath/res';

  static String tempFlutterPath = '$tempPath/flutter';

  static String tempFlutterAppPath = '$tempFlutterPath/app.dart';

  static String tempFlutterMainPath = '$tempFlutterPath/main.dart';

  static String tempFlutterPagesPath = '$tempFlutterPath/pages';

  static String tempiOSPath = '$tempPath/ios';

  static String tempiOSAssetsPath = '$tempiOSPath/Assets.xcassets';

  static String tempiOSLaunchScreenPath =
      '$tempiOSPath/LaunchScreen.storyboard';

  static String tempMacOSPath = '$tempPath/macos';

  static String tempMacOSAssetsPath = '$tempMacOSPath/Assets.xcassets';

  static String tempWindowsPath = '$tempPath/windows';

  static String tempWindowsIconPath = '$tempWindowsPath/app_icon.ico';

  static String ideaPath = '.idea';

  static String ideaLaunchpath = '$ideaPath/runConfigurations';

  static String vsCodePath = '.vscode';

  static String vsCodeLaunchPath = '$vsCodePath/launch.json';

  const K._();
}
