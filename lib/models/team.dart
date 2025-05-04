import 'package:cloud_firestore/cloud_firestore.dart';

class Team {
  final String id;
  final String name;
  final String description;
  final String imageUrl; // use firebase to store
  final String teamLeaderId;
  final List<String> members;

  Team({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.teamLeaderId,
    required this.members,
  });

  factory Team.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Team(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      teamLeaderId: data['teamLeaderId'] ?? '',
      members: List<String>.from(data['members'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'teamLeaderId': teamLeaderId,
      'members': members,
    };
  }
}
