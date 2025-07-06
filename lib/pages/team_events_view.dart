import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:navysync/models/event.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TeamEventsView extends StatelessWidget {
  final String teamId;
  const TeamEventsView({super.key, required this.teamId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Event',
            onPressed: () async {
              final result = await showDialog<Map<String, dynamic>>(
                context: context,
                builder: (context) => _AddEventDialog(teamId: teamId),
              );
              if (result != null) {
                await FirebaseFirestore.instance
                    .collection('events')
                    .add(result);
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('events')
                .where('teamId', isEqualTo: teamId)
                .orderBy('date', descending: false)
                .snapshots(),
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
          if (events.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 60, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    'No events for this team yet.',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(Icons.event, color: Colors.blue.shade700),
                  title: Text(
                    event.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Type: \\${event.event_type}'),
                      Text(
                        'Date: \\${DateFormat('yyyy-MM-dd').format(event.date)}',
                        style: const TextStyle(fontSize: 13),
                      ),
                      if (event.location.isNotEmpty)
                        Text('Location: \\${event.location}'),
                      if (event.description.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(event.description),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _AddEventDialog extends StatefulWidget {
  final String teamId;
  const _AddEventDialog({required this.teamId});

  @override
  State<_AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<_AddEventDialog> {
  final _formKey = GlobalKey<FormState>();
  String _eventName = '';
  String _eventDesc = '';
  DateTime? _eventDate;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Event'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Event Name'),
                validator:
                    (v) =>
                        v == null || v.trim().isEmpty ? 'Enter a name' : null,
                onChanged: (v) => setState(() => _eventName = v),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (v) => setState(() => _eventDesc = v),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextFormField(
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Date'),
                controller: TextEditingController(
                  text:
                      _eventDate != null
                          ? DateFormat('yyyy-MM-dd').format(_eventDate!)
                          : '',
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _eventDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _eventDate = picked);
                },
                validator: (_) => _eventDate == null ? 'Pick a date' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Event event = Event(
              id: '',
              creatorId: FirebaseAuth.instance.currentUser?.uid ?? '',
              title: _eventName,
              description: _eventDesc,
              date: _eventDate!,
              location: '',
              event_type: 'General',
              visibility: 'team',
              teamId: widget.teamId,
            );

            if (_formKey.currentState?.validate() ?? false) {
              Navigator.pop(context, event.toJson());
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
