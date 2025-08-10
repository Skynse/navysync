import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:navysync/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:navysync/models/user.dart';
import 'package:navysync/models/department.dart';
import 'package:navysync/models/team.dart';
import 'package:navysync/models/permission.dart';
import 'package:navysync/services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  NavySyncUser? _currentUser;
  Department? _userDepartment;
  List<Team> _userTeams = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      // Get current user data using AuthService
      _currentUser = await _authService.loadUserData();

      if (_currentUser == null) {
        if (mounted) context.go('/auth_gate');
        return;
      }

      // Fetch user's department
      if (_currentUser?.departmentId != null && _currentUser!.departmentId.isNotEmpty) {
        final deptDoc =
            await FirebaseFirestore.instance
                .collection('departments')
                .doc(_currentUser!.departmentId)
                .get();

        if (deptDoc.exists) {
          _userDepartment = Department.fromFirestore(deptDoc);
        }
      }

      // Fetch user's teams
      if (_currentUser?.teamIds != null && _currentUser!.teamIds.isNotEmpty) {
        final teamsQuery =
            await FirebaseFirestore.instance
                .collection('teams')
                .where(FieldPath.documentId, whereIn: _currentUser!.teamIds)
                .get();

        _userTeams =
            teamsQuery.docs.map((doc) => Team.fromFirestore(doc)).toList();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load profile: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('My Profile'), centerTitle: true),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    List<SettingsTile> settingsTiles = [
      SettingsTile(
        icon: Icons.person,
        title: 'Account',
        subtitle: 'Manage your account settings',
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.6,
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Settings',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Edit Profile'),
                      onTap: () {
                        // Handle edit profile
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.photo_camera),
                      title: Text('Change Profile Picture'),
                      onTap: () {
                        // Handle change profile picture
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      SettingsTile(
        icon: Icons.notifications,
        title: 'Notifications',
        subtitle: 'Manage your notification preferences',
        onTap: () {},
      ),
      SettingsTile(
        icon: Icons.security,
        title: 'Privacy',
        subtitle: 'Manage your privacy settings',
        onTap: () {},
      ),
      SettingsTile(
        icon: Icons.help,
        title: 'Help & Support',
        subtitle: 'Get help and support for the app',
        onTap: () {},
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit profile page
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            // Profile header with image and basic info
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          _currentUser?.profilePictureUrl != null &&
                                  _currentUser!.profilePictureUrl.isNotEmpty
                              ? NetworkImage(_currentUser!.profilePictureUrl)
                              : null,
                      backgroundColor: AppColors.navyBlue.withOpacity(0.8),
                      child:
                          _currentUser?.profilePictureUrl== null ||
                                  _currentUser!.profilePictureUrl.isEmpty
                              ? Text(
                                _currentUser?.name != null &&
                                        _currentUser!.name.isNotEmpty
                                    ? _currentUser!.name[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  fontSize: 30,
                                  color: Colors.white,
                                ),
                              )
                              : null,
                    ),
                    SizedBox(height: 16),
                    Text(
                      _currentUser?.name??
                          FirebaseAuth.instance.currentUser!.email ??
                          'User',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    // Display user roles as chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children:
                          _currentUser?.roles
                              .map(
                                (role) => Chip(
                                  label: Text(role),
                                  backgroundColor: _getRoleColor(role),
                                  labelStyle: TextStyle(color: Colors.white),
                                ),
                              )
                              .toList() ??
                          [],
                    ),
                    SizedBox(height: 16),
                    // Display department and team affiliations
                    if (_userDepartment != null)
                      ListTile(
                        leading: Icon(
                          Icons.business,
                          color: AppColors.navyBlue,
                        ),
                        title: Text('Department'),
                        subtitle: Text(_userDepartment!.name),
                        dense: true,
                      ),
                    Divider(),
                    if (_userTeams.isNotEmpty)
                      ListTile(
                        leading: Icon(Icons.group, color: AppColors.navyBlue),
                        title: Text('Teams'),
                        subtitle: Text(
                          _userTeams.map((team) => team.name).join(', '),
                        ),
                        dense: true,
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: settingsTiles.length,
                itemBuilder: (BuildContext context, int index) {
                  return settingsTiles[index];
                },
                separatorBuilder:
                    (BuildContext context, int index) => const Divider(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await _authService.signOut();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Logged out successfully!'),
                        ),
                      );
                      context.go('/auth_gate');
                    }
                  } catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Logout failed: $error')),
                    );
                  }
                },
                // navy blue
                child: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navyBlue, // Navy blue
                  foregroundColor: Colors.white,

                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }
}

// Helper function to get color based on role
Color _getRoleColor(String role) {
  switch (role.toLowerCase()) {
    case 'admin':
      return Colors.red.shade700;
    case 'department_head':
      return Colors.purple.shade700;
    case 'team_leader':
      return Colors.blue.shade700;
    case 'member':
      return Colors.teal.shade600;
    default:
      return Colors.grey.shade700;
  }
}
