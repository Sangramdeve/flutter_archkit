# Flutter ArchKit

[![pub package](https://img.shields.io/pub/v/flutter_archkit.svg)](https://pub.dev/packages/flutter_archkit)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A powerful, automated multi-flavor configuration tool and package for Flutter applications. `flutter_archkit` automates setting up environment flavors across Android, iOS, VS Code, and Dart entry points with a single YAML configuration file.

---

## Features

- 🤖 **Android Flavor Setup**: Automatically configures `productFlavors` and `dimension` in `android/app/build.gradle.kts`.
- 🍎 **iOS Configuration**: Generates flavor `.xcconfig` files, shared `.xcscheme` schemes, patches `Info.plist` display names, and updates Xcode `project.pbxproj` build configurations.
- ⚙️ **Dart ServerConfig**: Generates `lib/core/config/server_config.dart` and flavor main entrypoints (`lib/main_<flavor>.dart`).
- 💻 **IDE Support**: Automatically writes `.vscode/launch.json` with debug/profile/release configurations for each flavor.
- 🛠️ **CLI Tool**: Run via `dart run flutter_archkit:setup_flavor`.

---

## Getting Started

Add `flutter_archkit` to your `pubspec.yaml` under `dev_dependencies` or `dependencies`:

```yaml
dev_dependencies:
  flutter_archkit: ^0.0.1
```

Or run:

```bash
flutter pub add --dev flutter_archkit
```

---

## Quick Start / Usage

### 1. Create `flavor.yaml`

Create a `flavor.yaml` file in your root project directory:

```yaml
flavors:
  dev:
    appName: "MyApp Dev"
    applicationIdSuffix: ".dev"
    baseUrl: "https://dev.api.example.com"
  prod:
    appName: "MyApp"
    baseUrl: "https://api.example.com"
```

### 2. Run the CLI Generator

Run the command to setup all flavor files automatically:

```bash
dart run flutter_archkit:setup_flavor
```

Optionally specify a custom YAML file path:

```bash
dart run flutter_archkit:setup_flavor --config=custom_flavor.yaml
```

---

## Output Structure

The CLI generator generates/patches the following files:

- 📱 `android/app/build.gradle.kts`
- 🍎 `ios/Flutter/Flavors/*.xcconfig`
- 🍎 `ios/Runner.xcodeproj/xcshareddata/xcschemes/*.xcscheme`
- 🍎 `ios/Runner/Info.plist`
- 🍎 `ios/Runner.xcodeproj/project.pbxproj`
- 🎯 `lib/core/config/server_config.dart`
- 🎯 `lib/main_<flavor>.dart`
- 💻 `.vscode/launch.json`

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
