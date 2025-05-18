import 'package:flutter/material.dart';

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({super.key});

  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      tabs: const [Tab(text: 'Login'), Tab(text: 'Register')],
      indicatorColor: Colors.blue,
      labelColor: Colors.blue,
      unselectedLabelColor: Colors.grey,
    );
  }

  Widget _buildLoginTab() {
    return Center(
      child: Container(
        child: Form(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BeautifulTextFormField(label: 'Email'),
              BeautifulTextFormField(label: 'Password', obscureText: true),
              ElevatedButton(
                onPressed: () {
                  // Handle login action
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterTab() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Register Form'),
            // Add your registration form widgets here
            ElevatedButton(
              onPressed: () {
                // Handle registration action
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: TabBarView(
                  controller: _tabController,
                  children: [_buildLoginTab(), _buildRegisterTab()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BeautifulTextFormField extends StatelessWidget {
  final String label;
  final bool obscureText;

  const BeautifulTextFormField({
    super.key,
    required this.label,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
      ),
    );
  }
}
