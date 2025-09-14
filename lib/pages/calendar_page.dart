import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';
import '../providers/event_provider.dart';
import '../constants.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  Timer? _refreshTimer;
  CalendarController? _calendarController;

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
    _calendarController!.displayDate = DateTime.now();
    _setupAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _calendarController?.dispose();
    super.dispose();
  }

  void _setupAutoRefresh() {
    // Auto-refresh every 30 seconds to catch Firebase changes
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      ref.invalidate(allUserEventsProvider);
    });
  }

  bool _isEventInCurrentMonth(DateTime eventDate, DateTime displayDate) {
    return eventDate.year == displayDate.year && eventDate.month == displayDate.month;
  }

  @override
  Widget build(BuildContext context) {
    final userEventsAsync = ref.watch(allUserEventsProvider);
    
    // Auto-refresh events every 30 seconds to catch Firebase changes
    ref.listen(allUserEventsProvider, (previous, next) {
      // This will be called whenever the provider updates
    });
    
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        title: const Text(
          'Calendar',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.navyBlue,
        elevation: 2,
        shadowColor: AppColors.navyBlue.withOpacity(0.3),
        iconTheme: const IconThemeData(color: AppColors.white),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              ref.invalidate(allUserEventsProvider);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Refreshing events...'),
                  duration: Duration(seconds: 1),
                  backgroundColor: Color.from(alpha: 1, red: 0, green: 0.2, blue: 0.4),
                ),
              );
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Events',
          ),
        ],
      ),
      body: userEventsAsync.when(
        data: (events) {
          final List<Appointment> appointments = events
              .map((event) {
                // Use proper start and end times
                final startTime = event.startTime?.toDate() ?? event.date;
                DateTime endTime;
                
                if (event.endTime != null) {
                  endTime = event.endTime!.toDate();
                  
                  // Check if this is truly meant to be a multi-day event
                  final startDate = DateTime(startTime.year, startTime.month, startTime.day);
                  final endDate = DateTime(endTime.year, endTime.month, endTime.day);
                  
                  // If end time is on a different day, check if it's intentionally multi-day
                  if (!startDate.isAtSameMomentAs(endDate)) {
                    // If the difference is more than 1 day, keep as multi-day
                    final daysDifference = endDate.difference(startDate).inDays;
                    if (daysDifference == 0) {
                      // Same date but different day due to time - cap at end of start day
                      endTime = DateTime(startTime.year, startTime.month, startTime.day, 23, 59, 59);
                    }
                    // If daysDifference > 0, keep as intentional multi-day event
                  }
                } else {
                  // For events without explicit end time
                  // Always end on the same day to prevent spanning
                  endTime = DateTime(startTime.year, startTime.month, startTime.day, 23, 59, 59);
                }
                
                return Appointment(
                  startTime: startTime,
                  endTime: endTime,
                  subject: event.title,
                  notes: '${event.description}\n\nLocation: ${event.location}',
                  color: event.displayColor,
                  location: event.location,
                  // Remove isAllDay to ensure proper agenda display
                );
              })
              .toList();

          return Column(
            children: [
              // Calendar container
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(AppDimensions.paddingS),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.navyBlue.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: SfCalendar(
                    view: CalendarView.timelineMonth,
                    controller: _calendarController,
                    dataSource: _EventDataSource(appointments),
                    firstDayOfWeek: 1, // Start week on Monday (1 = Monday, 7 = Sunday)
                    headerDateFormat: 'MMMM yyyy', // Month format for month view
                    headerHeight: 60,
                    showNavigationArrow: true,
                    showDatePickerButton: false, // Disable date picker button
                    allowViewNavigation: false, // Prevent unwanted view navigation
                    initialDisplayDate: DateTime.now(),
              monthViewSettings: MonthViewSettings(
                numberOfWeeksInView: 6, // Standard month view
                appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                appointmentDisplayCount: 2, // Month view appointments
                showTrailingAndLeadingDates: true, // Show trailing/leading dates
                showAgenda: true,
                agendaViewHeight: 200, // Reduce agenda height
                agendaStyle: AgendaStyle(
                  backgroundColor: AppColors.lightGray,
                  appointmentTextStyle: const TextStyle(
                    color: AppColors.navyBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  dayTextStyle: const TextStyle(
                    color: AppColors.darkGray,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  dateTextStyle: const TextStyle(
                    color: AppColors.navyBlue,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                monthCellStyle: const MonthCellStyle(
                  backgroundColor: AppColors.white,
                  textStyle: TextStyle(
                    color: AppColors.navyBlue,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  trailingDatesTextStyle: TextStyle(
                    color: AppColors.darkGray,
                    fontSize: 14,
                  ),
                  leadingDatesTextStyle: TextStyle(
                    color: AppColors.darkGray,
                    fontSize: 14,
                  ),
                ),
              ),
              appointmentBuilder: (context, details) {
                final appointment = details.appointments.first;
                final eventDate = appointment.startTime;
                final currentDisplayDate = _calendarController?.displayDate ?? DateTime.now();
                final isCurrentMonth = _isEventInCurrentMonth(eventDate, currentDisplayDate);
                
                // Check if this is an agenda item (bottom section) in month view
                final isAgendaItem = details.bounds.height > 30;
                
                return FutureBuilder<String?>(
                  future: _getUserAttendanceStatus(appointment.subject, events),
                  builder: (context, snapshot) {
                    final attendanceStatus = snapshot.data;
                    
                    // Special styling for agenda items in month view
                    if (isAgendaItem) {
                      // Find the corresponding event for additional details
                      final correspondingEvent = events.firstWhere(
                        (e) => e.title == appointment.subject,
                        orElse: () => events.first,
                      );
                      
                      // Format time display
                      String timeDisplay = '';
                      if (correspondingEvent.startTime != null) {
                        final startTime = correspondingEvent.startTime!.toDate();
                        if (correspondingEvent.endTime != null) {
                          final endTime = correspondingEvent.endTime!.toDate();
                          timeDisplay = '${TimeOfDay.fromDateTime(startTime).format(context)} - ${TimeOfDay.fromDateTime(endTime).format(context)}';
                        } else {
                          timeDisplay = TimeOfDay.fromDateTime(startTime).format(context);
                        }
                      }
                      
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: appointment.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: appointment.color.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Color indicator
                            Container(
                              width: 4,
                              height: 20,
                              decoration: BoxDecoration(
                                color: appointment.color,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Title
                            Expanded(
                              flex: 3,
                              child: Text(
                                appointment.subject,
                                style: const TextStyle(
                                  color: AppColors.navyBlue,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Time display
                            if (timeDisplay.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      size: 12,
                                      color: AppColors.darkGray,
                                    ),
                                    const SizedBox(width: 2),
                                    Flexible(
                                      child: Text(
                                        timeDisplay,
                                        style: const TextStyle(
                                          color: AppColors.darkGray,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            // Location display
                            if (correspondingEvent.location.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 12,
                                      color: AppColors.darkGray,
                                    ),
                                    const SizedBox(width: 2),
                                    Flexible(
                                      child: Text(
                                        correspondingEvent.location,
                                        style: const TextStyle(
                                          color: AppColors.darkGray,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            // Attendance indicator
                            if (attendanceStatus != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: attendanceStatus == 'attending' 
                                    ? AppColors.success 
                                    : AppColors.error,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.white,
                                    width: 1,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }
                    
                    // Default calendar cell styling for month view
                    return Container(
                      width: details.bounds.width * 0.95, // Month view: nearly full width
                      height: details.bounds.height * 0.6, // Month view: shorter height for better centering
                      margin: const EdgeInsets.symmetric(
                        horizontal: 4, // Month view margins
                        vertical: 4 // Month view margins
                      ),
                      decoration: BoxDecoration(
                        color: (!isCurrentMonth)
                          ? appointment.color.withOpacity(0.3) // Lighter color for adjacent month events
                          : appointment.color, // Full color for current month
                        borderRadius: BorderRadius.circular(4),
                        border: (!isCurrentMonth)
                          ? Border.all(
                              color: appointment.color.withOpacity(0.5),
                              width: 1,
                            ) // Border for adjacent month events
                          : null,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        child: Text(
                          appointment.subject,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 9, // Month view text size
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1, // Single line in month view
                          softWrap: true,
                        ),
                      ),
                    );
                  },
                );
              },
              onSelectionChanged: (CalendarSelectionDetails details) {
                // This ensures the agenda updates when a date is selected
                // The agenda should automatically show events for the selected date
              },
              headerStyle: const CalendarHeaderStyle(
                backgroundColor: AppColors.navyBlue,
                textAlign: TextAlign.center,
                textStyle: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              viewHeaderStyle: const ViewHeaderStyle(
                backgroundColor: AppColors.primaryBlue,
                dayTextStyle: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              todayHighlightColor: AppColors.gold,
              selectionDecoration: BoxDecoration(
                color: AppColors.lightBlue.withOpacity(0.3),
                border: Border.all(color: AppColors.lightBlue, width: 2),
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              cellBorderColor: AppColors.lightGray,
              backgroundColor: AppColors.white,
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => Container(
          color: AppColors.lightGray,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: AppColors.navyBlue,
                  strokeWidth: 3,
                ),
                SizedBox(height: AppDimensions.paddingM),
                Text(
                  'Loading events...',
                  style: TextStyle(
                    color: AppColors.navyBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        error: (error, stackTrace) => Container(
          color: AppColors.lightGray,
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingL),
                const Text(
                  'Error loading events',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.navyBlue,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingS),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.darkGray,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingL),
                ElevatedButton.icon(
                  onPressed: () => ref.refresh(allUserEventsProvider),
                  icon: const Icon(Icons.refresh, color: AppColors.white),
                  label: const Text(
                    'Retry',
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navyBlue,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingL,
                      vertical: AppDimensions.paddingM,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                    ),
                    elevation: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePersonalEventDialog(context),
        backgroundColor: AppColors.navyBlue,
        foregroundColor: AppColors.white,
        tooltip: 'Create Personal Event',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreatePersonalEventDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final locationController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    bool isAllDay = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  decoration: const BoxDecoration(
                    color: AppColors.navyBlue,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppDimensions.radiusL),
                      topRight: Radius.circular(AppDimensions.radiusL),
                    ),
                  ),
                  child: const Text(
                    'Create Personal Event',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Form
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  child: Column(
                    children: [
                      // Title field
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: 'Event Title',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                          ),
                          prefixIcon: const Icon(Icons.title, color: AppColors.navyBlue),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingM),
                      // Description field
                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Description (Optional)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                          ),
                          prefixIcon: const Icon(Icons.description, color: AppColors.navyBlue),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingM),
                      // Location field
                      TextField(
                        controller: locationController,
                        decoration: InputDecoration(
                          labelText: 'Location (Optional)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                          ),
                          prefixIcon: const Icon(Icons.location_on, color: AppColors.navyBlue),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingM),
                      // All day toggle
                      Row(
                        children: [
                          const Text('All Day Event'),
                          const Spacer(),
                          Switch(
                            value: isAllDay,
                            onChanged: (value) {
                              setState(() {
                                isAllDay = value;
                              });
                            },
                            activeThumbColor: AppColors.navyBlue,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.paddingM),
                      // Date picker
                      ListTile(
                        leading: const Icon(Icons.calendar_today, color: AppColors.navyBlue),
                        title: const Text('Date'),
                        subtitle: Text('${selectedDate.month}/${selectedDate.day}/${selectedDate.year}'),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020), // Allow selecting dates from 2020
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                      ),
                      // Time picker (only if not all day)
                      if (!isAllDay)
                        ListTile(
                          leading: const Icon(Icons.access_time, color: AppColors.navyBlue),
                          title: const Text('Time'),
                          subtitle: Text(selectedTime.format(context)),
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                            );
                            if (picked != null) {
                              setState(() {
                                selectedTime = picked;
                              });
                            }
                          },
                        ),
                    ],
                  ),
                ),
                // Actions
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: AppColors.darkGray),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.paddingM),
                      ElevatedButton(
                        onPressed: () {
                          if (titleController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter an event title'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                            return;
                          }
                          _createPersonalEvent(
                            context,
                            titleController.text.trim(),
                            descriptionController.text.trim(),
                            locationController.text.trim(),
                            selectedDate,
                            isAllDay ? null : selectedTime,
                            isAllDay,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.navyBlue,
                          foregroundColor: AppColors.white,
                        ),
                        child: const Text('Create Event'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createPersonalEvent(
    BuildContext context,
    String title,
    String description,
    String location,
    DateTime date,
    TimeOfDay? time,
    bool isAllDay,
  ) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Calculate start and end times
      DateTime startTime;
      DateTime? endTime;

      if (isAllDay) {
        startTime = DateTime(date.year, date.month, date.day);
        endTime = DateTime(date.year, date.month, date.day, 23, 59, 59);
      } else {
        startTime = DateTime(
          date.year,
          date.month,
          date.day,
          time?.hour ?? 0,
          time?.minute ?? 0,
        );
        endTime = startTime.add(const Duration(hours: 1)); // Default 1 hour duration
      }

      // Create the event document
      final eventData = {
        'title': title,
        'description': description,
        'location': location,
        'date': Timestamp.fromDate(date),
        'startTime': Timestamp.fromDate(startTime),
        'endTime': Timestamp.fromDate(endTime),
        'isAllDay': isAllDay,
        'visibility': 'private', // Personal events are private
        'createdBy': currentUser.uid,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'tags': <String>[],
        'attendees': <String>[currentUser.uid], // Only the creator
        'isActive': true,
      };

      await FirebaseFirestore.instance
          .collection('events')
          .add(eventData);

      if (context.mounted) {
        Navigator.of(context).pop(); // Close the dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Personal event "$title" created successfully!'),
            backgroundColor: AppColors.primaryBlue,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating event: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
          ),
        );
      }
    }
  }

  Future<String?> _getUserAttendanceStatus(String eventTitle, List<Event> events) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return null;

      // Find the event by title
      final event = events.firstWhere(
        (e) => e.title == eventTitle,
        orElse: () => events.first,
      );

      final attendanceDoc = await FirebaseFirestore.instance
          .collection('events')
          .doc(event.id)
          .collection('attendance')
          .doc(currentUser.uid)
          .get();

      if (attendanceDoc.exists) {
        return attendanceDoc.data()?['status'] as String?;
      }
      return null;
    } catch (e) {
      print('Error getting attendance status: $e');
      return null;
    }
  }
}

class _EventDataSource extends CalendarDataSource {
  _EventDataSource(List<Appointment> source) {
    appointments = source;
  }
}