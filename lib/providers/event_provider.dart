import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/repositories/event_repository.dart';
import '../models/event.dart';
import 'auth_provider.dart';

// Event repository provider
final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository();
});

// Current user events provider (events visible to the current user)
final userEventsProvider = FutureProvider<List<Event>>((ref) async {
  final currentUserAsync = ref.watch(currentUserProvider);
  
  return await currentUserAsync.when(
    data: (currentUser) async {
      if (currentUser == null) return [];
      final repository = ref.watch(eventRepositoryProvider);
      return repository.getVisibleEvents(currentUser);
    },
    loading: () => <Event>[],
    error: (_, __) => <Event>[],
  );
});

// Upcoming user events provider
final upcomingUserEventsProvider = FutureProvider<List<Event>>((ref) async {
  final currentUserAsync = ref.watch(currentUserProvider);
  
  return await currentUserAsync.when(
    data: (currentUser) async {
      if (currentUser == null) return [];
      final repository = ref.watch(eventRepositoryProvider);
      return repository.getUpcomingVisibleEvents(currentUser, limit: 10);
    },
    loading: () => <Event>[],
    error: (_, __) => <Event>[],
  );
});

// Events by visibility provider
final eventsByVisibilityProvider = FutureProvider.family<List<Event>, EventVisibility>((ref, visibility) async {
  final repository = ref.watch(eventRepositoryProvider);
  return repository.getByVisibility(visibility);
});

// Events by date range provider
final eventsByDateRangeProvider = FutureProvider.family<List<Event>, DateRangeQuery>((ref, query) async {
  final currentUserAsync = ref.watch(currentUserProvider);
  final repository = ref.watch(eventRepositoryProvider);
  
  return await currentUserAsync.when(
    data: (currentUser) => repository.getByDateRange(query.start, query.end, user: currentUser),
    loading: () => <Event>[],
    error: (_, __) => <Event>[],
  );
});

// Single event provider
final eventProvider = FutureProvider.family<Event?, String>((ref, eventId) async {
  final repository = ref.watch(eventRepositoryProvider);
  return repository.getById(eventId);
});

// User created events provider
final userCreatedEventsProvider = FutureProvider<List<Event>>((ref) async {
  final currentUserAsync = ref.watch(currentUserProvider);
  
  return await currentUserAsync.when(
    data: (currentUser) async {
      if (currentUser == null) return [];
      final repository = ref.watch(eventRepositoryProvider);
      return repository.getByCreator(currentUser.id);
    },
    loading: () => <Event>[],
    error: (_, __) => <Event>[],
  );
});

// Event search provider
final eventSearchProvider = FutureProvider.family<List<Event>, String>((ref, query) async {
  if (query.isEmpty) return [];
  
  final currentUserAsync = ref.watch(currentUserProvider);
  
  return await currentUserAsync.when(
    data: (currentUser) async {
      if (currentUser == null) return [];
      final repository = ref.watch(eventRepositoryProvider);
      return repository.searchEvents(query, currentUser);
    },
    loading: () => <Event>[],
    error: (_, __) => <Event>[],
  );
});

// Stream provider for real-time upcoming events
final upcomingEventsStreamProvider = StreamProvider<List<Event>>((ref) async* {
  final currentUserAsync = ref.watch(currentUserProvider);
  
  await for (final userState in Stream.value(currentUserAsync)) {
    yield* userState.when(
      data: (currentUser) {
        if (currentUser == null) return Stream.value([]);
        final repository = ref.watch(eventRepositoryProvider);
        return repository.watchUpcoming(limit: 20, user: currentUser);
      },
      loading: () => Stream.value([]),
      error: (_, __) => Stream.value([]),
    );
  }
});

// Event actions provider
final eventActionsProvider = Provider<EventActions>((ref) {
  final repository = ref.watch(eventRepositoryProvider);
  return EventActions(repository, ref);
});

class EventActions {
  final EventRepository _repository;
  final Ref _ref;

  EventActions(this._repository, this._ref);

  Future<String> createEvent(Event event) async {
    final eventId = await _repository.create(event);
    // Invalidate related providers to refresh UI
    _ref.invalidate(userEventsProvider);
    _ref.invalidate(upcomingUserEventsProvider);
    return eventId;
  }

  Future<void> updateEvent(String id, Event event) async {
    await _repository.update(id, event);
    // Invalidate related providers
    _ref.invalidate(userEventsProvider);
    _ref.invalidate(upcomingUserEventsProvider);
    _ref.invalidate(eventProvider(id));
  }

  Future<void> deleteEvent(String id) async {
    // Soft delete by setting isActive to false
    final event = await _repository.getById(id);
    if (event != null) {
      await _repository.update(id, event.copyWith(isActive: false));
      // Invalidate related providers
      _ref.invalidate(userEventsProvider);
      _ref.invalidate(upcomingUserEventsProvider);
    }
  }

  Future<List<Event>> getUpcomingEvents({int? limit}) async {
    final currentUserAsync = _ref.read(currentUserProvider);
    
    return await currentUserAsync.when(
      data: (currentUser) async {
        if (currentUser == null) return [];
        return await _repository.getUpcomingVisibleEvents(currentUser, limit: limit);
      },
      loading: () => <Event>[],
      error: (_, __) => <Event>[],
    );
  }

  Future<List<Event>> getEventsByDateRange(DateTime start, DateTime end) async {
    final currentUserAsync = _ref.read(currentUserProvider);
    
    return await currentUserAsync.when(
      data: (currentUser) => _repository.getByDateRange(start, end, user: currentUser),
      loading: () => <Event>[],
      error: (_, __) => <Event>[],
    );
  }

  Future<List<Event>> getEventsByCreator(String userId) async {
    return await _repository.getByCreator(userId);
  }

  Future<List<Event>> searchEvents(String query) async {
    final currentUserAsync = _ref.read(currentUserProvider);
    
    return await currentUserAsync.when(
      data: (currentUser) async {
        if (currentUser == null) return [];
        return await _repository.searchEvents(query, currentUser);
      },
      loading: () => <Event>[],
      error: (_, __) => <Event>[],
    );
  }
}

// Helper class for date range queries
class DateRangeQuery {
  final DateTime start;
  final DateTime end;

  const DateRangeQuery(this.start, this.end);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DateRangeQuery && 
           other.start == start && 
           other.end == end;
  }

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}
