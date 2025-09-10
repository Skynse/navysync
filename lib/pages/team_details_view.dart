import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:navysync/models/event.dart';
import 'package:navysync/models/team.dart';
import 'package:navysync/models/user.dart';
import 'package:navysync/pages/team_events_view.dart';
import 'package:navysync/pages/teams.dart';
import 'package:navysync/services/auth_service.dart';

class TeamDetailsView extends StatefulWidget {
  final String teamId;
  const TeamDetailsView({super.key, required this.teamId});

  @override
  State<TeamDetailsView> createState() => _TeamDetailsViewState();
}

class _TeamDetailsViewState extends State<TeamDetailsView> {
  final AuthService _authService = AuthService();
  DocumentSnapshot? _currentUser;
  Team? _team;
  List<QueryDocumentSnapshot> _teamMembers = [];
  List<dynamic> _teamAnnouncements = [];
  List<dynamic> _teamEvents = [];
  bool _isLoading = true;
  bool _canManageTeam = false;

  @override
  void initState() {
    super.initState();
    _loadTeamData();
  }

  Future<void> _loadTeamData() async {
    setState(() => _isLoading = true);

    try {
      // Get current user
      _currentUser =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser?.uid)
              .get();

      // Fetch team data
      final teamDoc =
          await FirebaseFirestore.instance
              .collection('teams')
              .doc(widget.teamId)
              .get();

      if (!teamDoc.exists) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Team not found')));
        context.pop();
        return;
      }

      _team = Team.fromFirestore(teamDoc);

      // Check permissions
      _canManageTeam =
          _team!.teamLeaderId == _currentUser?.id ||
          _currentUser?["roles"].contains('MODERATOR') ||
          _currentUser?["roles"].contains('DEPARTMENT_HEAD');

      // Fetch team members
      if (_team!.members.isNotEmpty) {
        final membersSnapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .where(FieldPath.documentId, whereIn: _team!.members)
                .get();

        _teamMembers = membersSnapshot.docs;
      }

      // Fetch team announcements
      final announcementsSnapshot =
          await FirebaseFirestore.instance
              .collection('announcements')
              .where('teamId', isEqualTo: widget.teamId)
              .orderBy('createdAt', descending: true)
              .limit(5)
              .get();

      _teamAnnouncements =
          announcementsSnapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList();

      // Fetch team events
      final eventsSnapshot =
          await FirebaseFirestore.instance
              .collection("events")
              .where('teamId', isEqualTo: widget.teamId)
              .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()))
              .orderBy('date')
              .limit(5)
              .get();

      _teamEvents =
          eventsSnapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading team data: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showAddMemberDialog() {
    TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Team Member'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter member email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (emailController.text.isNotEmpty) {
                    // Look up user by email
                    final userQuerySnapshot =
                        await FirebaseFirestore.instance
                            .collection('users')
                            .where('email', isEqualTo: emailController.text)
                            .limit(1)
                            .get();

                    if (userQuerySnapshot.docs.isNotEmpty) {
                      final userId = userQuerySnapshot.docs.first.id;

                      // Add user to team
                      await FirebaseFirestore.instance
                          .collection('teams')
                          .doc(widget.teamId)
                          .update({
                            'members': FieldValue.arrayUnion([userId]),
                          });

                      // Add team to user's teamIds
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(userId)
                          .update({
                            'teamIds': FieldValue.arrayUnion([widget.teamId]),
                          });

                      Navigator.pop(context);
                      _loadTeamData(); // Reload data
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('User not found')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800,
                ),
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Team Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_team == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Team Not Found')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Could not load team information'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/teams'),
                child: const Text('Back to Teams'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_team!.name),
        actions: [
          if (_canManageTeam)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => context.push('/teams/${widget.teamId}/manage'),
            ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadTeamData),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadTeamData,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Team Header
              Container(
                width: double.infinity,
                color: Colors.blue.shade50,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _team!.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _team!.description,
                      style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                    ),
                  ],
                ),
              ),

              // Team Members
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Team Members',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_canManageTeam)
                          TextButton.icon(
                            icon: const Icon(Icons.person_add, size: 18),
                            label: const Text('Add'),
                            onPressed: _showAddMemberDialog,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 2,
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _teamMembers.length,
                        itemBuilder: (context, index) {
                          final member = _teamMembers[index];
                          final bool isTeamLeader =
                              member.id == _team!.teamLeaderId;

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage:
                                  member["profilePictureUrl"] != null
                                      ? NetworkImage(
                                        member["profilePictureUrl"],
                                      )
                                      : null,
                              child:
                                  member["profilePictureUrl"] == null ||
                                          member["profilePictureUrl"].isEmpty
                                      ? Text(
                                        member["name"] != null &&
                                                member["name"].isNotEmpty
                                            ? member["name"][0].toUpperCase()
                                            : '?',
                                      )
                                      : null,
                            ),
                            title: Text(member["name"] ?? 'Unknown User'),
                            subtitle: Text(
                              isTeamLeader ? 'Team Leader' : 'Member',
                            ),
                            trailing:
                                _canManageTeam && !isTeamLeader
                                    ? IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                      ),
                                      color: Colors.red,
                                      onPressed: () async {
                                        // Show confirmation dialog
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder:
                                              (context) => AlertDialog(
                                                title: const Text(
                                                  'Remove Member',
                                                ),
                                                content: Text(
                                                  'Remove ${member["name"]} from the team?',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed:
                                                        () => Navigator.pop(
                                                          context,
                                                          false,
                                                        ),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed:
                                                        () => Navigator.pop(
                                                          context,
                                                          true,
                                                        ),
                                                    style: TextButton.styleFrom(
                                                      foregroundColor:
                                                          Colors.red,
                                                    ),
                                                    child: const Text('Remove'),
                                                  ),
                                                ],
                                              ),
                                        );

                                        if (confirm == true) {
                                          // Remove member from team
                                          await FirebaseFirestore.instance
                                              .collection('teams')
                                              .doc(widget.teamId)
                                              .update({
                                                'members':
                                                    FieldValue.arrayRemove([
                                                      member.id,
                                                    ]),
                                              });

                                          // Remove team from user
                                          await FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(member.id)
                                              .update({
                                                'teamIds':
                                                    FieldValue.arrayRemove([
                                                      widget.teamId,
                                                    ]),
                                              });

                                          _loadTeamData(); // Reload data
                                        }
                                      },
                                    )
                                    : null,
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Announcements
                    const Text(
                      'Announcements',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 2,
                      child:
                          _teamAnnouncements.isEmpty
                              ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: Text('No announcements yet'),
                                ),
                              )
                              : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _teamAnnouncements.length,
                                itemBuilder: (context, index) {
                                  final announcement =
                                      _teamAnnouncements[index];
                                  return ListTile(
                                    title: Text(
                                      announcement['title'] ?? 'Untitled',
                                    ),
                                    subtitle: Text(
                                      announcement['content'] ?? '',
                                    ),
                                    leading: const Icon(Icons.announcement),
                                    trailing: Text(
                                      announcement['createdAt'] != null
                                          ? _formatDate(
                                            announcement['createdAt'],
                                          )
                                          : '',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  );
                                },
                              ),
                    ),

                    const SizedBox(height: 24),

                    // Upcoming Events
                    const Text(
                      'Upcoming Events',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 2,
                      child:
                          _teamEvents.isEmpty
                              ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: Text('No upcoming events'),
                                ),
                              )
                              : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _teamEvents.length,
                                itemBuilder: (context, index) {
                                  final event = _teamEvents[index];
                                  return ListTile(
                                    title: Text(
                                      event['title'] ?? 'Untitled Event',
                                    ),
                                    subtitle: Text(event['description'] ?? ''),
                                    leading: const Icon(Icons.event),
                                    trailing: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          event['date'] != null
                                              ? _formatDate(
                                                event['date'],
                                                showTime: true,
                                              )
                                              : '',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          event['location'] ?? '',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    onTap:
                                        // () => context.push(
                                        //   '/events/${event['id']}',
                                        //   extra: event,
                                        // ),
                                        () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => TeamEventsView(
                                                  eventObject: Event.fromJson(
                                                    event,
                                                  ),
                                                ),
                                          ),
                                        ),
                                  );
                                },
                              ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(dynamic date, {bool showTime = false}) {
    if (date == null) return '';

    DateTime dateTime;
    if (date is Timestamp) {
      dateTime = date.toDate();
    } else if (date is String) {
      dateTime = DateTime.parse(date);
    } else {
      return '';
    }

    if (showTime) {
      return '${dateTime.month}/${dateTime.day}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
    }
  }

  Widget _buildEventDetailsDialog(Map<String, dynamic> event) {
    final eventDate = event['date'] as Timestamp?;
    final displayDate = eventDate?.toDate() ?? DateTime.now();
    
    return AlertDialog(
      title: Text(
        event['title'] ?? 'Event Details',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (event['description'] != null && 
                event['description'].toString().isNotEmpty) ...[
              const Text(
                'Description:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(event['description']),
              const SizedBox(height: 16),
            ],
            const Text(
              'Date & Time:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(_formatDate(displayDate, showTime: true)),
              ],
            ),
            const SizedBox(height: 16),
            if (event['location'] != null && 
                event['location'].toString().isNotEmpty) ...[
              const Text(
                'Location:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(child: Text(event['location'])),
                ],
              ),
              const SizedBox(height: 16),
            ],
            // Attendance Section
            const Text(
              'Will you attend this event?',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _updateEventAttendance(event['id'], 'attending');
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Attending'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _updateEventAttendance(event['id'], 'not_attending');
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.cancel),
                    label: const Text('Not Attending'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Future<void> _updateEventAttendance(String eventId, String status) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final attendanceCollection = FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .collection('attendance');

      await attendanceCollection.doc(currentUser.uid).set({
        'userId': currentUser.uid,
        'status': status,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'attending' 
                ? 'Marked as attending!' 
                : 'Marked as not attending.',
          ),
          backgroundColor: status == 'attending' ? Colors.green : Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating attendance: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
