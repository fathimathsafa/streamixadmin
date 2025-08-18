
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:streamnexadmin/core/constants/color_constants.dart';
import 'package:streamnexadmin/core/constants/text_styles.dart';

class UserManagementScreen extends StatelessWidget {
  final List<User> users = [
    User('john_doe', 'john@email.com', 'Premium', 'Active', '2023-01-15'),
    User('jane_smith', 'jane@email.com', 'Basic', 'Active', '2023-02-20'),
    User('bob_wilson', 'bob@email.com', 'Premium', 'Suspended', '2023-03-10'),
    User('alice_brown', 'alice@email.com', 'Standard', 'Active', '2023-04-05'),
    User('mike_davis', 'mike@email.com', 'Premium', 'Active', '2023-05-12'),
    User('sarah_jones', 'sarah@email.com', 'Basic', 'Inactive', '2023-06-08'),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Responsive values
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
              child: ListView.builder(
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
                            '${user.plan} • Joined: ${user.joinDate}',
                            style: TextStyles.smallText(
                              color: Colors.grey[400],
                              size: isTablet ? 14 : 12,
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 12 : 8, 
                              vertical: isTablet ? 6 : 4
                            ),
                            decoration: BoxDecoration(
                              color: user.status == 'Active' 
                                  ? Colors.green.withOpacity(0.2)
                                  : user.status == 'Suspended'
                                      ? Colors.orange.withOpacity(0.2)
                                      : Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: user.status == 'Active' 
                                    ? Colors.green
                                    : user.status == 'Suspended'
                                        ? Colors.orange
                                        : Colors.red,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              user.status, 
                              style: TextStyle(
                                fontSize: isTablet ? 12 : 10,
                                color: user.status == 'Active' 
                                    ? Colors.green
                                    : user.status == 'Suspended'
                                        ? Colors.orange
                                        : Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          PopupMenuButton(
                            icon: Icon(
                              Icons.more_vert, 
                              color: Colors.white,
                              size: isTablet ? 28 : 24,
                            ),
                            color: Colors.grey[850],
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
                                  'Suspend', 
                                  style: TextStyles.smallText(
                                    color: Colors.orange,
                                    size: isTablet ? 16 : 14,
                                  ),
                                ),
                                value: 'suspend',
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
}

class User {
  final String username;
  final String email;
  final String plan;
  final String status;
  final String joinDate;

  User(this.username, this.email, this.plan, this.status, this.joinDate);
}