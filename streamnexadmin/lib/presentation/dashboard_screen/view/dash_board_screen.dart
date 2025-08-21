// dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:streamnexadmin/core/constants/color_constants.dart';
import 'package:streamnexadmin/core/constants/text_styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:streamnexadmin/presentation/models/content.dart';
import 'package:streamnexadmin/presentation/video_details_screen/view/video_details_screen.dart';
import 'package:streamnexadmin/presentation/dashboard_screen/controller/dashboard_controller.dart';

class DashboardScreen extends StatelessWidget {
  final DashboardController controller = DashboardController();
 
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
 
 
   String _formatRelativeTime(DateTime dateTime) {
     final now = DateTime.now();
     final diff = now.difference(dateTime);
     if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
     if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
     if (diff.inHours < 24) return '${diff.inHours}h ago';
     if (diff.inDays < 7) return '${diff.inDays}d ago';
     return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
   }

  DashboardScreen({super.key}) {
    controller.loadDashboardData();
  }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Responsive values
    final isTablet = screenWidth > 600;
    final isCompact = screenWidth < 360;
    final padding = isTablet ? 24.0 : (isCompact ? 12.0 : 16.0);
    final spacing = isTablet ? 20.0 : (isCompact ? 12.0 : 16.0);
    
    // Real content lists are populated in _loadDashboardData
    
    return Scaffold(
      backgroundColor: ColorTheme.mainColor,
      appBar: AppBar(
              backgroundColor: ColorTheme.mainColor,
        centerTitle: true,
        title: Text(
          'Dashboard',
          style: TextStyles.appBarHeadding(size: isTablet ? 22 : 20),
        ),
        automaticallyImplyLeading: false,
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return Padding(
        padding: EdgeInsets.all(padding),
        child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overview',
                style: TextStyles.subText(size: isTablet ? 20 : 18),
              ),
              SizedBox(height: spacing),
              // Horizontal stat cards instead of GridView
              controller.isLoading
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
                              child: _buildStatCard('Total Users', _formatNumber(controller.totalUsers), Icons.people, ColorTheme.secondaryColor, isTablet),
                            ),
                            SizedBox(width: spacing),
                            Expanded(
                              child: _buildStatCard('Total Videos', _formatNumber(controller.totalVideos), Icons.movie, ColorTheme.secondaryColor, isTablet),
                            ),
                          ],
                        ),
                        SizedBox(height: spacing),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard('Admin Videos', _formatNumber(controller.adminVideos), Icons.admin_panel_settings, ColorTheme.secondaryColor, isTablet),
                            ),
                            SizedBox(width: spacing),
                            Expanded(
                              child: _buildStatCard('User Videos', _formatNumber(controller.userVideos), Icons.person, ColorTheme.secondaryColor, isTablet),
                            ),
                          ],
                        ),
                      ],
                    ),
              SizedBox(height: spacing),
              Text(
                'Top Watched Content',
                style: TextStyles.subText(size: isTablet ? 20 : 18),
              ),
              SizedBox(height: isTablet ? 12 : (isCompact ? 6 : 8)),
              // Top Watched Content - No fixed height
              ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: controller.topWatched.length,
                separatorBuilder: (context, index) => SizedBox(height: spacing),
                itemBuilder: (context, index) {
                  final content = controller.topWatched[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(isTablet ? 16 : (isCompact ? 10 : 12)),
                      child: InkWell(
                        onTap: () async {
                          try {
                            final source = (content['source'] ?? 'user').toString();
                            final col = source == 'admin' ? 'admin_videos' : 'videos';
                            final docId = (content['id'] ?? '').toString();
                            if (docId.isEmpty) return;
                            final doc = await FirebaseFirestore.instance.collection(col).doc(docId).get();
                            if (!doc.exists) return;
                            final data = doc.data() as Map<String, dynamic>;
                            final detail = Content(
                              (data['title'] ?? 'Untitled').toString(),
                              (data['type'] ?? 'Movie').toString(),
                              (data['category'] ?? data['genre'] ?? '').toString(),
                              DateTime.now().year,
                              _parseDouble(data['rating']),
                              (data['thumbnailUrl'] ?? '').toString(),
                              (data['videoUrl'] ?? data['url'] ?? '').toString(),
                              (data['uploadedBy'] ?? (source == 'admin' ? 'admin' : 'user')).toString(),
                              '',
                              (data['director'] ?? '').toString(),
                              (data['duration'] ?? '').toString(),
                              (data['language'] ?? '').toString(),
                              (data['ratingCode'] ?? '').toString(),
                              (data['description'] ?? '').toString(),
                              (data['starring'] ?? '').toString(),
                              (data['tags'] ?? '').toString(),
                              (data['fileName'] ?? '').toString(),
                              _parseInt(data['views']),
                              (data['status'] ?? 'active').toString(),
                              _parseDouble(data['userRating']),
                              _parseDouble(data['fileSizeGB']),
                              doc.id,
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VideoDetailsScreen(content: detail),
                              ),
                            );
                          } catch (_) {}
                        },
                        child: Row(
                          children: [
                            // Thumbnail (if available)
                            Flexible(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: isTablet ? 70 : 56,
                                  height: isTablet ? 70 : 56,
                                  child: (content['thumbnailUrl'] != null && (content['thumbnailUrl'] as String).isNotEmpty)
                                      ? Image.network(
                                          content['thumbnailUrl'] as String,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(color: Colors.grey[800], child: Icon(Icons.image, color: ColorTheme.secondaryColor, size: isTablet ? 24 : 20));
                                          },
                                        )
                                      : Container(color: Colors.grey[800], child: Icon(Icons.image, color: ColorTheme.secondaryColor, size: isTablet ? 24 : 20)),
                                ),
                              ),
                            ),
                            SizedBox(width: spacing),
            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                                  Text(
                                    (content['title'] ?? 'Untitled').toString(),
                                    style: TextStyles.smallText(
                                      size: isTablet ? 14 : 13,
                                      weight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                 
                                ],
                              ),
                            ),
                ],
              ),
            ),
                    ),
                  );
                },
              ),
              SizedBox(height: spacing),
            Text(
              'Recent Activity',
                style: TextStyles.subText(size: isTablet ? 20 : 18),
            ),
            SizedBox(height: 10),
              // Recent Activity - No fixed height
              ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: controller.recentActivities.length,
                separatorBuilder: (context, index) => SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final activity = controller.recentActivities[index];
                  return Container(
                    decoration: BoxDecoration(
                    color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(isTablet ? 16 : 12),
                      child: Row(
                        children: [
                        
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
                                  _formatRelativeTime(activity['time'] as DateTime),
                                  style: TextStyles.smallText(
                                    color: ColorTheme.secondaryColor,
                                    size: isTablet ? 12 : 11,
                                  ),
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
            ],
          ),
        ),
      );
        },
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
                color: color,
                size: isTablet ? 18 : 16,
              ),
            ),
            SizedBox(height: 5),
            Text(
              title, 
              textAlign: TextAlign.center,
              style: TextStyles.smallText(
                color: color,
                size: isTablet ? 14 : 12,
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
                color: color,
                size: isTablet ? 14 : 12,
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