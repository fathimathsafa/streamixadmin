import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class DashboardController extends ChangeNotifier {
  int totalUsers = 0;
  int totalVideos = 0;
  int adminVideos = 0;
  int userVideos = 0;
  bool isLoading = true;
  List<Map<String, dynamic>> topWatched = [];
  List<Map<String, dynamic>> recentActivities = [];

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  DateTime? _safeToDateTime(dynamic value) {
    try {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString());
    } catch (_) {
      return null;
    }
  }

  Future<void> loadDashboardData() async {
    try {
      isLoading = true;
      notifyListeners();

      final usersQuery = await FirebaseFirestore.instance.collection('users').get();

      final adminVideosQuery = await FirebaseFirestore.instance.collection('admin_videos').get();
      final userVideosQuery = await FirebaseFirestore.instance.collection('videos').get();

      final combinedVideos = <Map<String, dynamic>>[];
      for (final doc in adminVideosQuery.docs) {
        final data = doc.data();
        combinedVideos.add({
          'title': (data['title'] ?? 'Untitled').toString(),
          'views': _parseInt(data['views']),
          'source': 'admin',
          'thumbnailUrl': (data['thumbnailUrl'] ?? '').toString(),
          'videoUrl': (data['videoUrl'] ?? data['url'] ?? '').toString(),
          'id': doc.id,
        });
      }
      for (final doc in userVideosQuery.docs) {
        final data = doc.data();
        combinedVideos.add({
          'title': (data['title'] ?? 'Untitled').toString(),
          'views': _parseInt(data['views']),
          'source': 'user',
          'thumbnailUrl': (data['thumbnailUrl'] ?? '').toString(),
          'videoUrl': (data['videoUrl'] ?? data['url'] ?? '').toString(),
          'id': doc.id,
        });
      }
      combinedVideos.sort((a, b) => (b['views'] as int).compareTo(a['views'] as int));
      final topFive = combinedVideos.take(5).toList();

      final recentUsersFuture = FirebaseFirestore.instance
          .collection('users')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();
      final recentAdminUploadsFuture = FirebaseFirestore.instance
          .collection('admin_videos')
          .orderBy('uploadedAt', descending: true)
          .limit(5)
          .get();
      final recentUserUploadsFuture = FirebaseFirestore.instance
          .collection('videos')
          .orderBy('uploadedAt', descending: true)
          .limit(5)
          .get();

      final recentUsersQuery = await recentUsersFuture;
      final recentAdminUploadsQuery = await recentAdminUploadsFuture;
      final recentUserUploadsQuery = await recentUserUploadsFuture;

      final recentItems = <Map<String, dynamic>>[];
      final uploadUserIds = <String>{};
      for (final doc in recentUsersQuery.docs) {
        final data = doc.data();
        recentItems.add({
          'type': 'user',
          'user': (data['displayName'] ?? data['email'] ?? 'Unknown').toString(),
          'content': 'New user registered',
          'time': _safeToDateTime(data['createdAt']) ?? DateTime.now(),
        });
      }
      for (final doc in recentAdminUploadsQuery.docs) {
        final data = doc.data();
        recentItems.add({
          'type': 'upload',
          'userId': (data['uploadedBy'] ?? '').toString(),
          'content': 'Admin uploaded "${(data['title'] ?? 'Untitled').toString()}"',
          'time': _safeToDateTime(data['uploadedAt']) ?? DateTime.now(),
        });
        final uid = (data['uploadedBy'] ?? '').toString();
        if (uid.isNotEmpty) uploadUserIds.add(uid);
      }
      for (final doc in recentUserUploadsQuery.docs) {
        final data = doc.data();
        recentItems.add({
          'type': 'upload',
          'userId': (data['uploadedBy'] ?? '').toString(),
          'content': 'User uploaded "${(data['title'] ?? 'Untitled').toString()}"',
          'time': _safeToDateTime(data['uploadedAt']) ?? DateTime.now(),
        });
        final uid = (data['uploadedBy'] ?? '').toString();
        if (uid.isNotEmpty) uploadUserIds.add(uid);
      }

      final Map<String, String> idToName = {};
      if (uploadUserIds.isNotEmpty) {
        final ids = uploadUserIds.toList();
        const int maxBatch = 10;
        for (int i = 0; i < ids.length; i += maxBatch) {
          final chunk = ids.sublist(i, i + maxBatch > ids.length ? ids.length : i + maxBatch);
          try {
            final snap = await FirebaseFirestore.instance
                .collection('users')
                .where(FieldPath.documentId, whereIn: chunk)
                .get();
            for (final d in snap.docs) {
              final u = d.data();
              final name = (u['displayName'] ?? '').toString();
              final email = (u['email'] ?? '').toString();
              idToName[d.id] = name.isNotEmpty ? name : (email.isNotEmpty ? email : 'User');
            }
          } catch (_) {}
        }
      }
      for (final item in recentItems) {
        if (item['type'] == 'upload') {
          final uid = (item['userId'] ?? '').toString();
          item['user'] = idToName[uid] ?? (uid.isNotEmpty ? uid : 'User');
          item.remove('userId');
        }
      }
      recentItems.sort((a, b) => (b['time'] as DateTime).compareTo(a['time'] as DateTime));
      final recentEight = recentItems.take(8).toList();

      totalUsers = usersQuery.docs.length;
      adminVideos = adminVideosQuery.docs.length;
      userVideos = userVideosQuery.docs.length;
      totalVideos = adminVideos + userVideos;
      topWatched = topFive;
      recentActivities = recentEight;
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      notifyListeners();
    }
  }
}



