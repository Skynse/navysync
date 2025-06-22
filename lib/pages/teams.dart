import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:navysync/models/team.dart';
import 'package:navysync/models/user.dart';
import 'package:navysync/pages/team_details_view.dart';
import 'package:navysync/services/auth_service.dart';
import 'package:navysync/models/permission.dart';

class TeamsView extends StatefulWidget {
  const TeamsView({super.key});

  @override
  State<TeamsView> createState() => _TeamsViewState();
}

class _TeamsViewState extends State<TeamsView> {
  final AuthService _authService = AuthService();
  NavySyncUser? _currentUser;
  List<Team> _teams = [];
  List<Team> _myTeams = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserAndTeams();
  }

  Future<void> _loadUserAndTeams() async {
    setState(() => _isLoading = true);

    try {
      // Get current user
      _currentUser = await _authService.loadUserData();
      if (_currentUser == null) return;

      // Get all teams
      final teamsSnapshot =
          await FirebaseFirestore.instance.collection('teams').get();
      _teams =
          teamsSnapshot.docs.map((doc) => Team.fromFirestore(doc)).toList();

      // Filter teams user is part of
      if (_currentUser!.teamIds.isNotEmpty) {
        _myTeams =
            _teams
                .where((team) => _currentUser!.teamIds.contains(team.id))
                .toList();
      }

      // Add teams user is leader of but not in members list
      for (var team in _teams) {
        if (team.teamLeaderId == _currentUser!.id &&
            !_myTeams.any((myTeam) => myTeam.id == team.id)) {
          _myTeams.add(team);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load teams: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Widget to display each team card
  Widget _buildTeamCard(Team team) {
    final bool isTeamLeader = team.teamLeaderId == _currentUser?.id;
    final Color cardColor = isTeamLeader ? Colors.blue.shade50 : Colors.white;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isTeamLeader ? Colors.blue.shade800 : Colors.grey.shade300,
          width: isTeamLeader ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => context.push('/teams/${team.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue.shade800,
                    child: Text(
                      team.name.isNotEmpty ? team.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          team.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isTeamLeader)
                          Chip(
                            label: const Text('Team Leader'),
                            backgroundColor: Colors.blue.shade800,
                            labelStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.people),
                        tooltip: 'Members',
                        onPressed: () => _showTeamMembers(team),
                      ),
                      Text(
                        '${team.members.length}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                team.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_authService.hasPermission(
                        Permission.CREATE,
                        Permission.RESOURCE_EVENT,
                      ) ||
                      isTeamLeader)
                    TextButton.icon(
                      icon: const Icon(Icons.calendar_month, size: 18),
                      label: const Text('Events'),
                      onPressed: () => context.push('/teams/${team.id}/events'),
                    ),
                  if (isTeamLeader || _currentUser?.isAdmin() == true)
                    TextButton.icon(
                      icon: const Icon(Icons.settings, size: 18),
                      label: const Text('Manage'),
                      onPressed: () => context.push('/teams/${team.id}/manage'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show team members dialog
  void _showTeamMembers(Team team) async {
    // Fetch member details
    final membersSnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId, whereIn: team.members)
            .get();

    final members =
        membersSnapshot.docs
            .map((doc) => NavySyncUser.fromMap({'id': doc.id, ...doc.data()}))
            .toList();

    if (!mounted) return;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('${team.name} Members'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: members.length,
                itemBuilder: (context, index) {
                  final member = members[index];
                  final bool isTeamLeader = member.id == team.teamLeaderId;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          member.profilePictureUrl.isNotEmpty
                              ? NetworkImage(member.profilePictureUrl)
                              : null,
                      child:
                          member.profilePictureUrl.isEmpty
                              ? Text(member.name[0].toUpperCase())
                              : null,
                    ),
                    title: Text(member.name),
                    trailing:
                        isTeamLeader
                            ? Chip(
                              label: const Text('Leader'),
                              backgroundColor: Colors.blue.shade800,
                              labelStyle: const TextStyle(color: Colors.white),
                            )
                            : null,
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  // Build team lists - My Teams and Other Teams
  Widget _buildTeamLists() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_teams.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.group_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No teams available',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            if (_currentUser?.isAdmin() == true ||
                _currentUser?.roles.contains('department_head') == true)
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Create a Team'),
                onPressed: () => context.push('/teams/create'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800,
                ),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUserAndTeams,
      child: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        children: [
          if (_myTeams.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'MY TEAMS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            ..._myTeams.map(_buildTeamCard).toList(),
            const Divider(height: 32, thickness: 1),
          ],

          if (_teams.isNotEmpty &&
              _teams.any(
                (team) => !_myTeams.any((myTeam) => myTeam.id == team.id),
              )) ...[
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'OTHER TEAMS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            ..._teams
                .where(
                  (team) => !_myTeams.any((myTeam) => myTeam.id == team.id),
                )
                .map(_buildTeamCard)
                .toList(),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teams'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: TeamSearchDelegate(_teams),
              );
            },
          ),
        ],
      ),
      body: _buildTeamLists(),
      floatingActionButton:
          _currentUser?.isAdmin() == true ||
                  _currentUser?.roles.contains('department_head') == true
              ? FloatingActionButton(
                backgroundColor: Colors.blue.shade800,
                onPressed: () => context.push('/teams/create'),
                child: const Icon(Icons.add, color: Colors.red),
              )
              : null,
    );
  }
}

// Search delegate for teams
class TeamSearchDelegate extends SearchDelegate<String> {
  final List<Team> teams;

  TeamSearchDelegate(this.teams);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results =
        teams
            .where(
              (team) =>
                  team.name.toLowerCase().contains(query.toLowerCase()) ||
                  team.description.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final team = results[index];
        return ListTile(
          title: Text(team.name),
          subtitle: Text(team.description),
          onTap: () {
            close(context, team.id);
            context.push('/teams/${team.id}');
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final results =
        teams
            .where(
              (team) =>
                  team.name.toLowerCase().contains(query.toLowerCase()) ||
                  team.description.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final team = results[index];
        return ListTile(
          title: Text(team.name),
          subtitle: Text(team.description),
          onTap: () {
            close(context, team.id);
            context.push('/teams/${team.id}');
          },
        );
      },
    );
  }
}

class TeamCreateView extends StatefulWidget {
  const TeamCreateView({super.key});

  @override
  State<TeamCreateView> createState() => _TeamCreateViewState();
}

class _TeamCreateViewState extends State<TeamCreateView> {
  final AuthService _authService = AuthService();
  NavySyncUser? _currentUser;
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = true;
  bool _isSubmitting = false;

  List<NavySyncUser> _availableUsers = [];
  final List<String> _selectedMembers = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      // Get current user
      _currentUser = await _authService.loadUserData();
      if (_currentUser == null) {
        context.go('/auth_gate');
        return;
      } // Check if user has permission to create teams
      if (!_currentUser!.isAdmin() &&
          !_currentUser!.roles.contains('department_head')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You do not have permission to create teams'),
          ),
        );
        context.go('/teams');
        return;
      }

      // Load available users
      final usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      _availableUsers =
          usersSnapshot.docs
              .map((doc) => NavySyncUser.fromMap({'id': doc.id, ...doc.data()}))
              .toList();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _createTeam() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() => _isSubmitting = true);

    try {
      // Create a new team document
      final teamDocRef = FirebaseFirestore.instance.collection('teams').doc();

      // Add current user as team leader and member
      final members = [..._selectedMembers];
      if (!members.contains(_currentUser!.id)) {
        members.add(_currentUser!.id);
      }

      // Create team object
      final newTeam = Team(
        id: teamDocRef.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        teamLeaderId: _currentUser!.id,
        members: members,
      );

      // Save to Firestore
      await teamDocRef.set(newTeam.toMap());

      // Update each member's teamIds field
      for (final userId in members) {
        await FirebaseFirestore.instance.collection('users').doc(userId).update(
          {
            'teamIds': FieldValue.arrayUnion([teamDocRef.id]),
          },
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Team created successfully')),
        );
        context.go('/teams/${teamDocRef.id}');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error creating team: $e')));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Create Team')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Team'),
        actions: [
          TextButton.icon(
            onPressed: _isSubmitting ? null : _createTeam,
            icon:
                _isSubmitting
                    ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.check),
            label: const Text('Save'),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Team Icon Placeholder
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue.shade100,
                    child: Icon(
                      Icons.groups,
                      size: 60,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Colors.blue.shade800,
                      radius: 18,
                      child: IconButton(
                        icon: const Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          // This would be implemented with image picker
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Team icon upload not implemented yet',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Team Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Team Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.group),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a team name';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Team Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a team description';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Team Members Section
            const Text(
              'Team Members',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            // Selected Members Chips
            Wrap(
              spacing: 8,
              children: [
                ..._selectedMembers.map((userId) {
                  final user = _availableUsers.firstWhere(
                    (u) => u.id == userId,
                    orElse:
                        () => NavySyncUser(
                          id: userId,
                          profilePictureUrl: '',
                          name: 'Unknown User',
                          roles: const ['member'],
                        ),
                  );

                  return Chip(
                    avatar: CircleAvatar(
                      backgroundImage:
                          user.profilePictureUrl.isNotEmpty
                              ? NetworkImage(user.profilePictureUrl)
                              : null,
                      child:
                          user.profilePictureUrl.isEmpty
                              ? Text(
                                user.name.isNotEmpty
                                    ? user.name[0].toUpperCase()
                                    : '?',
                              )
                              : null,
                    ),
                    label: Text(user.name),
                    onDeleted: () {
                      setState(() {
                        _selectedMembers.remove(userId);
                      });
                    },
                  );
                }),

                // Add Member Chip
                ActionChip(
                  avatar: const Icon(Icons.add),
                  label: const Text('Add Member'),
                  onPressed: () {
                    _showAddMemberDialog();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMemberDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Team Members'),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: ListView.builder(
                itemCount: _availableUsers.length,
                itemBuilder: (context, index) {
                  final user = _availableUsers[index];
                  final bool isSelected = _selectedMembers.contains(user.id);
                  final bool isCurrentUser = user.id == _currentUser?.id;

                  if (isCurrentUser)
                    return const SizedBox.shrink(); // Don't show current user

                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: (selected) {
                      setState(() {
                        if (selected == true) {
                          if (!_selectedMembers.contains(user.id)) {
                            _selectedMembers.add(user.id);
                          }
                        } else {
                          _selectedMembers.remove(user.id);
                        }
                      });
                    },
                    title: Text(user.name),
                    subtitle: Text(user.roles.join(', ')),
                    secondary: CircleAvatar(
                      backgroundImage:
                          user.profilePictureUrl.isNotEmpty
                              ? NetworkImage(user.profilePictureUrl)
                              : null,
                      child:
                          user.profilePictureUrl.isEmpty
                              ? Text(
                                user.name.isNotEmpty
                                    ? user.name[0].toUpperCase()
                                    : '?',
                              )
                              : null,
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ],
          ),
    );
  }
}
