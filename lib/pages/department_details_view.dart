import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:navysync/models/department.dart';
import 'package:navysync/models/event.dart';
import 'package:navysync/models/user.dart';
import 'package:navysync/pages/team_events_view.dart';
import '../constants.dart';

class DepartmentDetailsView extends StatefulWidget {
  final String departmentId;
  const DepartmentDetailsView({super.key, required this.departmentId});

  @override
  State<DepartmentDetailsView> createState() => _DepartmentDetailsViewState();
}

class _DepartmentDetailsViewState extends State<DepartmentDetailsView> {
  DocumentSnapshot? _currentUser;
  Department? _department;
  List<QueryDocumentSnapshot> _departmentMembers = [];
  List<dynamic> _departmentAnnouncements = [];
  List<dynamic> _departmentEvents = [];
  bool _isLoading = true;
  bool _canManageDepartment = false;

  @override
  void initState() {
    super.initState();
    _loadDepartmentData();
  }

  Future<void> _loadDepartmentData() async {
    setState(() => _isLoading = true);

    try {
      // Get current user
      _currentUser =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser?.uid)
              .get();

      // Fetch department data
      final departmentDoc =
          await FirebaseFirestore.instance
              .collection('departments')
              .doc(widget.departmentId)
              .get();

      if (!departmentDoc.exists) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Department not found')));
        context.pop();
        return;
      }

      _department = Department.fromFirestore(departmentDoc);

      // Check permissions
      _canManageDepartment =
          _department!.departmentHeadId == _currentUser?.id ||
          _department!.assistantHeadIds.contains(_currentUser?.id) ||
          _currentUser?["roles"].contains('MODERATOR');

      // Fetch department members (all including head and assistants)
      final allMemberIds = _department!.allMemberIds;
      if (allMemberIds.isNotEmpty) {
        final membersSnapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .where(FieldPath.documentId, whereIn: allMemberIds)
                .get();

        _departmentMembers = membersSnapshot.docs;
      }

      // Fetch department announcements
      final announcementsSnapshot =
          await FirebaseFirestore.instance
              .collection('announcements')
              .where('departmentId', isEqualTo: widget.departmentId)
              .orderBy('createdAt', descending: true)
              .limit(5)
              .get();

      _departmentAnnouncements =
          announcementsSnapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList();

      // Fetch department events
      final eventsSnapshot =
          await FirebaseFirestore.instance
              .collection("events")
              .where('departmentId', isEqualTo: widget.departmentId)
              .where(
                'date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()),
              )
              .orderBy('date')
              .limit(5)
              .get();

      _departmentEvents =
          eventsSnapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading department data: $e')),
      );
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
            title: const Text('Add Department Member'),
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

                      // Add user to department
                      await FirebaseFirestore.instance
                          .collection('departments')
                          .doc(widget.departmentId)
                          .update({
                            'members': FieldValue.arrayUnion([userId]),
                            'updatedAt': FieldValue.serverTimestamp(),
                          });

                      // Add department to user's departmentIds
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(userId)
                          .update({
                            'departmentIds': FieldValue.arrayUnion([
                              widget.departmentId,
                            ]),
                          });

                      Navigator.pop(context);
                      _loadDepartmentData(); // Reload data
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('User not found')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navyBlue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  String _getMemberRole(String memberId) {
    if (_department!.departmentHeadId == memberId) {
      return 'Department Head';
    } else if (_department!.assistantHeadIds.contains(memberId)) {
      return 'Assistant Head';
    } else {
      return 'Member';
    }
  }

  bool _canRemoveMember(String memberId) {
    // Can't remove department head
    if (_department!.departmentHeadId == memberId) return false;

    // Department head can remove anyone
    if (_department!.departmentHeadId == _currentUser?.id) return true;

    // Assistant heads can remove regular members only
    if (_department!.assistantHeadIds.contains(_currentUser?.id)) {
      return !_department!.assistantHeadIds.contains(memberId);
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Department Details'),
          backgroundColor: AppColors.navyBlue,
          foregroundColor: AppColors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_department == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Department Not Found'),
          backgroundColor: AppColors.navyBlue,
          foregroundColor: AppColors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Could not load department information'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/departments'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navyBlue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Back to Departments'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(_department!.name),
        backgroundColor: AppColors.navyBlue,
        foregroundColor: AppColors.white,
        actions: [
          if (_canManageDepartment)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed:
                  () => context.push(
                    '/departments/${widget.departmentId}/manage',
                  ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDepartmentData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDepartmentData,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Department Header
              Container(
                width: double.infinity,
                color: AppColors.navyBlue.withOpacity(0.1),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.business,
                          size: 32,
                          color: AppColors.navyBlue,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _department!.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_department!.description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        _department!.description,
                        style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                      ),
                    ],
                  ],
                ),
              ),

              // Department Members
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Department Members',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_canManageDepartment)
                          TextButton.icon(
                            icon: const Icon(Icons.person_add, size: 18),
                            label: const Text('Add'),
                            onPressed: _showAddMemberDialog,
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.navyBlue,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 2,
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _departmentMembers.length,
                        itemBuilder: (context, index) {
                          final member = _departmentMembers[index];
                          final memberRole = _getMemberRole(member.id);
                          final isDepartmentHead =
                              member.id == _department!.departmentHeadId;
                          final isAssistantHead = _department!.assistantHeadIds
                              .contains(member.id);

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage:
                                  member["profilePictureUrl"] != null &&
                                          member["profilePictureUrl"].isNotEmpty
                                      ? NetworkImage(
                                        member["profilePictureUrl"],
                                      )
                                      : null,
                              backgroundColor:
                                  isDepartmentHead
                                      ? Colors.amber[100]
                                      : isAssistantHead
                                      ? Colors.blue[100]
                                      : null,
                              child:
                                  member["profilePictureUrl"] == null ||
                                          member["profilePictureUrl"].isEmpty
                                      ? Text(
                                        member["name"] != null &&
                                                member["name"].isNotEmpty
                                            ? member["name"][0].toUpperCase()
                                            : '?',
                                        style: TextStyle(
                                          color:
                                              isDepartmentHead
                                                  ? Colors.amber[700]
                                                  : isAssistantHead
                                                  ? Colors.blue[700]
                                                  : null,
                                        ),
                                      )
                                      : null,
                            ),
                            title: Text(member["name"] ?? 'Unknown User'),
                            subtitle: Row(
                              children: [
                                if (isDepartmentHead)
                                  Icon(
                                    Icons.star,
                                    size: 14,
                                    color: Colors.amber[700],
                                  )
                                else if (isAssistantHead)
                                  Icon(
                                    Icons.assistant,
                                    size: 14,
                                    color: Colors.blue[700],
                                  )
                                else
                                  Icon(
                                    Icons.person,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                const SizedBox(width: 4),
                                Text(memberRole),
                              ],
                            ),
                            trailing:
                                _canManageDepartment &&
                                        _canRemoveMember(member.id)
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
                                                  'Remove ${member["name"]} from the department?',
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
                                          // Remove member from department
                                          if (isAssistantHead) {
                                            await FirebaseFirestore.instance
                                                .collection('departments')
                                                .doc(widget.departmentId)
                                                .update({
                                                  'assistantHeadIds':
                                                      FieldValue.arrayRemove([
                                                        member.id,
                                                      ]),
                                                  'updatedAt':
                                                      FieldValue.serverTimestamp(),
                                                });
                                          } else {
                                            await FirebaseFirestore.instance
                                                .collection('departments')
                                                .doc(widget.departmentId)
                                                .update({
                                                  'members':
                                                      FieldValue.arrayRemove([
                                                        member.id,
                                                      ]),
                                                  'updatedAt':
                                                      FieldValue.serverTimestamp(),
                                                });
                                          }

                                          // Remove department from user
                                          await FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(member.id)
                                              .update({
                                                'departmentIds':
                                                    FieldValue.arrayRemove([
                                                      widget.departmentId,
                                                    ]),
                                              });

                                          _loadDepartmentData(); // Reload data
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
                          _departmentAnnouncements.isEmpty
                              ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: Text('No announcements yet'),
                                ),
                              )
                              : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _departmentAnnouncements.length,
                                itemBuilder: (context, index) {
                                  final announcement =
                                      _departmentAnnouncements[index];
                                  return ListTile(
                                    title: Text(
                                      announcement['title'] ?? 'Untitled',
                                    ),
                                    subtitle: Text(
                                      announcement['content'] ?? '',
                                    ),
                                    leading: Icon(
                                      Icons.announcement,
                                      color: AppColors.navyBlue,
                                    ),
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
                          _departmentEvents.isEmpty
                              ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: Text('No upcoming events'),
                                ),
                              )
                              : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _departmentEvents.length,
                                itemBuilder: (context, index) {
                                  final event = _departmentEvents[index];
                                  return ListTile(
                                    title: Text(
                                      event['title'] ?? 'Untitled Event',
                                    ),
                                    subtitle: Text(event['description'] ?? ''),
                                    leading: Icon(
                                      Icons.event,
                                      color: AppColors.navyBlue,
                                    ),
                                    trailing: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
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
                                        if (event['location'] != null &&
                                            event['location']
                                                .toString()
                                                .isNotEmpty)
                                          Text(
                                            event['location'],
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                      ],
                                    ),
                                    onTap:
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
}
