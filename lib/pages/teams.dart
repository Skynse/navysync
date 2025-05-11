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
      description: 'Frontend and backend development team working on core features',
     
      teamLeaderId: 'user123',
      members: ['user123', 'user124', 'user125', 'user126'],
    ),
    Team(
      id: 'team2',
      name: 'Design Squad',
      description: 'UI/UX design team responsible for product design and user experience',
      
      teamLeaderId: 'user127',
      members: ['user127', 'user128', 'user129'],
    ),
    Team(
      id: 'team3',
      name: 'Quality Assurance',
      description: 'Testing and quality assurance team ensuring product reliability',
    
      teamLeaderId: 'user130',
      members: ['user130', 'user131', 'user132', 'user133', 'user134'],
    ),
  ];
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Teams')), 
    
    body: CustomScrollView(
      slivers: [
        SliverList.builder(
          itemCount: getDummyTeams().length,
          itemBuilder: (context, index) {
            final team = getDummyTeams()[index];
            return Card(
              child: ListTile(
                title: Text(team.name),
                subtitle: Text(team.description),

              )
            );

          }
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
