import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({super.key});

  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  TextEditingController registerEmailController = TextEditingController();
  TextEditingController registerPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    emailController.dispose();
    passwordController.dispose();

    registerEmailController.dispose();
    registerPasswordController.dispose();
    confirmPasswordController.dispose();
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

  // LINE 43 - 140
  Widget _buildLoginTab() {
    return Center(
      child: Container(
        child: Form(
          child: Column(
            spacing: 16,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  hint: Text(
                    'Email',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  prefixIcon: Icon(Icons.email, color: Colors.grey.shade600),
                  border: InputBorder.none,
                  fillColor: Colors.grey.shade200,
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Colors.grey.shade400,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
              ),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  hint: Text(
                    'Password',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  prefixIcon: Icon(Icons.email, color: Colors.grey.shade600),
                  border: InputBorder.none,
                  fillColor: Colors.grey.shade200,
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Colors.grey.shade400,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                style: ButtonStyle(
                  fixedSize: WidgetStateProperty.all(Size(200, 50)),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  backgroundColor: WidgetStateProperty.all(Color(0XFF000080)),
                ),

                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: emailController.text,
                      password: passwordController.text,
                    );
                  } catch (e) {
                    // Handle login error
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
                  }
                },
                child: const Text(
                  'Login',

                  style: TextStyle(
                    color: Color(0XFFe89c31),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterTab() {
    return Center(
      child: Container(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            spacing: 16,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: registerEmailController,
                decoration: InputDecoration(
                  hint: Text(
                    'Email',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  prefixIcon: Icon(Icons.email, color: Colors.grey.shade600),
                  border: InputBorder.none,
                  fillColor: Colors.grey.shade200,
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Colors.grey.shade400,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
              ),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
                controller: registerPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  hint: Text(
                    'Password',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  prefixIcon: Icon(Icons.lock, color: Colors.grey.shade600),
                  border: InputBorder.none,
                  fillColor: Colors.grey.shade200,
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Colors.grey.shade400,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
              ),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  // if (value != passwordController.text) {
                  //   return 'Passwords do not match';
                  // }
                  return null;
                },
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  hint: Text(
                    'Confirm Password',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  prefixIcon: Icon(Icons.lock, color: Colors.grey.shade600),
                  border: InputBorder.none,
                  fillColor: Colors.grey.shade200,
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Colors.grey.shade400,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
              ),

              SizedBox(height: 16),
              ElevatedButton(
                style: ButtonStyle(
                  fixedSize: WidgetStateProperty.all(Size(200, 50)),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  backgroundColor: WidgetStateProperty.all(Color(0XFF000080)),
                ),

                onPressed: () async {
                  // validate form
                  if (_formKey.currentState!.validate() &&
                      registerPasswordController.text ==
                          confirmPasswordController.text) {
                    try {
                      await FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                            email: registerEmailController.text,
                            password: registerPasswordController.text,
                          );

                      if (context.mounted) {
                        context.go('/auth_gate');
                      }
                    } catch (e) {
                      // Handle login error
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Login failed: $e')),
                      );
                    }
                  }
                },
                child: const Text(
                  'Register',

                  style: TextStyle(
                    color: Color(0XFFe89c31),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
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
