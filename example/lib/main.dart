import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter ArchKit Example',
      theme: ThemeData(primaryColor: Colors.blue, useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(title: const Text('Flutter ArchKit Example')),
        body: const Center(
          child: Text(
            'Run `dart run flutter_archkit:setup_flavor` to configure flavors.',
          ),
        ),
      ),
    );
  }
}
