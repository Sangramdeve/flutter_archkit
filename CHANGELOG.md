## 0.0.1

* Initial release of `flutter_archkit`.
* Automated multi-flavor generator for Flutter applications.
* Configures Android product flavors (`build.gradle.kts`).
* Generates iOS `.xcconfig` build configurations, shared `.xcscheme` schemes, patches `Info.plist`, and updates `project.pbxproj`.
* Generates Dart `ServerConfig` (`lib/core/config/server_config.dart`) and main entry points (`lib/main_<flavor>.dart`).
* Generates VS Code debug launch configurations (`.vscode/launch.json`).
* CLI tool support via `dart run flutter_archkit:setup_flavor`.
