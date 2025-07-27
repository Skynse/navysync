import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:navysync/models/team.dart';
import 'package:navysync/models/user.dart';

class TeamManageView extends StatefulWidget {
  final String teamId;
  const TeamManageView({super.key, required this.teamId});

  @override
  State<TeamManageView> createState() => _TeamManageViewState();
}

class _TeamManageViewState extends State<TeamManageView> {
  Team? _team;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _members = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTeam();
  }

  Future<void> _loadTeam() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final teamDoc =
          await FirebaseFirestore.instance
              .collection('teams')
              .doc(widget.teamId)
              .get();
      if (!teamDoc.exists) throw 'Team not found';
      _team = Team.fromFirestore(teamDoc);
      final membersSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('teamIds', arrayContains: widget.teamId)
              .get();
      _members = membersSnapshot.docs.toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addMember() async {
    final usersSnapshot =
        await FirebaseFirestore.instance.collection('users').get();
    final allUsers = usersSnapshot.docs.toList();
    if (allUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No users available to add.')),
      );
      return;
    }
    QueryDocumentSnapshot<Map<String, dynamic>>? selectedUserDoc =
        await showDialog<QueryDocumentSnapshot<Map<String, dynamic>>>(
          context: context,
          builder:
              (context) => SimpleDialog(
                title: const Text('Select user to add'),
                children:
                    allUsers
                        .map(
                          (user) => SimpleDialogOption(
                            onPressed: () => Navigator.pop(context, user),
                            child: Text(user["name"] ?? 'Unknown User'),
                          ),
                        )
                        .toList(),
              ),
        );
    if (selectedUserDoc != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(selectedUserDoc['id'])
          .update({
            'teamIds': FieldValue.arrayUnion([widget.teamId]),
          });
      await _loadTeam();
    }
  }

  Future<void> _removeMember(String id) async {
    if (id == _team?.teamLeaderId) return;
    await FirebaseFirestore.instance.collection('users').doc(id).update({
      'teamIds': FieldValue.arrayRemove([widget.teamId]),
    });
    await _loadTeam();
  }

  Future<void> _editTeam() async {
    final nameController = TextEditingController(text: _team?.name ?? '');
    final descController = TextEditingController(
      text: _team?.description ?? '',
    );
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Team'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Team Name'),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Save'),
              ),
            ],
          ),
    );
    if (result == true) {
      await FirebaseFirestore.instance
          .collection('teams')
          .doc(widget.teamId)
          .update({
            'name': nameController.text,
            'description': descController.text,
          });
      await _loadTeam();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Team')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Text(
                  'Error: \\$_error',
                  style: TextStyle(color: Colors.red),
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _team?.name ?? '',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _team?.description ?? '',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Members',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.separated(
                        itemCount: _members.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final user = _members[index];
                          final isLeader = user.id == _team?.teamLeaderId;
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage:
                                  user["profilePictureUrl"].isNotEmpty
                                      ? NetworkImage(user["profilePictureUrl"])
                                      : null,
                              child:
                                  user["profilePictureUrl"].isEmpty
                                      ? Text(
                                        user["name"] != null &&
                                                user["name"].isNotEmpty
                                            ? user["name"][0].toUpperCase()
                                            : '?',
                                      )
                                      : null,
                            ),
                            title: Text(user["name"] ?? 'Unknown User'),
                            subtitle: Text(
                              user["roles"]?.join(', ') ?? 'No roles',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isLeader)
                                  Chip(
                                    label: const Text('Leader'),
                                    backgroundColor: Colors.blue.shade800,
                                    labelStyle: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                if (!isLeader)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle,
                                      color: Colors.red,
                                    ),
                                    tooltip: 'Remove',
                                    onPressed: () async {
                                      await _removeMember(user.id);
                                    },
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.person_add),
                          label: const Text('Add Member'),
                          onPressed: _addMember,
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit Team'),
                          onPressed: _editTeam,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
    );
  }
}
