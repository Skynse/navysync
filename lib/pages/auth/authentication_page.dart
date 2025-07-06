import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:navysync/models/user.dart';

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
    // Redirect if already logged in and not verified
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go('/verify_email');
        }
      });
    } else if (user != null && user.emailVerified) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go('/auth_gate');
        }
      });
    }
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
      dividerColor: Colors.transparent,
      controller: _tabController,
      tabs: const [Tab(text: 'Login'), Tab(text: 'Register')],
      indicatorColor: Colors.blue,
      labelColor: Colors.blue,
      unselectedLabelColor: Colors.grey,
      indicator: UnderlineTabIndicator(
        borderRadius: BorderRadius.all(Radius.circular(50.0)),
        borderSide: BorderSide(width: 3.0, color: Colors.blue),
      ),
    );
  }

  // LINE 43 - 140
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _loginErrorMessage;

  Widget _buildLoginTab() {
    return Center(
      child: Container(
        child: Form(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_loginErrorMessage != null)
                Container(
                  margin: EdgeInsets.only(bottom: 16),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _loginErrorMessage!,
                          style: TextStyle(color: Colors.red.shade800),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, size: 16),
                        color: Colors.red.shade800,
                        onPressed: () {
                          setState(() {
                            _loginErrorMessage = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  prefixIcon: Icon(Icons.email, color: Colors.grey.shade600),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  fillColor: Colors.grey.shade100,
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
                    borderSide: BorderSide(color: Color(0xFF000080), width: 2),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: Icon(Icons.lock, color: Colors.grey.shade600),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  fillColor: Colors.grey.shade100,
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
                    borderSide: BorderSide(color: Color(0xFF000080), width: 2),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Password recovery logic
                    // Show dialog to enter email
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: Text('Reset Password'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Enter your email to receive a reset link',
                                ),
                                SizedBox(height: 16),
                                TextFormField(
                                  controller: TextEditingController(
                                    text: emailController.text,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  // Send password reset email
                                  Navigator.pop(context);
                                  try {
                                    await FirebaseAuth.instance
                                        .sendPasswordResetEmail(
                                          email: emailController.text,
                                        );
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Password reset link sent to ${emailController.text}',
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (error) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Failed to send reset link: $error',
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF000080),
                                  foregroundColor: Colors.white,
                                ),
                                child: Text('Send Reset Link'),
                              ),
                            ],
                          ),
                    );
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(color: Color(0xFF000080)),
                  ),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(
                    MediaQuery.of(context).size.width * 0.9,
                    50,
                  ),
                  backgroundColor: Color(0xFF000080),
                  foregroundColor: Color(0xFFE89C31),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                ),
                onPressed:
                    _isLoading
                        ? null
                        : () async {
                          if (emailController.text.isEmpty ||
                              passwordController.text.isEmpty) {
                            setState(() {
                              _loginErrorMessage =
                                  'Please enter both email and password';
                            });
                            return;
                          }

                          setState(() {
                            _isLoading = true;
                            _loginErrorMessage = null;
                          });

                          try {
                            await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                                  email: emailController.text,
                                  password: passwordController.text,
                                );
                          } catch (e) {
                            setState(() {
                              _loginErrorMessage = _getFirebaseErrorMessage(
                                e.toString(),
                              );
                            });
                          } finally {
                            // Check if the user is authenticated
                            User? user = FirebaseAuth.instance.currentUser;
                            if (user != null && user.emailVerified) {
                              // User is authenticated, navigate to auth gate
                              if (context.mounted) {
                                context.go('/auth_gate');
                              }
                            } else {
                              if (user != null &&
                                  !user.emailVerified &&
                                  user.email == emailController.text) {
                                // User is authenticated but not verified, show error
                                setState(() {
                                  _loginErrorMessage =
                                      'Please verify your email before logging in.';
                                });

                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text("Send Verification Email"),
                                      content: Text(
                                        "Your email is not verified. Would you like to send a verification email?",
                                      ),
                                      actions: [
                                        TextButton(
                                          child: Text("Send"),
                                          onPressed: () async {
                                            try {
                                              await user
                                                  .sendEmailVerification();

                                              await user.reload();
                                              if (mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Verification email sent to ${user.email}',
                                                    ),
                                                  ),
                                                );
                                              }
                                            } catch (error) {
                                              if (mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Failed to send verification email: $error',
                                                    ),
                                                  ),
                                                );
                                              }
                                            }
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else {
                                // User is not authenticated, show error
                                setState(() {
                                  _loginErrorMessage =
                                      'Authentication failed. Please try again.';
                                });
                              }
                            }
                            if (mounted) {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          }
                        },
                child:
                    _isLoading
                        ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFE89C31),
                            ),
                            strokeWidth: 3,
                          ),
                        )
                        : const Text(
                          'Login',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getFirebaseErrorMessage(String errorCode) {
    // Convert Firebase error messages to user-friendly messages
    if (errorCode.contains('user-not-found')) {
      return 'No account found with this email. Please register first.';
    } else if (errorCode.contains('wrong-password')) {
      return 'Incorrect password. Please try again.';
    } else if (errorCode.contains('invalid-email')) {
      return 'Invalid email format. Please check your email.';
    } else if (errorCode.contains('network-request-failed')) {
      return 'Network error. Please check your internet connection.';
    } else {
      return 'Authentication failed. Please try again later.';
    }
  }

  bool _isRegisterPasswordVisible = false;
  bool _isRegisterConfirmPasswordVisible = false;
  bool _isRegistering = false;
  String? _registerErrorMessage;

  Widget _buildRegisterTab() {
    return Center(
      child: Container(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_registerErrorMessage != null)
                Container(
                  margin: EdgeInsets.only(bottom: 16),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _registerErrorMessage!,
                          style: TextStyle(color: Colors.red.shade800),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, size: 16),
                        color: Colors.red.shade800,
                        onPressed: () {
                          setState(() {
                            _registerErrorMessage = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              TextFormField(
                controller: registerEmailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email address';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email address',
                  prefixIcon: Icon(Icons.email, color: Colors.grey.shade600),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  fillColor: Colors.grey.shade100,
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
                    borderSide: BorderSide(color: Color(0xFF000080), width: 2),
                  ),
                ),
              ),
              SizedBox(height: 16),
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
                obscureText: !_isRegisterPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Create a password (min. 6 characters)',
                  prefixIcon: Icon(Icons.lock, color: Colors.grey.shade600),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isRegisterPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: () {
                      setState(() {
                        _isRegisterPasswordVisible =
                            !_isRegisterPasswordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  fillColor: Colors.grey.shade100,
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
                    borderSide: BorderSide(color: Color(0xFF000080), width: 2),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != registerPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                controller: confirmPasswordController,
                obscureText: !_isRegisterConfirmPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  hintText: 'Re-enter your password',
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: Colors.grey.shade600,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isRegisterConfirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: () {
                      setState(() {
                        _isRegisterConfirmPasswordVisible =
                            !_isRegisterConfirmPasswordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  fillColor: Colors.grey.shade100,
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
                    borderSide: BorderSide(color: Color(0xFF000080), width: 2),
                  ),
                ),
              ),

              SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(
                    MediaQuery.of(context).size.width * 0.9,
                    50,
                  ),
                  backgroundColor: Color(0xFF000080),
                  foregroundColor: Color(0xFFE89C31),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                ),
                onPressed:
                    _isRegistering
                        ? null
                        : () async {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }

                          setState(() {
                            _isRegistering = true;
                            _registerErrorMessage = null;
                          });

                          try {
                            await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                                  email: registerEmailController.text,
                                  password: registerPasswordController.text,
                                )
                                .then((UserCredential userCredential) async {
                                  if (userCredential.user == null) {
                                    return;
                                  }

                                  await FirebaseAuth.instance.currentUser!
                                      .sendEmailVerification();
                                  FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(userCredential.user!.uid)
                                      .set(
                                        NavySyncUser(
                                          id: userCredential.user!.uid,
                                          profilePictureUrl: '',
                                          name: 'User',
                                          roles: ['unassigned'],
                                        ).toMap(),
                                      )
                                      .then((_) {
                                        print(
                                          'User profile created in Firestore',
                                        );
                                      })
                                      .catchError((error) {
                                        print(
                                          'Failed to create user profile: $error',
                                        );
                                      });
                                });

                            // clear inputs
                            registerEmailController.clear();
                            registerPasswordController.clear();
                            confirmPasswordController.clear();

                            // navigate to login tab
                            _tabController.index = 0;

                            await FirebaseAuth.instance.currentUser!.reload();

                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("Please verify your email"),
                                  content: Text(
                                    "A verification email has been sent to ${registerEmailController.text}. Please check your inbox and follow the instructions to verify your account.",
                                  ),
                                );
                              },
                            );
                          } catch (e) {
                            setState(() {
                              _registerErrorMessage =
                                  _getFirebaseRegisterErrorMessage(
                                    e.toString(),
                                  );
                            });
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isRegistering = false;
                              });
                            }
                          }
                        },
                child:
                    _isRegistering
                        ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFE89C31),
                            ),
                            strokeWidth: 3,
                          ),
                        )
                        : const Text(
                          'Register',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getFirebaseRegisterErrorMessage(String errorCode) {
    if (errorCode.contains('email-already-in-use')) {
      return 'This email is already registered. Please login instead.';
    } else if (errorCode.contains('invalid-email')) {
      return 'The email address is not valid.';
    } else if (errorCode.contains('weak-password')) {
      return 'The password is too weak. Please use a stronger password.';
    } else if (errorCode.contains('network-request-failed')) {
      return 'Network error. Please check your internet connection.';
    } else {
      return 'Registration failed: ${errorCode.split(']').last.trim()}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 0.25 * MediaQuery.sizeOf(context).height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF000080), Color(0xFF0000B3)],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.sailing,
                          size: 60,
                          color: Color(0xFF000080),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'NavySync',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
