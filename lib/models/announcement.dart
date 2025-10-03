import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../constants.dart';

enum AnnouncementVisibility {
  public,
  organization, // Everyone in the organization can see
  department, // Only department members can see
  team, // Only team members can see
  private, // Only invited users can see
}

enum AnnouncementPriority { low, normal, high, urgent }

class Announcement {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final AnnouncementVisibility visibility;
  final AnnouncementPriority priority;
  final String? departmentId; // Required if visibility is department
  final String? teamId; // Required if visibility is team
  final List<String>
  targetUsers; // List of user IDs (for private announcements)
  final List<String> tags; // Optional tags for categorization
  final String? imageUrl; // Optional announcement image
  final String? link; // Optional external link
  final DateTime? expiresAt; // Optional expiration date
  final List<String> readBy; // Users who have read this announcement
  final bool isPinned; // Whether the announcement is pinned
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  const Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.visibility,
    this.priority = AnnouncementPriority.normal,
    this.departmentId,
    this.teamId,
    this.targetUsers = const [],
    this.tags = const [],
    this.imageUrl,
    this.link,
    this.expiresAt,
    this.readBy = const [],
    this.isPinned = false,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory Announcement.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Announcement.fromJson({'id': doc.id, ...data});
  }

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      authorId: json['authorId'] ?? '',
      visibility: _parseVisibility(json['visibility']),
      priority: _parsePriority(json['priority']),
      departmentId: json['departmentId'],
      teamId: json['teamId'],
      targetUsers: List<String>.from(json['targetUsers'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      imageUrl: json['imageUrl'],
      link: json['link'],
      expiresAt:
          json['expiresAt'] is Timestamp
              ? (json['expiresAt'] as Timestamp).toDate()
              : json['expiresAt'] is String
              ? DateTime.tryParse(json['expiresAt'])
              : null,
      readBy: List<String>.from(json['readBy'] ?? []),
      isPinned: json['isPinned'] ?? false,
      createdAt:
          json['createdAt'] is Timestamp
              ? (json['createdAt'] as Timestamp).toDate()
              : DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt:
          json['updatedAt'] is Timestamp
              ? (json['updatedAt'] as Timestamp).toDate()
              : DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      isActive: json['isActive'] ?? true,
    );
  }

  static AnnouncementVisibility _parseVisibility(dynamic visibility) {
    if (visibility is String) {
      switch (visibility) {
        case 'public':
          return AnnouncementVisibility.public;
        case 'organization':
          return AnnouncementVisibility.organization;
        case 'department':
          return AnnouncementVisibility.department;
        case 'team':
          return AnnouncementVisibility.team;
        case 'private':
          return AnnouncementVisibility.private;
        default:
          return AnnouncementVisibility.organization;
      }
    }
    return AnnouncementVisibility.organization;
  }

  static AnnouncementPriority _parsePriority(dynamic priority) {
    if (priority is String) {
      switch (priority) {
        case 'low':
          return AnnouncementPriority.low;
        case 'normal':
          return AnnouncementPriority.normal;
        case 'high':
          return AnnouncementPriority.high;
        case 'urgent':
          return AnnouncementPriority.urgent;
        default:
          return AnnouncementPriority.normal;
      }
    }
    return AnnouncementPriority.normal;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'authorId': authorId,
      'visibility': visibility.name,
      'priority': priority.name,
      'departmentId': departmentId,
      'teamId': teamId,
      'targetUsers': targetUsers,
      'tags': tags,
      'imageUrl': imageUrl,
      'link': link,
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'readBy': readBy,
      'isPinned': isPinned,
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

  // Helper method to check if a user can access this announcement
  bool canUserAccess(
    String userId,
    List<String> userRoles,
    String userDepartmentId,
    List<String> userTeamIds,
  ) {
    // Always allow the author
    if (userId == authorId) {
      return true;
    }

    // Check based on announcement visibility
    switch (visibility) {
      case AnnouncementVisibility.public:
        // Everyone can access
        return true;
      case AnnouncementVisibility.organization:
        // Everyone in the organization can access
        return true;
      case AnnouncementVisibility.department:
        // Department members can access
        return departmentId != null && departmentId == userDepartmentId;
      case AnnouncementVisibility.team:
        // Team members can access
        return teamId != null && userTeamIds.contains(teamId);
      case AnnouncementVisibility.private:
        // Only specifically targeted users can access
        return targetUsers.contains(userId);
    }
  }

  // Helper method to get display color based on priority
  Color get priorityColor {
    switch (priority) {
      case AnnouncementPriority.low:
        return AppColors.darkGray;
      case AnnouncementPriority.normal:
        return AppColors.primaryBlue;
      case AnnouncementPriority.high:
        return AppColors.warning;
      case AnnouncementPriority.urgent:
        return AppColors.error;
    }
  }

  // Helper method to get visibility icon
  IconData get visibilityIcon {
    switch (visibility) {
      case AnnouncementVisibility.public:
        return Icons.public;
      case AnnouncementVisibility.organization:
        return Icons.public;
      case AnnouncementVisibility.department:
        return Icons.business;
      case AnnouncementVisibility.team:
        return Icons.group;
      case AnnouncementVisibility.private:
        return Icons.lock;
    }
  }

  // Helper method to get priority icon
  IconData get priorityIcon {
    switch (priority) {
      case AnnouncementPriority.low:
        return Icons.arrow_downward;
      case AnnouncementPriority.normal:
        return Icons.remove;
      case AnnouncementPriority.high:
        return Icons.arrow_upward;
      case AnnouncementPriority.urgent:
        return Icons.priority_high;
    }
  }

  // Helper method to check if announcement is expired
  bool get isExpired {
    return expiresAt != null && DateTime.now().isAfter(expiresAt!);
  }

  // Helper method to check if user has read the announcement
  bool isReadByUser(String userId) {
    return readBy.contains(userId);
  }

  Announcement copyWith({
    String? title,
    String? content,
    AnnouncementVisibility? visibility,
    AnnouncementPriority? priority,
    String? departmentId,
    String? teamId,
    List<String>? targetUsers,
    List<String>? tags,
    String? imageUrl,
    String? link,
    DateTime? expiresAt,
    List<String>? readBy,
    bool? isPinned,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Announcement(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      authorId: authorId,
      visibility: visibility ?? this.visibility,
      priority: priority ?? this.priority,
      departmentId: departmentId ?? this.departmentId,
      teamId: teamId ?? this.teamId,
      targetUsers: targetUsers ?? this.targetUsers,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
      link: link ?? this.link,
      expiresAt: expiresAt ?? this.expiresAt,
      readBy: readBy ?? this.readBy,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Announcement && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Announcement(id: $id, title: $title, visibility: ${visibility.name})';
  }
}
