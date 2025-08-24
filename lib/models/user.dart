import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart';

class NavySyncUser {
  final String id;
  final String profilePictureUrl;
  final String name;
  final String email;
  final String departmentId; // Primary department assignment
  final List<String> teamIds; // Teams the user belongs to
  final List<String>
  roles; // Multiple roles possible: 'admin', 'department_head', 'team_leader', 'member'
  final Map<String, dynamic>
  permissions; // Specific permissions by resource type
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final String? phoneNumber;

  const NavySyncUser({
    required this.id,
    this.profilePictureUrl = '',
    required this.name,
    required this.email,
    this.departmentId = '',
    this.teamIds = const [],
    this.roles = const [UserRoles.member],
    this.permissions = const {},
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.phoneNumber,
  });

  factory NavySyncUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return NavySyncUser.fromMap({'id': doc.id, ...data});
  }

  factory NavySyncUser.fromMap(Map<String, dynamic> map) {
    return NavySyncUser(
      id: map['id'] ?? '',
      profilePictureUrl: map['profilePictureUrl'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      departmentId: map['departmentId'] ?? '',
      teamIds: List<String>.from(map['teamIds'] ?? []),
      roles: List<String>.from(map['roles'] ?? [UserRoles.member]),
      permissions: Map<String, dynamic>.from(map['permissions'] ?? {}),
      createdAt:
          map['createdAt'] is Timestamp
              ? (map['createdAt'] as Timestamp).toDate()
              : DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt:
          map['updatedAt'] is Timestamp
              ? (map['updatedAt'] as Timestamp).toDate()
              : DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
      phoneNumber: map['phoneNumber'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'profilePictureUrl': profilePictureUrl,
      'name': name,
      'email': email,
      'departmentId': departmentId,
      'teamIds': teamIds,
      'roles': roles,
      'permissions': permissions,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
      'phoneNumber': phoneNumber,
    };
  }

  Map<String, dynamic> toFirestore() {
    final data = toMap();
    data.remove('id'); // Don't include ID in Firestore document
    return data;
  }

  // Helper methods for permission checks
  bool isAdmin() => roles.contains(UserRoles.admin);

  bool isDepartmentHead([String? deptId]) {
    if (!roles.contains(UserRoles.departmentHead)) return false;
    return deptId == null || departmentId == deptId;
  }

  bool isTeamLeader([String? teamId]) {
    if (!roles.contains(UserRoles.teamLeader)) return false;
    return teamId == null || teamIds.contains(teamId);
  }

  bool isMemberOfTeam(String teamId) => teamIds.contains(teamId);

  bool isMemberOfDepartment(String deptId) => departmentId == deptId;

  // Check if user has access to a particular event
  bool canAccessEvent(Map<String, dynamic> eventData) {
    if (isAdmin()) return true;

    final eventDeptId = eventData['departmentId'] as String?;
    final eventTeamId = eventData['teamId'] as String?;
    final eventType =
        eventData['eventType'] ??
        eventData['event_type'] ??
        EventTypes.departmental;

    switch (eventType) {
      case EventTypes.departmental:
        if (eventDeptId != null) {
          return eventDeptId == departmentId || isDepartmentHead(eventDeptId);
        }
        return true;
      case EventTypes.team:
        if (eventTeamId != null) {
          return teamIds.contains(eventTeamId) || isTeamLeader(eventTeamId);
        }
        return false;
      case EventTypes.organization:
        return true;
      case EventTypes.private:
        final attendees = List<String>.from(eventData['attendees'] ?? []);
        return attendees.contains(id);
      default:
        return false;
    }
  }

  // Check if user has permission for a specific action
  bool hasPermission(String action, String resourceType) {
    // Admins have all permissions
    if (isAdmin()) return true;

    // Check role-specific permissions
    if (permissions.containsKey(resourceType)) {
      final allowedActions = List<String>.from(permissions[resourceType] ?? []);
      return allowedActions.contains(action);
    }

    // Default permissions based on role
    if (roles.contains(UserRoles.departmentHead) &&
        ['department', 'team', 'event'].contains(resourceType)) {
      return ['view', 'create', 'edit'].contains(action);
    }

    if (roles.contains(UserRoles.teamLeader) &&
        ['team', 'event'].contains(resourceType)) {
      return ['view', 'create'].contains(action);
    }

    // Basic member permissions
    return action == 'view';
  }

  NavySyncUser copyWith({
    String? profilePictureUrl,
    String? name,
    String? email,
    String? departmentId,
    List<String>? teamIds,
    List<String>? roles,
    Map<String, dynamic>? permissions,
    DateTime? updatedAt,
    bool? isActive,
    String? phoneNumber,
  }) {
    return NavySyncUser(
      id: id,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      name: name ?? this.name,
      email: email ?? this.email,
      departmentId: departmentId ?? this.departmentId,
      teamIds: teamIds ?? this.teamIds,
      roles: roles ?? this.roles,
      permissions: permissions ?? this.permissions,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isActive: isActive ?? this.isActive,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NavySyncUser && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'NavySyncUser(id: $id, name: $name, email: $email, roles: $roles)';
  }
}
