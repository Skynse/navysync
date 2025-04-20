import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TasksView extends StatefulWidget {
  const TasksView({super.key});

  @override
  State<TasksView> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<TasksView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Tasks')));
  }
}
