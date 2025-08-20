// dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:streamnexadmin/core/constants/color_constants.dart';
import 'package:streamnexadmin/core/constants/text_styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _totalUsers = 0;
  int _totalVideos = 0;
  int _adminVideos = 0;
  int _userVideos = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      print('📊 Loading dashboard data...');
      
      // Load total users count
      final usersQuery = await FirebaseFirestore.instance
          .collection('users')
          .get();
      
      // Load total videos count (all videos - admin and user uploaded)
      final videosQuery = await FirebaseFirestore.instance
          .collection('videos')
          .get();
      
      // Count admin vs user videos
      int adminVideos = 0;
      int userVideos = 0;
      
      print('🔍 Found ${videosQuery.docs.length} videos in total');
      for (int i = 0; i < videosQuery.docs.length; i++) {
        final videoData = videosQuery.docs[i].data();
        final uploadedBy = videoData['uploadedBy'] ?? 'Unknown';
        
        // Check if uploadedBy is an admin (you can modify this logic based on your admin IDs)
        // For now, let's assume admin videos have specific uploader IDs or we can check against admin collection
        if (_isAdminUploader(uploadedBy)) {
          adminVideos++;
          print('👑 Admin Video ${i + 1}: ${videoData['title'] ?? 'Untitled'} - Uploaded by: $uploadedBy');
        } else {
          userVideos++;
          print('👤 User Video ${i + 1}: ${videoData['title'] ?? 'Untitled'} - Uploaded by: $uploadedBy');
        }
      }
      
      setState(() {
        _totalUsers = usersQuery.docs.length;
        _totalVideos = videosQuery.docs.length;
        _adminVideos = adminVideos;
        _userVideos = userVideos;
        _isLoading = false;
      });
      
      print('✅ Dashboard data loaded - Users: $_totalUsers, Total Videos: $_totalVideos, Admin Videos: $_adminVideos, User Videos: $_userVideos');
      
    } catch (e) {
      print('❌ Error loading dashboard data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _isAdminUploader(String uploaderId) {
    // You can modify this logic based on how you identify admin users
    // For example, check if the uploader ID exists in an admin collection
    // or if it matches specific admin user IDs
    
    // Option 1: Check against admin collection (recommended)
    // This would require an additional query to check if uploaderId is in admin collection
    
    // Option 2: Check against specific admin IDs (if you know them)
    // List<String> adminIds = ['admin1', 'admin2', 'admin3'];
    // return adminIds.contains(uploaderId);
    
    // Option 3: Check if uploaderId contains 'admin' (simple approach)
    return uploaderId.toLowerCase().contains('admin') || 
           uploaderId.toLowerCase().contains('moderator') ||
           uploaderId.toLowerCase().contains('admin_');
  }
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
              _isLoading
                  ? Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildLoadingCard('Total Users', Icons.people, ColorTheme.secondaryColor, isTablet),
                            ),
                            SizedBox(width: spacing),
                            Expanded(
                              child: _buildLoadingCard('Total Videos', Icons.movie, ColorTheme.secondaryColor, isTablet),
                            ),
                          ],
                        ),
                        SizedBox(height: spacing),
                        Row(
                          children: [
                            Expanded(
                              child: _buildLoadingCard('Admin Videos', Icons.admin_panel_settings, Colors.blue, isTablet),
                            ),
                            SizedBox(width: spacing),
                            Expanded(
                              child: _buildLoadingCard('User Videos', Icons.person, Colors.green, isTablet),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard('Total Users', _formatNumber(_totalUsers), Icons.people, ColorTheme.secondaryColor, isTablet),
                            ),
                            SizedBox(width: spacing),
                            Expanded(
                              child: _buildStatCard('Total Videos', _formatNumber(_totalVideos), Icons.movie, ColorTheme.secondaryColor, isTablet),
                            ),
                          ],
                        ),
                        SizedBox(height: spacing),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard('Admin Videos', _formatNumber(_adminVideos), Icons.admin_panel_settings, Colors.blue, isTablet),
                            ),
                            SizedBox(width: spacing),
                            Expanded(
                              child: _buildStatCard('User Videos', _formatNumber(_userVideos), Icons.person, Colors.green, isTablet),
                            ),
                          ],
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

  Widget _buildLoadingCard(String title, IconData icon, Color color, bool isTablet) {
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
            CircularProgressIndicator(
              color: color,
              strokeWidth: 2,
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

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }
}