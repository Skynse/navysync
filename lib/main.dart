import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:navysync/components/menu_nav.dart';
import 'package:navysync/pages/home_page.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
  
    );
  }
}

final _router = GoRouter(
  initialLocation: '/home',
  
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, child) {
        return Scaffold(
          body: child,
          bottomNavigationBar: MenuNav(),
        );
      },

      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => HomeScreen(
            
              ),
            ),
          ]
        ),
      ]
    ),
  ],
);
