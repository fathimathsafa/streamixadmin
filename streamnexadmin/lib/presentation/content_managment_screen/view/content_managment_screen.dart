import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:streamnexadmin/core/constants/color_constants.dart';
import 'package:streamnexadmin/core/constants/text_styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:streamnexadmin/presentation/content_managment_screen/view/video_details_screen.dart';

class ContentManagementScreen extends StatefulWidget {
  @override
  _ContentManagementScreenState createState() => _ContentManagementScreenState();
}

class _ContentManagementScreenState extends State<ContentManagementScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  
  List<Content> adminVideos = [];
  List<Content> userVideos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAdminVideos();
    _loadUserVideos();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadAdminVideos() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('admin_videos')
          .orderBy('uploadedAt', descending: true)
          .get();

      setState(() {
        adminVideos = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return Content(
            data['title']?.toString() ?? 'Untitled',
            'Movie',
            data['category']?.toString() ?? 'Unknown',
            _parseYear(data['releaseDate']),
            _parseRating(data['rating']),
            data['thumbnailUrl']?.toString() ?? '',
            data['videoUrl']?.toString() ?? '',
            data['uploadedBy']?.toString() ?? 'admin',
            _formatUploadTime(data['uploadedAt']),
            data['director']?.toString() ?? '',
            data['duration']?.toString() ?? '',
            data['language']?.toString() ?? '',
            '',
            data['description']?.toString() ?? '',
            data['starring']?.toString() ?? '',
            data['tags']?.toString() ?? '',
            data['fileName']?.toString() ?? '',
            (data['views'] is int) ? data['views'] as int : int.tryParse('${data['views']}') ?? 0,
            data['status']?.toString() ?? 'active',
            _parseRating(data['userRating']),
            _parseFileSize(data['fileSizeGB']),
            doc.id, // document ID for delete operations
          );
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading admin videos: $e');
      setState(() {
        _isLoading = false;
        adminVideos = [];
      });
    }
  }

  Future<void> _loadUserVideos() async {
    try {
      // For now, we'll use an empty list since user_videos collection doesn't exist yet
      setState(() {
        userVideos = [];
      });
    } catch (e) {
      print('Error loading user videos: $e');
      setState(() {
        userVideos = [];
      });
    }
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
    } catch (e) {
      print('Error parsing year: $e');
    }
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

      final now = DateTime.now();
      final difference = now.difference(uploadTime);

      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  double _parseRating(dynamic rating) {
    if (rating == null) return 0.0;
    try {
      if (rating is double) return rating;
      if (rating is int) return rating.toDouble();
      if (rating is String) return double.tryParse(rating) ?? 0.0;
      return 0.0;
    } catch (e) {
      print('Error parsing rating: $e');
      return 0.0;
    }
  }

  double _parseFileSize(dynamic fileSize) {
    if (fileSize == null) return 0.0;
    try {
      if (fileSize is double) return fileSize;
      if (fileSize is int) return fileSize.toDouble();
      if (fileSize is String) return double.tryParse(fileSize) ?? 0.0;
      return 0.0;
    } catch (e) {
      print('Error parsing file size: $e');
      return 0.0;
    }
  }

  Future<void> _deleteVideo(String documentId, String uploaderType) async {
    try {
      await FirebaseFirestore.instance
          .collection('${uploaderType.toLowerCase()}_videos')
          .doc(documentId)
          .delete();

      // Refresh the list
      if (uploaderType == 'Admin') {
        await _loadAdminVideos();
      } else {
        await _loadUserVideos();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Video deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting video: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Responsive values
    final isTablet = screenWidth > 600;
    final padding = isTablet ? 24.0 : 16.0;
    final spacing = isTablet ? 20.0 : 16.0;
    
    // Check if TabController is initialized
    if (_tabController == null) {
      return Scaffold(
        backgroundColor: ColorTheme.mainColor,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: ColorTheme.mainColor,
          title: Text(
            'Content Management',
            style: TextStyles.appBarHeadding(),
          ),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: CircularProgressIndicator(
            color: ColorTheme.secondaryColor,
          ),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: ColorTheme.mainColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: ColorTheme.mainColor,
        title: Text(
          'Content Management',
          style: TextStyles.appBarHeadding(),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _loadAdminVideos();
              _loadUserVideos();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController!,
          indicatorColor: ColorTheme.secondaryColor,
          labelColor: ColorTheme.secondaryColor,
          unselectedLabelColor: Colors.grey[400],
          labelStyle: GoogleFonts.montserrat(
            fontSize: isTablet ? 16 : 14,
            fontWeight: FontWeight.w600,
          ),
          tabs: [
            Tab(
              icon: Icon(Icons.admin_panel_settings, size: isTablet ? 24 : 20),
              text: 'Admin Videos',
            ),
            Tab(
              icon: Icon(Icons.people, size: isTablet ? 24 : 20),
              text: 'User Videos',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController!,
        children: [
          _buildVideoList(adminVideos, 'Admin', isTablet, padding, spacing),
          _buildVideoList(userVideos, 'User', isTablet, padding, spacing),
        ],
      ),
    );
  }

  Widget _buildVideoList(List<Content> videos, String uploaderType, bool isTablet, double padding, double spacing) {
    if (_isLoading && uploaderType == 'Admin') {
      return Center(
        child: CircularProgressIndicator(
          color: ColorTheme.secondaryColor,
        ),
      );
    }

    if (videos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 80,
              color: Colors.grey[600],
            ),
            SizedBox(height: 16),
            Text(
              'No ${uploaderType.toLowerCase()} videos found',
              style: TextStyles.subText(
                color: Colors.grey[400],
                size: isTablet ? 20 : 18,
              ),
            ),
            SizedBox(height: 8),
            Text(
              uploaderType == 'Admin' 
                ? 'Upload videos using the "Add Movie" feature'
                : 'No user videos uploaded yet',
              style: TextStyles.smallText(
                color: Colors.grey[500],
                size: isTablet ? 14 : 12,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search ${uploaderType.toLowerCase()} videos...',
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
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final content = videos[index];
                return Card(
                  color: Colors.grey[850],
                  margin: EdgeInsets.only(bottom: isTablet ? 12 : 8),
                  child: ListTile(
                    dense: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoDetailsScreen(content: content),
                        ),
                      );
                    },
                    leading: Container(
                      width: isTablet ? 80 : 60,
                      height: isTablet ? 100 : 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: content.posterUrl!.startsWith('http')
                            ? Image.network(
                                content.posterUrl!,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: Colors.grey[700],
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded / 
                                              loadingProgress.expectedTotalBytes!
                                            : null,
                                        color: ColorTheme.secondaryColor,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[700],
                                    child: Icon(
                                      Icons.video_file,
                                      color: ColorTheme.secondaryColor,
                                      size: 30,
                                    ),
                                  );
                                },
                              )
                            : Container(
                                color: Colors.grey[700],
                                child: Icon(
                                  Icons.video_file,
                                  color: ColorTheme.secondaryColor,
                                  size: 30,
                                ),
                              ),
                      ),
                    ),
                    title: Text(
                      content.title, 
                      style: TextStyles.smallText(),
                    ),
                    subtitle: Text(
                      '${content.type} • ${content.genre} • ${content.year}'
                      '${content.rating > 0 ? '  ★ ${content.rating}' : ''}',
                      style: TextStyles.smallText(color: Colors.grey[400], size: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: PopupMenuButton(
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
                              color: Colors.blue,
                              size: isTablet ? 16 : 14,
                            ),
                          ),
                          value: 'view',
                        ),
                        PopupMenuItem(
                          child: Text(
                            'Edit', 
                            style: TextStyles.smallText(
                              color: Colors.green,
                              size: isTablet ? 16 : 14,
                            ),
                          ),
                          value: 'edit',
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
                      onSelected: (value) async {
                        if (value == 'delete') {
                          // Show confirmation dialog
                          bool? confirm = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Colors.grey[900],
                                title: Text('Delete Video', style: TextStyle(color: Colors.white)),
                                content: Text(
                                  'Are you sure you want to delete "${content.title}"?',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: Text('Cancel', style: TextStyle(color: Colors.white70)),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: ColorTheme.secondaryColor,
                                    ),
                                    child: Text('Delete', style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirm == true) {
                            await _deleteVideo(content.documentId, uploaderType);
                          }
                        } else if (value == 'view') {
                          // Show video details
                          _showVideoDetails(content, isTablet);
                        }
                        // Handle other actions
                        print('$value action for ${content.title}');
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showVideoDetails(Content content, bool isTablet) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(content.title, style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (content.description.isNotEmpty) ...[
                  Text('Description:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(content.description, style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 16),
                ],
                Text('Genre: ${content.genre}', style: TextStyle(color: Colors.white70)),
                if (content.director.isNotEmpty) Text('Director: ${content.director}', style: TextStyle(color: Colors.white70)),
                if (content.starring.isNotEmpty) Text('Cast: ${content.starring}', style: TextStyle(color: Colors.white70)),
                if (content.duration.isNotEmpty) Text('Duration: ${content.duration}', style: TextStyle(color: Colors.white70)),
                if (content.language.isNotEmpty) Text('Language: ${content.language}', style: TextStyle(color: Colors.white70)),
                if (content.ratingCode.isNotEmpty) Text('Rating: ${content.ratingCode}', style: TextStyle(color: Colors.white70)),
                Text('Year: ${content.year}', style: TextStyle(color: Colors.white70)),
                Text('Uploaded by: ${content.uploader}', style: TextStyle(color: Colors.white70)),
                Text('Upload time: ${content.uploadTime}', style: TextStyle(color: Colors.white70)),
                if (content.fileSizeGB > 0) Text('File size: ${content.fileSizeGB.toStringAsFixed(1)} GB', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close', style: TextStyle(color: Colors.white70)),
            ),
          ],
        );
      },
    );
  }
}

// Models
class Content {
  final String title;
  final String type;
  final String genre;
  final int year;
  final double rating;
  final String? posterUrl;
  final String? videoUrl;
  final String uploader;
  final String uploadTime;
  final String director;
  final String duration;
  final String language;
  final String ratingCode;
  final String description;
  final String starring;
  final String? tags;
  final String? fileName;
  final int views;
  final String status;
  final double userRating;
  final double fileSizeGB;
  final String documentId;

  Content(
    this.title, 
    this.type, 
    this.genre, 
    this.year, 
    this.rating, 
    this.posterUrl, 
    this.videoUrl,
    this.uploader, 
    this.uploadTime,
    this.director,
    this.duration,
    this.language,
    this.ratingCode,
    this.description,
    this.starring,
    this.tags,
    this.fileName,
    this.views,
    this.status,
    this.userRating,
    this.fileSizeGB,
    this.documentId,
  );
}
