import 'package:cloud_firestore/cloud_firestore.dart';

class Team {
  final String id;
  final String name;
  final String description;
  final String teamLeaderId;
  final List<String> members;

  Team({
    required this.id,
    required this.name,
    required this.description,

    required this.teamLeaderId,
    required this.members,
  });

  factory Team.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final members = List<String>.from(data['members'] ?? []);
    print('[Team.fromFirestore] doc.id: \\${doc.id}, members: \\${members}');
    return Team(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',

      teamLeaderId: data['teamLeaderId'] ?? '',
      members: members,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,

      'teamLeaderId': teamLeaderId,
      'members': members,
    };
  }
}
