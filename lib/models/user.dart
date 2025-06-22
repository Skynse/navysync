class NavySyncUser {
  final String id;
  final String profilePictureUrl;
  final String name;
  final String departmentId; // Primary department assignment
  final List<String> teamIds; // Teams the user belongs to
  final List<String>
  roles; // Multiple roles possible: 'admin', 'department_head', 'team_leader', 'member'
  final Map<String, dynamic>
  permissions; // Specific permissions by resource type

  NavySyncUser({
    required this.id,
    required this.profilePictureUrl,
    required this.name,
    this.departmentId = '',
    this.teamIds = const [],
    required this.roles,
    this.permissions = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profilePictureUrl': profilePictureUrl,
      'name': name,
      'departmentId': departmentId,
      'teamIds': teamIds,
      'roles': roles,
      'permissions': permissions,
    };
  }

  factory NavySyncUser.fromMap(Map<String, dynamic> map) {
    return NavySyncUser(
      id: map['id'] ?? '',
      profilePictureUrl: map['profilePictureUrl'] ?? '',
      name: map['name'] ?? '',
      departmentId: map['departmentId'] ?? '',
      teamIds: List<String>.from(map['teamIds'] ?? []),
      roles: List<String>.from(map['roles'] ?? ['member']),
      permissions: Map<String, dynamic>.from(map['permissions'] ?? {}),
    );
  }

  // Helper methods for permission checks
  bool isAdmin() => roles.contains('admin');
  bool isDepartmentHead(String deptId) =>
      roles.contains('department_head') && departmentId == deptId;
  bool isTeamLeader(String teamId) =>
      roles.contains('team_leader') && teamIds.contains(teamId);
  bool isMemberOfTeam(String teamId) => teamIds.contains(teamId);

  // Check if user has access to a particular event
  bool canAccessEvent(Map<String, dynamic> eventData) {
    if (isAdmin()) return true;

    String? eventDeptId = eventData['departmentId'];
    String? eventTeamId = eventData['teamId'];
    String eventType = eventData['event_type'] ?? 'departmental';

    if (eventType == 'departmental' && eventDeptId != null) {
      return eventDeptId == departmentId || isDepartmentHead(eventDeptId);
    } else if (eventType == 'team' && eventTeamId != null) {
      return teamIds.contains(eventTeamId) || isTeamLeader(eventTeamId);
    }

    // Organization-wide events
    return true;
  }

  // Check if user has permission for a specific action
  bool hasPermission(String action, String resourceType) {
    // Admins have all permissions
    if (isAdmin()) return true;

    // Check role-specific permissions
    if (permissions.containsKey(resourceType)) {
      List<String> allowedActions = List<String>.from(
        permissions[resourceType] ?? [],
      );
      return allowedActions.contains(action);
    }

    // Default permissions based on role
    if (roles.contains('department_head') &&
        (resourceType == 'department' || resourceType == 'team')) {
      return ['view', 'create', 'edit'].contains(action);
    }

    if (roles.contains('team_leader') && resourceType == 'team') {
      return ['view', 'create'].contains(action);
    }

    // Basic member permissions
    return action == 'view';
  }
}
