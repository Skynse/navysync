import 'package:cloud_firestore/cloud_firestore.dart';

class Team {
  final String id;
  final String name;
  final String description;
  final String teamLeaderId;
  final List<String> members;
  final String departmentId;
  final DateTime createdAt;
  final DateTime updatedAt;


  const Team({
    required this.id,
    required this.name,
    required this.description,
    required this.teamLeaderId,
    this.members = const [],
    this.departmentId = '',
    required this.createdAt,
    required this.updatedAt,

  });

  factory Team.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Team.fromMap({
      'id': doc.id,
      ...data,
    });
  }

  factory Team.fromMap(Map<String, dynamic> map) {
    return Team(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      teamLeaderId: map['teamLeaderId'] ?? '',
      members: List<String>.from(map['members'] ?? []),
      departmentId: map['departmentId'] ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),

    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'teamLeaderId': teamLeaderId,
      'members': members,
      'departmentId': departmentId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
 
    };
  }

  Map<String, dynamic> toFirestore() {
    final data = toMap();
    data.remove('id'); // Don't include ID in Firestore document
    return data;
  }

  // Helper methods
  bool isMember(String userId) => members.contains(userId);
  bool isLeader(String userId) => teamLeaderId == userId;
  int get memberCount => members.length;
  
  List<String> get allMemberIds => [teamLeaderId, ...members];

  Team copyWith({
    String? name,
    String? description,
    String? teamLeaderId,
    List<String>? members,
    String? departmentId,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Team(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      teamLeaderId: teamLeaderId ?? this.teamLeaderId,
      members: members ?? this.members,
      departmentId: departmentId ?? this.departmentId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),

    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Team && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Team(id: $id, name: $name, memberCount: $memberCount)';
  }
}
