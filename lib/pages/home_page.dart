import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:navysync/components/e_fab.dart';
import 'package:navysync/models/event.dart';
import 'package:navysync/models/team.dart';
import 'package:navysync/providers/event_provider.dart';
import '../constants.dart';

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

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<Team> _userTeams = [];
  bool _isLoading = true;
  String? _error;

  // Real statistics
  int _totalEvents = 0;
  int _userTeamsCount = 0;
  int _departmentMembersCount = 0;
  int _todaysEvents = 0;

  late final StreamSubscription<User?> _authSubscription;

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((
      user,
    ) async {
      if (!mounted) return; // Prevent setState after dispose
      if (user != null) {
        await AppUserProfile.load(user.uid);
        if (!mounted) return;
        setState(() {
          _error = null;
          _isLoading = false;
        });
        _loadDashboardData();
      } else {
        if (!mounted) return;
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

  bool _canUserAccessEvent(Event event) {
    // Example: check department/team access using cached profile
    final deptId = AppUserProfile.departmentId;
    final teams = _userTeams.map((t) => t.id).toList();
    return (event.departmentId?.isEmpty != false ||
            event.departmentId == deptId) &&
        (event.teamId?.isEmpty != false || teams.contains(event.teamId));
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

  Widget _buildEnhancedEventCard(Event event) {
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
                  color: event.displayColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  event.visibilityIcon,
                  color: event.displayColor,
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
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: event.displayColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            event.visibilityLabel,
                            style: TextStyle(
                              color: event.displayColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isToday) ...[
                          SizedBox(width: 8),
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
                      ],
                    ),
                    if (event.location.isNotEmpty) ...[
                      SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 12,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.location,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
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
                  fontSize: 12,
                  color: isToday ? Color(0xFFE89C31) : Colors.grey[600],
                  fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              Text(
                _formatEventDateTime(event.date),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
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

  Widget _buildTeamCard(Team team) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.groups,
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (team.description.isNotEmpty) ...[
                      SizedBox(height: 2),
                      Text(
                        team.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: () => context.push('/teams/${team.id}'),
                icon: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _getTeamLeaders(team.id),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container(
                  height: 32,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Loading leaders...',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }

              final leaders = snapshot.data!;
              final totalMembers = team.members.length + (team.teamLeaderId.isNotEmpty ? 1 : 0);

              return Row(
                children: [
                  // Overlapping commander circles
                  SizedBox(
                    height: 32,
                    width: leaders.length > 1 ? (leaders.length * 20.0) + 12 : 32,
                    child: Stack(
                      children: leaders.asMap().entries.map((entry) {
                        final index = entry.key;
                        final leader = entry.value;
                        
                        // Determine background color based on role
                        Color backgroundColor;
                        if (leader['isLeader']) {
                          backgroundColor = AppColors.navyBlue; // Team leader
                        } else if (leader['isModerator']) {
                          backgroundColor = Colors.red.shade700; // Moderator
                        } else if (leader['isDepartmentHead']) {
                          backgroundColor = Colors.purple.shade700; // Department head
                        } else {
                          backgroundColor = AppColors.primaryBlue; // Default
                        }
                        
                        return Positioned(
                          left: index * 20.0, // 20px overlap for semi-covered effect
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 3,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 16,
                              backgroundImage: leader['profilePictureUrl'] != null &&
                                      leader['profilePictureUrl'].isNotEmpty
                                  ? NetworkImage(leader['profilePictureUrl'])
                                  : null,
                              backgroundColor: backgroundColor,
                              child: leader['profilePictureUrl'] == null ||
                                      leader['profilePictureUrl'].isEmpty
                                  ? Text(
                                      (leader['name'] ?? '?')[0].toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          leaders.length == 1 
                              ? 'Team Commander'
                              : 'Team Leadership',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (leaders.isNotEmpty)
                          Text(
                            leaders.map((l) => l['name']).join(', '),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Text(
                    '$totalMembers member${totalMembers == 1 ? '' : 's'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getTeamLeaders(String teamId) async {
    try {
      // Find the team first to get the leader ID
      final team = _userTeams.firstWhere(
        (t) => t.id == teamId,
        orElse: () => throw Exception('Team not found'),
      );

      final leaderIds = <String>[];
      
      // Add team leader
      if (team.teamLeaderId.isNotEmpty) {
        leaderIds.add(team.teamLeaderId);
      }

      // Find admins/moderators among team members
      if (team.members.isNotEmpty) {
        // Get user data to check for admin/moderator roles
        final membersSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId, whereIn: team.members.take(10).toList())
            .get();

        for (final doc in membersSnapshot.docs) {
          final data = doc.data();
          final roles = List<String>.from(data['roles'] ?? []);
          
          // Check if user has admin/moderator roles
          if (roles.contains('MODERATOR') || roles.contains('DEPARTMENT_HEAD')) {
            leaderIds.add(doc.id);
          }
        }
      }

      // Remove duplicates
      final uniqueLeaderIds = leaderIds.toSet().toList();

      if (uniqueLeaderIds.isEmpty) {
        return [];
      }

      // Get user data for all leaders
      final leadersData = <Map<String, dynamic>>[];
      
      // Query users in batches (Firestore limit is 10 for 'whereIn')
      for (int i = 0; i < uniqueLeaderIds.length; i += 10) {
        final batch = uniqueLeaderIds.skip(i).take(10).toList();
        
        final leadersSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        for (final doc in leadersSnapshot.docs) {
          final data = doc.data();
          final roles = List<String>.from(data['roles'] ?? []);
          
          leadersData.add({
            'id': doc.id,
            'name': data['name'] ?? 'Unknown User',
            'profilePictureUrl': data['profilePictureUrl'] ?? '',
            'email': data['email'] ?? '',
            'isLeader': doc.id == team.teamLeaderId,
            'roles': roles,
            'isModerator': roles.contains('MODERATOR'),
            'isDepartmentHead': roles.contains('DEPARTMENT_HEAD'),
          });
        }
      }

      // Sort to put team leader first, then moderators, then department heads
      leadersData.sort((a, b) {
        if (a['isLeader'] && !b['isLeader']) return -1;
        if (!a['isLeader'] && b['isLeader']) return 1;
        if (a['isModerator'] && !b['isModerator']) return -1;
        if (!a['isModerator'] && b['isModerator']) return 1;
        if (a['isDepartmentHead'] && !b['isDepartmentHead']) return -1;
        if (!a['isDepartmentHead'] && b['isDepartmentHead']) return 1;
        return 0;
      });

      return leadersData;
    } catch (e) {
      print('Error loading team leaders: $e');
      return [];
    }
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

  String _formatEventDateTime(DateTime eventDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(Duration(days: 1));
    final eventDay = DateTime(eventDate.year, eventDate.month, eventDate.day);

    // Format time
    final time =
        '${eventDate.hour.toString().padLeft(2, '0')}:${eventDate.minute.toString().padLeft(2, '0')}';

    if (eventDay == today) {
      return 'Today at $time';
    } else if (eventDay == tomorrow) {
      return 'Tomorrow at $time';
    } else if (eventDate.year == now.year) {
      // Same year, show month and day
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[eventDate.month - 1]} ${eventDate.day} at $time';
    } else {
      // Different year, show full date
      return '${eventDate.day}/${eventDate.month}/${eventDate.year} at $time';
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
    return AppUserProfile.roles.contains('MODERATOR') ||
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
              CircularProgressIndicator(color: AppColors.navyBlue),
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
              expandedHeight: MediaQuery.of(context).size.height * 0.22, // 22% of screen height
              floating: false,
              pinned: true,
              elevation: 0,
              stretch: true,
              backgroundColor: AppColors.navyBlue,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsets.only(left: 20, bottom: 16),
                title: Text(
                  "Dashboard",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.navyBlue, AppColors.primaryBlue],
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
                      "Here's what's happening today.",
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
                            onTap: () => context.go('/teams'),
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
                            onTap: () => context.go('/calendar'),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 2 - 22,
                          child: _buildStatCard(
                            onTap: () {
                              context.go('/departments');
                            },
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
                    // Events Section Header - Will show events from Consumer below
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Events",
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
                              color: AppColors.navyBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Events Section - Using Provider System
            Consumer(
              builder: (context, ref, child) {
                final upcomingEventsAsync = ref.watch(
                  upcomingUserEventsProvider,
                );

                return upcomingEventsAsync.when(
                  data: (events) {
                    if (events.isEmpty) {
                      return SliverToBoxAdapter(
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
                      );
                    }

                    // Show up to 5 upcoming events
                    final displayEvents = events.take(5).toList();

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            _buildEnhancedEventCard(displayEvents[index]),
                        childCount: displayEvents.length,
                      ),
                    );
                  },
                  loading:
                      () => SliverToBoxAdapter(
                        child: Container(
                          margin: EdgeInsets.all(16),
                          padding: EdgeInsets.all(24),
                          child: Center(
                            child: Column(
                              children: [
                                CircularProgressIndicator(
                                  color: AppColors.navyBlue,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Loading events...',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  error:
                      (error, stack) => SliverToBoxAdapter(
                        child: Container(
                          margin: EdgeInsets.all(16),
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.red[400],
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Error loading events',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[600],
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                error.toString(),
                                style: TextStyle(color: Colors.red[500]),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                );
              },
            ),
            // Teams Section
            if (_userTeams.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Your Team${_userTeams.length > 1 ? 's' : ''}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.go('/teams'),
                            child: Text(
                              "View All",
                              style: TextStyle(
                                color: AppColors.navyBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      ..._userTeams.take(2).map((team) => _buildTeamCard(team)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),

      floatingActionButton: ExpandableFab(
        distance: 70,
        children: [
          _canCreateEvent()
              ? ActionButton(
                icon: Icon(Icons.event),
                onPressed: () {
                  context.push('/create-event');
                },
              )
              : Container(),
          ActionButton(
            icon: Icon(Icons.announcement),
            onPressed: () {
              context.push('/create-announcement');
            },
          ),
        ],
      ),
    );
  }
}
