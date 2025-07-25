import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:navysync/models/event.dart';
import 'package:navysync/pages/auth/auth_gate.dart';
import 'package:navysync/pages/auth/authentication_page.dart';
import 'package:navysync/pages/auth/verify_email_page.dart';
import 'package:navysync/pages/home_page.dart';
import 'package:navysync/pages/profile.dart';
import 'package:navysync/pages/tasks.dart';
import 'package:navysync/pages/team_details_view.dart';
import 'package:navysync/pages/team_events_view.dart';
import 'package:navysync/pages/teams.dart';
import 'package:navysync/pages/team_manage_view.dart';
import 'package:navysync/pages/calendar_page.dart';
import 'package:navysync/pages/create_event_page.dart';

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

                  routes: [
                    // Route for event details, passing the event object via extra
                  ],
                ),

                // GoRoute(
                //   path: 'events/:eventId',
                //   builder: (context, state) {
                //     final event = state.extra as Event?;
                //     if (event == null) {
                //       // Handle missing event object, e.g., show error or fallback
                //       return Scaffold(
                //         body: Center(child: Text('Event not found')),
                //       );
                //     }
                //     return TeamEventsView(eventObject: event);
                //   },
                // ),
                GoRoute(
                  path: ':teamId/manage',
                  builder: (context, state) {
                    final teamId = state.pathParameters['teamId']!;
                    return TeamManageView(teamId: teamId);
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
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/calendar',
              builder: (context, state) => CalendarPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/create-event',
              builder: (context, state) => CreateEventPage(),
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
