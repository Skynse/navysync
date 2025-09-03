import 'package:flutter/material.dart';

class DepartmentsPage extends StatefulWidget {
  @override
  State<DepartmentsPage> createState() => _DepartmentsPageState();
}

class _DepartmentsPageState extends State<DepartmentsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Departments')),
      body: Center(child: Text('Departments Page')),
    );
  }
}
