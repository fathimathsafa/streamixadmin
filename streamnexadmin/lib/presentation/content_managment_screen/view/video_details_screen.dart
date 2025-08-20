import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:streamnexadmin/core/constants/color_constants.dart';
import 'package:streamnexadmin/core/constants/text_styles.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:streamnexadmin/presentation/content_managment_screen/view/content_managment_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:chewie/src/material/material_controls.dart';

class VideoDetailsScreen extends StatefulWidget {
  final Content content;

  const VideoDetailsScreen({Key? key, required this.content}) : super(key: key);

  @override
  State<VideoDetailsScreen> createState() => _VideoDetailsScreenState();
}

class _VideoDetailsScreenState extends State<VideoDetailsScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  String? _resolvedFileSize;
  

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
    _loadActualFileSize();
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      if (widget.content.videoUrl != null && widget.content.videoUrl!.isNotEmpty) {
        _videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(widget.content.videoUrl!),
        );
        await _videoPlayerController!.initialize();
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController!,
          autoPlay: false,
          looping: false,
          allowFullScreen: true,
          allowMuting: true,
          showOptions: false,
          allowPlaybackSpeedChanging: false,
          showControlsOnInitialize: true,

          materialProgressColors: ChewieProgressColors(
            playedColor: ColorTheme.secondaryColor,
            handleColor: ColorTheme.secondaryColor,
            backgroundColor: Colors.grey[600]!,
            bufferedColor: Colors.grey[400]!,
          ),
          errorBuilder: (context, errorMessage) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                  SizedBox(height: 12),
                  Text('Error loading video', style: GoogleFonts.montserrat(color: Colors.white)),
                  SizedBox(height: 6),
                  Text(errorMessage, style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 12), textAlign: TextAlign.center),
                ],
              ),
            );
          },
        );
        setState(() {});
      }
    } catch (e) {
      print('Error initializing video player: $e');
    }
  }

  Future<void> _loadActualFileSize() async {
    try {
      final url = widget.content.videoUrl;
      if (url != null && url.isNotEmpty) {
        final ref = FirebaseStorage.instance.refFromURL(url);
        final metadata = await ref.getMetadata();
        final bytes = metadata.size;
        if (bytes != null) {
          setState(() {
            _resolvedFileSize = _formatBytes(bytes);
          });
        }
      }
    } catch (e) {
      // Ignore and rely on fallback fileSizeGB
    }
  }

  String _formatBytes(int bytes) {
    const int kb = 1024;
    const int mb = 1024 * 1024;
    const int gb = 1024 * 1024 * 1024;
    if (bytes >= gb) {
      return '${(bytes / gb).toStringAsFixed(1)} GB';
    } else if (bytes >= mb) {
      return '${(bytes / mb).toStringAsFixed(1)} MB';
    } else if (bytes >= kb) {
      return '${(bytes / kb).toStringAsFixed(1)} KB';
    }
    return '$bytes B';
  }

  String _getFileSizeText() {
    if (_resolvedFileSize != null && _resolvedFileSize!.isNotEmpty) {
      return _resolvedFileSize!;
    }
    if ((widget.content.videoUrl != null && widget.content.videoUrl!.isNotEmpty)) {
      return 'Calculating...';
    }
    if (widget.content.fileSizeGB > 0) {
      return '${widget.content.fileSizeGB.toStringAsFixed(1)} GB';
    }
    return 'Unknown';
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final padding = isTablet ? 24.0 : 16.0;
    final spacing = isTablet ? 20.0 : 16.0;

    return Scaffold(
      backgroundColor: ColorTheme.mainColor,
      appBar: AppBar(
        backgroundColor: ColorTheme.mainColor,
        centerTitle: true,
        title: Text(
          'Movie Details',
          style: TextStyles.appBarHeadding(),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Player Section (no thumbnail)
            Padding(
              padding: EdgeInsets.all(padding),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    color: Colors.black,
                    child: (widget.content.videoUrl != null && widget.content.videoUrl!.isNotEmpty)
                        ? AspectRatio(
                            aspectRatio: 16 / 9,
                            child: (_chewieController != null && _videoPlayerController != null && _videoPlayerController!.value.isInitialized)
                                ? Theme(
                                    data: Theme.of(context).copyWith(
                                      iconTheme: Theme.of(context).iconTheme.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                    child: Chewie(controller: _chewieController!),
                                  )
                                : Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircularProgressIndicator(color: ColorTheme.secondaryColor),
                                        SizedBox(height: 12),
                                        Text('Loading video...', style: GoogleFonts.montserrat(color: Colors.white70)),
                                      ],
                                    ),
                                  ),
                          )
                        : Container(
                            height: 200,
                            alignment: Alignment.center,
                            child: Text(
                              'No video available',
                              style: GoogleFonts.montserrat(color: Colors.white70),
                            ),
                          ),
                  ),
                ),
              ),
            ),

            // Movie Information Section
            Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Rating Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.content.title,
                              style: TextStyles.subText(
                                size: isTablet ? 28 : 24,
                                weight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '${widget.content.type} • ${widget.content.genre} • ${widget.content.year}',
                              style: TextStyles.smallText(
                                color: Colors.grey[400],
                                size: isTablet ? 16 : 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.content.rating > 0) ...[
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.amber),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: isTablet ? 20 : 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                widget.content.rating.toString(),
                                style: GoogleFonts.montserrat(
                                  color: Colors.amber,
                                  fontSize: isTablet ? 16 : 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: spacing),

                  // Basic Info (no thumbnail)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.content.director.isNotEmpty) ...[
                        _buildInfoRow('Director', widget.content.director, Icons.person),
                        SizedBox(height: 8),
                      ],
                      if (widget.content.duration.isNotEmpty) ...[
                        _buildInfoRow('Duration', widget.content.duration, Icons.access_time),
                        SizedBox(height: 8),
                      ],
                      if (widget.content.language.isNotEmpty) ...[
                        _buildInfoRow('Language', widget.content.language, Icons.language),
                        SizedBox(height: 8),
                      ],
                      if (widget.content.ratingCode.isNotEmpty) ...[
                        _buildInfoRow('Content Rating', widget.content.ratingCode, Icons.verified),
                        SizedBox(height: 8),
                      ],
                      _buildInfoRow('File Size', _getFileSizeText(), Icons.storage),
                      SizedBox(height: 8),
                      _buildInfoRow('Uploaded by', widget.content.uploader, Icons.person_outline),
                      SizedBox(height: 8),
                      _buildInfoRow('Upload time', widget.content.uploadTime, Icons.schedule),
                    ],
                  ),
                  SizedBox(height: spacing * 1.5),

                  // Description
                  if (widget.content.description.isNotEmpty) ...[
                    Text(
                      'Description',
                      style: TextStyles.subText(
                        size: isTablet ? 20 : 18,
                        weight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(spacing),
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.content.description,
                        style: TextStyles.smallText(
                          color: Colors.white,
                          size: isTablet ? 16 : 14,
                        ),
                      ),
                    ),
                    SizedBox(height: spacing),
                  ],

                  // Cast
                  if (widget.content.starring.isNotEmpty) ...[
                    Text(
                      'Cast',
                      style: TextStyles.subText(
                        size: isTablet ? 20 : 18,
                        weight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(spacing),
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.content.starring,
                        style: TextStyles.smallText(
                          color: Colors.white,
                          size: isTablet ? 16 : 14,
                        ),
                      ),
                    ),
                    SizedBox(height: spacing),
                  ],

                  // Tags
                  if (widget.content.genre.isNotEmpty) ...[
                    Text(
                      'Tags',
                      style: TextStyles.subText(
                        size: isTablet ? 20 : 18,
                        weight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildTagChip(widget.content.genre),
                        _buildTagChip(widget.content.type),
                        if (widget.content.year > 0) _buildTagChip(widget.content.year.toString()),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    
    return Row(
      children: [
        Icon(
          icon,
          color: ColorTheme.secondaryColor,
          size: isTablet ? 20 : 16,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyles.smallText(
                  color: Colors.grey[400],
                  size: isTablet ? 12 : 10,
                ),
              ),
              Text(
                value,
                style: TextStyles.smallText(
                  color: Colors.white,
                  size: isTablet ? 14 : 12,
                  weight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTagChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: ColorTheme.secondaryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorTheme.secondaryColor),
      ),
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          color: ColorTheme.secondaryColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}




