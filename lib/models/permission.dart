import 'package:flutter/foundation.dart';

/// Defines the Permission model for role-based access control
class Permission {
  // Permission constants for resources
  static const String VIEW = 'view';
  static const String CREATE = 'create';
  static const String EDIT = 'edit';
  static const String DELETE = 'delete';
  static const String MANAGE = 'manage';
  static const String ASSIGN = 'assign';

  // Resource types
  static const String RESOURCE_EVENT = 'event';
  static const String RESOURCE_TASK = 'task';
  static const String RESOURCE_USER = 'user';
  static const String RESOURCE_DEPARTMENT = 'department';
  static const String RESOURCE_TEAM = 'team';

  // Role definitions
  static const String ROLE_ADMIN = 'admin';
  static const String ROLE_DEPARTMENT_HEAD = 'department_head';
  static const String ROLE_TEAM_LEADER = 'team_leader';
  static const String ROLE_MEMBER = 'member';

  // Get permissions for a specific role
  static Map<String, List<String>> getRolePermissions(String role) {
    switch (role) {
      case ROLE_ADMIN:
        return {
          RESOURCE_EVENT: [VIEW, CREATE, EDIT, DELETE, MANAGE],
          RESOURCE_TASK: [VIEW, CREATE, EDIT, DELETE, ASSIGN],
          RESOURCE_USER: [VIEW, CREATE, EDIT, DELETE, MANAGE],
          RESOURCE_DEPARTMENT: [VIEW, CREATE, EDIT, DELETE, MANAGE],
          RESOURCE_TEAM: [VIEW, CREATE, EDIT, DELETE, MANAGE],
        };

      case ROLE_DEPARTMENT_HEAD:
        return {
          RESOURCE_EVENT: [VIEW, CREATE, EDIT, DELETE],
          RESOURCE_TASK: [VIEW, CREATE, EDIT, ASSIGN],
          RESOURCE_USER: [VIEW],
          RESOURCE_DEPARTMENT: [VIEW, EDIT],
          RESOURCE_TEAM: [VIEW, CREATE, EDIT],
        };

      case ROLE_TEAM_LEADER:
        return {
          RESOURCE_EVENT: [VIEW, CREATE, EDIT],
          RESOURCE_TASK: [VIEW, CREATE, EDIT, ASSIGN],
          RESOURCE_USER: [VIEW],
          RESOURCE_DEPARTMENT: [VIEW],
          RESOURCE_TEAM: [VIEW, EDIT],
        };

      case ROLE_MEMBER:
      default:
        return {
          RESOURCE_EVENT: [VIEW],
          RESOURCE_TASK: [VIEW],
          RESOURCE_USER: [VIEW],
          RESOURCE_DEPARTMENT: [VIEW],
          RESOURCE_TEAM: [VIEW],
        };
    }
  }

  // Check if a user has permission for an action on a resource
  static bool hasPermission(
    List<String> userRoles,
    String action,
    String resourceType,
  ) {
    bool permitted = false;

    for (String role in userRoles) {
      final permissions = getRolePermissions(role);
      if (permissions.containsKey(resourceType) &&
          permissions[resourceType]!.contains(action)) {
        permitted = true;
        break;
      }
    }

    return permitted;
  }

  // Create a context-aware permission checker
  static bool canAccessResource({
    required List<String> userRoles,
    required String userId,
    required String action,
    required String resourceType,
    String? resourceOwnerId,
    String? departmentId,
    String? teamId,
    String? userDepartmentId,
    List<String>? userTeamIds,
  }) {
    // Admin has all permissions
    if (userRoles.contains(ROLE_ADMIN)) return true;

    // Resource owner always has access
    if (resourceOwnerId != null && resourceOwnerId == userId) return true;

    // Department head has access to department resources
    if (userRoles.contains(ROLE_DEPARTMENT_HEAD) &&
        departmentId != null &&
        userDepartmentId != null &&
        departmentId == userDepartmentId) {
      final permissions = getRolePermissions(ROLE_DEPARTMENT_HEAD);
      if (permissions.containsKey(resourceType) &&
          permissions[resourceType]!.contains(action)) {
        return true;
      }
    }

    // Team leader has access to team resources
    if (userRoles.contains(ROLE_TEAM_LEADER) &&
        teamId != null &&
        userTeamIds != null &&
        userTeamIds.contains(teamId)) {
      final permissions = getRolePermissions(ROLE_TEAM_LEADER);
      if (permissions.containsKey(resourceType) &&
          permissions[resourceType]!.contains(action)) {
        return true;
      }
    }

    // Check generic role permission
    return hasPermission(userRoles, action, resourceType);
  }
}
