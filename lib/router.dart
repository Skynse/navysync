import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:navysync/pages/auth/auth_gate.dart';
import 'package:navysync/pages/auth/authentication_page.dart';
import 'package:navysync/pages/home_page.dart';
import 'package:navysync/pages/profile.dart';
import 'package:navysync/pages/tasks.dart';
import 'package:navysync/pages/teams.dart';

final router = GoRouter(
  initialLocation: '/auth_gate',

  routes: [
    GoRoute(
      path: '/auth_gate',
      builder: (context, state) {
        // This is where you would check if the user is authenticated
        // and redirect accordingly. For now, we just return HomeScreen.
        return AuthGate();
      },
    ),

    GoRoute(
      path: '/authentication',
      builder: (context, state) {
        // This is where you would show the authentication page
        return const AuthenticationPage();
      },
    ),

    StatefulShellRoute.indexedStack(
      builder:
          (context, state, navigationShell) =>
              ScaffoldWithNestedNavigation(navigationShell: navigationShell),

      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/home', builder: (context, state) => HomeScreen()),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/teams',
              builder: (context, state) => TeamsView(),
              routes: [
                GoRoute(
                  path: ':teamId',
                  builder: (context, state) {
                    final teamId = state.pathParameters['teamId']!;
                    return TeamDetailsView(teamId: teamId);
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/tasks', builder: (context, state) => TasksView()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => ProfilePage(),
            ),
          ],
        ),
      ],
    ),
  ],
);

class ScaffoldWithNestedNavigation extends StatefulWidget {
  const ScaffoldWithNestedNavigation({Key? key, required this.navigationShell})
    : super(key: key ?? const ValueKey('ScaffoldWithNestedNavigation'));
  final StatefulNavigationShell navigationShell;

  @override
  State<ScaffoldWithNestedNavigation> createState() =>
      _ScaffoldWithNestedNavigationState();
}

class _ScaffoldWithNestedNavigationState
    extends State<ScaffoldWithNestedNavigation> {
  void _goBranch(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: widget.navigationShell,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: widget.navigationShell.currentIndex,
          onTap: (index) => setState(() => _goBranch(index)),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Teams'),
            BottomNavigationBarItem(icon: Icon(Icons.task), label: "Tasks"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          iconSize: 30,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}
