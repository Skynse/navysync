import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:navysync/models/announcement.dart';
import '../constants.dart';

class CreateAnnouncementPage extends StatefulWidget {
  const CreateAnnouncementPage({super.key});

  @override
  State<CreateAnnouncementPage> createState() => _CreateAnnouncementPageState();
}

class _CreateAnnouncementPageState extends State<CreateAnnouncementPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _linkController = TextEditingController();

  AnnouncementVisibility _visibility = AnnouncementVisibility.organization;
  AnnouncementPriority _priority = AnnouncementPriority.normal;
  DateTime _expiresAt = DateTime.now().add(const Duration(days: 7));
  bool _isPinned = false;
  bool _isLoading = false;
  bool _showPreview = false;
  List<String> _tags = [];
  final _tagController = TextEditingController();

  // Department and Team selection
  String? _selectedDepartmentId;
  String? _selectedTeamId;
  List<Map<String, dynamic>> _departments = [];
  List<Map<String, dynamic>> _teams = [];

  Future<void> createAnnouncement() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final announcement = Announcement(
        id: '', // Firestore will generate this
        title: _titleController.text.trim(),
        content: _bodyController.text.trim(),
        authorId: currentUser.uid,
        visibility: _visibility,
        priority: _priority,
        tags: _tags,
        link: _linkController.text.trim().isEmpty ? null : _linkController.text.trim(),
        expiresAt: _expiresAt,
        isPinned: _isPinned,
        departmentId: _visibility == AnnouncementVisibility.department ? _selectedDepartmentId : null,
        teamId: _visibility == AnnouncementVisibility.team ? _selectedTeamId : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('announcements')
          .add(announcement.toFirestore());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Announcement created successfully!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating announcement: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDepartmentsAndTeams();
  }

  Future<void> _loadDepartmentsAndTeams() async {
    try {
      // Load departments
      final departmentsSnapshot = await FirebaseFirestore.instance
          .collection('departments')
          .orderBy('name')
          .get();
      
      _departments = departmentsSnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc.data()['name'] as String? ?? 'Unknown Department',
        };
      }).toList();

      // Load teams
      final teamsSnapshot = await FirebaseFirestore.instance
          .collection('teams')
          .orderBy('name')
          .get();
      
      _teams = teamsSnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc.data()['name'] as String? ?? 'Unknown Team',
        };
      }).toList();

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error loading departments and teams: $e');
    }
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
      });
      _tagController.clear();
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _showPreviewDialog() {
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                decoration: BoxDecoration(
                  color: _getPriorityColor(_priority),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppDimensions.radiusL),
                    topRight: Radius.circular(AppDimensions.radiusL),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getPriorityIcon(_priority),
                      color: AppColors.white,
                      size: 24,
                    ),
                    const SizedBox(width: AppDimensions.paddingS),
                    Expanded(
                      child: Text(
                        _titleController.text.trim(),
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingS,
                        vertical: AppDimensions.paddingXS,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                      ),
                      child: Text(
                        _getPriorityLabel(_priority),
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Visibility and Date Info
                      Row(
                        children: [
                          Icon(
                            _getVisibilityIcon(_visibility),
                            color: AppColors.darkGray,
                            size: 16,
                          ),
                          const SizedBox(width: AppDimensions.paddingXS),
                          Text(
                            _getVisibilityLabel(_visibility),
                            style: const TextStyle(
                              color: AppColors.darkGray,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.paddingM),
                          Icon(
                            Icons.schedule,
                            color: AppColors.darkGray,
                            size: 16,
                          ),
                          const SizedBox(width: AppDimensions.paddingXS),
                          Text(
                            'Expires: ${_expiresAt.month}/${_expiresAt.day}/${_expiresAt.year}',
                            style: const TextStyle(
                              color: AppColors.darkGray,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: AppDimensions.paddingM),
                      
                      // Content
                      Text(
                        _bodyController.text.trim(),
                        style: const TextStyle(
                          color: AppColors.navyBlue,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      
                      // Link if provided
                      if (_linkController.text.trim().isNotEmpty) ...[
                        const SizedBox(height: AppDimensions.paddingM),
                        Container(
                          padding: const EdgeInsets.all(AppDimensions.paddingM),
                          decoration: BoxDecoration(
                            color: AppColors.lightBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                            border: Border.all(
                              color: AppColors.lightBlue.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.link,
                                color: AppColors.lightBlue,
                                size: 16,
                              ),
                              const SizedBox(width: AppDimensions.paddingS),
                              Expanded(
                                child: Text(
                                  _linkController.text.trim(),
                                  style: const TextStyle(
                                    color: AppColors.lightBlue,
                                    fontSize: 14,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      // Tags if any
                      if (_tags.isNotEmpty) ...[
                        const SizedBox(height: AppDimensions.paddingM),
                        Wrap(
                          spacing: AppDimensions.paddingS,
                          runSpacing: AppDimensions.paddingXS,
                          children: _tags.map((tag) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.paddingS,
                              vertical: AppDimensions.paddingXS,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.lightBlue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                color: AppColors.navyBlue,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              // Action Buttons
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.darkGray,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppDimensions.paddingM,
                          ),
                        ),
                        child: const Text(
                          'Edit',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingM),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          createAnnouncement();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.navyBlue,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppDimensions.paddingM,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                          ),
                        ),
                        child: const Text(
                          'Post Announcement',
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _linkController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        title: const Text(
          'Create Announcement',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.navyBlue,
        elevation: 2,
        iconTheme: const IconThemeData(color: AppColors.white),
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              boxShadow: [
                BoxShadow(
                  color: AppColors.navyBlue.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Column(
              spacing: AppDimensions.paddingL,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingS),
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      ),
                      child: const Icon(
                        Icons.campaign,
                        color: AppColors.navyBlue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingM),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'New Announcement',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.navyBlue,
                            ),
                          ),
                          Text(
                            'Share important information',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.darkGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                TextFormField(
                  controller: _titleController,
                  style: const TextStyle(color: AppColors.navyBlue),
                  decoration: InputDecoration(
                    labelText: 'Announcement Title',
                    labelStyle: const TextStyle(color: AppColors.darkGray),
                    filled: true,
                    fillColor: AppColors.lightGray.withOpacity(0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      borderSide: const BorderSide(color: AppColors.lightBlue, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      borderSide: const BorderSide(color: AppColors.error, width: 2),
                    ),
                    prefixIcon: const Icon(Icons.title, color: AppColors.darkGray),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),

                TextFormField(
                  controller: _bodyController,
                  style: const TextStyle(color: AppColors.navyBlue),
                  decoration: InputDecoration(
                    labelText: 'Content',
                    labelStyle: const TextStyle(color: AppColors.darkGray),
                    filled: true,
                    fillColor: AppColors.lightGray.withOpacity(0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      borderSide: const BorderSide(color: AppColors.darkGray, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      borderSide: const BorderSide(color: AppColors.darkGray, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      borderSide: const BorderSide(color: AppColors.lightBlue, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      borderSide: const BorderSide(color: AppColors.error, width: 1),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      borderSide: const BorderSide(color: AppColors.error, width: 2),
                    ),
                    prefixIcon: const Icon(Icons.description, color: AppColors.darkGray),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter content';
                    }
                    return null;
                  },
                ),

                Container(
                  decoration: BoxDecoration(
                    color: AppColors.lightGray.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    border: Border.all(color: AppColors.lightBlue.withOpacity(0.3)),
                  ),
                  child: DropdownMenuFormField(
                    onSelected: (value) {
                      setState(() {
                        switch (value) {
                          case 'organization':
                            _visibility = AnnouncementVisibility.organization;
                            _selectedDepartmentId = null;
                            _selectedTeamId = null;
                            break;
                          case 'department':
                            _visibility = AnnouncementVisibility.department;
                            _selectedTeamId = null;
                            break;
                          case 'team':
                            _visibility = AnnouncementVisibility.team;
                            _selectedDepartmentId = null;
                            break;

                        }
                      });
                    },
                    dropdownMenuEntries: const [
                      DropdownMenuEntry(
                        value: 'organization',
                        label: 'Organization',
                        leadingIcon: Icon(Icons.business, color: AppColors.navyBlue),
                      ),
                      DropdownMenuEntry(
                        value: 'department',
                        label: 'Department',
                        leadingIcon: Icon(Icons.domain, color: AppColors.navyBlue),
                      ),
                      DropdownMenuEntry(
                        value: 'team',
                        label: 'Team',
                        leadingIcon: Icon(Icons.group, color: AppColors.navyBlue),
                      ),
                    ],
                    initialSelection: 'organization',
                    hintText: 'Select Visibility',
                  ),
                ),

                // Department selector (shown when department visibility is selected)
                if (_visibility == AnnouncementVisibility.department)
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.lightGray.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      border: Border.all(color: AppColors.lightBlue.withOpacity(0.3)),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedDepartmentId,
                      onChanged: (value) {
                        setState(() {
                          _selectedDepartmentId = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Select Department',
                        prefixIcon: Icon(Icons.business, color: AppColors.navyBlue),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(AppDimensions.paddingM),
                      ),
                      validator: (value) {
                        if (_visibility == AnnouncementVisibility.department && value == null) {
                          return 'Please select a department';
                        }
                        return null;
                      },
                      items: _departments.map((dept) {
                        return DropdownMenuItem<String>(
                          value: dept['id'],
                          child: Text(dept['name']),
                        );
                      }).toList(),
                    ),
                  ),

                // Team selector (shown when team visibility is selected)
                if (_visibility == AnnouncementVisibility.team)
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.lightGray.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      border: Border.all(color: AppColors.lightBlue.withOpacity(0.3)),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedTeamId,
                      onChanged: (value) {
                        setState(() {
                          _selectedTeamId = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Select Team',
                        prefixIcon: Icon(Icons.group, color: AppColors.navyBlue),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(AppDimensions.paddingM),
                      ),
                      validator: (value) {
                        if (_visibility == AnnouncementVisibility.team && value == null) {
                          return 'Please select a team';
                        }
                        return null;
                      },
                      items: _teams.map((team) {
                        return DropdownMenuItem<String>(
                          value: team['id'],
                          child: Text(team['name']),
                        );
                      }).toList(),
                    ),
                  ),

                Container(
                  decoration: BoxDecoration(
                    color: AppColors.lightGray.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    border: Border.all(color: AppColors.lightBlue.withOpacity(0.3)),
                  ),
                  child: DropdownMenuFormField(
                    onSelected: (value) {
                      setState(() {
                        switch (value) {
                          case 'low':
                            _priority = AnnouncementPriority.low;
                            break;
                          case 'normal':
                            _priority = AnnouncementPriority.normal;
                            break;
                          case 'high':
                            _priority = AnnouncementPriority.high;
                            break;
                          case 'urgent':
                            _priority = AnnouncementPriority.urgent;
                            break;
                        }
                      });
                    },
                    dropdownMenuEntries: const [
                      DropdownMenuEntry(
                        value: 'low',
                        label: 'Low Priority',
                        leadingIcon: Icon(Icons.arrow_downward, color: AppColors.darkGray),
                      ),
                      DropdownMenuEntry(
                        value: 'normal',
                        label: 'Normal Priority',
                        leadingIcon: Icon(Icons.remove, color: AppColors.primaryBlue),
                      ),
                      DropdownMenuEntry(
                        value: 'high',
                        label: 'High Priority',
                        leadingIcon: Icon(Icons.arrow_upward, color: AppColors.warning),
                      ),
                      DropdownMenuEntry(
                        value: 'urgent',
                        label: 'Urgent',
                        leadingIcon: Icon(Icons.priority_high, color: AppColors.error),
                      ),
                    ],
                    initialSelection: 'normal',
                    hintText: 'Select Priority',
                  ),
                ),

                Container(
                  decoration: BoxDecoration(
                    color: AppColors.lightGray.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    border: Border.all(color: AppColors.lightBlue.withOpacity(0.3)),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      onTap: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: _expiresAt,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(DateTime.now().year + 1),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: Theme.of(context).colorScheme.copyWith(
                                  primary: AppColors.navyBlue,
                                  onPrimary: AppColors.white,
                                  surface: AppColors.white,
                                  onSurface: AppColors.navyBlue,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (selectedDate != null) {
                          setState(() {
                            _expiresAt = selectedDate;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(AppDimensions.paddingM),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: AppColors.navyBlue,
                              size: 20,
                            ),
                            const SizedBox(width: AppDimensions.paddingS),
                            Text(
                              'Expires: ${_expiresAt.month}/${_expiresAt.day}/${_expiresAt.year}',
                              style: const TextStyle(
                                color: AppColors.navyBlue,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: AppColors.navyBlue,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _showPreviewDialog,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.preview, color: AppColors.white),
                    label: Text(
                      _isLoading ? 'Creating...' : 'Preview Announcement',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navyBlue,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.paddingM,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                      ),
                      elevation: 3,
                      shadowColor: AppColors.navyBlue.withOpacity(0.3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper methods for preview
  IconData _getVisibilityIcon(AnnouncementVisibility visibility) {
    switch (visibility) {
      case AnnouncementVisibility.organization:
        return Icons.business;
      case AnnouncementVisibility.department:
        return Icons.domain;
      case AnnouncementVisibility.team:
        return Icons.group;
      case AnnouncementVisibility.private:
        return Icons.lock;
      case AnnouncementVisibility.public:
        return Icons.business; // Fallback, shouldn't be used
    }
  }

  String _getVisibilityLabel(AnnouncementVisibility visibility) {
    switch (visibility) {
      case AnnouncementVisibility.organization:
        return 'Organization';
      case AnnouncementVisibility.department:
        return 'Department';
      case AnnouncementVisibility.team:
        return 'Team';
      case AnnouncementVisibility.private:
        return 'Private';
      case AnnouncementVisibility.public:
        return 'Organization'; // Fallback, shouldn't be used
    }
  }

  Color _getPriorityColor(AnnouncementPriority priority) {
    switch (priority) {
      case AnnouncementPriority.low:
        return AppColors.darkGray;
      case AnnouncementPriority.normal:
        return AppColors.primaryBlue;
      case AnnouncementPriority.high:
        return AppColors.warning;
      case AnnouncementPriority.urgent:
        return AppColors.error;
    }
  }

  IconData _getPriorityIcon(AnnouncementPriority priority) {
    switch (priority) {
      case AnnouncementPriority.low:
        return Icons.arrow_downward;
      case AnnouncementPriority.normal:
        return Icons.remove;
      case AnnouncementPriority.high:
        return Icons.arrow_upward;
      case AnnouncementPriority.urgent:
        return Icons.priority_high;
    }
  }

  String _getPriorityLabel(AnnouncementPriority priority) {
    switch (priority) {
      case AnnouncementPriority.low:
        return 'Low Priority';
      case AnnouncementPriority.normal:
        return 'Normal Priority';
      case AnnouncementPriority.high:
        return 'High Priority';
      case AnnouncementPriority.urgent:
        return 'Urgent';
    }
  }
}
