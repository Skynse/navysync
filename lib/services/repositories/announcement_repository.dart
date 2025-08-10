import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/announcement.dart';
import '../../models/user.dart';
import 'base_repository.dart';

class AnnouncementRepository extends BaseRepository<Announcement> {
  AnnouncementRepository() : super('announcements');

  @override
  Announcement fromFirestore(DocumentSnapshot doc) => Announcement.fromFirestore(doc);

  @override
  Map<String, dynamic> toFirestore(Announcement item) => item.toFirestore();

  // Get announcements visible to a specific user
  Future<List<Announcement>> getVisibleAnnouncements(NavySyncUser user, {int? limit}) async {
    final queries = <Future<QuerySnapshot>>[];

    // Organization announcements (visible to everyone)
    queries.add(
      collection
          .where('visibility', isEqualTo: 'organization')
          .where('isActive', isEqualTo: true)
          .get(),
    );

    // Department announcements (if user has a department)
    if (user.departmentId.isNotEmpty) {
      queries.add(
        collection
            .where('visibility', isEqualTo: 'department')
            .where('departmentId', isEqualTo: user.departmentId)
            .where('isActive', isEqualTo: true)
            .get(),
      );
    }

    // Team announcements (for each team the user belongs to)
    for (final teamId in user.teamIds) {
      queries.add(
        collection
            .where('visibility', isEqualTo: 'team')
            .where('teamId', isEqualTo: teamId)
            .where('isActive', isEqualTo: true)
            .get(),
      );
    }

    // Private announcements where user is a target
    queries.add(
      collection
          .where('visibility', isEqualTo: 'private')
          .where('targetUsers', arrayContains: user.id)
          .where('isActive', isEqualTo: true)
          .get(),
    );

    // Announcements created by the user
    queries.add(
      collection
          .where('authorId', isEqualTo: user.id)
          .where('isActive', isEqualTo: true)
          .get(),
    );

    // Execute all queries
    final results = await Future.wait(queries);
    
    // Combine and deduplicate announcements
    final announcementMap = <String, Announcement>{};
    for (final querySnapshot in results) {
      for (final doc in querySnapshot.docs) {
        final announcement = fromFirestore(doc);
        if (announcement.canUserAccess(user.id, user.roles, user.departmentId, user.teamIds)) {
          // Filter out expired announcements
          if (!announcement.isExpired) {
            announcementMap[announcement.id] = announcement;
          }
        }
      }
    }

    // Sort by priority and creation date (pinned first)
    final announcements = announcementMap.values.toList()
      ..sort((a, b) {
        // Pinned announcements first
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        
        // Then by priority (urgent first)
        final priorityOrder = {
          AnnouncementPriority.urgent: 0,
          AnnouncementPriority.high: 1,
          AnnouncementPriority.normal: 2,
          AnnouncementPriority.low: 3,
        };
        
        final aPriority = priorityOrder[a.priority] ?? 2;
        final bPriority = priorityOrder[b.priority] ?? 2;
        
        if (aPriority != bPriority) return aPriority.compareTo(bPriority);
        
        // Finally by creation date (newest first)
        return b.createdAt.compareTo(a.createdAt);
      });

    return limit != null ? announcements.take(limit).toList() : announcements;
  }

  // Get announcements by visibility type
  Future<List<Announcement>> getByVisibility(AnnouncementVisibility visibility, {int? limit}) async {
    return getAll(
      query: collection
          .where('visibility', isEqualTo: visibility.name)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true),
      limit: limit,
    );
  }

  // Get announcements by priority
  Future<List<Announcement>> getByPriority(AnnouncementPriority priority, {int? limit}) async {
    return getAll(
      query: collection
          .where('priority', isEqualTo: priority.name)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true),
      limit: limit,
    );
  }

  // Get pinned announcements
  Future<List<Announcement>> getPinnedAnnouncements({int? limit}) async {
    return getAll(
      query: collection
          .where('isPinned', isEqualTo: true)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true),
      limit: limit,
    );
  }

  // Get announcements by department
  Future<List<Announcement>> getByDepartment(String departmentId, {int? limit}) async {
    return getAll(
      query: collection
          .where('visibility', whereIn: ['organization', 'department'])
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true),
      limit: limit,
    );
  }

  // Get announcements by team
  Future<List<Announcement>> getByTeam(String teamId, {int? limit}) async {
    return getAll(
      query: collection
          .where('teamId', isEqualTo: teamId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true),
      limit: limit,
    );
  }

  // Get announcements created by a user
  Future<List<Announcement>> getByAuthor(String authorId, {int? limit}) async {
    return getAll(
      query: collection
          .where('authorId', isEqualTo: authorId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true),
      limit: limit,
    );
  }

  // Mark announcement as read by user
  Future<void> markAsRead(String announcementId, String userId) async {
    try {
      await collection.doc(announcementId).update({
        'readBy': FieldValue.arrayUnion([userId]),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to mark announcement as read: $e');
    }
  }

  // Mark announcement as unread by user
  Future<void> markAsUnread(String announcementId, String userId) async {
    try {
      await collection.doc(announcementId).update({
        'readBy': FieldValue.arrayRemove([userId]),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to mark announcement as unread: $e');
    }
  }

  // Pin/unpin announcement
  Future<void> setPinned(String announcementId, bool isPinned) async {
    try {
      await collection.doc(announcementId).update({
        'isPinned': isPinned,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to update announcement pin status: $e');
    }
  }

  // Get unread announcements for a user
  Future<List<Announcement>> getUnreadAnnouncements(NavySyncUser user, {int? limit}) async {
    final allAnnouncements = await getVisibleAnnouncements(user);
    final unreadAnnouncements = allAnnouncements
        .where((announcement) => !announcement.isReadByUser(user.id))
        .toList();

    return limit != null ? unreadAnnouncements.take(limit).toList() : unreadAnnouncements;
  }

  // Search announcements by title or content
  Future<List<Announcement>> searchAnnouncements(String query, NavySyncUser user) async {
    final announcements = await getVisibleAnnouncements(user);
    final lowerQuery = query.toLowerCase();
    
    return announcements.where((announcement) {
      return announcement.title.toLowerCase().contains(lowerQuery) ||
             announcement.content.toLowerCase().contains(lowerQuery) ||
             announcement.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  // Watch announcements visible to a user
  Stream<List<Announcement>> watchVisibleAnnouncements(NavySyncUser user) {
    // For simplicity, watch organization announcements
    // In production, implement more sophisticated real-time updates
    Query<Object?> query = collection
        .where('visibility', whereIn: ['organization'])
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true);

    return query.snapshots().map((snapshot) {
      final announcements = snapshot.docs.map((doc) => fromFirestore(doc)).toList();
      return announcements.where((announcement) => 
        announcement.canUserAccess(user.id, user.roles, user.departmentId, user.teamIds) &&
        !announcement.isExpired
      ).toList();
    });
  }

  // Clean up expired announcements (should be run periodically)
  Future<void> cleanupExpiredAnnouncements() async {
    try {
      final expiredQuery = await collection
          .where('expiresAt', isLessThan: Timestamp.now())
          .where('isActive', isEqualTo: true)
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in expiredQuery.docs) {
        batch.update(doc.reference, {
          'isActive': false,
          'updatedAt': Timestamp.now(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to cleanup expired announcements: $e');
    }
  }
}
