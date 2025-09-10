import 'package:flutter/material.dart';
import '../constants.dart';

class DepartmentsPage extends StatefulWidget {
  const DepartmentsPage({super.key});

  @override
  State<DepartmentsPage> createState() => _DepartmentsPageState();
}

class _DepartmentsPageState extends State<DepartmentsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Departments',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.navyBlue,
        elevation: 2,
        iconTheme: const IconThemeData(color: AppColors.white),
        centerTitle: false,
      ),
      body: Center(child: Text('[Work in Progress!] Departments Page')),
    );
  }
}
