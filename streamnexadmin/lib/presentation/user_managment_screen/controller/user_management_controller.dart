import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserManagementController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = true;
  List<User> _users = [];
  String _searchQuery = '';

  bool get isLoading => _isLoading;
  List<User> get users => _getFilteredUsers();
  String get searchQuery => _searchQuery;

  void ensureInitialized() {
    if (_users.isEmpty && _isLoading) {
      loadUsers();
    }
  }

  Future<void> loadUsers() async {
    try {
      print('🔍 Starting to load users from Firestore...');
      
      final querySnapshot = await _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .get();

      print('📊 Found ${querySnapshot.docs.length} users in Firestore');

      _users = querySnapshot.docs.map((doc) {
        final data = doc.data();
        print('👤 Loading user: ${data['email'] ?? 'Unknown'}');
        return User(
          data['uid']?.toString() ?? doc.id,
          data['displayName']?.toString() ?? data['email']?.toString().split('@')[0] ?? 'Unknown',
          data['email']?.toString() ?? 'No email',
          data['plan']?.toString() ?? 'Basic',
          data['status']?.toString() ?? 'Active',
          _formatDate(data['createdAt']),
        );
      }).toList();
      
      _isLoading = false;
      notifyListeners();
      
      print('✅ Users loading completed - loaded ${_users.length} users');
      
    } catch (e) {
      print('❌ Error loading users: $e');
      _users = [];
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery = query.toLowerCase().trim();
    notifyListeners();
  }

  List<User> _getFilteredUsers() {
    if (_searchQuery.isEmpty) return _users;
    
    return _users.where((user) {
      final searchLower = _searchQuery.toLowerCase();
      return user.username.toLowerCase().contains(searchLower) ||
             user.email.toLowerCase().contains(searchLower) ||
             user.plan.toLowerCase().contains(searchLower) ||
             user.status.toLowerCase().contains(searchLower) ||
             user.joinDate.toLowerCase().contains(searchLower);
    }).toList();
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Unknown';
    try {
      if (date is Timestamp) {
        final dateTime = date.toDate();
        return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
      }
      if (date is String) {
        return date;
      }
    } catch (e) {
      print('Error formatting date: $e');
    }
    return 'Unknown';
  }

  Future<void> deleteUser(User user) async {
    try {
      print('🗑️ Deleting user: ${user.userId}');
      
      await _firestore
          .collection('users')
          .doc(user.userId)
          .delete();

      print('✅ User deleted from Firestore successfully');
      
      // Reload the users list
      await loadUsers();

    } catch (e) {
      print('❌ Error deleting user: $e');
      throw e;
    }
  }
}

class User {
  final String userId;
  final String username;
  final String email;
  final String plan;
  final String status;
  final String joinDate;

  User(this.userId, this.username, this.email, this.plan, this.status, this.joinDate);
}
