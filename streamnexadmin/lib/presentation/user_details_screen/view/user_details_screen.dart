import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:streamnexadmin/core/constants/color_constants.dart';
import 'package:streamnexadmin/core/constants/text_styles.dart';
import '../../content_managment_screen/view/video_details_screen.dart';
import '../../content_managment_screen/view/content_managment_screen.dart';

class UserDetailsScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String userEmail;

  const UserDetailsScreen({
    Key? key,
    required this.userId,
    required this.userName,
    required this.userEmail,
  }) : super(key: key);

  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  List<Map<String, dynamic>> _userVideos = [];

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    try {
      print('🔍 Loading user details for: ${widget.userId}');
      
      // Load user data
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        _userData = userDoc.data();
      }

      // Load user's videos using uploadedBy field
      print('🔍 Searching for videos with uploadedBy: ${widget.userId}');
      
      try {
        // First, let's check what videos exist and their uploadedBy values
        final allVideosQuery = await FirebaseFirestore.instance
            .collection('videos')
            .get();
        
        print('📊 Total videos in collection: ${allVideosQuery.docs.length}');
        
        // Show all uploadedBy values to debug
        final allUploadedByValues = <String>{};
        for (var doc in allVideosQuery.docs) {
          final data = doc.data();
          if (data['uploadedBy'] != null) {
            allUploadedByValues.add(data['uploadedBy'].toString());
          }
        }
        print('🔍 All uploadedBy values in videos: $allUploadedByValues');
        print('🔍 Looking for userId: ${widget.userId}');
        
        // Now try the direct query
        final videosQuery = await FirebaseFirestore.instance
            .collection('videos')
            .where('uploadedBy', isEqualTo: widget.userId)
            .get();
        
        print('✅ Direct query found ${videosQuery.docs.length} videos');
        
        _userVideos = videosQuery.docs.map((doc) {
          final data = doc.data();
          print('📹 Found video: ${data['title'] ?? 'Untitled'} by ${data['uploadedBy']}');
          return {
            'id': doc.id,
            ...data,
          };
        }).toList();
        
      } catch (e) {
        print('❌ Error loading videos: $e');
        _userVideos = [];
      }

      print('✅ Loaded ${_userVideos.length} videos for user');

      setState(() {
        _isLoading = false;
      });

    } catch (e) {
      print('❌ Error loading user details: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Unknown';
    try {
      if (date is Timestamp) {
        final dateTime = date.toDate();
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
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
    final isTablet = screenWidth > 600;
    final padding = isTablet ? 24.0 : 16.0;

    return Scaffold(
      backgroundColor: ColorTheme.mainColor,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back_ios, color: Colors.white)),
        backgroundColor: ColorTheme.mainColor,
        title: Text(
          'User Details',
          style: TextStyles.appBarHeadding(),
        ),
        
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: ColorTheme.secondaryColor,
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Info Card
                  Card(
                    color: Colors.grey[850],
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: isTablet ? 40 : 30,
                                backgroundColor: ColorTheme.secondaryColor,
                                child: Text(
                                  widget.userName[0].toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: isTablet ? 24 : 20,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.userName,
                                      style: TextStyles.subText(
                                        size: isTablet ? 24 : 20,
                                        weight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      widget.userEmail,
                                      style: TextStyles.smallText(
                                        color: Colors.grey[400],
                                        size: isTablet ? 16 : 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          _buildInfoRow('User ID', widget.userId),
                          _buildInfoRow('Plan', _userData?['plan'] ?? 'Basic'),
                          _buildInfoRow('Status', _userData?['status'] ?? 'Active'),
                          _buildInfoRow('Joined', _formatDate(_userData?['createdAt'])),
                        
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Videos Section
                  Row(
                    children: [
                      Icon(
                        Icons.video_library,
                        color: ColorTheme.secondaryColor,
                        size: isTablet ? 28 : 24,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Uploaded Videos (${_userVideos.length})',
                          style: TextStyles.subText(
                            size: isTablet ? 22 : 20,
                            weight: FontWeight.bold,
                          ),
                        ),
                      ),
                      
                    ],
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Videos List
                  _userVideos.isEmpty
                      ? Card(
                          color: Colors.grey[850],
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.video_library_outlined,
                                  size: 60,
                                  color: Colors.grey[600],
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No Videos Uploaded',
                                  style: TextStyles.subText(
                                    color: Colors.grey[400],
                                    size: isTablet ? 18 : 16,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'This user hasn\'t uploaded any videos yet.',
                                  style: TextStyles.smallText(
                                    color: Colors.grey[500],
                                    size: isTablet ? 14 : 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _userVideos.length,
                          itemBuilder: (context, index) {
                            final video = _userVideos[index];
                            return Card(
                              color: Colors.grey[850],
                              margin: EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: Container(
                                  width: isTablet ? 80 : 60,
                                  height: isTablet ? 60 : 45,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.grey[800],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: video['thumbnailUrl'] != null
                                        ? Image.network(
                                            video['thumbnailUrl'],
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                color: ColorTheme.secondaryColor.withOpacity(0.3),
                                                child: Icon(
                                                  Icons.play_arrow,
                                                  color: ColorTheme.secondaryColor,
                                                  size: isTablet ? 24 : 20,
                                                ),
                                              );
                                            },
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return Container(
                                                color: Colors.grey[800],
                                                child: Center(
                                                  child: CircularProgressIndicator(
                                                    value: loadingProgress.expectedTotalBytes != null
                                                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                        : null,
                                                    color: ColorTheme.secondaryColor,
                                                    strokeWidth: 2,
                                                  ),
                                                ),
                                              );
                                            },
                                          )
                                        : Container(
                                            color: ColorTheme.secondaryColor.withOpacity(0.3),
                                            child: Icon(
                                              Icons.play_arrow,
                                              color: ColorTheme.secondaryColor,
                                              size: isTablet ? 24 : 20,
                                            ),
                                          ),
                                  ),
                                ),
                                title: Text(
                                  video['title'] ?? 'Untitled Video',
                                  style: TextStyles.smallText(
                                    size: isTablet ? 16 : 14,
                                    weight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (video['cast'] != null && video['cast'].isNotEmpty)
                                      Text(
                                        'Cast: ${video['cast']}',
                                        style: TextStyles.smallText(
                                          color: Colors.grey[300],
                                          size: isTablet ? 12 : 10,
                                        ),
                                      ),
                                    Text(
                                      'Uploaded: ${_formatDate(video['uploadedAt'])}',
                                      style: TextStyles.smallText(
                                        color: Colors.grey[400],
                                        size: isTablet ? 12 : 10,
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () => _playVideo(video),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isTablet ? 120 : 100,
            child: Text(
              '$label:',
              style: TextStyles.smallText(
                color: Colors.grey[400],
                size: isTablet ? 14 : 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyles.smallText(
                size: isTablet ? 14 : 12,
                weight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _playVideo(Map<String, dynamic> video) {
    try {
      // Create Content object from video data with all required positional arguments
      final content = Content(
        video['title'] ?? 'Untitled Video', // title
        video['type'] ?? 'Movie', // type
        video['genre'] ?? '', // genre
        video['year'] ?? 2024, // year
        video['rating']?.toDouble() ?? 0.0, // rating
        video['thumbnailUrl'], // posterUrl
        video['videoUrl'] ?? video['url'] ?? video['fileUrl'] ?? '', // videoUrl
        widget.userName, // uploader
        _formatDate(video['uploadedAt']), // uploadTime
        video['director'] ?? '', // director
        video['duration'] ?? '', // duration
        video['language'] ?? '', // language
        video['ratingCode'] ?? '', // ratingCode
        video['description'] ?? '', // description
        video['cast'] ?? video['starring'] ?? '', // starring
        video['tags'], // tags
        video['fileName'], // fileName
        video['views'] ?? 0, // views
        video['status'] ?? 'Active', // status
        video['userRating']?.toDouble() ?? 0.0, // userRating
        video['fileSizeGB']?.toDouble() ?? 0.0, // fileSizeGB
        video['id'] ?? '', // documentId
      );
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoDetailsScreen(content: content),
        ),
      );
    } catch (e) {
      print('❌ Error navigating to video details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening video details'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

