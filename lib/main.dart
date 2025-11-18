import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'menu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const ControlPanelApp());
}

class ControlPanelApp extends StatelessWidget {
  const ControlPanelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Foresight Menu",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
        useMaterial3: true,
      ),
      home: const ControlPanelPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}


