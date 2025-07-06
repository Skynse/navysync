import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:navysync/models/event.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('events').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}'));
          }
          final docs = snapshot.data?.docs ?? [];
          final user = FirebaseAuth.instance.currentUser;
          // TODO: Replace with actual user roles, department, and teams
          final userRoles = <String>[];
          final userDepartmentId = '';
          final userTeamIds = <String>[];
          final List<Event> events =
              docs
                  .map(
                    (doc) => Event.fromJson({
                      'id': doc.id,
                      ...doc.data() as Map<String, dynamic>,
                    }),
                  )
                  .where(
                    (event) =>
                        user == null ||
                        event.canUserAccess(
                          user.uid,
                          userRoles,
                          userDepartmentId,
                          userTeamIds,
                        ),
                  )
                  .toList();
          final List<Appointment> appointments =
              events
                  .map(
                    (event) => Appointment(
                      startTime: event.date,
                      endTime: event.date.add(const Duration(hours: 1)),
                      subject: event.title,
                      notes:
                          event.description + '\nLocation: ' + event.location,
                      color: Colors.blue,
                    ),
                  )
                  .toList();
          return SfCalendar(
            view: CalendarView.month,
            dataSource: _EventDataSource(appointments),
            monthViewSettings: const MonthViewSettings(
              appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
            ),
          );
        },
      ),
    );
  }
}

class _EventDataSource extends CalendarDataSource {
  _EventDataSource(List<Appointment> source) {
    appointments = source;
  }
}
