import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:navysync/pages/auth/auth_gate.dart';
import 'package:navysync/pages/auth/authentication_page.dart';
import 'package:navysync/pages/auth/verify_email_page.dart';
import 'package:navysync/pages/create_announcement_page.dart';
import 'package:navysync/pages/departments.dart';
import 'package:navysync/pages/department_details_view.dart';
import 'package:navysync/pages/home_page.dart';
import 'package:navysync/pages/profile.dart';
import 'package:navysync/pages/team_details_view.dart';
import 'package:navysync/pages/teams.dart';
import 'package:navysync/pages/team_manage_view.dart';
import 'package:navysync/pages/calendar_page.dart';
import 'package:navysync/pages/create_event_page.dart';
import 'package:navysync/pages/team_events_view.dart';
import 'package:navysync/pages/learn_page.dart';
import 'package:navysync/models/event.dart';
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
              path: '/departments',
              builder: (context, state) => const DepartmentsView(),
              routes: [
                GoRoute(
                  path: ':departmentId',
                  builder: (context, state) {
                    final departmentId = state.pathParameters['departmentId']!;
                    return DepartmentDetailsView(departmentId: departmentId);
                  },
                  routes: [
                    GoRoute(
                      path: 'manage',
                      builder: (context, state) {
                        final departmentId =
                            state.pathParameters['departmentId']!;
                        // TODO: Create DepartmentManageView
                        return Scaffold(
                          appBar: AppBar(
                            title: const Text('Manage Department'),
                          ),
                          body: const Center(
                            child: Text('Department management coming soon'),
                          ),
                        );
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
              path: '/calendar',
              builder: (context, state) => const CalendarPage(),
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
      ],
    ),
    // Standalone routes (not in bottom nav)
    GoRoute(path: '/learn', builder: (context, state) => const LearnPage()),
    GoRoute(
      path: '/create-event',
      builder: (context, state) => const CreateEventPage(),
    ),
    GoRoute(
      path: '/team-events',
      builder: (context, state) {
        final event = state.extra as Event;
        return TeamEventsView(eventObject: event);
      },
    ),
    GoRoute(
      path: '/create-announcement',
      builder: (context, state) => CreateAnnouncementPage(),
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
            icon: Icon(Icons.business_outlined),
            activeIcon: Icon(Icons.business),
            label: 'Departments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
