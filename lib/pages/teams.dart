import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TeamsView extends StatefulWidget {
  const TeamsView({super.key});

  @override
  State<TeamsView> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<TeamsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Teams')));
  }
}
