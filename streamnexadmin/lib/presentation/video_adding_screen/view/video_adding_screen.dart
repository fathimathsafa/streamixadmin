import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:streamnexadmin/core/constants/color_constants.dart';
import 'package:streamnexadmin/core/constants/text_styles.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddVideoScreen extends StatefulWidget {
  const AddVideoScreen({super.key});

  @override
  State<AddVideoScreen> createState() => _AddVideoScreenState();
}

class _AddVideoScreenState extends State<AddVideoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _starringController = TextEditingController();
  final _durationController = TextEditingController();
  final _languageController = TextEditingController();
  final _directorController = TextEditingController();
  final _ratingController = TextEditingController();
  final _fileSizeController = TextEditingController();
  
  String? _selectedCategory;
  DateTime? _selectedReleaseDate;
  bool _isUploading = false;
  PlatformFile? _selectedVideo;
  File? _selectedThumbnail;
  double _uploadProgress = 0.0;
  String _uploadStatus = '';

  final List<String> _categories = [
    'Action',
    'Adventure',
    'Animation',
    'Comedy',
    'Crime',
    'Documentary',
    'Drama',
    'Family',
    'Fantasy',
    'Horror',
    'Mystery',
    'Romance',
    'Sci-Fi',
    'Thriller',
    'War',
    'Western',
    'Other'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _starringController.dispose();
    _durationController.dispose();
    _languageController.dispose();
    _directorController.dispose();
    _ratingController.dispose();
    _fileSizeController.dispose();
    super.dispose();
  }

  Future<void> _selectThumbnail() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedThumbnail = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting thumbnail: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectReleaseDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedReleaseDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: ColorTheme.secondaryColor,
              onPrimary: Colors.white,
              surface: Colors.grey[900]!,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedReleaseDate) {
      setState(() {
        _selectedReleaseDate = picked;
      });
    }
  }

  Future<void> _selectVideo() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          _selectedVideo = result.files.first;
          _uploadStatus = 'Video selected: ${_selectedVideo!.name}';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting video: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _uploadVideo() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedVideo == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select a video first'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
        _uploadStatus = 'Starting upload...';
      });

      try {
        // Check file size (limit to 2GB for movies)
        final fileSizeMB = _selectedVideo!.size / (1024 * 1024);
        final fileSizeGB = fileSizeMB / 1024;
        
        if (fileSizeGB > 2) {
          throw Exception('Video file too large. Please select a file smaller than 2GB.');
        }

        // Show file size info
        setState(() {
          _uploadStatus = 'Preparing upload... (${fileSizeGB.toStringAsFixed(1)} GB)';
        });

        // Upload video to Firebase Storage with extended timeout for large files
        final videoFile = File(_selectedVideo!.path!);
        final videoName = '${DateTime.now().millisecondsSinceEpoch}_${_selectedVideo!.name}';
        final videoRef = FirebaseStorage.instance.ref().child('videos/$videoName');
        
        setState(() {
          _uploadStatus = 'Uploading video... (${fileSizeGB.toStringAsFixed(1)} GB)';
        });

        // Upload with extended timeout for large files
        final uploadTask = videoRef.putFile(videoFile);
        
        // Track upload progress with more detailed status
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          final uploadedMB = snapshot.bytesTransferred / (1024 * 1024);
          final totalMB = snapshot.totalBytes / (1024 * 1024);
          
          setState(() {
            _uploadProgress = progress;
            _uploadStatus = 'Uploading... ${(progress * 100).toStringAsFixed(1)}% (${uploadedMB.toStringAsFixed(1)} MB / ${totalMB.toStringAsFixed(1)} MB)';
          });
        });

        // Wait for upload with extended timeout for large files
        final snapshot = await uploadTask.timeout(
          Duration(minutes: 60), // 60 minute timeout for large files
          onTimeout: () {
            throw Exception('Upload timeout. Large files may take longer. Please try again.');
          },
        );

        final videoUrl = await snapshot.ref.getDownloadURL();

        // Upload thumbnail if selected
        String? thumbnailUrl;
        if (_selectedThumbnail != null) {
          setState(() {
            _uploadStatus = 'Uploading thumbnail...';
          });

          final thumbnailName = '${DateTime.now().millisecondsSinceEpoch}_thumbnail.jpg';
          final thumbnailRef = FirebaseStorage.instance.ref().child('thumbnails/$thumbnailName');
          final thumbnailSnapshot = await thumbnailRef.putFile(_selectedThumbnail!);
          thumbnailUrl = await thumbnailSnapshot.ref.getDownloadURL();
        }

        setState(() {
          _uploadStatus = 'Saving video details...';
        });

        // Save video details to Firestore with error handling
        try {
          final videoData = {
            'title': _titleController.text.trim(),
            'description': _descriptionController.text.trim(),
            'category': _selectedCategory,
            'starring': _starringController.text.trim(),
            'director': _directorController.text.trim(),
            'duration': _durationController.text.trim(),
            'language': _languageController.text.trim(),
            'rating': double.tryParse(_ratingController.text.trim()) ?? 0.0,
            'releaseDate': _selectedReleaseDate?.toIso8601String(),
            'tags': _categoryController.text.trim(),
            'fileSize': _fileSizeController.text.trim(),
            'videoUrl': videoUrl,
            'thumbnailUrl': thumbnailUrl,
            'fileName': _selectedVideo!.name,
            'fileSize': _selectedVideo!.size,
            'fileSizeMB': fileSizeMB,
            'fileSizeGB': fileSizeGB,
            'uploadedBy': 'admin',
            'uploadedAt': FieldValue.serverTimestamp(),
            'status': 'active',
            'views': 0,
            'userRating': 0.0,
          };
          
          // Save to admin videos collection
          await FirebaseFirestore.instance.collection('admin_videos').add(videoData);

          setState(() {
            _isUploading = false;
            _uploadProgress = 0.0;
            _uploadStatus = '';
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Movie uploaded successfully! (${fileSizeGB.toStringAsFixed(1)} GB)'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 4),
            ),
          );

          // Clear form
          _clearForm();

        } catch (firestoreError) {
          // Video uploaded but Firestore save failed
          setState(() {
            _isUploading = false;
            _uploadProgress = 0.0;
            _uploadStatus = '';
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.warning, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Video uploaded but details not saved. Please check Firebase permissions.',
                      style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 6),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );

          // Show the video URL so admin can manually save details
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Colors.grey[900],
                title: Text('Video Uploaded Successfully', style: TextStyle(color: Colors.white)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Video uploaded to Firebase Storage but details could not be saved to database.',
                      style: TextStyle(color: Colors.white70),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Video URL:',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: SelectableText(
                        videoUrl,
                        style: TextStyle(color: Colors.blue[300], fontSize: 12),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Please check your Firebase Firestore security rules.',
                      style: TextStyle(color: Colors.orange[300], fontSize: 12),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _clearForm();
                    },
                    child: Text('OK', style: TextStyle(color: Colors.white70)),
                  ),
                ],
              );
            },
          );
        }

      } catch (e) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
          _uploadStatus = '';
        });

        String errorMessage = 'Upload failed. Please try again.';
        
        if (e.toString().contains('timeout')) {
          errorMessage = 'Upload timeout. Large movies may take longer. Please try again.';
        } else if (e.toString().contains('too large')) {
          errorMessage = 'Video file too large. Please select a file smaller than 2GB.';
        } else if (e.toString().contains('network')) {
          errorMessage = 'Network error. Please check your internet connection.';
        } else if (e.toString().contains('permission')) {
          errorMessage = 'Permission denied. Please check Firebase configuration.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _categoryController.clear();
    _starringController.clear();
    _durationController.clear();
    _languageController.clear();
    _directorController.clear();
    _ratingController.clear();
    _fileSizeController.clear();
    setState(() {
      _selectedCategory = null;
      _selectedReleaseDate = null;
      _selectedVideo = null;
      _selectedThumbnail = null;
    });
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
          'Add Movie',
          style: TextStyles.appBarHeadding(),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail Upload Section
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: EdgeInsets.all(spacing),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Movie Thumbnail',
                        style: TextStyles.subText(
                          size: isTablet ? 20 : 18,
                          weight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: spacing),
                      Container(
                        width: double.infinity,
                        height: isTablet ? 200 : 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[700]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: InkWell(
                          onTap: _isUploading ? null : _selectThumbnail,
                          child: _selectedThumbnail != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _selectedThumbnail!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_outlined,
                                      size: isTablet ? 60 : 48,
                                      color: Colors.grey[400],
                                    ),
                                    SizedBox(height: spacing / 2),
                                    Text(
                                      'Tap to select thumbnail',
                                      style: GoogleFonts.montserrat(
                                        fontSize: isTablet ? 16 : 14,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'JPG, PNG up to 2MB',
                                      style: GoogleFonts.montserrat(
                                        fontSize: isTablet ? 12 : 10,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      if (_selectedThumbnail != null && !_isUploading) ...[
                        SizedBox(height: spacing / 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _selectedThumbnail = null;
                                });
                              },
                              icon: Icon(Icons.clear, size: isTablet ? 20 : 16),
                              label: Text(
                                'Clear Thumbnail',
                                style: GoogleFonts.montserrat(fontSize: isTablet ? 14 : 12),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[700],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: spacing),

              // Video Upload Section
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: EdgeInsets.all(spacing),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upload Movie',
                        style: TextStyles.subText(
                          size: isTablet ? 20 : 18,
                          weight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: spacing),
                      Container(
                        width: double.infinity,
                        height: isTablet ? 250 : 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[700]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: InkWell(
                          onTap: _isUploading ? null : _selectVideo,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_selectedVideo != null) ...[
                                Icon(
                                  Icons.video_file,
                                  size: isTablet ? 60 : 48,
                                  color: ColorTheme.secondaryColor,
                                ),
                                SizedBox(height: spacing / 2),
                                Text(
                                  _selectedVideo!.name,
                                  style: GoogleFonts.montserrat(
                                    fontSize: isTablet ? 16 : 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '${(_selectedVideo!.size / (1024 * 1024)).toStringAsFixed(1)} MB',
                                  style: GoogleFonts.montserrat(
                                    fontSize: isTablet ? 14 : 12,
                                    color: Colors.grey[400],
                                  ),
                                ),
                                if (_isUploading) ...[
                                  SizedBox(height: spacing / 2),
                                  LinearProgressIndicator(
                                    value: _uploadProgress,
                                    backgroundColor: Colors.grey[700],
                                    valueColor: AlwaysStoppedAnimation<Color>(ColorTheme.secondaryColor),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    _uploadStatus,
                                    style: GoogleFonts.montserrat(
                                      fontSize: isTablet ? 12 : 10,
                                      color: Colors.grey[400],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ] else ...[
                                Icon(
                                  Icons.cloud_upload_outlined,
                                  size: isTablet ? 80 : 64,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: spacing),
                                Text(
                                  'Tap to select movie file',
                                  style: GoogleFonts.montserrat(
                                    fontSize: isTablet ? 18 : 16,
                                    color: Colors.grey[400],
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'MP4, AVI, MOV up to 2GB',
                                  style: GoogleFonts.montserrat(
                                    fontSize: isTablet ? 14 : 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      if (_selectedVideo != null && !_isUploading) ...[
                        SizedBox(height: spacing / 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _selectedVideo = null;
                                  _uploadStatus = '';
                                });
                              },
                              icon: Icon(Icons.clear, size: isTablet ? 20 : 16),
                              label: Text(
                                'Clear Selection',
                                style: GoogleFonts.montserrat(fontSize: isTablet ? 14 : 12),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[700],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: spacing),

              // Movie Details Section
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: EdgeInsets.all(spacing),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Movie Details',
                        style: TextStyles.subText(
                          size: isTablet ? 20 : 18,
                          weight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: spacing),
                      
                      // Title Field
                      TextFormField(
                        controller: _titleController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Movie Title',
                          labelStyle: GoogleFonts.montserrat(color: Colors.grey[400]),
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
                          prefixIcon: Icon(Icons.title, color: Colors.grey[400]),
                          fillColor: Colors.grey[800],
                          filled: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: spacing),

                      // Description Field
                      TextFormField(
                        controller: _descriptionController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Description',
                          labelStyle: GoogleFonts.montserrat(color: Colors.grey[400]),
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
                          prefixIcon: Icon(Icons.description, color: Colors.grey[400]),
                          fillColor: Colors.grey[800],
                          filled: true,
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: spacing),

                      // Category Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Category',
                          labelStyle: GoogleFonts.montserrat(color: Colors.grey[400]),
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
                          prefixIcon: Icon(Icons.category, color: Colors.grey[400]),
                          fillColor: Colors.grey[800],
                          filled: true,
                        ),
                        dropdownColor: Colors.grey[850],
                        items: _categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category, style: TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a category';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: spacing),

                      // Director Field
                      TextFormField(
                        controller: _directorController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Director',
                          labelStyle: GoogleFonts.montserrat(color: Colors.grey[400]),
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
                          prefixIcon: Icon(Icons.person, color: Colors.grey[400]),
                          fillColor: Colors.grey[800],
                          filled: true,
                        ),
                      ),
                      SizedBox(height: spacing),

                      // Starring Field
                      TextFormField(
                        controller: _starringController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Cast (comma separated)",
                          labelStyle: GoogleFonts.montserrat(color: Colors.grey[400]),
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
                          prefixIcon: Icon(Icons.people, color: Colors.grey[400]),
                          fillColor: Colors.grey[800],
                          filled: true,
                        ),
                      ),
                      SizedBox(height: spacing),

                      // Duration Field
                      TextFormField(
                        controller: _durationController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Duration (e.g., 2h 30m)',
                          labelStyle: GoogleFonts.montserrat(color: Colors.grey[400]),
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
                          prefixIcon: Icon(Icons.access_time, color: Colors.grey[400]),
                          fillColor: Colors.grey[800],
                          filled: true,
                        ),
                      ),
                      SizedBox(height: spacing),

                      // Language Field
                      TextFormField(
                        controller: _languageController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Language',
                          labelStyle: GoogleFonts.montserrat(color: Colors.grey[400]),
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
                          prefixIcon: Icon(Icons.language, color: Colors.grey[400]),
                          fillColor: Colors.grey[800],
                          filled: true,
                        ),
                      ),
                      SizedBox(height: spacing),

                      // Rating Field (Numeric)
                      TextFormField(
                        controller: _ratingController,
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Rating (1-10)',
                          labelStyle: GoogleFonts.montserrat(color: Colors.grey[400]),
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
                          prefixIcon: Icon(Icons.star, color: Colors.grey[400]),
                          fillColor: Colors.grey[800],
                          filled: true,
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final rating = double.tryParse(value);
                            if (rating == null || rating < 1 || rating > 10) {
                              return 'Please enter a rating between 1 and 10';
                            }
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: spacing),

                      // Release Date Field
                      InkWell(
                        onTap: _selectReleaseDate,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[700]!),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[800],
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, color: Colors.grey[400]),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _selectedReleaseDate != null
                                      ? 'Release Date: ${_selectedReleaseDate!.day}/${_selectedReleaseDate!.month}/${_selectedReleaseDate!.year}'
                                      : 'Select Release Date',
                                  style: GoogleFonts.montserrat(
                                    color: _selectedReleaseDate != null ? Colors.white : Colors.grey[400],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: spacing),

                      // File Size Field
                      TextFormField(
                        controller: _fileSizeController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'File Size (e.g., 1.5 GB)',
                          labelStyle: GoogleFonts.montserrat(color: Colors.grey[400]),
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
                          prefixIcon: Icon(Icons.storage, color: Colors.grey[400]),
                          fillColor: Colors.grey[800],
                          filled: true,
                        ),
                      ),
                      SizedBox(height: spacing),

                      // Tags Field
                      TextFormField(
                        controller: _categoryController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Tags (comma separated)',
                          labelStyle: GoogleFonts.montserrat(color: Colors.grey[400]),
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
                          prefixIcon: Icon(Icons.tag, color: Colors.grey[400]),
                          fillColor: Colors.grey[800],
                          filled: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: spacing),

              // Upload Button
              SizedBox(
                width: double.infinity,
                height: isTablet ? 60 : 50,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _uploadVideo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorTheme.secondaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isUploading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Uploading...',
                              style: GoogleFonts.montserrat(fontSize: isTablet ? 18 : 16),
                            ),
                          ],
                        )
                      : Text(
                          'Upload Movie',
                          style: GoogleFonts.montserrat(fontSize: isTablet ? 18 : 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 