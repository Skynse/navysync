import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:navysync/models/department.dart';
import 'package:navysync/models/user.dart';
import '../constants.dart';

class DepartmentsView extends StatefulWidget {
  const DepartmentsView({super.key});

  @override
  State<DepartmentsView> createState() => _DepartmentsViewState();
}

class _DepartmentsViewState extends State<DepartmentsView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<List<Department>> _departmentsStream;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _departmentsStream = _fetchDepartments();
  }

  Stream<List<Department>> _fetchDepartments() {
    return _firestore.collection('departments').snapshots().map((snapshot) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return [];

      return snapshot.docs.map((doc) => Department.fromFirestore(doc)).where((
        dept,
      ) {
        return dept.members.contains(user.uid) ||
            dept.departmentHeadId == user.uid ||
            dept.assistantHeadIds.contains(user.uid);
      }).toList();
    });
  }

  bool _canCreateDepartment() {
    // Permissions removed: always allow department creation for now
    return true;
  }

  void _showCreateDepartmentDialog() {
    showDialog(
      context: context,
      builder:
          (context) => DepartmentCreateDialog(
            onDepartmentCreated: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Department created successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Departments',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.navyBlue,
        elevation: 2,
        iconTheme: const IconThemeData(color: AppColors.white),
        centerTitle: false,
      ),
      body: StreamBuilder<List<Department>>(
        stream: _departmentsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading departments',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please try again later',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          final departments = snapshot.data ?? [];

          if (departments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.business_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No departments found',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _canCreateDepartment()
                        ? 'Create your first department to get started'
                        : 'You are not a member of any departments',
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  if (_canCreateDepartment()) ...[
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _showCreateDepartmentDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Create Department'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navyBlue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _departmentsStream = _fetchDepartments();
              });
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: departments.length,
              itemBuilder: (context, index) {
                final department = departments[index];
                final isHead = department.departmentHeadId == _currentUser?.uid;
                final isAssistantHead = department.assistantHeadIds.contains(
                  _currentUser?.uid,
                );

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => context.push('/departments/${department.id}'),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.navyBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.business,
                                  color: AppColors.navyBlue,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            department.name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        if (isHead)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.amber[100],
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.star,
                                                  size: 12,
                                                  color: Colors.amber[700],
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Head',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.amber[700],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        if (!isHead && isAssistantHead)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blue[100],
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.assistant,
                                                  size: 12,
                                                  color: Colors.blue[700],
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Assistant',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.blue[700],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                    if (department.description.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        department.description,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${department.memberCount} member${department.memberCount != 1 ? 's' : ''}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey[400],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton:
          _canCreateDepartment()
              ? FloatingActionButton(
                onPressed: _showCreateDepartmentDialog,
                backgroundColor: AppColors.navyBlue,
                foregroundColor: Colors.white,
                child: const Icon(Icons.add),
              )
              : null,
    );
  }
}

class DepartmentCreateDialog extends StatefulWidget {
  final VoidCallback onDepartmentCreated;

  const DepartmentCreateDialog({super.key, required this.onDepartmentCreated});

  @override
  State<DepartmentCreateDialog> createState() => _DepartmentCreateDialogState();
}

class _DepartmentCreateDialogState extends State<DepartmentCreateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  List<NavySyncUser> _availableUsers = [];
  final List<String> _selectedMembers = [];
  final List<String> _selectedAssistantHeads = [];

  @override
  void initState() {
    super.initState();
    _loadAvailableUsers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableUsers() async {
    try {
      final usersSnapshot = await _firestore.collection('users').get();
      final users =
          usersSnapshot.docs
              .map((doc) => NavySyncUser.fromMap({'id': doc.id, ...doc.data()}))
              .toList();

      setState(() {
        _availableUsers = users;
      });
    } catch (e) {
      print('Error loading users: $e');
    }
  }

  Future<void> _createDepartment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // Include current user as department head and member
      final members = <String>{currentUser.uid, ..._selectedMembers}.toList();

      final department = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'departmentHeadId': currentUser.uid,
        'assistantHeadIds': _selectedAssistantHeads,
        'members': members,
        'imageUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      };

      await _firestore.collection('departments').add(department);

      widget.onDepartmentCreated();
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating department: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.navyBlue.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.business, color: AppColors.navyBlue),
                  const SizedBox(width: 12),
                  const Text(
                    'Create New Department',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Form content
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Department name
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Department Name',
                          hintText: 'Enter department name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Department name is required';
                          }
                          if (value.trim().length < 3) {
                            return 'Department name must be at least 3 characters';
                          }
                          return null;
                        },
                        textCapitalization: TextCapitalization.words,
                      ),

                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Enter department description (optional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description_outlined),
                        ),
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                      ),

                      const SizedBox(height: 20),

                      // Assistant Heads selection
                      const Text(
                        'Assistant Heads',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select users to be assistant heads of this department.',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const SizedBox(height: 12),

                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child:
                            _availableUsers.isEmpty
                                ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                                : ListView.builder(
                                  itemCount: _availableUsers.length,
                                  itemBuilder: (context, index) {
                                    final user = _availableUsers[index];
                                    final isSelected = _selectedAssistantHeads
                                        .contains(user.id);
                                    final isCurrentUser =
                                        user.id ==
                                        FirebaseAuth.instance.currentUser?.uid;

                                    if (isCurrentUser)
                                      return const SizedBox.shrink();

                                    return CheckboxListTile(
                                      title: Text(user.name),
                                      subtitle: const Text('Assistant Head'),
                                      value: isSelected,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          if (value == true) {
                                            _selectedAssistantHeads.add(
                                              user.id,
                                            );
                                          } else {
                                            _selectedAssistantHeads.remove(
                                              user.id,
                                            );
                                          }
                                        });
                                      },
                                      secondary: CircleAvatar(
                                        backgroundImage:
                                            user.profilePictureUrl.isNotEmpty
                                                ? NetworkImage(
                                                  user.profilePictureUrl,
                                                )
                                                : null,
                                        child:
                                            user.profilePictureUrl.isEmpty
                                                ? Text(
                                                  user.name.isNotEmpty
                                                      ? user.name[0]
                                                          .toUpperCase()
                                                      : '?',
                                                )
                                                : null,
                                      ),
                                    );
                                  },
                                ),
                      ),

                      const SizedBox(height: 20),

                      // Members selection
                      const Text(
                        'Department Members',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select users to add to this department. You will be automatically added as the department head.',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const SizedBox(height: 12),

                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child:
                            _availableUsers.isEmpty
                                ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                                : ListView.builder(
                                  itemCount: _availableUsers.length,
                                  itemBuilder: (context, index) {
                                    final user = _availableUsers[index];
                                    final isSelected = _selectedMembers
                                        .contains(user.id);
                                    final isCurrentUser =
                                        user.id ==
                                        FirebaseAuth.instance.currentUser?.uid;

                                    return CheckboxListTile(
                                      title: Text(user.name),
                                      subtitle: Text(
                                        isCurrentUser
                                            ? 'Department Head (You)'
                                            : 'Member',
                                        style: TextStyle(
                                          color:
                                              isCurrentUser
                                                  ? AppColors.navyBlue
                                                  : null,
                                          fontWeight:
                                              isCurrentUser
                                                  ? FontWeight.bold
                                                  : null,
                                        ),
                                      ),
                                      value: isSelected || isCurrentUser,
                                      onChanged:
                                          isCurrentUser
                                              ? null // Can't uncheck current user
                                              : (bool? value) {
                                                setState(() {
                                                  if (value == true) {
                                                    _selectedMembers.add(
                                                      user.id,
                                                    );
                                                  } else {
                                                    _selectedMembers.remove(
                                                      user.id,
                                                    );
                                                  }
                                                });
                                              },
                                      secondary: CircleAvatar(
                                        backgroundImage:
                                            user.profilePictureUrl.isNotEmpty
                                                ? NetworkImage(
                                                  user.profilePictureUrl,
                                                )
                                                : null,
                                        child:
                                            user.profilePictureUrl.isEmpty
                                                ? Text(
                                                  user.name.isNotEmpty
                                                      ? user.name[0]
                                                          .toUpperCase()
                                                      : '?',
                                                )
                                                : null,
                                      ),
                                    );
                                  },
                                ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _createDepartment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navyBlue,
                      foregroundColor: Colors.white,
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Text('Create Department'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
