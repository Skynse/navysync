import 'package:flutter/material.dart';

// App Colors
class AppColors {
  static const navyBlue = Color(0xFF001F3F);
  static const primaryBlue = Color(0xFF003366);
  static const lightBlue = Color(0xFF4A90E2);
  static const gold = Color(0xFFD4AF37);
  static const white = Color(0xFFFFFFFF);
  static const lightGray = Color(0xFFF5F5F5);
  static const darkGray = Color(0xFF666666);
  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFE57373);
  static const warning = Color(0xFFFFB74D);
}

// App Dimensions
class AppDimensions {
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;

  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;
  static const double radiusXL = 16.0;
}

// App Strings
class AppStrings {
  static const String appName = 'NavySync';
  static const String defaultError = 'An error occurred. Please try again.';
  static const String noInternetConnection = 'No internet connection';
  static const String loading = 'Loading...';
  static const String retry = 'Retry';
}

// Event Types
class EventTypes {
  static const String departmental = 'departmental';
  static const String team = 'team';
  static const String organization = 'organization';
  static const String private = 'private';
}

// User Roles
class UserRoles {
  static const String departmentHead = 'DEPARTMENT_HEAD';
  static const String teamHead = 'TEAM_HEAD';
  static const String member = 'MEMBER';
}
