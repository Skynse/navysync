import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:navysync/models/event.dart';
import 'package:navysync/models/team.dart';
import 'package:navysync/services/auth_service.dart';
import 'package:navysync/models/permission.dart' as permissions;

class AppUserProfile {
  static Map<String, dynamic>? current;

  static Future<void> load(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      current = {'id': doc.id, ...doc.data()!};
    } else {
      current = null;
    }
  }

  static String get departmentId => current?['departmentId'] ?? '';
  static List get roles => current?['roles'] ?? [];
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Event> _upcomingEvents = [];
  List<Team> _userTeams = [];
  bool _isLoading = true;
  String? _error;

  // Real statistics
  int _totalEvents = 0;
  int _userTeamsCount = 0;
  int _departmentMembersCount = 0;
  int _todaysEvents = 0;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        await AppUserProfile.load(user.uid);
        setState(() {
          _error = null;
          _isLoading = false;
        });
        _loadDashboardData();
      } else {
        setState(() {
          _error = 'User not authenticated';
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _error = 'User not authenticated';
          _isLoading = false;
        });
        return;
      }

      // Load all dashboard data concurrently
      await Future.wait([
        _loadUpcomingEvents(),
        _loadUserTeams(),
        _loadStatistics(),
      ]);
    } catch (e) {
      _error = 'Failed to load dashboard: $e';
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadUpcomingEvents() async {
    final now = DateTime.now();
    final oneWeekFromNow = now.add(Duration(days: 7));

    // There is no top-level 'events' collection. Instead, fetch events from each team the user is a member of.
    List<Event> allEvents = [];
    for (final team in _userTeams) {
      final eventsSnapshot =
          await FirebaseFirestore.instance
              .collection('teams')
              .doc(team.id)
              .collection('events')
              .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
              .where(
                'date',
                isLessThanOrEqualTo: Timestamp.fromDate(oneWeekFromNow),
              )
              .orderBy('date')
              .get();

      allEvents.addAll(
        eventsSnapshot.docs.map((doc) {
          final data = doc.data();
          if (data is Map<String, dynamic>) {
            return Event.fromJson({'id': doc.id, ...data, 'teamId': team.id});
          } else {
            return Event.fromJson({'id': doc.id, 'teamId': team.id});
          }
        }),
      );
    }

    // Optionally sort and limit to 5 upcoming events
    allEvents.sort((a, b) => a.date.compareTo(b.date));
    _upcomingEvents =
        allEvents.where((event) => _canUserAccessEvent(event)).take(5).toList();
  }

  bool _canUserAccessEvent(Event event) {
    // Example: check department/team access using cached profile
    final deptId = AppUserProfile.departmentId;
    final teams = _userTeams.map((t) => t.id).toList();
    return (event.departmentId.isEmpty || event.departmentId == deptId) &&
        (event.teamId.isEmpty || teams.contains(event.teamId));
  }

  Future<void> _loadUserTeams() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final teamsQuery = FirebaseFirestore.instance
        .collection('teams')
        .where('members', arrayContains: user.uid);

    final snapshot = await teamsQuery.get();
    _userTeams = snapshot.docs.map((doc) => Team.fromFirestore(doc)).toList();

    _userTeamsCount = _userTeams.length;
  }

  Future<void> _loadStatistics() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Count today's events
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(Duration(days: 1));

    final todayEventsQuery = FirebaseFirestore.instance
        .collection('events')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay));

    final todaySnapshot = await todayEventsQuery.get();
    _todaysEvents = todaySnapshot.docs.length;

    // Count total accessible events
    final allEventsSnapshot =
        await FirebaseFirestore.instance.collection('events').get();

    _totalEvents =
        allEventsSnapshot.docs
            .map((doc) => Event.fromJson({'id': doc.id, ...doc.data()}))
            .where((event) => _canUserAccessEvent(event))
            .length;

    // Count department members (if user has department access)
    final deptId = AppUserProfile.departmentId;
    if (deptId.isNotEmpty) {
      final deptMembersQuery = FirebaseFirestore.instance
          .collection('users')
          .where('departmentId', isEqualTo: deptId);

      final deptSnapshot = await deptMembersQuery.get();
      _departmentMembersCount = deptSnapshot.docs.length;
    }
  }

  Widget _buildEventCard(Event event) {
    final isToday = _isEventToday(event.date);
    final timeUntil = _getTimeUntilEvent(event.date);

    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
        border:
            isToday
                ? Border.all(color: Color(0xFFE89C31), width: 2)
                : Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      isToday
                          ? Color(0xFFE89C31).withOpacity(0.1)
                          : Color(0xFF000080).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.event,
                  color: isToday ? Color(0xFFE89C31) : Color(0xFF000080),
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (isToday)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFFE89C31),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'TODAY',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (event.location.isNotEmpty) ...[
                      SizedBox(height: 2),
                      Text(
                        event.location,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (event.description.isNotEmpty) ...[
            SizedBox(height: 8),
            Text(
              event.description,
              style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                timeUntil,
                style: TextStyle(
                  color: isToday ? Color(0xFFE89C31) : Colors.grey[600],
                  fontSize: 12,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              Text(
                _formatEventTime(event.date),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            if (subtitle != null) ...[
              SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isEventToday(DateTime eventDate) {
    final now = DateTime.now();
    return eventDate.year == now.year &&
        eventDate.month == now.month &&
        eventDate.day == now.day;
  }

  String _getTimeUntilEvent(DateTime eventDate) {
    final now = DateTime.now();
    final difference = eventDate.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} away';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} away';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} away';
    } else if (difference.inMinutes > -60) {
      return 'Happening now';
    } else {
      return 'Ended';
    }
  }

  String _formatEventTime(DateTime eventDate) {
    final hour = eventDate.hour;
    final minute = eventDate.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

    return '${displayHour}:${minute.toString().padLeft(2, '0')} $period';
  }

  IconData _getEventTypeIcon(String eventType) {
    switch (eventType.toLowerCase()) {
      case 'meeting':
        return Icons.business_center;
      case 'training':
        return Icons.school;
      case 'ceremony':
        return Icons.emoji_events;
      case 'drill':
        return Icons.fitness_center;
      case 'social':
        return Icons.celebration;
      default:
        return Icons.event;
    }
  }

  String _getWelcomeMessage() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'Welcome, Sailor';

    final name = user.displayName ?? '';
    final firstName = name.split(' ').first;

    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }

    return '$greeting, $firstName';
  }

  bool _canCreateEvent() {
    return AppUserProfile.roles.contains('admin') ||
        AppUserProfile.roles.contains('event_creator');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF000080)),
              SizedBox(height: 16),
              Text(
                'Loading your dashboard...',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadDashboardData,
                child: Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 140,
              floating: false,
              pinned: true,
              elevation: 0,
              stretch: true,
              backgroundColor: Color(0xFF000080),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsets.only(left: 20, bottom: 16),
                title: Text(
                  "Dashboard",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF000080), Color(0xFF0000B3)],
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.refresh, color: Colors.white),
                  onPressed: _loadDashboardData,
                ),
                IconButton(
                  icon: Icon(Icons.calendar_month, color: Colors.white),
                  onPressed: () => context.push('/calendar'),
                ),
                SizedBox(width: 16),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getWelcomeMessage(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Here's what's happening today",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 2 - 22,
                          child: _buildStatCard(
                            title: "Today's Events",
                            value: "$_todaysEvents",
                            icon: Icons.today,
                            color: Color(0xFFE89C31),
                            subtitle:
                                _todaysEvents == 1
                                    ? "event scheduled"
                                    : "events scheduled",
                            onTap: () => context.push('/calendar'),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 2 - 22,
                          child: _buildStatCard(
                            title: "Your Teams",
                            value: "$_userTeamsCount",
                            icon: Icons.groups,
                            color: Color(0xFF2196F3),
                            subtitle:
                                _userTeamsCount == 1
                                    ? "team membership"
                                    : "team memberships",
                            onTap: () => context.push('/teams'),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 2 - 22,
                          child: _buildStatCard(
                            title: "Total Events",
                            value: "$_totalEvents",
                            icon: Icons.event_available,
                            color: Color(0xFF000080),
                            subtitle: "accessible to you",
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 2 - 22,
                          child: _buildStatCard(
                            title: "Department",
                            value: "$_departmentMembersCount",
                            icon: Icons.people,
                            color: Color(0xFF4CAF50),
                            subtitle:
                                _departmentMembersCount == 1
                                    ? "member"
                                    : "members",
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    if (_upcomingEvents.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Upcoming Events",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.push('/calendar'),
                            child: Text(
                              "View All",
                              style: TextStyle(
                                color: Color(0xFF000080),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (_upcomingEvents.isEmpty)
              SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_available,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No upcoming events',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Check back later or create a new event',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildEventCard(_upcomingEvents[index]),
                  childCount: _upcomingEvents.length,
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Quick Actions",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        if (_canCreateEvent()) ...[
                          Expanded(
                            child: _buildQuickActionButton(
                              title: "Create Event",
                              icon: Icons.add_circle_outline,
                              color: Color(0xFF000080),
                              onPressed: () => context.push('/create-event'),
                            ),
                          ),
                          SizedBox(width: 16),
                        ],
                        Expanded(
                          child: _buildQuickActionButton(
                            title: "My Teams",
                            icon: Icons.groups,
                            color: Color(0xFF2196F3),
                            onPressed: () => context.push('/teams'),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildQuickActionButton(
                            title: "Calendar",
                            icon: Icons.calendar_month,
                            color: Color(0xFFE89C31),
                            onPressed: () => context.push('/calendar'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 80), // Space for FAB
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          _canCreateEvent()
              ? FloatingActionButton.extended(
                heroTag: 'create_event_action_home',
                onPressed: () => context.push('/create-event'),
                backgroundColor: Color(0xFF000080),
                icon: Icon(Icons.add, color: Colors.white),
                label: Text(
                  "Create Event",
                  style: TextStyle(color: Colors.white),
                ),
                elevation: 4,
              )
              : null,
    );
  }
}
