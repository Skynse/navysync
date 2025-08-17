import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../models/event.dart';
import '../providers/event_provider.dart';
import '../constants.dart';

class CalendarPage extends ConsumerWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userEventsAsync = ref.watch(userEventsProvider);
    
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        title: const Text(
          'Calendar',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.navyBlue,
        elevation: 2,
        shadowColor: AppColors.navyBlue.withOpacity(0.3),
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: userEventsAsync.when(
        data: (events) {
          final List<Appointment> appointments = events
              .where((event) => event.isActive) // Only show active events
              .map((event) {
                // Use proper start and end times
                final startTime = event.startTime?.toDate() ?? event.date;
                final endTime = event.endTime?.toDate() ?? startTime.add(const Duration(hours: 1));
                
                return Appointment(
                  startTime: startTime,
                  endTime: endTime,
                  subject: event.title,
                  notes: '${event.description}\n\nLocation: ${event.location}',
                  color: event.displayColor,
                  location: event.location,
                );
              })
              .toList();

          return Container(
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
              view: CalendarView.month,
              dataSource: _EventDataSource(appointments),
              monthViewSettings: MonthViewSettings(
                appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                showAgenda: true,
                agendaStyle: AgendaStyle(
                  backgroundColor: AppColors.lightGray,
                  appointmentTextStyle: const TextStyle(
                    color: AppColors.navyBlue,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  dayTextStyle: const TextStyle(
                    color: AppColors.darkGray,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  dateTextStyle: const TextStyle(
                    color: AppColors.navyBlue,
                    fontSize: 24,
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
                return Container(
                  width: details.bounds.width,
                  height: details.bounds.height,
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: appointment.color,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    boxShadow: [
                      BoxShadow(
                        color: appointment.color.withOpacity(0.3),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingXS,
                      vertical: 2,
                    ),
                    child: Text(
                      appointment.subject,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                );
              },
              onTap: (details) {
                if (details.appointments != null && details.appointments!.isNotEmpty) {
                  _showEventDetails(context, details.appointments!.first, events);
                }
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
                  onPressed: () => ref.refresh(userEventsProvider),
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
    );
  }

  void _showEventDetails(BuildContext context, Appointment appointment, List<Event> events) {
    // Find the corresponding event
    final event = events.firstWhere(
      (e) => e.title == appointment.subject,
      orElse: () => events.first,
    );

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        child: Container(
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
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with event title and visibility indicator
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                decoration: BoxDecoration(
                  color: event.displayColor,
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
                          event.visibilityIcon,
                          color: AppColors.white,
                          size: 20,
                        ),
                        const SizedBox(width: AppDimensions.paddingS),
                        Expanded(
                          child: Text(
                            event.title,
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
                      event.visibilityLabel,
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
                    if (event.description.isNotEmpty) ...[
                      _buildDetailSection(
                        'Description',
                        event.description,
                        Icons.description,
                      ),
                      const SizedBox(height: AppDimensions.paddingM),
                    ],
                    if (event.location.isNotEmpty) ...[
                      _buildDetailSection(
                        'Location',
                        event.location,
                        Icons.location_on,
                      ),
                      const SizedBox(height: AppDimensions.paddingM),
                    ],
                    _buildDetailSection(
                      'Date & Time',
                      '${appointment.startTime.day}/${appointment.startTime.month}/${appointment.startTime.year} at ${appointment.startTime.hour.toString().padLeft(2, '0')}:${appointment.startTime.minute.toString().padLeft(2, '0')}',
                      Icons.access_time,
                    ),
                    if (event.tags.isNotEmpty) ...[
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
                        children: event.tags.map((tag) => Container(
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
              // Actions
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.navyBlue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingL,
                          vertical: AppDimensions.paddingM,
                        ),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
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
}

class _EventDataSource extends CalendarDataSource {
  _EventDataSource(List<Appointment> source) {
    appointments = source;
  }
}
