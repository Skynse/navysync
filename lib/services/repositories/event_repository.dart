import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/event.dart';
import '../../models/user.dart';
import 'base_repository.dart';

class EventRepository extends BaseRepository<Event> {
  EventRepository() : super('events');

  @override
  Event fromFirestore(DocumentSnapshot doc) => Event.fromFirestore(doc);

  @override
  Map<String, dynamic> toFirestore(Event item) => item.toFirestore();

  // Get events visible to a specific user
  Future<List<Event>> getVisibleEvents(NavySyncUser user, {int? limit}) async {
    final queries = <Future<QuerySnapshot>>[];

    // Organization events (visible to everyone)
    queries.add(
      collection
          .where('visibility', whereIn: ['organization', 'team'])
          .where('isActive', isEqualTo: true)
          .get(),
    );

    // Department events (if user has a department)
    if (user.departmentId.isNotEmpty) {
      queries.add(
        collection
            .where('visibility', isEqualTo: 'department')
            .where('departmentId', isEqualTo: user.departmentId)
            .where('isActive', isEqualTo: true)
            .get(),
      );
    }

    // Team events (for each team the user belongs to)
    for (final teamId in user.teamIds) {
      queries.add(
        collection
            .where('visibility', isEqualTo: 'team')
            .where('teamId', isEqualTo: teamId)
            .where('isActive', isEqualTo: true)
            .get(),
      );
    }

    // Private events where user is an attendee
    queries.add(
      collection
          .where('visibility', isEqualTo: 'private')
          .where('attendees', arrayContains: user.id)
          .where('isActive', isEqualTo: true)
          .get(),
    );

    // Events created by the user
    queries.add(
      collection
          .where('createdBy', isEqualTo: user.id)
          .where('isActive', isEqualTo: true)
          .get(),
    );

    // Execute all queries
    final results = await Future.wait(queries);
    
    // Combine and deduplicate events
    final eventMap = <String, Event>{};
    for (final querySnapshot in results) {
      for (final doc in querySnapshot.docs) {
        final event = fromFirestore(doc);
        if (event.canUserAccess(user.id, user.roles, user.departmentId, user.teamIds)) {
          eventMap[event.id] = event;
        }
      }
    }

    // Sort by date and apply limit
    final events = eventMap.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return limit != null ? events.take(limit).toList() : events;
  }

  // Get upcoming events visible to a user
  Future<List<Event>> getUpcomingVisibleEvents(NavySyncUser user, {int? limit}) async {
    final allEvents = await getVisibleEvents(user);
    final upcomingEvents = allEvents
        .where((event) => event.date.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return limit != null ? upcomingEvents.take(limit).toList() : upcomingEvents;
  }

  // Get events by visibility type
  Future<List<Event>> getByVisibility(EventVisibility visibility, {int? limit}) async {
    return getAll(
      query: collection
          .where('visibility', isEqualTo: visibility.name)
          .where('isActive', isEqualTo: true)
          .orderBy('date'),
      limit: limit,
    );
  }

  // Get events by department
  Future<List<Event>> getByDepartment(String departmentId, {int? limit}) async {
    return getAll(
      query: collection
          .where('visibility', whereIn: ['organization', 'department'])
          .where('isActive', isEqualTo: true)
          .orderBy('date'),
      limit: limit,
    );
  }

  // Get events by team
  Future<List<Event>> getByTeam(String teamId, {int? limit}) async {
    return getAll(
      query: collection
          .where('teamId', isEqualTo: teamId)
          .where('isActive', isEqualTo: true)
          .orderBy('date'),
      limit: limit,
    );
  }

  // Get upcoming events
  Future<List<Event>> getUpcoming({int? limit}) async {
    return getAll(
      query: collection
          .where('date', isGreaterThan: Timestamp.now())
          .where('isActive', isEqualTo: true)
          .orderBy('date'),
      limit: limit,
    );
  }

  // Get events for a specific date range
  Future<List<Event>> getByDateRange(DateTime start, DateTime end, {NavySyncUser? user}) async {
    Query<Object?> baseQuery = collection
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .where('isActive', isEqualTo: true)
        .orderBy('date');

    final allEvents = await getAll(query: baseQuery);
    
    // Filter by user visibility if user is provided
    if (user != null) {
      return allEvents
          .where((event) => event.canUserAccess(user.id, user.roles, user.departmentId, user.teamIds))
          .toList();
    }
    
    return allEvents;
  }

  // Get events created by a user
  Future<List<Event>> getByCreator(String userId, {int? limit}) async {
    return getAll(
      query: collection
          .where('createdBy', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true),
      limit: limit,
    );
  }

  // Search events by title or description
  Future<List<Event>> searchEvents(String query, NavySyncUser user) async {
    // Firestore doesn't support full-text search, so we'll get all visible events
    // and filter on the client side. For production, consider using Algolia or similar.
    final events = await getVisibleEvents(user);
    final lowerQuery = query.toLowerCase();
    
    return events.where((event) {
      return event.title.toLowerCase().contains(lowerQuery) ||
             event.description.toLowerCase().contains(lowerQuery) ||
             event.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  // Watch events visible to a user
  Stream<List<Event>> watchVisibleEvents(NavySyncUser user) {
    // For simplicity, we'll watch organization and department events
    // In production, you might want to implement a more sophisticated approach
    Query<Object?> query = collection
        .where('visibility', whereIn: ['organization'])
        .where('isActive', isEqualTo: true)
        .orderBy('date');

    return query.snapshots().map((snapshot) {
      final events = snapshot.docs.map((doc) => fromFirestore(doc)).toList();
      return events.where((event) => 
        event.canUserAccess(user.id, user.roles, user.departmentId, user.teamIds)
      ).toList();
    });
  }

  // Watch upcoming events
  Stream<List<Event>> watchUpcoming({int? limit, NavySyncUser? user}) {
    Query<Object?> query = collection
        .where('date', isGreaterThan: Timestamp.now())
        .where('isActive', isEqualTo: true)
        .orderBy('date');
    
    if (limit != null) {
      query = query.limit(limit);
    }
    
    return query.snapshots().map((snapshot) {
      final events = snapshot.docs.map((doc) => fromFirestore(doc)).toList();
      
      // Filter by user visibility if provided
      if (user != null) {
        return events.where((event) => 
          event.canUserAccess(user.id, user.roles, user.departmentId, user.teamIds)
        ).toList();
      }
      
      return events;
    });
  }
}
