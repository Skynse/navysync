import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:navysync/models/announcement.dart';

class CreateAnnouncementPage extends StatefulWidget {
  @override
  State<CreateAnnouncementPage> createState() => _DepartmentsPageState();
}

class _DepartmentsPageState extends State<CreateAnnouncementPage> {
  final _formKey = GlobalKey<FormState>();
  AnnouncementVisibility _visibility = AnnouncementVisibility.public;
  AnnouncementPriority _priority = AnnouncementPriority.normal;
  DateTime _expiresAt = DateTime.now().add(Duration(days: 7));

  TextEditingController _titleController = TextEditingController();
  TextEditingController _bodyController = TextEditingController();

  Future<void> createAnnouncement(Announcement announcement) async {
    var announcementJson = announcement.toFirestore();
    announcementJson['authorId'] = FirebaseAuth.instance.currentUser?.uid;
    FirebaseFirestore.instance
        .collection('announcements')
        .add(announcementJson);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Announcement')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            spacing: 16.0,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Announcement Title'),
              ),

              TextFormField(
                controller: _bodyController,
                decoration: InputDecoration(labelText: 'body'),
                maxLines: 5,
              ),

              DropdownMenuFormField(
                onSelected: (value) {
                  setState(() {
                    switch (value) {
                      case 'public':
                        _visibility = AnnouncementVisibility.public;
                        break;
                      case 'organization':
                        _visibility = AnnouncementVisibility.organization;
                        break;
                      case 'department':
                        _visibility = AnnouncementVisibility.department;
                        break;
                      case 'team':
                        _visibility = AnnouncementVisibility.team;
                        break;
                    }
                  });
                },
                dropdownMenuEntries: [
                  DropdownMenuEntry(
                    value: 'public',
                    label: 'Public',
                    leadingIcon: Icon(Icons.public),
                  ),
                  DropdownMenuEntry(
                    value: 'organization',
                    label: 'Organization',
                    leadingIcon: Icon(Icons.public),
                  ),
                  DropdownMenuEntry(
                    value: 'department',
                    label: 'Department',
                    leadingIcon: Icon(Icons.public),
                  ),
                  DropdownMenuEntry(
                    value: 'team',
                    label: 'Team',
                    leadingIcon: Icon(Icons.public),
                  ),
                ],

                initialSelection: 'public',
                hintText: 'Select Visibility',
              ),

              // priority
              DropdownMenuFormField(
                onSelected: (value) {
                  setState(() {
                    switch (value) {
                      case 'low':
                        _priority = AnnouncementPriority.low;
                        break;
                      case 'normal':
                        _priority = AnnouncementPriority.normal;
                        break;
                      case 'high':
                        _priority = AnnouncementPriority.high;
                        break;

                      case 'urgent':
                        _priority = AnnouncementPriority.urgent;
                        break;
                    }
                  });
                },
                dropdownMenuEntries: [
                  DropdownMenuEntry(
                    value: 'low',
                    label: 'Low',
                    leadingIcon: Icon(Icons.low_priority),
                  ),
                  DropdownMenuEntry(
                    value: 'normal',
                    label: 'Normal',
                    leadingIcon: Icon(Icons.priority_high),
                  ),
                  DropdownMenuEntry(
                    value: 'high',
                    label: 'High',
                    leadingIcon: Icon(Icons.priority_high),
                  ),
                  DropdownMenuEntry(
                    value: 'urgent',
                    label: 'Urgent',
                    leadingIcon: Icon(Icons.priority_high),
                  ),
                ],
                initialSelection: 'normal',
                hintText: 'Select Priority',
              ),

              InputDatePickerFormField(
                firstDate: DateTime.now(),
                lastDate: DateTime(DateTime.now().year + 1),
              ),

              Text("Visibility: $_visibility"),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text('Create Announcement'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
