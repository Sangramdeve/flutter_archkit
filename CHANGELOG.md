## 0.0.2

* Initial release of `flutter_archkit`.
* Interactive project generator (`archkit create`) supporting Clean, MVVM, and MVC architectures.
* Integrated state management templates for Bloc, Cubit, Riverpod, Provider, and GetX.
* Feature module generator (`archkit feature <name>` / `archkit -f <name>`) for dynamic feature scaffolding.
* Automatic project architecture detection via `.metadata` configuration persistence.
* Modular template engine architecture (`lib/src/cli/generators/templates/`).
* Automated multi-flavor generator for Flutter applications (`setup_flavor`).
* Multi-flavor Android Gradle configuration (`build.gradle.kts`).
* iOS `.xcconfig` build configurations, shared `.xcscheme` schemes, `Info.plist` patching, and `project.pbxproj` updates.
* Dart `ServerConfig` (`lib/core/config/server_config.dart`) and flavor entry points (`lib/main_<flavor>.dart`).
* VS Code debug launch configurations (`.vscode/launch.json`).
