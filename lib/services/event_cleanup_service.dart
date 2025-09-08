import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventCleanupService {
  static final EventCleanupService _instance = EventCleanupService._internal();
  factory EventCleanupService() => _instance;
  EventCleanupService._internal();

  static const Duration _defaultGracePeriod = Duration(hours: 24);
  static const Duration _cleanupInterval = Duration(hours: 12); // Run cleanup every 12 hours

  DateTime? _lastCleanup;

  /// Initialize the cleanup service and run initial cleanup
  Future<void> initialize() async {
    await _runCleanupIfNeeded();
  }

  /// Check if cleanup is needed and run it
  Future<void> _runCleanupIfNeeded() async {
    final now = DateTime.now();
    
    // Run cleanup if it's never been run or if enough time has passed
    if (_lastCleanup == null || now.difference(_lastCleanup!).abs() >= _cleanupInterval) {
      await cleanupExpiredEvents();
      _lastCleanup = now;
    }
  }

  /// Main cleanup method that marks expired events as inactive
  Future<int> cleanupExpiredEvents({Duration? gracePeriod}) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('EventCleanupService: No authenticated user, skipping cleanup');
        return 0;
      }

      final now = DateTime.now();
      final graceTime = gracePeriod ?? _defaultGracePeriod;

      // Query all active events
      final eventsSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('isActive', isEqualTo: true)
          .get();

      if (eventsSnapshot.docs.isEmpty) {
        print('EventCleanupService: No active events found');
        return 0;
      }

      final batch = FirebaseFirestore.instance.batch();
      int expiredCount = 0;

      for (final doc in eventsSnapshot.docs) {
        final data = doc.data();
        
        if (_isEventExpired(data, now, graceTime)) {
          // Mark as inactive instead of deleting for data retention
          batch.update(doc.reference, {
            'isActive': false,
            'deletedAt': Timestamp.now(),
            'updatedAt': Timestamp.now(),
            'deletionReason': 'automatic_cleanup_expired',
            'cleanupVersion': '1.0',
          });
          
          expiredCount++;
          
          final title = data['title'] ?? 'Unknown Event';
          print('EventCleanupService: Marking "$title" as inactive (expired)');
        }
      }

      if (expiredCount > 0) {
        await batch.commit();
        print('EventCleanupService: Successfully cleaned up $expiredCount expired events');
      } else {
        print('EventCleanupService: No expired events found');
      }

      return expiredCount;
    } catch (e) {
      print('EventCleanupService: Error during cleanup - $e');
      return 0;
    }
  }

  /// Check if an event is expired based on its end time or date
  bool _isEventExpired(Map<String, dynamic> eventData, DateTime now, Duration gracePeriod) {
    try {
      // Check endTime first (most accurate)
      if (eventData['endTime'] != null) {
        final endTime = (eventData['endTime'] as Timestamp).toDate();
        final expirationTime = endTime.add(gracePeriod);
        return now.isAfter(expirationTime);
      }
      
      // Fallback to date (assume end of day)
      if (eventData['date'] != null) {
        final eventDate = (eventData['date'] as Timestamp).toDate();
        final endOfDay = DateTime(
          eventDate.year,
          eventDate.month,
          eventDate.day,
          23,
          59,
          59,
        );
        final expirationTime = endOfDay.add(gracePeriod);
        return now.isAfter(expirationTime);
      }
      
      // If neither endTime nor date exists, don't expire the event
      print('EventCleanupService: Event has no endTime or date, skipping: ${eventData['title']}');
      return false;
    } catch (e) {
      print('EventCleanupService: Error checking expiration for event: $e');
      return false;
    }
  }

  /// Force cleanup with custom parameters (for moderator use)
  Future<int> forceCleanup({
    Duration? gracePeriod,
    bool includePersonalEvents = false,
  }) async {
    print('EventCleanupService: Force cleanup initiated');
    final result = await cleanupExpiredEvents(gracePeriod: gracePeriod);
    _lastCleanup = DateTime.now();
    return result;
  }

  /// Get cleanup status information
  Map<String, dynamic> getCleanupStatus() {
    return {
      'lastCleanup': _lastCleanup?.toIso8601String(),
      'nextCleanupDue': _lastCleanup?.add(_cleanupInterval).toIso8601String(),
      'cleanupInterval': _cleanupInterval.toString(),
      'gracePeriod': _defaultGracePeriod.toString(),
    };
  }

  /// Manual trigger for cleanup (can be called from UI)
  Future<int> triggerManualCleanup() async {
    print('EventCleanupService: Manual cleanup triggered');
    return await forceCleanup();
  }
}
