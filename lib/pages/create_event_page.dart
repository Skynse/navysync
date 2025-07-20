import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  String _location = '';
  DateTime _date = DateTime.now();
  String? _selectedTeamId;
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _userTeams = [];

  @override
  void initState() {
    super.initState();
    _fetchUserTeams();
  }

  Future<void> _fetchUserTeams() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final teamsQuery =
        await FirebaseFirestore.instance
            .collection('teams')
            .where('members', arrayContains: user.uid)
            .get();
    setState(() {
      _userTeams =
          teamsQuery.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
      if (_userTeams.isNotEmpty) {
        _selectedTeamId = _userTeams.first['id'];
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedTeamId == null) return;
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not authenticated');
      await FirebaseFirestore.instance
          .collection('teams')
          .doc(_selectedTeamId)
          .collection('events')
          .add({
            'title': _title,
            'description': _description,
            'location': _location,
            'date': Timestamp.fromDate(_date),
            'createdBy': user.uid,
          });
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Event')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child:
            _userTeams.isEmpty
                ? const Center(
                  child: Text('You are not a member of any teams.'),
                )
                : Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedTeamId,
                        items:
                            _userTeams
                                .map(
                                  (team) => DropdownMenuItem<String>(
                                    value: team['id'] as String,
                                    child: Text(team['name'] ?? 'Unnamed Team'),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) => setState(() => _selectedTeamId = v),
                        decoration: const InputDecoration(labelText: 'Team'),
                        validator: (v) => v == null ? 'Select a team' : null,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Title'),
                        onSaved: (v) => _title = v ?? '',
                        validator:
                            (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                        onSaved: (v) => _description = v ?? '',
                        maxLines: 2,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Location',
                        ),
                        onSaved: (v) => _location = v ?? '',
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        title: Text(
                          'Date: ${_date.toLocal().toString().split(' ')[0]}',
                        ),
                        trailing: Icon(Icons.calendar_today),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _date,
                            firstDate: DateTime.now().subtract(
                              const Duration(days: 1),
                            ),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (picked != null) setState(() => _date = picked);
                        },
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 8),
                        Text(_error!, style: TextStyle(color: Colors.red)),
                      ],
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        child:
                            _isLoading
                                ? const CircularProgressIndicator()
                                : const Text('Create Event'),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
