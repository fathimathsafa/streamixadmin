// dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:streamnexadmin/core/constants/color_constants.dart';
import 'package:streamnexadmin/core/constants/text_styles.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Responsive values
    final isTablet = screenWidth > 600;
    final isMobile = screenWidth <= 600;
    final crossAxisCount = isTablet ? 4 : (isMobile ? 2 : 3);
    final padding = isTablet ? 24.0 : 16.0;
    final spacing = isTablet ? 20.0 : 16.0;
    
    // Top watched content data
    final topContent = [
      {'title': 'Stranger Things S4', 'views': '2.1M', 'hours': '45.2K', 'rating': '4.8'},
      {'title': 'The Crown S6', 'views': '1.8M', 'hours': '38.7K', 'rating': '4.7'},
      {'title': 'Money Heist S5', 'views': '1.6M', 'hours': '32.1K', 'rating': '4.6'},
      {'title': 'The Witcher S3', 'views': '1.4M', 'hours': '28.9K', 'rating': '4.5'},
      {'title': 'Ozark S4', 'views': '1.2M', 'hours': '25.4K', 'rating': '4.4'},
    ];
    
    // Sample activity data
    final activities = [
      {'type': 'upload', 'user': 'admin_john', 'content': 'New movie "The Matrix 4"', 'time': '2 minutes ago', 'icon': Icons.movie, 'color': ColorTheme.secondaryColor},
      {'type': 'user', 'user': 'sarah_wilson', 'content': 'New user registration', 'time': '5 minutes ago', 'icon': Icons.person_add, 'color': ColorTheme.secondaryColor},
      {'type': 'content', 'user': 'moderator_mike', 'content': 'Content flagged for review', 'time': '8 minutes ago', 'icon': Icons.flag, 'color': ColorTheme.secondaryColor},
      {'type': 'upload', 'user': 'content_team', 'content': 'TV Series "Breaking Bad" S1', 'time': '12 minutes ago', 'icon': Icons.tv, 'color': ColorTheme.secondaryColor},
      {'type': 'user', 'user': 'alex_chen', 'content': 'User profile updated', 'time': '15 minutes ago', 'icon': Icons.edit, 'color': ColorTheme.secondaryColor},
      {'type': 'system', 'user': 'System', 'content': 'Backup completed successfully', 'time': '20 minutes ago', 'icon': Icons.backup, 'color': ColorTheme.secondaryColor},
      {'type': 'upload', 'user': 'admin_jane', 'content': 'Documentary "Planet Earth"', 'time': '25 minutes ago', 'icon': Icons.video_library, 'color': ColorTheme.secondaryColor},
      {'type': 'user', 'user': 'david_brown', 'content': 'Premium subscription activated', 'time': '30 minutes ago', 'icon': Icons.star, 'color': ColorTheme.secondaryColor},
    ];
    
    return Scaffold(
      backgroundColor: ColorTheme.mainColor,
      appBar: AppBar(
        backgroundColor: ColorTheme.mainColor,
        centerTitle: true,
        title: Text(
          'Dashboard',
          style: TextStyles.appBarHeadding(),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Overview',
                style: TextStyles.subText(
                  
                ),
              ),
              SizedBox(height: spacing),
              // Horizontal stat cards instead of GridView
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard('Total Users', '125,430', Icons.people, ColorTheme.secondaryColor, isTablet),
                  ),
                  SizedBox(width: spacing),
                  Expanded(
                    child: _buildStatCard('Total Content', '8,945', Icons.movie, ColorTheme.secondaryColor, isTablet),
                  ),
                ],
              ),
              SizedBox(height: spacing),
              Text(
                'Top Watched Content',
                style: TextStyles.subText(
                  
                ),
              ),
              SizedBox(height: 10),
              // Top Watched Content - No fixed height
              ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: topContent.length,
                separatorBuilder: (context, index) => SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final content = topContent[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              color: ColorTheme.secondaryColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: ColorTheme.secondaryColor, width: 1),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: ColorTheme.secondaryColor,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  content['title']!,
                                  style: TextStyles.smallText(
                                    size: isTablet ? 14 : 13,
                                    weight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.visibility, color: ColorTheme.secondaryColor, size: 14),
                                    SizedBox(width: 4),
                                    Text(
                                      '${content['views']} views',
                                      style: TextStyles.smallText(
                                        color: ColorTheme.secondaryColor,
                                        size: isTablet ? 12 : 11,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Icon(Icons.access_time, color: ColorTheme.secondaryColor, size: 14),
                                    SizedBox(width: 4),
                                    Text(
                                      '${content['hours']} hours',
                                      style: TextStyles.smallText(
                                        color: ColorTheme.secondaryColor,
                                        size: isTablet ? 12 : 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: spacing),
              Row(
                children: [
                  Text(
                    'Recent Activity',
                    style: TextStyles.subText(
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              // Recent Activity - No fixed height
              ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: activities.length,
                separatorBuilder: (context, index) => SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final activity = activities[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        children: [
                        
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${activity['user']} - ${activity['content']}',
                                  style: TextStyles.smallText(
                                    size: isTablet ? 14 : 13,
                                    weight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  activity['time'] as String,
                                  style: TextStyles.smallText(
                                    color: ColorTheme.secondaryColor,
                                    size: isTablet ? 12 : 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _getActivityBadge(activity['type'] as String),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getActivityBadge(String type) {
    Color badgeColor;
    String badgeText;
    IconData badgeIcon;
    
    switch (type) {
      case 'upload':
        badgeColor = Colors.red;
        badgeText = 'Upload';
        badgeIcon = Icons.cloud_upload;
        break;
      case 'user':
        badgeColor = Colors.red;
        badgeText = 'User';
        badgeIcon = Icons.person;
        break;
      case 'content':
        badgeColor = Colors.red;
        badgeText = 'Content';
        badgeIcon = Icons.content_paste;
        break;
      case 'system':
        badgeColor = Colors.red;
        badgeText = 'System';
        badgeIcon = Icons.settings;
        break;
      default:
        badgeColor = Colors.red;
        badgeText = 'Other';
        badgeIcon = Icons.info;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 12, color: badgeColor),
          SizedBox(width: 4),
          Text(
            badgeText,
            style: TextStyle(
              fontSize: 10,
              color: badgeColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isTablet) {
    return Card(
      color: Colors.grey[850],
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon, 
              size: isTablet ? 50 : 40, 
              color: color
            ),
            SizedBox(height: isTablet ? 15 : 10),
            Text(
              value,
              style: TextStyles.smallText(
                color: color
              ),
            ),
            SizedBox(height: 5),
            Text(
              title, 
              textAlign: TextAlign.center,
              style: TextStyles.smallText(
                                color: color

              ),
            ),
          ],
        ),
      ),
    );
  }
}