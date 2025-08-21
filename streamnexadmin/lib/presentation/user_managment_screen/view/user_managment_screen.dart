import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:streamnexadmin/core/constants/color_constants.dart';
import 'package:streamnexadmin/core/constants/text_styles.dart';
import 'package:streamnexadmin/presentation/user_managment_screen/controller/user_management_controller.dart';
import '../../user_details_screen/view/user_details_screen.dart';
class UserManagementScreen extends StatelessWidget {
  UserManagementScreen({super.key});

  final UserManagementController controller = UserManagementController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final padding = isTablet ? 24.0 : 16.0;
    final spacing = isTablet ? 20.0 : 16.0;
    
    controller.ensureInitialized();
    
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
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              children: [
                // Search Bar
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: TextStyle(color: Colors.white),
                        onChanged: (value) {
                          controller.updateSearchQuery(value);
                        },
                        decoration: InputDecoration(
                          hintText: 'Search users...',
                          hintStyle: GoogleFonts.montserrat(color: Colors.grey[400]),
                          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                          suffixIcon: controller.searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear, color: Colors.grey[400]),
                                  onPressed: () {
                                    controller.updateSearchQuery('');
                                  },
                                )
                              : null,
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
                // Content Area
                Expanded(
                  child: controller.isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: ColorTheme.secondaryColor,
                          ),
                        )
                      : controller.users.isEmpty
                          ? _buildEmptyState(isTablet)
                          : ListView.builder(
                              itemCount: controller.users.length,
                              itemBuilder: (context, index) {
                                final user = controller.users[index];
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
                                    trailing: PopupMenuButton(
                                      icon: Icon(
                                        Icons.more_vert, 
                                        color: Colors.white,
                                        size: isTablet ? 28 : 24,
                                      ),
                                      color: Colors.grey[850],
                                      onSelected: (value) => _handleMenuAction(context, value, user),
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
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isTablet) {
    final hasSearchQuery = controller.searchQuery.isNotEmpty;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasSearchQuery ? Icons.search_off : Icons.people_outline,
            size: 80,
            color: Colors.grey[600],
          ),
          SizedBox(height: 16),
          Text(
            hasSearchQuery 
                ? 'No users found for "${controller.searchQuery}"'
                : 'No Users Found',
            style: TextStyles.subText(
              color: Colors.grey[400],
              size: isTablet ? 20 : 18,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            hasSearchQuery
                ? 'Try adjusting your search terms'
                : 'No users have been registered yet.\nUsers will appear here when they sign up.',
            style: TextStyles.smallText(
              color: Colors.grey[500],
              size: isTablet ? 14 : 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action, User user) {
    switch (action) {
      case 'view':
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
        _showDeleteDialog(context, user);
        break;
    }
  }

  void _showDeleteDialog(BuildContext context, User user) {
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
              await _deleteUser(context, user);
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

  Future<void> _deleteUser(BuildContext context, User user) async {
    try {
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

      await controller.deleteUser(user);

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

    } catch (e) {
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
