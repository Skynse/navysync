import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final Timestamp? startTime;
  final Timestamp? endTime;
  final String location;
  final String createdBy;
  final String event_type; // 'departmental', 'team', 'organization'
  final String departmentId; // Required if event_type is 'departmental'
  final String teamId; // Required if event_type is 'team'
  final List<String> attendees; // List of user IDs who can attend
  final String visibility; // 'public', 'department', 'team', 'private'

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.startTime,
    this.endTime,
    required this.location,
    required this.createdBy,
    required this.event_type,
    this.departmentId = '',
    this.teamId = '',
    this.attendees = const [],
    this.visibility = 'department',
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date:
          json['date'] is Timestamp
              ? (json['date'] as Timestamp).toDate()
              : DateTime.parse(json['date']),

      startTime: json['startTime'],
      endTime: json['endTime'],
      location: json['location'],
      createdBy: json['createdBy'],
      event_type: json['event_type'] ?? 'departmental',
      departmentId: json['departmentId'] ?? '',
      teamId: json['teamId'] ?? '',
      attendees: List<String>.from(json['attendees'] ?? []),
      visibility: json['visibility'] ?? 'department',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'location': location,
      'creatorId': createdBy,
      'event_type': event_type,
      'departmentId': departmentId,
      'teamId': teamId,
      'attendees': attendees,
      'visibility': visibility,
    };
  }

  // Helper method to check if a user can access this event
  bool canUserAccess(
    String userId,
    List<String> userRoles,
    String userDepartmentId,
    List<String> userTeamIds,
  ) {
    // Always allow the creator and admins
    if (userId == createdBy || userRoles.contains('admin')) {
      return true;
    }

    // Check based on event type
    switch (event_type) {
      case 'departmental':
        // Department members or department heads can access
        if (departmentId == userDepartmentId) {
          return true;
        }
        break;
      case 'team':
        // Team members or team leaders can access
        if (userTeamIds.contains(teamId)) {
          return true;
        }
        break;
      case 'organization':
        // Everyone in the organization can access
        return true;
      case 'private':
        // Only specifically invited users can access
        return attendees.contains(userId);
    }

    return false;
  }
}
