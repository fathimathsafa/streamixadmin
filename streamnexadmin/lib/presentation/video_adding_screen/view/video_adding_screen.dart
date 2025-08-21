import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:streamnexadmin/core/constants/color_constants.dart';
import 'package:streamnexadmin/core/constants/text_styles.dart';
import 'package:streamnexadmin/presentation/video_adding_screen/controller/video_adding_controller.dart';

class AddVideoScreen extends StatelessWidget {
  AddVideoScreen({super.key});

  final VideoAddingController controller = VideoAddingController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isCompact = screenWidth < 400;
    
    // Responsive sizing
    final padding = isTablet ? 24.0 : (isCompact ? 12.0 : 16.0);
    final spacing = isTablet ? 20.0 : (isCompact ? 12.0 : 16.0);
    final smallSpacing = isTablet ? 12.0 : (isCompact ? 8.0 : 10.0);
    final tinySpacing = isTablet ? 8.0 : (isCompact ? 4.0 : 6.0);
    
    // Responsive text sizes
    final titleSize = isTablet ? 20.0 : (isCompact ? 16.0 : 18.0);
    final subtitleSize = isTablet ? 18.0 : (isCompact ? 14.0 : 16.0);
    final bodySize = isTablet ? 16.0 : (isCompact ? 12.0 : 14.0);
    final smallSize = isTablet ? 14.0 : (isCompact ? 10.0 : 12.0);
    final tinySize = isTablet ? 12.0 : (isCompact ? 8.0 : 10.0);
    
    // Responsive container sizes
    final thumbnailHeight = isTablet ? 200.0 : (isCompact ? 120.0 : 150.0);
    final videoHeight = isTablet ? 250.0 : (isCompact ? 180.0 : 200.0);
    final buttonHeight = isTablet ? 60.0 : (isCompact ? 45.0 : 50.0);
    final iconSize = isTablet ? 60.0 : (isCompact ? 40.0 : 48.0);
    final largeIconSize = isTablet ? 80.0 : (isCompact ? 60.0 : 64.0);
    
    return Scaffold(
      backgroundColor: ColorTheme.mainColor,
      appBar: AppBar(
        backgroundColor: ColorTheme.mainColor,
        centerTitle: true,
        title: Text(
          'Add Video',
          style: TextStyles.appBarHeadding(),
        ),
        automaticallyImplyLeading: false,
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Form(
              key: controller.formKey,
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
                            'Video Thumbnail',
                            style: TextStyles.subText(
                              size: titleSize,
                              weight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: spacing),
                          Container(
                            width: double.infinity,
                            height: thumbnailHeight,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[700]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: InkWell(
                              onTap: controller.isUploading ? null : () => _selectThumbnail(context),
                              child: controller.selectedThumbnail != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        controller.selectedThumbnail!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    )
                                  : Flexible(
                                    child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Flexible(
                                            child: Icon(
                                              Icons.image_outlined,
                                              size: iconSize,
                                              color: Colors.grey[400],
                                            ),
                                          ),
                                          SizedBox(height: smallSpacing),
                                          Flexible(
                                            child: Text(
                                              'Tap to select thumbnail',
                                              style: GoogleFonts.montserrat(
                                                fontSize: bodySize,
                                                color: Colors.grey[400],
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: tinySpacing),
                                          Flexible(
                                            child: Text(
                                              'JPG, PNG up to 2MB',
                                              style: GoogleFonts.montserrat(
                                                fontSize: tinySize,
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ),
                            ),
                          ),
                          if (controller.selectedThumbnail != null && !controller.isUploading) ...[
                            SizedBox(height: smallSpacing),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => controller.clearThumbnail(),
                                  icon: Icon(Icons.clear, size: bodySize),
                                  label: Text(
                                    'Clear Thumbnail',
                                    style: GoogleFonts.montserrat(fontSize: smallSize),
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
                            'Add Video',
                            style: TextStyles.subText(
                              size: titleSize,
                              weight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: spacing),
                          Container(
                            width: double.infinity,
                            height: videoHeight,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[700]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: InkWell(
                              onTap: controller.isUploading ? null : () => _selectVideo(context),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (controller.selectedVideo != null) ...[
                                    Icon(
                                      Icons.video_file,
                                      size: iconSize,
                                      color: ColorTheme.secondaryColor,
                                    ),
                                    SizedBox(height: smallSpacing),
                                    Text(
                                      controller.selectedVideo!.name,
                                      style: GoogleFonts.montserrat(
                                        fontSize: bodySize,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: tinySpacing),
                                    Text(
                                      '${(controller.selectedVideo!.size / (1024 * 1024)).toStringAsFixed(1)} MB',
                                      style: GoogleFonts.montserrat(
                                        fontSize: smallSize,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                    if (controller.isUploading) ...[
                                      SizedBox(height: smallSpacing),
                                      LinearProgressIndicator(
                                        value: controller.uploadProgress,
                                        backgroundColor: Colors.grey[700],
                                        valueColor: AlwaysStoppedAnimation<Color>(ColorTheme.secondaryColor),
                                      ),
                                      SizedBox(height: tinySpacing),
                                      Text(
                                        controller.uploadStatus,
                                        style: GoogleFonts.montserrat(
                                          fontSize: tinySize,
                                          color: Colors.grey[400],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ] else ...[
                                    Flexible(
                                      child: Icon(
                                        Icons.cloud_upload_outlined,
                                        size: largeIconSize,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                    SizedBox(height: spacing),
                                    Flexible(
                                      child: Text(
                                        'Tap to select movie file',
                                        style: GoogleFonts.montserrat(
                                          fontSize: subtitleSize,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: tinySpacing),
                                    Flexible(
                                      child: Text(
                                        'MP4, AVI, MOV up to 2GB',
                                        style: GoogleFonts.montserrat(
                                          fontSize: smallSize,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          if (controller.selectedVideo != null && !controller.isUploading) ...[
                            SizedBox(height: smallSpacing),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => controller.clearVideo(),
                                  icon: Icon(Icons.clear, size: bodySize),
                                  label: Text(
                                    'Clear Selection',
                                    style: GoogleFonts.montserrat(fontSize: smallSize),
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
                              size: titleSize,
                              weight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: spacing),
                          
                          // Title Field
                          TextFormField(
                            controller: controller.titleController,
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
                            controller: controller.descriptionController,
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
                            value: controller.selectedCategory,
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
                            items: controller.categories.map((String category) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Text(category, style: TextStyle(color: Colors.white)),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              controller.setSelectedCategory(newValue);
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
                            controller: controller.directorController,
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
                            controller: controller.starringController,
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
                            controller: controller.durationController,
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
                            controller: controller.languageController,
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
                            controller: controller.ratingController,
                            style: TextStyle(color: Colors.white),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Rating',
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
                                if (rating == null || rating < 1 || rating > 5) {
                                  return 'Please enter a rating between 1 and 5';
                                }
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: spacing),

                          // Release Date Field
                          InkWell(
                            onTap: () => _selectReleaseDate(context),
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
                                      controller.selectedReleaseDate != null
                                          ? 'Release Date: ${controller.selectedReleaseDate!.day}/${controller.selectedReleaseDate!.month}/${controller.selectedReleaseDate!.year}'
                                          : 'Select Release Date',
                                      style: GoogleFonts.montserrat(
                                        color: controller.selectedReleaseDate != null ? Colors.white : Colors.grey[400],
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
                            controller: controller.fileSizeController,
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
                            controller: controller.categoryController,
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
                    height: buttonHeight,
                    child: ElevatedButton(
                      onPressed: controller.isUploading ? null : () => _uploadVideo(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorTheme.secondaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: controller.isUploading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: bodySize,
                                  height: bodySize,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                SizedBox(width: smallSpacing),
                                Text(
                                  'Uploading...',
                                  style: GoogleFonts.montserrat(fontSize: subtitleSize),
                                ),
                              ],
                            )
                          : Text(
                              'Upload Movie',
                              style: GoogleFonts.montserrat(fontSize: subtitleSize),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectThumbnail(BuildContext context) async {
    try {
      await controller.selectThumbnail();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting thumbnail: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectVideo(BuildContext context) async {
    try {
      await controller.selectVideo();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting video: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectReleaseDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedReleaseDate ?? DateTime.now(),
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
    if (picked != null && picked != controller.selectedReleaseDate) {
      controller.setSelectedReleaseDate(picked);
    }
  }

  Future<void> _uploadVideo(BuildContext context) async {
    try {
      await controller.uploadVideo();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Movie uploaded successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 4),
        ),
      );

    } catch (e) {
      String errorMessage = 'Upload failed. Please try again.';
      
      if (e.toString().contains('timeout')) {
        errorMessage = 'Upload timeout. Large movies may take longer. Please try again.';
      } else if (e.toString().contains('too large')) {
        errorMessage = 'Video file too large. Please select a file smaller than 2GB.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (e.toString().contains('permission')) {
        errorMessage = 'Permission denied. Please check Firebase configuration.';
      } else if (e.toString().contains('Video uploaded but details not saved')) {
        // Show special dialog for this case
        _showUploadSuccessDialog(context, e.toString());
        return;
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

  void _showUploadSuccessDialog(BuildContext context, String message) {
    // Extract video URL from the error message
    final urlMatch = RegExp(r'Video URL: (.+)').firstMatch(message);
    final videoUrl = urlMatch?.group(1) ?? 'URL not available';

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
                controller.clearForm();
              },
              child: Text('OK', style: TextStyle(color: Colors.white70)),
            ),
          ],
        );
      },
    );
  }
}
