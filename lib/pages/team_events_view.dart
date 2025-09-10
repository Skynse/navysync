import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:navysync/models/event.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants.dart';

class TeamEventsView extends StatefulWidget {
  final Event eventObject;
  const TeamEventsView({super.key, required this.eventObject});

  @override
  State<TeamEventsView> createState() => _TeamEventsViewState();
}

class _TeamEventsViewState extends State<TeamEventsView> {
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
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(AppDimensions.paddingM),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            boxShadow: [
              BoxShadow(
                color: AppColors.navyBlue.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with event title and visibility indicator
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                decoration: BoxDecoration(
                  color: widget.eventObject.displayColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppDimensions.radiusL),
                    topRight: Radius.circular(AppDimensions.radiusL),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          widget.eventObject.visibilityIcon,
                          color: AppColors.white,
                          size: 20,
                        ),
                        const SizedBox(width: AppDimensions.paddingS),
                        Expanded(
                          child: Text(
                            widget.eventObject.title,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.paddingXS),
                    Text(
                      widget.eventObject.visibilityLabel,
                      style: TextStyle(
                        color: AppColors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.eventObject.description.isNotEmpty) ...[
                      _buildDetailSection(
                        'Description',
                        widget.eventObject.description,
                        Icons.description,
                      ),
                      const SizedBox(height: AppDimensions.paddingM),
                    ],
                    if (widget.eventObject.location.isNotEmpty) ...[
                      _buildDetailSection(
                        'Location',
                        widget.eventObject.location,
                        Icons.location_on,
                      ),
                      const SizedBox(height: AppDimensions.paddingM),
                    ],
                    _buildDetailSection(
                      'Date & Time',
                      DateFormat('MM/dd/yyyy hh:mm a').format(widget.eventObject.date),
                      Icons.access_time,
                    ),
                    if (widget.eventObject.tags.isNotEmpty) ...[
                      const SizedBox(height: AppDimensions.paddingM),
                      const Text(
                        'Tags',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: AppColors.navyBlue,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingS),
                      Wrap(
                        spacing: AppDimensions.paddingS,
                        runSpacing: AppDimensions.paddingXS,
                        children: widget.eventObject.tags.map((tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingS,
                            vertical: AppDimensions.paddingXS,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.lightBlue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                            border: Border.all(
                              color: AppColors.lightBlue.withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              color: AppColors.navyBlue,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              // Attendance List
              FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
                future: _getEventAttendance(widget.eventObject.id),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox.shrink();
                  }
                  
                  final attendanceData = snapshot.data!;
                  final attending = attendanceData['attending'] ?? [];
                  final notAttending = attendanceData['not_attending'] ?? [];
                  
                  if (attending.isEmpty && notAttending.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  
                  return Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Attendance List',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: AppColors.navyBlue,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.paddingS),
                        if (attending.isNotEmpty) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppDimensions.paddingS),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                              border: Border.all(color: AppColors.success.withOpacity(0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.check_circle, color: AppColors.success, size: 16),
                                    const SizedBox(width: AppDimensions.paddingXS),
                                    Text(
                                      'Attending (${attending.length})',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.success,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppDimensions.paddingXS),
                                Wrap(
                                  spacing: AppDimensions.paddingXS,
                                  runSpacing: AppDimensions.paddingXS,
                                  children: attending.map((user) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppDimensions.paddingS,
                                      vertical: AppDimensions.paddingXS,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                                    ),
                                    child: Text(
                                      user['displayName'] ?? 'Unknown User',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.success,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  )).toList(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppDimensions.paddingS),
                        ],
                        if (notAttending.isNotEmpty) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppDimensions.paddingS),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                              border: Border.all(color: AppColors.error.withOpacity(0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.cancel, color: AppColors.error, size: 16),
                                    const SizedBox(width: AppDimensions.paddingXS),
                                    Text(
                                      'Not Attending (${notAttending.length})',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.error,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppDimensions.paddingXS),
                                Wrap(
                                  spacing: AppDimensions.paddingXS,
                                  runSpacing: AppDimensions.paddingXS,
                                  children: notAttending.map((user) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppDimensions.paddingS,
                                      vertical: AppDimensions.paddingXS,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.error.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                                    ),
                                    child: Text(
                                      user['displayName'] ?? 'Unknown User',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.error,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  )).toList(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppDimensions.paddingS),
                        ],
                      ],
                    ),
                  );
                },
              ),
              // Attendance Selection
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Will you attend this event?',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppColors.navyBlue,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingS),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _updateAttendance(context, widget.eventObject.id, 'attending'),
                            icon: const Icon(Icons.check_circle),
                            label: const Text('Attending'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: AppColors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.paddingS),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _updateAttendance(context, widget.eventObject.id, 'not_attending'),
                            icon: const Icon(Icons.cancel),
                            label: const Text('Not Attending'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              foregroundColor: AppColors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.paddingL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, String content, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: AppColors.navyBlue,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingXS),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 18,
              color: AppColors.darkGray,
            ),
            const SizedBox(width: AppDimensions.paddingS),
            Expanded(
              child: Text(
                content,
                style: const TextStyle(
                  color: AppColors.darkGray,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _updateAttendance(BuildContext context, String eventId, String status) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final attendanceCollection = FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .collection('attendance');

      await attendanceCollection.doc(currentUser.uid).set({
        'userId': currentUser.uid,
        'status': status, // 'attending' or 'not_attending'
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {}); // Refresh the UI to show updated attendance

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'attending' 
                ? 'Marked as attending!' 
                : 'Marked as not attending.',
          ),
          backgroundColor: status == 'attending' 
              ? AppColors.success 
              : AppColors.error,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating attendance: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<Map<String, List<Map<String, dynamic>>>> _getEventAttendance(String eventId) async {
    try {
      final attendanceSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .collection('attendance')
          .get();

      List<Map<String, dynamic>> attending = [];
      List<Map<String, dynamic>> notAttending = [];

      for (final doc in attendanceSnapshot.docs) {
        final data = doc.data();
        final userId = data['userId'] as String;
        
        // Get user details
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          final userInfo = {
            'userId': userId,
            'displayName': userData['name'] ?? 
                         (userData['firstName'] != null && userData['lastName'] != null
                             ? '${userData['firstName']} ${userData['lastName']}'
                             : userData['email']?.split('@')[0] ?? 'Unknown User'),
            'status': data['status'],
          };

          if (data['status'] == 'attending') {
            attending.add(userInfo);
          } else if (data['status'] == 'not_attending') {
            notAttending.add(userInfo);
          }
        }
      }

      return {
        'attending': attending,
        'not_attending': notAttending,
      };
    } catch (e) {
      print('Error fetching attendance: $e');
      return {'attending': [], 'not_attending': []};
    }
  }
}
