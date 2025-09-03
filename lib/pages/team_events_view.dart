import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:navysync/models/event.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants.dart';

class TeamEventsView extends StatelessWidget {
  final Event eventObject;
  const TeamEventsView({super.key, required this.eventObject});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Event Details',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.navyBlue,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(eventObject.title),
            const SizedBox(height: 8),
            Text(DateFormat('MM/dd/yyyy hh:mm a').format(eventObject.date)),
            const SizedBox(height: 16),
            Text(eventObject.description),
            const SizedBox(height: 16),
            Text('Location: ${eventObject.location}'),
          ],
        ),
      ),
    );
  }
}
