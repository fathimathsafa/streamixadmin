import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:streamnexadmin/presentation/models/content.dart';

class ContentManagementController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _initialized = false;
  bool _isLoading = true;
  List<Content> _adminVideos = [];
  List<Content> _userVideos = [];
  String _adminSearchQuery = '';
  String _userSearchQuery = '';

  bool get isLoading => _isLoading;
  List<Content> get adminVideos => _getFilteredVideos(_adminVideos, _adminSearchQuery);
  List<Content> get userVideos => _getFilteredVideos(_userVideos, _userSearchQuery);
  String get adminSearchQuery => _adminSearchQuery;
  String get userSearchQuery => _userSearchQuery;

  void ensureInitialized() {
    if (_initialized) return;
    _initialized = true;
    _loadAll();
  }

  Future<void> refresh() async {
    await _loadAll();
  }

  Future<void> _loadAll() async {
    _setLoading(true);
    try {
      await Future.wait([
        loadAdminVideos(),
        loadUserVideos(),
      ]);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadAdminVideos() async {
    try {
      final querySnapshot = await _firestore
          .collection('admin_videos')
          .orderBy('uploadedAt', descending: true)
          .get();
      _adminVideos = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return _mapToContent(data, doc.id, uploaderFallback: 'admin');
      }).toList();
      notifyListeners();
    } catch (_) {
      _adminVideos = [];
      notifyListeners();
    }
  }

  Future<void> loadUserVideos() async {
    try {
      final querySnapshot = await _firestore
          .collection('videos')
          .orderBy('uploadedAt', descending: true)
          .get();
      _userVideos = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return _mapToContent(data, doc.id, uploaderFallback: 'user');
      }).toList();
      notifyListeners();
    } catch (_) {
      _userVideos = [];
      notifyListeners();
    }
  }

  Future<void> deleteVideo(String documentId, String uploaderType) async {
    await _firestore
        .collection('${uploaderType.toLowerCase()}_videos')
        .doc(documentId)
        .delete();
    if (uploaderType == 'Admin') {
      await loadAdminVideos();
    } else {
      await loadUserVideos();
    }
  }

  Content _mapToContent(Map<String, dynamic> data, String id, {required String uploaderFallback}) {
    return Content(
      (data['title']?.toString() ?? 'Untitled'),
      'Movie',
      (data['category']?.toString() ?? 'Unknown'),
      _parseYear(data['releaseDate']),
      _parseDouble(data['rating']),
      (data['thumbnailUrl']?.toString() ?? ''),
      (data['videoUrl']?.toString() ?? ''),
      (data['uploadedBy']?.toString() ?? uploaderFallback),
      _formatUploadTime(data['uploadedAt']),
      (data['director']?.toString() ?? ''),
      (data['duration']?.toString() ?? ''),
      (data['language']?.toString() ?? ''),
      '',
      (data['description']?.toString() ?? ''),
      (data['starring']?.toString() ?? ''),
      (data['tags']?.toString() ?? ''),
      (data['fileName']?.toString() ?? ''),
      _parseInt(data['views']),
      (data['status']?.toString() ?? 'active'),
      _parseDouble(data['userRating']),
      _parseDouble(data['fileSizeGB']),
      id,
    );
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  int _parseYear(dynamic releaseDate) {
    if (releaseDate == null) return DateTime.now().year;
    try {
      if (releaseDate is String) {
        return DateTime.parse(releaseDate).year;
      }
      if (releaseDate is Timestamp) {
        return releaseDate.toDate().year;
      }
    } catch (_) {}
    return DateTime.now().year;
  }

  String _formatUploadTime(dynamic uploadedAt) {
    if (uploadedAt == null) return 'Unknown';
    try {
      DateTime uploadTime;
      if (uploadedAt is Timestamp) {
        uploadTime = uploadedAt.toDate();
      } else if (uploadedAt is String) {
        uploadTime = DateTime.parse(uploadedAt);
      } else {
        return 'Unknown';
      }
      final diff = DateTime.now().difference(uploadTime);
      if (diff.inDays > 0) return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
      if (diff.inHours > 0) return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
      if (diff.inMinutes > 0) return '${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''} ago';
      return 'Just now';
    } catch (_) {
      return 'Unknown';
    }
  }

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

  void updateAdminSearchQuery(String query) {
    _adminSearchQuery = query.toLowerCase().trim();
    notifyListeners();
  }

  void updateUserSearchQuery(String query) {
    _userSearchQuery = query.toLowerCase().trim();
    notifyListeners();
  }

  List<Content> _getFilteredVideos(List<Content> videos, String query) {
    if (query.isEmpty) return videos;
    
    return videos.where((video) {
      final searchLower = query.toLowerCase();
      return video.title.toLowerCase().contains(searchLower) ||
             video.genre.toLowerCase().contains(searchLower) ||
             video.director.toLowerCase().contains(searchLower) ||
             video.starring.toLowerCase().contains(searchLower) ||
             video.type.toLowerCase().contains(searchLower) ||
             video.year.toString().contains(searchLower);
    }).toList();
  }
}


