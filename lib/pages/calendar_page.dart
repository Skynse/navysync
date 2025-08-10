import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../models/event.dart';
import '../providers/event_provider.dart';

class CalendarPage extends ConsumerWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userEventsAsync = ref.watch(userEventsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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

          return SfCalendar(
            view: CalendarView.month,
            dataSource: _EventDataSource(appointments),
            monthViewSettings: const MonthViewSettings(
              appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
              showAgenda: true,
            ),
            appointmentBuilder: (context, details) {
              final appointment = details.appointments.first;
              return Container(
                width: details.bounds.width,
                height: details.bounds.height,
                decoration: BoxDecoration(
                  color: appointment.color,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Text(
                    appointment.subject,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            },
            onTap: (details) {
              if (details.appointments != null && details.appointments!.isNotEmpty) {
                _showEventDetails(context, details.appointments!.first, events);
              }
            },
            headerStyle: CalendarHeaderStyle(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              textStyle: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            viewHeaderStyle: ViewHeaderStyle(
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              dayTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading events',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(userEventsProvider),
                child: const Text('Retry'),
              ),
            ],
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
      builder: (context) => AlertDialog(
        title: Text(
          event.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (event.description.isNotEmpty) ...[
                const Text(
                  'Description',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(event.description),
                const SizedBox(height: 16),
              ],
              if (event.location.isNotEmpty) ...[
                const Text(
                  'Location',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16),
                    const SizedBox(width: 4),
                    Expanded(child: Text(event.location)),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              const Text(
                'Time',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${appointment.startTime.day}/${appointment.startTime.month}/${appointment.startTime.year} '
                      '${appointment.startTime.hour.toString().padLeft(2, '0')}:${appointment.startTime.minute.toString().padLeft(2, '0')}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(event.visibilityIcon, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    event.visibilityLabel,
                    style: TextStyle(
                      color: event.displayColor,
                      fontWeight: FontWeight.w500,
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
      ),
    );
  }
}

class _EventDataSource extends CalendarDataSource {
  _EventDataSource(List<Appointment> source) {
    appointments = source;
  }
}
