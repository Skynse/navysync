import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:navysync/pages/auth/auth_gate.dart';
import 'package:navysync/pages/auth/authentication_page.dart';
import 'package:navysync/pages/auth/verify_email_page.dart';
import 'package:navysync/pages/home_page.dart';
import 'package:navysync/pages/profile.dart';
import 'package:navysync/pages/tasks.dart';
import 'package:navysync/pages/team_details_view.dart';
import 'package:navysync/pages/teams.dart';
import 'package:navysync/pages/team_manage_view.dart';
import 'package:navysync/pages/calendar_page.dart';
import 'package:navysync/pages/create_event_page.dart';
import 'package:navysync/constants.dart';

final router = GoRouter(
  initialLocation: '/auth_gate',
  routes: [
    GoRoute(path: '/auth_gate', builder: (context, state) => const AuthGate()),
    GoRoute(
      path: '/authentication',
      builder: (context, state) => const AuthenticationPage(),
    ),
    GoRoute(
      path: '/verify_email',
      builder: (context, state) => const VerifyEmailPage(),
    ),
    StatefulShellRoute.indexedStack(
      builder:
          (context, state, navigationShell) =>
              ScaffoldWithNestedNavigation(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/teams',
              builder: (context, state) => const TeamsView(),
              routes: [
                GoRoute(
                  path: ':teamId',
                  builder: (context, state) {
                    final teamId = state.pathParameters['teamId']!;
                    return TeamDetailsView(teamId: teamId);
                  },
                  routes: [
                    GoRoute(
                      path: 'manage',
                      builder: (context, state) {
                        final teamId = state.pathParameters['teamId']!;
                        return TeamManageView(teamId: teamId);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/tasks',
              builder: (context, state) => const TasksView(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/calendar',
              builder: (context, state) => const CalendarPage(),
            ),
          ],
        ),
      ],
    ),
    // Standalone routes (not in bottom nav)
    GoRoute(
      path: '/create-event',
      builder: (context, state) => const CreateEventPage(),
    ),
  ],
);

class ScaffoldWithNestedNavigation extends StatelessWidget {
  const ScaffoldWithNestedNavigation({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _goBranch,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.darkGray,
        backgroundColor: AppColors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Teams',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_outlined),
            activeIcon: Icon(Icons.task),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
        ],
      ),
    );
  }
}
