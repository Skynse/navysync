import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:navysync/constants.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // custom settings tiles

  @override
  Widget build(BuildContext context) {
    List<SettingsTile> settingsTiles = [
      SettingsTile(
        icon: Icons.person,
        title: 'Account',
        subtitle: 'Manage your account settings',
        onTap: () {
          showBottomSheet(
            context: context,
            builder: (context) {
              return Container(child: Center(child: Text('Account Settings')));
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
      body: Padding(
        padding: const EdgeInsets.only(left: 24.0, right: 25.0),
        child: Column(
          children: [
            AppBar(title: Text('My Profile'), centerTitle: true),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                children: [
                  CircleAvatar(radius: 30, backgroundColor: Colors.blue),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Full Name',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        icon: Icon(Icons.add),
                        onPressed: () {},
                        label: Text("+ Add Status"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
                  await FirebaseAuth.instance
                      .signOut()
                      .then((_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Logged out successfully!'),
                            ),
                          );
                          context.go('/auth_gate');
                        }
                      })
                      .catchError((error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Logout failed: $error')),
                        );
                      });
                },
                // navy blue
                child: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: navyBlue, // Navy blue
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
