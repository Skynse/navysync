import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:navysync/models/team.dart';
import 'package:navysync/models/user.dart';
import '../constants.dart';

class GuestPage extends StatefulWidget {
  const GuestPage({super.key});

  @override
  State<GuestPage> createState() => _GuestPageState();
}

class _GuestPageState extends State<GuestPage> {
  Future<Map<String, List<dynamic>>> loadTeams() async {
    final snapshot = await FirebaseFirestore.instance.collection('teams').get();
    final teamsList = <Team>[];
    final leadersList = <NavySyncUser>[];

    for (var doc in snapshot.docs) {
      var team = Team.fromFirestore(doc);
      teamsList.add(team);

      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(team.teamLeaderId)
              .get();

      if (userDoc.exists) {
        var leader = NavySyncUser.fromFirestore(userDoc);
        leadersList.add(leader);
      }
    }

    return {'teams': teamsList, 'leaders': leadersList};
  }

  Widget buildTeamPreview(List<Team> teams, List<NavySyncUser> leaders) {
    return ListView.builder(
      itemBuilder: (context, index) {
        final team = teams[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Text(
                team.name.isNotEmpty ? team.name[0].toUpperCase() : '',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            style: ListTileStyle.drawer,
            contentPadding: const EdgeInsets.all(24),
            title: Text(
              team.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Description: ${team.description}'),
                Text('Team Leader: ${leaders[index].name}'),
                Text('${team.memberCount} members'),
              ],
            ),
            isThreeLine: true,
            onTap: () {
              showModalBottomSheet<void>(
                useSafeArea: true,
                isScrollControlled: true,
                context: context,
                builder: (BuildContext context) {
                  return TeamPreviewPage(team: team, leader: leaders[index]);
                },
              );
            },
          ),
        );
      },
      itemCount: teams.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Guest Page',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.navyBlue,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: FutureBuilder<Map<String, List<dynamic>>>(
        future: loadTeams(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!['teams']!.isEmpty) {
            return const Center(child: Text('No teams found'));
          }

          final teams = snapshot.data!['teams']! as List<Team>;
          final leaders = snapshot.data!['leaders']! as List<NavySyncUser>;

          return buildTeamPreview(teams, leaders);
        },
      ),
    );
  }
}

class TeamPreviewPage extends StatefulWidget {
  Team team;
  NavySyncUser? leader;
  TeamPreviewPage({super.key, required this.team, this.leader});

  @override
  State<TeamPreviewPage> createState() => _TeamPreviewPageState();
}

class _TeamPreviewPageState extends State<TeamPreviewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.team.name,
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.navyBlue,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.team.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Team Leader: ${widget.leader?.name ?? 'Unknown'}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 10),
            Text(
              widget.team.description,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Text(
              'Members: ${widget.team.memberCount}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
