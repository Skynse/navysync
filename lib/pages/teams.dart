import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:navysync/models/team.dart';

class TeamsView extends StatefulWidget {
  const TeamsView({super.key});

  @override
  State<TeamsView> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<TeamsView> {
  List<Team> getDummyTeams() {
    return [
      Team(
        id: 'team1',
        name: 'Development Team Alpha',
        description:
            'Frontend and backend development team working on core features',

        teamLeaderId: 'user123',
        members: ['user123', 'user124', 'user125', 'user126'],
      ),
      Team(
        id: 'team2',
        name: 'Design Squad',
        description:
            'UI/UX design team responsible for product design and user experience',

        teamLeaderId: 'user127',
        members: ['user127', 'user128', 'user129'],
      ),
      Team(
        id: 'team3',
        name: 'Quality Assurance',
        description:
            'Testing and quality assurance team ensuring product reliability',

        teamLeaderId: 'user130',
        members: ['user130', 'user131', 'user132', 'user133', 'user134'],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teams')),

      body: CustomScrollView(
        slivers: [
          SliverList.builder(
            itemCount: getDummyTeams().length,
            itemBuilder: (context, index) {
              final team = getDummyTeams()[index];
              return Card(
                child: ListTile(
                  onTap: () {
                    context.push('/teams/${team.id}');
                  },
                  title: Text(team.name),
                  subtitle: Text(team.description),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/teams/create');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TeamDetailsView extends StatefulWidget {
  final String teamId;
  const TeamDetailsView({super.key, required this.teamId});

  @override
  State<TeamDetailsView> createState() => _TeamDetailsViewState();
}

class _TeamDetailsViewState extends State<TeamDetailsView> {
  Team team = Team(
    id: 'team3',
    name: 'Quality Assurance',
    description:
        'Testing and quality assurance team ensuring product reliability',

    teamLeaderId: 'user130',
    members: ['user130', 'user131', 'user132', 'user133', 'user134'],
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(team.name), backgroundColor: Colors.blue),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              color: Colors.blue.withOpacity(0.1),
              padding: const EdgeInsets.all(16),
              child: Text(
                team.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Announcements',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ListTile(
                            title: const Text('Announcement name'),
                            subtitle: const Text('Announcement description'),
                            leading: const Icon(Icons.announcement),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Upcoming Events',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ListTile(
                            title: const Text('Event name'),
                            subtitle: const Text('Event description'),
                            leading: const Icon(Icons.event),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Activities',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 3,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text('Activity ${index + 1}'),
                                subtitle: const Text('Activity description'),
                                leading: const Icon(Icons.work),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add functionality for creating new announcements/events
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
