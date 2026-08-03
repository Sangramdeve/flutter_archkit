import 'dart:io';
import 'package:path/path.dart' as p;

class RouteGenerator {
  Future<void> generate(String projectPath, String routerOption) async {
    final routerDir = Directory(p.join(projectPath, 'lib', 'core', 'router'));
    if (!routerDir.existsSync()) {
      routerDir.createSync(recursive: true);
    }

    final normalized = _normalizeRouterOption(routerOption);

    // Detect existing home page / view
    final cleanHome = File(p.join(projectPath, 'lib', 'features', 'home', 'presentation', 'page', 'home_page.dart'));
    final mvvmHome = File(p.join(projectPath, 'lib', 'views', 'home_view.dart'));

    String homeImport = '';
    String homeWidget = "const Scaffold(body: Center(child: Text('Home Page')))";

    if (cleanHome.existsSync()) {
      homeImport = "import '../../features/home/presentation/page/home_page.dart';";
      homeWidget = "const HomePage()";
    } else if (mvvmHome.existsSync()) {
      homeImport = "import '../../views/home_view.dart';";
      homeWidget = "const HomeView()";
    }

    switch (normalized) {
      case 'navigator1':
        _generateNavigator1(projectPath, homeImport, homeWidget);
        break;
      case 'navigator2':
        _generateNavigator2(projectPath, homeImport, homeWidget);
        break;
      case 'go_router':
        _generateGoRouter(projectPath, homeImport, homeWidget);
        break;
      case 'auto_route':
        _generateAutoRoute(projectPath, homeImport, homeWidget);
        break;
      case 'getx':
        _generateGetX(projectPath, homeImport, homeWidget);
        break;
      default:
        _generateNavigator1(projectPath, homeImport, homeWidget);
    }
  }

  String _normalizeRouterOption(String option) {
    final lower = option.toLowerCase();
    if (lower.contains('1') || lower.contains('navigator 1')) return 'navigator1';
    if (lower.contains('2') || lower.contains('navigator 2')) return 'navigator2';
    if (lower.contains('go_router') || lower.contains('go router') || lower.contains('go')) return 'go_router';
    if (lower.contains('auto_route') || lower.contains('auto route') || lower.contains('auto')) return 'auto_route';
    if (lower.contains('getx') || lower.contains('get')) return 'getx';
    return 'navigator1';
  }

  void _generateNavigator1(String projectPath, String homeImport, String homeWidget) {
    final routerFile = File(p.join(projectPath, 'lib', 'core', 'router', 'app_router.dart'));
    final code = '''
import 'package:flutter/material.dart';
${homeImport.isNotEmpty ? '$homeImport\n' : ''}
class AppRoutes {
  static const String home = '/';
  static const String details = '/details';
}

class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => $homeWidget,
        );
      case AppRoutes.details:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Details Page')),
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for \${settings.name}')),
          ),
        );
    }
  }
}
''';
    routerFile.writeAsStringSync(code);

    final mainFile = File(p.join(projectPath, 'lib', 'main.dart'));
    final mainCode = '''
import 'package:flutter/material.dart';
import 'core/router/app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
''';
    mainFile.writeAsStringSync(mainCode);
  }

  void _generateNavigator2(String projectPath, String homeImport, String homeWidget) {
    final routerFile = File(p.join(projectPath, 'lib', 'core', 'router', 'app_router.dart'));
    final code = '''
import 'package:flutter/material.dart';
${homeImport.isNotEmpty ? '$homeImport\n' : ''}
class AppRoutePath {
  final String path;
  const AppRoutePath.home() : path = '/';
  const AppRoutePath.details() : path = '/details';
  const AppRoutePath.unknown() : path = '/404';

  bool get isHomePage => path == '/';
  bool get isDetailsPage => path == '/details';
  bool get isUnknown => path == '/404';
}

class AppRouteInformationParser extends RouteInformationParser<AppRoutePath> {
  @override
  Future<AppRoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = routeInformation.uri;
    if (uri.pathSegments.isEmpty) {
      return const AppRoutePath.home();
    }
    if (uri.pathSegments.length == 1 && uri.pathSegments.first == 'details') {
      return const AppRoutePath.details();
    }
    return const AppRoutePath.unknown();
  }

  @override
  RouteInformation? restoreRouteInformation(AppRoutePath configuration) {
    if (configuration.isUnknown) {
      return RouteInformation(uri: Uri.parse('/404'));
    }
    if (configuration.isDetailsPage) {
      return RouteInformation(uri: Uri.parse('/details'));
    }
    return RouteInformation(uri: Uri.parse('/'));
  }
}

class AppRouterDelegate extends RouterDelegate<AppRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoutePath> {
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  AppRoutePath _currentPath = const AppRoutePath.home();

  @override
  AppRoutePath get currentConfiguration => _currentPath;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        MaterialPage(
          key: const ValueKey('HomePage'),
          child: $homeWidget,
        ),
        if (_currentPath.isDetailsPage)
          const MaterialPage(
            key: ValueKey('DetailsPage'),
            child: Scaffold(
              body: Center(child: Text('Details Page')),
            ),
          ),
        if (_currentPath.isUnknown)
          const MaterialPage(
            key: ValueKey('UnknownPage'),
            child: Scaffold(
              body: Center(child: Text('Page Not Found')),
            ),
          ),
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) return false;
        _currentPath = const AppRoutePath.home();
        notifyListeners();
        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(AppRoutePath configuration) async {
    _currentPath = configuration;
  }
}
''';
    routerFile.writeAsStringSync(code);

    final mainFile = File(p.join(projectPath, 'lib', 'main.dart'));
    final mainCode = '''
import 'package:flutter/material.dart';
import 'core/router/app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppRouterDelegate _routerDelegate = AppRouterDelegate();
  final AppRouteInformationParser _routeInformationParser = AppRouteInformationParser();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerDelegate: _routerDelegate,
      routeInformationParser: _routeInformationParser,
    );
  }
}
''';
    mainFile.writeAsStringSync(mainCode);
  }

  void _generateGoRouter(String projectPath, String homeImport, String homeWidget) {
    final routerFile = File(p.join(projectPath, 'lib', 'core', 'router', 'app_router.dart'));
    final code = '''
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
${homeImport.isNotEmpty ? '$homeImport\n' : ''}
class AppRouter {
  static const String home = '/';
  static const String details = '/details';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        builder: (context, state) => $homeWidget,
      ),
      GoRoute(
        path: details,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Details Page')),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Error: \${state.error}')),
    ),
  );
}
''';
    routerFile.writeAsStringSync(code);

    final mainFile = File(p.join(projectPath, 'lib', 'main.dart'));
    final mainCode = '''
import 'package:flutter/material.dart';
import 'core/router/app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: AppRouter.router,
    );
  }
}
''';
    mainFile.writeAsStringSync(mainCode);
  }

  void _generateAutoRoute(String projectPath, String homeImport, String homeWidget) {
    final routerFile = File(p.join(projectPath, 'lib', 'core', 'router', 'app_router.dart'));
    final code = '''
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
${homeImport.isNotEmpty ? '$homeImport\n' : ''}
part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends _\$AppRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: HomeRoute.page, initial: true),
      ];
}

@RoutePage()
class HomePageWidget extends StatelessWidget {
  const HomePageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return $homeWidget;
  }
}
''';
    routerFile.writeAsStringSync(code);

    final mainFile = File(p.join(projectPath, 'lib', 'main.dart'));
    final mainCode = '''
import 'package:flutter/material.dart';
import 'core/router/app_router.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final _appRouter = AppRouter();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: _appRouter.config(),
    );
  }
}
''';
    mainFile.writeAsStringSync(mainCode);
  }

  void _generateGetX(String projectPath, String homeImport, String homeWidget) {
    final routerFile = File(p.join(projectPath, 'lib', 'core', 'router', 'app_router.dart'));
    final code = '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';
${homeImport.isNotEmpty ? '$homeImport\n' : ''}
abstract class Routes {
  static const HOME = '/';
  static const DETAILS = '/details';
}

class AppPages {
  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: Routes.HOME,
      page: () => $homeWidget,
    ),
    GetPage(
      name: Routes.DETAILS,
      page: () => const Scaffold(
        body: Center(child: Text('Details Page')),
      ),
    ),
  ];
}
''';
    routerFile.writeAsStringSync(code);

    final mainFile = File(p.join(projectPath, 'lib', 'main.dart'));
    final mainCode = '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/router/app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}
''';
    mainFile.writeAsStringSync(mainCode);
  }
}
