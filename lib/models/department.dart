import 'package:cloud_firestore/cloud_firestore.dart';

class Department {
  final String id;
  final String name;
  final String description;
  final String imageUrl; // use firebase to store
  final String departmentHeadId;
  final List<String> members;

  Department({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.departmentHeadId,
    required this.members,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'ownerId': departmentHeadId,
      'members': members,
    };
  }
}
