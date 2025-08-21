import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:streamnexadmin/core/constants/color_constants.dart';
import 'package:streamnexadmin/core/constants/text_styles.dart';
import 'package:streamnexadmin/presentation/video_details_screen/view/video_details_screen.dart';
import 'package:streamnexadmin/presentation/models/content.dart';
import 'package:streamnexadmin/presentation/content_managment_screen/controller/content_management_controller.dart';

class ContentManagementScreen extends StatelessWidget {
  ContentManagementScreen({super.key});

  final ContentManagementController controller = ContentManagementController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final padding = isTablet ? 24.0 : 16.0;
    final spacing = isTablet ? 20.0 : 16.0;

    controller.ensureInitialized();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: ColorTheme.mainColor,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: ColorTheme.mainColor,
          title: Text(
            'Content Management',
            style: TextStyles.appBarHeadding(),
          ),
          automaticallyImplyLeading: false,
          
          bottom: TabBar(
            indicatorColor: ColorTheme.secondaryColor,
            labelColor: ColorTheme.secondaryColor,
            unselectedLabelColor: Colors.grey[400],
            labelStyle: GoogleFonts.montserrat(
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(icon: Icon(Icons.admin_panel_settings), text: 'Admin Videos'),
              Tab(icon: Icon(Icons.people), text: 'User Videos'),
            ],
          ),
        ),
        body: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            return TabBarView(
              children: [
                _buildTabContent(context, controller.adminVideos, 'Admin', isTablet, padding, spacing, controller),
                _buildTabContent(context, controller.userVideos, 'User', isTablet, padding, spacing, controller),
              ],
            );
          },
        ),
      ),
    );
  }

    Widget _buildTabContent(
    BuildContext context,
    List<Content> videos,
    String uploaderType,
    bool isTablet,
    double padding,
    double spacing,
    ContentManagementController controller,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 360;
    
    if (controller.isLoading && uploaderType == 'Admin') {
      return Center(
        child: CircularProgressIndicator(color: ColorTheme.secondaryColor),
      );
    }

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        children: [
          // Search Bar - Always visible
          Row(
            children: [
              Expanded(
                child: TextField(
                  style: TextStyle(color: Colors.white),
                  onChanged: (value) {
                    if (uploaderType == 'Admin') {
                      controller.updateAdminSearchQuery(value);
                    } else {
                      controller.updateUserSearchQuery(value);
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Search ${uploaderType.toLowerCase()} videos...',
                    hintStyle: GoogleFonts.montserrat(color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                    suffixIcon: (uploaderType == 'Admin' ? controller.adminSearchQuery : controller.userSearchQuery).isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey[400]),
                            onPressed: () {
                              if (uploaderType == 'Admin') {
                                controller.updateAdminSearchQuery('');
                              } else {
                                controller.updateUserSearchQuery('');
                              }
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
            child: videos.isEmpty
                ? _buildEmptyState(uploaderType, isTablet, controller)
                : ListView.builder(
                    itemCount: videos.length,
                    itemBuilder: (context, index) {
                      final content = videos[index];
                      return Card(
                        color: Colors.grey[850],
                        margin: EdgeInsets.only(bottom: isTablet ? 12 : 8),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VideoDetailsScreen(content: content),
                              ),
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.all(isTablet ? 12 : (isCompact ? 6 : 8)),
                            child: Row(
                              children: [
                                // Thumbnail
                                Container(
                                  width: isTablet ? 60 : (isCompact ? 45 : 50),
                                  height: isTablet ? 90 : (isCompact ? 68 : 75),
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
                                    child: (content.posterUrl ?? '').startsWith('http')
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
                                                  size: isTablet ? 24 : 20,
                                                ),
                                              );
                                            },
                                          )
                                        : Container(
                                            color: Colors.grey[700],
                                            child: Icon(
                                              Icons.video_file,
                                              color: ColorTheme.secondaryColor,
                                              size: isTablet ? 24 : 20,
                                            ),
                                          ),
                                  ),
                                ),
                                SizedBox(width: isTablet ? 12 : (isCompact ? 6 : 8)),
                                // Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        content.title,
                                        style: TextStyles.smallText(size: isTablet ? 14 : (isCompact ? 12 : 13)),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '${content.type} • ${content.genre} • ${content.year}'
                                        '${content.rating > 0 ? '  ★ ${content.rating}' : ''}',
                                        style: TextStyles.smallText(color: Colors.grey[400], size: isTablet ? 10 : (isCompact ? 9 : 10)),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                // Menu
                                PopupMenuButton(
                                  icon: Icon(
                                    Icons.more_vert,
                                    color: Colors.white,
                                    size: isTablet ? 24 : (isCompact ? 18 : 20),
                                  ),
                                  color: Colors.grey[850],
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Edit', style: TextStyles.smallText(color: Colors.green, size: isTablet ? 16 : 14)),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Delete', style: TextStyles.smallText(color: ColorTheme.secondaryColor, size: isTablet ? 16 : 14)),
                                    ),
                                  ],
                                  onSelected: (value) async {
                                    if (value == 'delete') {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          backgroundColor: Colors.grey[900],
                                          title: Text('Delete Video', style: TextStyle(color: Colors.white)),
                                          content: Text('Are you sure you want to delete "${content.title}"?', style: TextStyle(color: Colors.white70)),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('Cancel', style: TextStyle(color: Colors.white70))),
                                            ElevatedButton(
                                              onPressed: () => Navigator.of(context).pop(true),
                                              style: ElevatedButton.styleFrom(backgroundColor: ColorTheme.secondaryColor),
                                              child: Text('Delete', style: TextStyle(color: Colors.white)),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        await controller.deleteVideo(content.documentId, uploaderType);
                                      }
                                    } else if (value == 'view') {
                                      _showVideoDetails(context, content, isTablet);
                                    }
                                  },
                                ),
                              ],
                            ),
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

  Widget _buildEmptyState(String uploaderType, bool isTablet, ContentManagementController controller) {
    final hasSearchQuery = (uploaderType == 'Admin' ? controller.adminSearchQuery : controller.userSearchQuery).isNotEmpty;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasSearchQuery ? Icons.search_off : Icons.video_library_outlined, 
            size: 80, 
            color: Colors.grey[600]
          ),
          SizedBox(height: 16),
          Text(
            hasSearchQuery 
                ? 'No videos found for "${uploaderType == 'Admin' ? controller.adminSearchQuery : controller.userSearchQuery}"'
                : 'No ${uploaderType.toLowerCase()} videos found',
            style: TextStyles.subText(color: Colors.grey[400], size: isTablet ? 20 : 18),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            hasSearchQuery
                ? 'Try adjusting your search terms'
                : (uploaderType == 'Admin'
                    ? 'Upload videos using the "Add Movie" feature'
                    : 'No user videos uploaded yet'),
            style: TextStyles.smallText(color: Colors.grey[500], size: isTablet ? 14 : 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showVideoDetails(BuildContext context, Content content, bool isTablet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Close', style: TextStyle(color: Colors.white70))),
        ],
      ),
    );
  }
}


