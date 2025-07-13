import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:navysync/models/team.dart';
import 'package:navysync/models/user.dart';
import 'package:navysync/pages/team_details_view.dart';
import 'package:navysync/services/auth_service.dart';
import 'package:navysync/models/permission.dart' as permissions;

class TeamsView extends StatefulWidget {
  const TeamsView({super.key});

  @override
  State<TeamsView> createState() => _TeamsViewState();
}

class _TeamsViewState extends State<TeamsView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<List<Team>> _teamsStream;

  @override
  void initState() {
    super.initState();
    _teamsStream = _fetchTeams();
  }

  Stream<List<Team>> _fetchTeams() {
    return _firestore.collection('teams').snapshots().map((snapshot) {
      // only return teams where members contains the current user id
      final user = AuthService().currentUser;
      return snapshot.docs
          .map((doc) => Team.fromFirestore(doc))
          .where((team) => team.members.contains(user?.id ?? ''))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teams')),
      body: StreamBuilder<List<Team>>(
        stream: _teamsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final teams = snapshot.data ?? [];
          if (teams.isEmpty) {
            return const Center(child: Text('No teams found.'));
          }
          return ListView.builder(
            itemCount: teams.length,
            itemBuilder: (context, index) {
              final team = teams[index];
              return ListTile(
                title: Text(team.name),
                subtitle: Text(team.description),
                onTap: () => context.push('/teams/${team.id}'),
              );
            },
          );
        },
      ),
    );
  }
}

class TeamCreateView extends StatelessWidget {
  const TeamCreateView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Team')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final user =  AuthService().currentUser;
          
            if (user == null || !user.hasPermission(permissions.Permission.CREATE, permissions.Permission.RESOURCE_TEAM )) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('You do not have permission to create a team.'),
                ),
              );
              return;
            }
            // Logic to create a new team
            // This could involve showing a dialog or navigating to a form page
          },
          child: const Text('Create New Team'),
        ),
      ),
    );
  }
}
