import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:navysync/pages/auth/authentication_page.dart';
import 'package:navysync/router.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // pass in context from the streambuilder down to the widget tree
        // snapshot is expecting type User.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Add Your Code here.
          if (!snapshot.hasData) {
            // User is not logged in
            context.go('/authentication');
          } else {
            // User is logged in
            context.go('/home');
          }
        });

        return Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
