import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../constants.dart';

enum EventVisibility {
  organization, // Everyone in the organization can see
  department,   // Only department members can see
  team,        // Only team members can see
  private,     // Only invited attendees can see
}

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final Timestamp? startTime;
  final Timestamp? endTime;
  final String location;
  final String createdBy;
  final EventVisibility visibility;
  final String? departmentId; // Required if visibility is department
  final String? teamId; // Required if visibility is team
  final List<String> attendees; // List of user IDs who can attend (for private events)
  final List<String> tags; // Optional tags for categorization
  final String? imageUrl; // Optional event image
  final bool isRecurring;
  final Map<String, dynamic>? recurringPattern; // For recurring events
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.startTime,
    this.endTime,
    required this.location,
    required this.createdBy,
    required this.visibility,
    this.departmentId,
    this.teamId,
    this.attendees = const [],
    this.tags = const [],
    this.imageUrl,
    this.isRecurring = false,
    this.recurringPattern,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Event.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: json['date'] is Timestamp
          ? (json['date'] as Timestamp).toDate()
          : json['date'] is String
              ? DateTime.tryParse(json['date']) ?? DateTime.now()
              : DateTime.now(),
      startTime: json['startTime'] as Timestamp?,
      endTime: json['endTime'] as Timestamp?,
      location: json['location'] ?? '',
      createdBy: json['createdBy'] ?? '',
      visibility: _parseVisibility(json['visibility']),
      departmentId: json['departmentId'],
      teamId: json['teamId'],
      attendees: List<String>.from(json['attendees'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      imageUrl: json['imageUrl'],
      isRecurring: json['isRecurring'] ?? false,
      recurringPattern: json['recurringPattern'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      isActive: json['isActive'] ?? true,
    );
  }

  static EventVisibility _parseVisibility(dynamic visibility) {
    if (visibility is String) {
      switch (visibility) {
        case 'organization':
          return EventVisibility.organization;
        case 'department':
          return EventVisibility.department;
        case 'team':
          return EventVisibility.team;
        case 'private':
          return EventVisibility.private;
        default:
          return EventVisibility.organization;
      }
    }
    return EventVisibility.organization;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'startTime': startTime,
      'endTime': endTime,
      'location': location,
      'createdBy': createdBy,
      'visibility': visibility.name,
      'departmentId': departmentId,
      'teamId': teamId,
      'attendees': attendees,
      'tags': tags,
      'imageUrl': imageUrl,
      'isRecurring': isRecurring,
      'recurringPattern': recurringPattern,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
    };
  }

  Map<String, dynamic> toFirestore() {
    final data = toJson();
    data.remove('id'); // Don't include ID in Firestore document
    return data;
  }

  // Helper method to check if a user can access this event
  bool canUserAccess(
    String userId,
    List<String> userRoles,
    String userDepartmentId,
    List<String> userTeamIds,
  ) {
    // Always allow the creator and moderators
    if (userId == createdBy || userRoles.contains(UserRoles.moderator)) {
      return true;
    }

    // Check based on event visibility
    switch (visibility) {
      case EventVisibility.organization:
        // Everyone in the organization can access
        return true;
      case EventVisibility.department:
        // Department members or department heads can access
        return departmentId != null && departmentId == userDepartmentId;
      case EventVisibility.team:
        // Team members or team leaders can access
        return teamId != null && userTeamIds.contains(teamId);
      case EventVisibility.private:
        // Only specifically invited users can access
        return attendees.contains(userId);
    }
  }

  // Helper method to get display color based on event visibility
  Color get displayColor {
    // Use standard blue for all events for consistency
    return AppColors.primaryBlue;
  }

  // Helper method to get visibility icon
  IconData get visibilityIcon {
    switch (visibility) {
      case EventVisibility.organization:
        return Icons.public;
      case EventVisibility.department:
        return Icons.business;
      case EventVisibility.team:
        return Icons.group;
      case EventVisibility.private:
        return Icons.lock;
    }
  }

  // Helper method to get visibility label
  String get visibilityLabel {
    switch (visibility) {
      case EventVisibility.organization:
        return 'Organization';
      case EventVisibility.department:
        return 'Department';
      case EventVisibility.team:
        return 'Team';
      case EventVisibility.private:
        return 'Private';
    }
  }

  Event copyWith({
    String? title,
    String? description,
    DateTime? date,
    Timestamp? startTime,
    Timestamp? endTime,
    String? location,
    EventVisibility? visibility,
    String? departmentId,
    String? teamId,
    List<String>? attendees,
    List<String>? tags,
    String? imageUrl,
    bool? isRecurring,
    Map<String, dynamic>? recurringPattern,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Event(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      createdBy: createdBy,
      visibility: visibility ?? this.visibility,
      departmentId: departmentId ?? this.departmentId,
      teamId: teamId ?? this.teamId,
      attendees: attendees ?? this.attendees,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPattern: recurringPattern ?? this.recurringPattern,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Event && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Event(id: $id, title: $title, visibility: ${visibility.name})';
  }
}
