import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:navysync/components/menu_nav.dart';
import 'package:navysync/pages/home_page.dart';
import 'package:navysync/pages/tasks.dart';
import 'package:navysync/pages/teams.dart';
import './router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
