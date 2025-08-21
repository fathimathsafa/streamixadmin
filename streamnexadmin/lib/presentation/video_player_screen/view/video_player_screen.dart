// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
// import 'package:chewie/chewie.dart';
// import 'package:streamnexadmin/core/constants/color_constants.dart';
// import 'package:streamnexadmin/core/constants/text_styles.dart';

// class VideoPlayerScreen extends StatefulWidget {
//   final String videoUrl;
//   final String title;

//   const VideoPlayerScreen({
//     Key? key,
//     required this.videoUrl,
//     required this.title,
//   }) : super(key: key);

//   @override
//   _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
// }

// class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
//   VideoPlayerController? _videoPlayerController;
//   ChewieController? _chewieController;
//   bool _isLoading = true;
//   String? _error;

//   @override
//   void initState() {
//     super.initState();
//     _initializePlayer();
//   }

//   Future<void> _initializePlayer() async {
//     try {
//       print('🎥 Initializing video player with URL: ${widget.videoUrl}');
      
//       _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      
//       await _videoPlayerController!.initialize();
      
//       _chewieController = ChewieController(
//         videoPlayerController: _videoPlayerController!,
//         autoPlay: true,
//         looping: false,
//         aspectRatio: _videoPlayerController!.value.aspectRatio,
//         allowFullScreen: true,
//         allowMuting: true,
//         showControls: true,
//         materialProgressColors: ChewieProgressColors(
//           playedColor: ColorTheme.secondaryColor,
//           handleColor: ColorTheme.secondaryColor,
//           backgroundColor: Colors.grey[600]!,
//           bufferedColor: Colors.grey[400]!,
//         ),
//       );
      
//       setState(() {
//         _isLoading = false;
//       });
      
//     } catch (e) {
//       print('❌ Error initializing video player: $e');
//       setState(() {
//         _isLoading = false;
//         _error = 'Failed to load video: ${e.toString()}';
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _chewieController?.dispose();
//     _videoPlayerController?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         title: Text(
//           widget.title,
//           style: TextStyles.appBarHeadding(),
//         ),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Center(
//         child: _isLoading
//             ? CircularProgressIndicator(
//                 color: ColorTheme.secondaryColor,
//               )
//             : _error != null
//                 ? Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.error_outline,
//                         size: 64,
//                         color: Colors.red,
//                       ),
//                       SizedBox(height: 16),
//                       Text(
//                         'Error Loading Video',
//                         style: TextStyles.subText(
//                           color: Colors.white,
//                           size: 18,
//                         ),
//                       ),
//                       SizedBox(height: 8),
//                       Text(
//                         _error!,
//                         style: TextStyles.smallText(
//                           color: Colors.grey[400],
//                           size: 14,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                       SizedBox(height: 16),
//                       ElevatedButton(
//                         onPressed: () {
//                           setState(() {
//                             _isLoading = true;
//                             _error = null;
//                           });
//                           _initializePlayer();
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: ColorTheme.secondaryColor,
//                         ),
//                         child: Text(
//                           'Retry',
//                           style: TextStyle(color: Colors.white),
//                         ),
//                       ),
//                     ],
//                   )
//                 : _chewieController != null
//                     ? Chewie(controller: _chewieController!)
//                     : Text(
//                         'Video player not available',
//                         style: TextStyles.smallText(color: Colors.white),
//                       ),
//       ),
//     );
//   }
// }
