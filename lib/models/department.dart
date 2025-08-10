import 'package:cloud_firestore/cloud_firestore.dart';

class Department {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String departmentHeadId;
  final List<String> assistantHeadIds;
  final List<String> members;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  const Department({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl = '',
    required this.departmentHeadId,
    this.assistantHeadIds = const [],
    this.members = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory Department.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Department.fromMap({
      'id': doc.id,
      ...data,
    });
  }

  factory Department.fromMap(Map<String, dynamic> map) {
    return Department(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      departmentHeadId: map['departmentHeadId'] ?? '',
      assistantHeadIds: List<String>.from(map['assistantHeadIds'] ?? []),
      members: List<String>.from(map['members'] ?? []),
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'departmentHeadId': departmentHeadId,
      'assistantHeadIds': assistantHeadIds,
      'members': members,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
    };
  }

  Map<String, dynamic> toFirestore() {
    final data = toMap();
    data.remove('id'); // Don't include ID in Firestore document
    return data;
  }

  // Helper methods
  bool isMember(String userId) => members.contains(userId);
  bool isHead(String userId) => departmentHeadId == userId;
  bool isAssistantHead(String userId) => assistantHeadIds.contains(userId);
  bool isLeadership(String userId) => isHead(userId) || isAssistantHead(userId);
  int get memberCount => members.length;
  
  List<String> get allMemberIds => [
    departmentHeadId,
    ...assistantHeadIds,
    ...members,
  ];

  Department copyWith({
    String? name,
    String? description,
    String? imageUrl,
    String? departmentHeadId,
    List<String>? assistantHeadIds,
    List<String>? members,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Department(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      departmentHeadId: departmentHeadId ?? this.departmentHeadId,
      assistantHeadIds: assistantHeadIds ?? this.assistantHeadIds,
      members: members ?? this.members,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Department && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Department(id: $id, name: $name, memberCount: $memberCount)';
  }
}
