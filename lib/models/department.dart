import 'package:cloud_firestore/cloud_firestore.dart';

class Department {
  final String id;
  final String name;
  final String description;
  final String imageUrl; // use firebase to store
  final String departmentHeadId;
  List<String>? assistantHeadIds = []; // optional, can be empty
  final List<String> members;

  Department({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.departmentHeadId,
    this.assistantHeadIds, // optional, can be empty
    required this.members,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id, // this is the document ID in Firestore
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'departmentHeadId': departmentHeadId,
      'assistantHeadIds': assistantHeadIds, // optional, can be empty
      'members': members,
    };
  }

  factory Department.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Department(
      id: doc.id, // Firestore document ID
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      departmentHeadId: data['departmentHeadId'] ?? '',
      assistantHeadIds: List<String>.from(data['assistantHeadIds'] ?? []),
      members: List<String>.from(data['members'] ?? []),
    );
  }
}
