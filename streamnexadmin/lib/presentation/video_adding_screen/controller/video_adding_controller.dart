import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class VideoAddingController extends ChangeNotifier {
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

  // Getters
  GlobalKey<FormState> get formKey => _formKey;
  TextEditingController get titleController => _titleController;
  TextEditingController get descriptionController => _descriptionController;
  TextEditingController get categoryController => _categoryController;
  TextEditingController get starringController => _starringController;
  TextEditingController get durationController => _durationController;
  TextEditingController get languageController => _languageController;
  TextEditingController get directorController => _directorController;
  TextEditingController get ratingController => _ratingController;
  TextEditingController get fileSizeController => _fileSizeController;

  String? _selectedCategory;
  DateTime? _selectedReleaseDate;
  bool _isUploading = false;
  PlatformFile? _selectedVideo;
  File? _selectedThumbnail;
  double _uploadProgress = 0.0;
  String _uploadStatus = '';

  String? get selectedCategory => _selectedCategory;
  DateTime? get selectedReleaseDate => _selectedReleaseDate;
  bool get isUploading => _isUploading;
  PlatformFile? get selectedVideo => _selectedVideo;
  File? get selectedThumbnail => _selectedThumbnail;
  double get uploadProgress => _uploadProgress;
  String get uploadStatus => _uploadStatus;

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

  List<String> get categories => _categories;

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

  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSelectedReleaseDate(DateTime? date) {
    _selectedReleaseDate = date;
    notifyListeners();
  }

  void setSelectedVideo(PlatformFile? video) {
    _selectedVideo = video;
    if (video != null) {
      _uploadStatus = 'Video selected: ${video.name}';
    } else {
      _uploadStatus = '';
    }
    notifyListeners();
  }

  void setSelectedThumbnail(File? thumbnail) {
    _selectedThumbnail = thumbnail;
    notifyListeners();
  }

  void setUploadProgress(double progress) {
    _uploadProgress = progress;
    notifyListeners();
  }

  void setUploadStatus(String status) {
    _uploadStatus = status;
    notifyListeners();
  }

  void setUploading(bool uploading) {
    _isUploading = uploading;
    if (!uploading) {
      _uploadProgress = 0.0;
      _uploadStatus = '';
    }
    notifyListeners();
  }

  Future<void> selectThumbnail() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 85,
      );

      if (image != null) {
        setSelectedThumbnail(File(image.path));
      }
    } catch (e) {
      throw Exception('Error selecting thumbnail: $e');
    }
  }

  Future<void> selectVideo() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result != null) {
        setSelectedVideo(result.files.first);
      }
    } catch (e) {
      throw Exception('Error selecting video: $e');
    }
  }

  Future<void> uploadVideo() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      throw Exception('Please fill all required fields');
    }

    if (_selectedVideo == null) {
      throw Exception('Please select a video first');
    }

    setUploading(true);
    setUploadProgress(0.0);
    setUploadStatus('Starting upload...');

    try {
      // Check file size (limit to 2GB for movies)
      final fileSizeMB = _selectedVideo!.size / (1024 * 1024);
      final fileSizeGB = fileSizeMB / 1024;
      
      if (fileSizeGB > 2) {
        throw Exception('Video file too large. Please select a file smaller than 2GB.');
      }

      // Show file size info
      setUploadStatus('Preparing upload... (${fileSizeGB.toStringAsFixed(1)} GB)');

      // Upload video to Firebase Storage with extended timeout for large files
      final videoFile = File(_selectedVideo!.path!);
      final videoName = '${DateTime.now().millisecondsSinceEpoch}_${_selectedVideo!.name}';
      final videoRef = FirebaseStorage.instance.ref().child('videos/$videoName');
      
      setUploadStatus('Uploading video... (${fileSizeGB.toStringAsFixed(1)} GB)');

      // Upload with extended timeout for large files
      final uploadTask = videoRef.putFile(videoFile);
      
      // Track upload progress with more detailed status
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        final uploadedMB = snapshot.bytesTransferred / (1024 * 1024);
        final totalMB = snapshot.totalBytes / (1024 * 1024);
        
        setUploadProgress(progress);
        setUploadStatus('Uploading... ${(progress * 100).toStringAsFixed(1)}% (${uploadedMB.toStringAsFixed(1)} MB / ${totalMB.toStringAsFixed(1)} MB)');
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
        setUploadStatus('Uploading thumbnail...');

        final thumbnailName = '${DateTime.now().millisecondsSinceEpoch}_thumbnail.jpg';
        final thumbnailRef = FirebaseStorage.instance.ref().child('thumbnails/$thumbnailName');
        final thumbnailSnapshot = await thumbnailRef.putFile(_selectedThumbnail!);
        thumbnailUrl = await thumbnailSnapshot.ref.getDownloadURL();
      }

      setUploadStatus('Saving video details...');

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

        setUploading(false);
        clearForm();

      } catch (firestoreError) {
        // Video uploaded but Firestore save failed
        setUploading(false);
        throw Exception('Video uploaded but details not saved. Please check Firebase permissions. Video URL: $videoUrl');
      }

    } catch (e) {
      setUploading(false);
      throw e;
    }
  }

  void clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _categoryController.clear();
    _starringController.clear();
    _durationController.clear();
    _languageController.clear();
    _directorController.clear();
    _ratingController.clear();
    _fileSizeController.clear();
    _selectedCategory = null;
    _selectedReleaseDate = null;
    _selectedVideo = null;
    _selectedThumbnail = null;
    notifyListeners();
  }

  void clearThumbnail() {
    _selectedThumbnail = null;
    notifyListeners();
  }

  void clearVideo() {
    _selectedVideo = null;
    _uploadStatus = '';
    notifyListeners();
  }
}
