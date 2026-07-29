## 0.0.3

* Updated `flavor.yaml` schema with structured `app.name`, `app.baseUrl`, `android.applicationId`, and `ios.bundleId` definitions.
* Improved Android flavor generator (`android/app/flavor.gradle.kts`) with explicit `applicationId` and idempotency block replacements.
* Fixed iOS Xcode project patcher (`project.pbxproj`) to inherit full target `buildSettings` (`INFOPLIST_FILE`, `SWIFT_VERSION`, `PRODUCT_BUNDLE_IDENTIFIER`, bridging headers) across all flavor build configurations.
* Added auto-upgrade for `IPHONEOS_DEPLOYMENT_TARGET = 16.0` in `project.pbxproj`.
* Added CocoaPods target xcconfig inclusions (`Pods-Runner.<config>-<flavor>.xcconfig` and `Pods-Runner.<mode>.xcconfig`).
* Added FVM fallback support in `ProcessService` for `flutter create` and `pub get`.
* Fixed runtime environment switch logic bug in generated `lib/core/config/server_config.dart`.
* Added Android Studio / IntelliJ IDEA 1-click run configuration generator (`.run/<flavor>.run.xml`).
* Added `--validate` and `--init` flags to `setup_flavor` CLI tool.
* Updated SDK constraint compatibility to `">=3.0.0 <4.0.0"`.

## 0.0.2

* Fixed CLI setup issue and package metadata updates.

## 0.0.1

* Initial release of `flutter_archkit`.
* Interactive project generator (`archkit create`) supporting Clean, MVVM, and MVC architectures.
* Integrated state management templates for Bloc, Cubit, Riverpod, Provider, and GetX.
* Feature module generator (`archkit feature <name>` / `archkit -f <name>`) for dynamic feature scaffolding.
* Automatic project architecture detection via `.metadata` configuration persistence.
* Automated multi-flavor generator for Flutter applications (`setup_flavor`).
