import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:navysync/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:navysync/models/user.dart';
import 'package:navysync/models/department.dart';
import 'package:navysync/models/team.dart';
import 'package:navysync/services/auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

// Phone number formatter class
class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Get only digits from the new text
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    // Don't process if no digits
    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }
    
    // Limit to 10 digits
    final limitedDigits = digits.length > 10 ? digits.substring(0, 10) : digits;
    
    String formattedText = '';
    int cursorPosition = 0;
    
    // Format based on number of digits
    if (limitedDigits.isNotEmpty) {
      formattedText = '(${limitedDigits.substring(0, math.min(limitedDigits.length, 3))}';
      if (limitedDigits.length > 3) {
        formattedText += ')-${limitedDigits.substring(3, math.min(limitedDigits.length, 6))}';
        if (limitedDigits.length > 6) {
          formattedText += '-${limitedDigits.substring(6)}';
        }
      }
    }
    
    // Calculate cursor position - always place at the end for better UX
    cursorPosition = formattedText.length;
    
    // If user is deleting and cursor would be in the middle of a separator, 
    // move it to a more natural position
    if (newValue.text.length < oldValue.text.length) {
      cursorPosition = formattedText.length;
    }
    
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();
  NavySyncUser? _currentUser;
  Department? _userDepartment;
  List<Team> _userTeams = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Function to convert role to title case
  String _formatRoleForDisplay(String role) {
    switch (role.toUpperCase()) {
      case 'MODERATOR':
        return 'Moderator';
      case 'DEPARTMENT_HEAD':
        return 'Department Head';
      case 'TEAM_LEADER':
        return 'Team Leader';
      case 'MEMBER':
        return 'Member';
      default:
        // Fallback: convert underscores to spaces and title case
        return role.toLowerCase()
            .split('_')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ');
    }
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

  Future<void> _changeProfilePicture() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image == null) return;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Show loading indicator
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // Upload to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('${user.uid}.jpg');

      final uploadTask = storageRef.putData(await image.readAsBytes());
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Update user document with new profile picture URL
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'profilePictureUrl': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Reload user data
      await _loadUserData();

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile picture: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _showEditProfileDialog() async {
    // Get current user data from Firestore to get firstName, lastName, bio, and phone
    String currentFirstName = '';
    String currentLastName = '';
    String currentBio = '';
    String currentPhone = _currentUser?.phoneNumber ?? '';
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          currentFirstName = userData['firstName'] ?? '';
          currentLastName = userData['lastName'] ?? '';
          currentBio = userData['bio'] ?? '';
          currentPhone = userData['phoneNumber'] ?? _currentUser?.phoneNumber ?? '';
          
          // If firstName/lastName don't exist but name does, split it
          if (currentFirstName.isEmpty && currentLastName.isEmpty && userData['name'] != null) {
            final nameParts = userData['name'].toString().split(' ');
            if (nameParts.isNotEmpty) {
              currentFirstName = nameParts[0];
              if (nameParts.length > 1) {
                currentLastName = nameParts.sublist(1).join(' ');
              }
            }
          }
        }
      }
    } catch (e) {
      // Handle error silently
    }
    
    final firstNameController = TextEditingController(text: currentFirstName);
    final lastNameController = TextEditingController(text: currentLastName);
    final phoneController = TextEditingController(text: currentPhone);
    final bioController = TextEditingController(text: currentBio);
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: _currentUser?.profilePictureUrl != null &&
                          _currentUser!.profilePictureUrl.isNotEmpty
                      ? NetworkImage(_currentUser!.profilePictureUrl)
                      : null,
                  backgroundColor: AppColors.navyBlue.withOpacity(0.8),
                  child: _currentUser?.profilePictureUrl == null ||
                          _currentUser!.profilePictureUrl.isEmpty
                      ? Text(
                          _currentUser?.name != null &&
                                  _currentUser!.name.isNotEmpty
                              ? _currentUser!.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog first
                    _changeProfilePicture();
                  },
                  icon: const Icon(Icons.photo_camera),
                  label: const Text('Change Profile Picture'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Last Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                    hintText: '(555)-123-4567',
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    PhoneNumberFormatter(),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: bioController,
                  decoration: const InputDecoration(
                    labelText: 'Bio',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.info),
                    hintText: 'Tell us about yourself...',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navyBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _updateProfile(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        bio: bioController.text.trim(),
        phoneNumber: phoneController.text.trim(),
      );
    }
  }

  Future<void> _updateProfile({
    required String firstName,
    required String lastName,
    required String bio,
    required String phoneNumber,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Combine first and last name for the name field
      final fullName = '$firstName $lastName'.trim();

      // Update Firestore document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'firstName': firstName,
        'lastName': lastName,
        'name': fullName, // Keep the name field for backward compatibility
        'bio': bio,
        'phoneNumber': phoneNumber,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update Firebase Auth display name
      await user.updateDisplayName(fullName);

      // Reload user data to reflect changes
      await _loadUserData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<String> _getUserBio() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return '';

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (userDoc.exists) {
        return userDoc.data()?['bio'] ?? '';
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  Future<String> _getUserPhoneNumber() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return '';

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (userDoc.exists) {
        return userDoc.data()?['phoneNumber'] ?? '';
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  Future<String> _getUserDisplayName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return '';

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final firstName = userData['firstName'] as String?;
        final lastName = userData['lastName'] as String?;
        
        // Prefer firstName + lastName if both exist
        if (firstName != null && firstName.isNotEmpty && 
            lastName != null && lastName.isNotEmpty) {
          return '$firstName $lastName';
        }
        
        // Fall back to just firstName if lastName is empty
        if (firstName != null && firstName.isNotEmpty) {
          return firstName;
        }
        
        // Fall back to the name field
        return userData['name'] ?? '';
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Profile',
            style: TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppColors.navyBlue,
          centerTitle: false,
          iconTheme: const IconThemeData(color: AppColors.white),
        ),
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
                        Navigator.pop(context);
                        _showEditProfileDialog();
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.photo_camera),
                      title: Text('Change Profile Picture'),
                      onTap: () {
                        Navigator.pop(context);
                        _changeProfilePicture();
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
        icon: Icons.school,
        title: 'Learn and Study',
        subtitle: 'Comprehensive guide and tutorials',
        onTap: () {
          context.push('/learn');
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
        title: const Text(
          'Profile',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.navyBlue,
        elevation: 2,
        iconTheme: const IconThemeData(color: AppColors.white),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: IconButton(
              icon: const Icon(Icons.edit, color: AppColors.white),
              onPressed: () => _showEditProfileDialog(),
            ),
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
                    // Display user name with firstName/lastName preference
                    FutureBuilder<String>(
                      future: _getUserDisplayName(),
                      builder: (context, snapshot) {
                        String displayName = snapshot.data ?? 
                            _currentUser?.name ?? 
                            FirebaseAuth.instance.currentUser?.email ?? 
                            'User';
                        return Text(
                          displayName,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
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
                                  label: Text(_formatRoleForDisplay(role)),
                                  backgroundColor: _getRoleColor(role),
                                  labelStyle: TextStyle(color: Colors.white),
                                ),
                              )
                              .toList() ??
                          [],
                    ),
                    SizedBox(height: 16),
                    // Display bio if available
                    FutureBuilder<String>(
                      future: _getUserBio(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.lightGray.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bio',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.navyBlue,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  snapshot.data!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return SizedBox.shrink();
                      },
                    ),
                    // Display phone number if available
                    FutureBuilder<String>(
                      future: _getUserPhoneNumber(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.lightGray.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Phone Number',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.navyBlue,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  snapshot.data!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return SizedBox.shrink();
                      },
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
                  // Show confirmation dialog
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Confirm Logout'),
                      content: const Text('Are you sure you want to log out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.navyBlue,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );

                  if (shouldLogout == true) {
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
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navyBlue, // Navy blue
                  foregroundColor: Colors.white,

                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                // navy blue
                child: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 18, color: Colors.white),
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
    case 'moderator':
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
