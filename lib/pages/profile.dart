import 'package:flutter/material.dart';

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
            return Container(
    
              child: Center(
                child: Text('Account Settings'),
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
      body: Padding(
        padding: const EdgeInsets.only(left: 24.0, right: 25.0),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: Text('My Profile'),
              centerTitle: true,
              expandedHeight: 200,
              flexibleSpace: FlexibleSpaceBar(
                // profile picture on left, circle avatar,
                background: Row(
                  spacing: 10,
                  children: [
                    CircleAvatar(radius: 30, backgroundColor: Colors.blue),

                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
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
            ),

            SliverList.separated(
              itemCount: settingsTiles.length,
              itemBuilder: (BuildContext context, int index) {
                return settingsTiles[index];
              },
              separatorBuilder:
                  (BuildContext context, int index) => const Divider(),
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
