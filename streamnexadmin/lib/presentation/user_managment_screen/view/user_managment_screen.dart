
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:streamnexadmin/core/constants/color_constants.dart';
import 'package:streamnexadmin/core/constants/text_styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../user_details_screen/view/user_details_screen.dart';

class UserManagementScreen extends StatefulWidget {
  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<User> users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      print('🔍 Starting to load users from Firestore...');
      
      // Try to load users from Firestore collection
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('createdAt', descending: true)
          .get();

      print('📊 Found ${querySnapshot.docs.length} users in Firestore');

      setState(() {
        users = querySnapshot.docs.map((doc) {
          final data = doc.data();
          print('👤 Loading user: ${data['email'] ?? 'Unknown'}');
          return User(
            data['uid']?.toString() ?? doc.id, // Use uid field if available, otherwise doc.id
            data['displayName']?.toString() ?? data['email']?.toString().split('@')[0] ?? 'Unknown',
            data['email']?.toString() ?? 'No email',
            data['plan']?.toString() ?? 'Basic',
            data['status']?.toString() ?? 'Active',
            _formatDate(data['createdAt']),
          );
        }).toList();
        _isLoading = false;
      });
      
      print('✅ Users loading completed - loaded ${users.length} users');
      
    } catch (e) {
      print('❌ Error loading users: $e');
      setState(() {
        users = [];
        _isLoading = false;
      });
    }
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




  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    final isTablet = screenWidth > 600;
    final isMobile = screenWidth <= 600;
    final padding = isTablet ? 24.0 : 16.0;
    final spacing = isTablet ? 20.0 : 16.0;
    
    return Scaffold(
      backgroundColor: ColorTheme.mainColor,
      appBar: AppBar(
        backgroundColor: ColorTheme.mainColor,
        centerTitle: true,
        title: Text(
          'User Management',
          style: TextStyles.appBarHeadding(),
        ),
        automaticallyImplyLeading: false,
        
      ),
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search users...',
                      hintStyle: GoogleFonts.montserrat(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[850],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[700]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[700]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: ColorTheme.secondaryColor),
                      ),
                    ),
                  ),
                ),
                
              ],
            ),
            SizedBox(height: spacing),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: ColorTheme.secondaryColor,
                      ),
                    )
                  : users.isEmpty
                      ? Builder(
                          builder: (context) {
                            print('📱 Rendering empty state - users count: ${users.length}, isLoading: $_isLoading');
                            return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 80,
                                color: Colors.grey[600],
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No Users Found',
                                style: TextStyles.subText(
                                  color: Colors.grey[400],
                                  size: isTablet ? 20 : 18,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'No users have been registered yet.\nUsers will appear here when they sign up.',
                                style: TextStyles.smallText(
                                  color: Colors.grey[500],
                                  size: isTablet ? 14 : 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
  })
                      : ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                  final user = users[index];
                  return Card(
                    color: Colors.grey[850],
                    margin: EdgeInsets.only(bottom: isTablet ? 12 : 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: isTablet ? 25 : 20,
                        backgroundColor: ColorTheme.secondaryColor,
                        child: Text(
                          user.username[0].toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 16 : 14,
                          ),
                        ),
                      ),
                      title: Text(
                        user.username, 
                        style: TextStyles.smallText(
                          size: isTablet ? 18 : 16,
                          weight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.email,
                            style: TextStyles.smallText(
                              color: Colors.grey[400],
                              size: isTablet ? 14 : 12,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Joined: ${user.joinDate}',
                            style: TextStyles.smallText(
                              color: Colors.grey[400],
                              size: isTablet ? 14 : 12,
                            ),
                          ),
                        ],
                      ),
                      trailing: 
                          PopupMenuButton(
                            icon: Icon(
                              Icons.more_vert, 
                              color: Colors.white,
                              size: isTablet ? 28 : 24,
                            ),
                            color: Colors.grey[850],
                            onSelected: (value) => _handleMenuAction(value, user),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                child: Text(
                                  'View Details', 
                                  style: TextStyles.smallText(
                                    color: Colors.white,
                                    size: isTablet ? 16 : 14,
                                  ),
                                ),
                                value: 'view',
                              ),
                              
                              PopupMenuItem(
                                child: Text(
                                  'Delete', 
                                  style: TextStyles.smallText(
                                    color: ColorTheme.secondaryColor,
                                    size: isTablet ? 16 : 14,
                                  ),
                                ),
                                value: 'delete',
                              ),
                            ],
                          ),
                        
                      
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(String action, User user) {
    switch (action) {
      case 'view':
        // Navigate to user details screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserDetailsScreen(
              userId: user.userId,
              userName: user.username,
              userEmail: user.email,
            ),
          ),
        );
        break;
      
      case 'delete':
        _showDeleteDialog(user);
        break;
    }
  }


  void _showDeleteDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: Text(
          'Delete User',
          style: TextStyles.subText(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete ${user.username}? This action cannot be undone.',
          style: TextStyles.smallText(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyles.smallText(color: Colors.grey[400]),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteUser(user);
            },
            child: Text(
              'Delete',
              style: TextStyles.smallText(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser(User user) async {
    try {
      print('🗑️ Deleting user: ${user.userId}');
      
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(
            color: ColorTheme.secondaryColor,
          ),
        ),
      );

      // Delete user from Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.userId)
          .delete();

      print('✅ User deleted from Firestore successfully');

      // Close loading dialog
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ User ${user.username} deleted successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // Reload the users list
      await _loadUsers();

    } catch (e) {
      print('❌ Error deleting user: $e');
      
      // Close loading dialog
      Navigator.pop(context);

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error deleting user: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
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