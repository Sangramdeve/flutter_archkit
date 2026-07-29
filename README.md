# Flutter ArchKit

[![pub package](https://img.shields.io/pub/v/flutter_archkit.svg)](https://pub.dev/packages/flutter_archkit)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A comprehensive Flutter Architecture CLI generator and multi-flavor configuration tool. `flutter_archkit` automates scaffolding Flutter projects with Clean, MVVM, or MVC architecture, state management (Bloc, Cubit, Riverpod, Provider, GetX), modular feature generators, and multi-flavor environment configurations.

---

## Features

- 🏗️ **Interactive Project Generator (`archkit create`)**: Scaffolds complete Flutter apps with interactive CLI prompts for Architecture, State Management, Organization ID, and Target Platforms.
- ⚡ **Feature Module Generator (`archkit feature <name>` / `archkit -f <name>`)**: Instantly generates feature modules (`auth`, `profile`, `home`, etc.) matching your project's architecture.
- 🔄 **Smart Metadata Auto-Detection**: Stores selected settings in `.metadata` so feature generation works without requiring command flags.
- 📂 **Modular Template Engine**: Clean templates for Clean Architecture (data, domain, presentation, di), MVVM (models, services, viewmodels, views), and MVC (models, controllers, views).
- 🤖 **Android Flavor Setup**: Automatically configures `productFlavors` and `applicationId` in `android/app/flavor.gradle.kts` and links with `build.gradle.kts`.
- 🍎 **iOS Flavor Setup**: Generates flavor `.xcconfig` files, CocoaPods target dependencies (`#include? Pods-Runner`), shared `.xcscheme` schemes, patches `Info.plist`, updates Xcode `project.pbxproj` build configurations, and sets `IPHONEOS_DEPLOYMENT_TARGET = 16.0`.
- ⚙️ **Dart ServerConfig**: Generates strongly-typed `lib/core/config/server_config.dart` runtime environment configurations.
- 💻 **IDE Support**: Automatically writes `.vscode/launch.json` for VS Code and `.run/<flavor>.run.xml` run configurations for Android Studio / IntelliJ IDEA.

---

## Installation

Activate `flutter_archkit` globally via Pub:

```bash
dart pub global activate flutter_archkit
```

Or add it to your project `pubspec.yaml` under `dev_dependencies`:

```yaml
dev_dependencies:
  flutter_archkit: ^0.0.3
```

---

## Usage Guide

### 1. Creating a New Flutter Project (`archkit create`)

Run the interactive project creation wizard:

```bash
archkit create my_app
```

**Interactive Prompts:**
- **Select Architecture**: `Clean` | `MVVM` | `MVC`
- **Select State Management**: `Bloc` | `Cubit` | `Riverpod` | `Provider` | `GetX`
- **Organization Identifier**: e.g., `com.example`
- **Platforms**: `Android`, `iOS`, `Web`, `Windows`, `macOS`, `Linux`

Or pass parameters via command flags:
```bash
archkit create my_app --org com.example --architecture Clean --state-management Bloc --platforms android,ios
```

---

### 2. Scaffolding a Feature Module (`archkit feature <name>` / `archkit -f <name>`)

Inside any project created with `archkit`, run:

```bash
archkit feature auth
```

or use the shortcut:

```bash
archkit -f auth
```

`archkit` auto-detects your project's architecture and state management from `.metadata` and generates the feature module matching your established code structure!

---

### 3. Multi-Flavor Setup (`setup_flavor`)

Generate a sample `flavor.yaml` automatically:

```bash
dart run flutter_archkit:setup_flavor --init
```

Or create `flavor.yaml` manually in your project root:

```yaml
flavors:
  dev:
    app:
      name: "Example Dev"
      baseUrl: "https://dev-api.example.com"
    android:
      applicationId: "com.example.app.dev"
    ios:
      bundleId: "com.example.app.dev"

  prod:
    app:
      name: "Example"
      baseUrl: "https://api.example.com"
    android:
      applicationId: "com.example.app"
    ios:
      bundleId: "com.example.app"
```

Validate your configuration:

```bash
dart run flutter_archkit:setup_flavor --validate
```

Execute the multi-flavor code generator:

```bash
dart run flutter_archkit:setup_flavor
```

---

## Generated Architecture Layouts

### Clean Architecture (`lib/features/auth/`)
```text
lib/features/auth/
├── data/
│   ├── data_sources/
│   │   ├── auth_remote_datasource.dart
│   │   └── auth_remote_datasource_impl.dart
│   ├── models/
│   │   └── auth_model.dart
│   └── repositories/
│       └── auth_repository_impl.dart
├── di/
│   ├── auth_di.dart
│   └── auth_di.config.dart
├── domain/
│   ├── repositories/
│   │   └── auth_repository.dart
│   └── usecases/
│       └── auth_usecase.dart
└── presentation/
    ├── bloc/ (or cubit / riverpod / provider / controllers)
    │   ├── auth_bloc.dart
    │   ├── auth_event.dart
    │   └── auth_state.dart
    └── page/
        └── auth_page.dart
```

### MVVM Architecture (`lib/`)
```text
lib/
├── models/auth_model.dart
├── services/auth_service.dart
├── viewmodels/auth_provider.dart (or auth_viewmodel.dart / auth_bloc.dart / auth_controller.dart)
└── views/auth_view.dart
```

### MVC Architecture (`lib/`)
```text
lib/
├── models/auth_model.dart
├── controllers/auth_controller.dart
└── views/auth_view.dart
```

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
