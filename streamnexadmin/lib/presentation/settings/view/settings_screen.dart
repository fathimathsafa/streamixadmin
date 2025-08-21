import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:streamnexadmin/core/constants/color_constants.dart';
import 'package:streamnexadmin/core/constants/text_styles.dart';
import 'package:streamnexadmin/presentation/login_screen/view/login_screen.dart';

class SettingsScreen extends StatelessWidget {
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
    
    // Responsive text sizes
    final titleSize = isTablet ? 20.0 : (isCompact ? 16.0 : 18.0);
    final subtitleSize = isTablet ? 18.0 : (isCompact ? 14.0 : 16.0);
    final bodySize = isTablet ? 16.0 : (isCompact ? 12.0 : 14.0);
    final smallSize = isTablet ? 14.0 : (isCompact ? 10.0 : 12.0);
    
    // Responsive button sizes
    final buttonHeight = isTablet ? 60.0 : (isCompact ? 45.0 : 50.0);
    final iconSize = isTablet ? 24.0 : (isCompact ? 18.0 : 20.0);
    
    return Scaffold(
      backgroundColor: ColorTheme.mainColor,
      appBar: AppBar(
        backgroundColor: ColorTheme.mainColor,
        centerTitle: true,
        title: Text(
          'Settings',
          style: TextStyles.appBarHeadding(),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  _buildSettingsSection('System', [
                    _buildSettingsTile('Platform Name', 'StreamNex Admin', Icons.business, isTablet, isCompact),
                    _buildSettingsTile('Version', 'v2.1.0', Icons.info, isTablet, isCompact),
                    _buildSettingsTile('Server Status', 'Online', Icons.cloud, isTablet, isCompact),
                  ], isTablet),
                  SizedBox(height: spacing),
                  // _buildSettingsSection('Security', [
                  //   _buildSettingsTile('Two-Factor Auth', 'Enabled', Icons.security, isTablet, isCompact),
                  //   _buildSettingsTile('Session Timeout', '30 minutes', Icons.timer, isTablet, isCompact),
                  //   _buildSettingsTile('Login Attempts', '5', Icons.lock, isTablet, isCompact),
                  // ], isTablet),
                  SizedBox(height: spacing),
                  _buildSettingsSection('Content', [
                    _buildSettingsTile('Auto Approval', 'Disabled', Icons.auto_awesome, isTablet, isCompact),
                    _buildSettingsTile('File Size Limit', '2GB', Icons.storage, isTablet, isCompact),
                    _buildSettingsTile('Supported Formats', 'MP4, AVI, MOV', Icons.video_file, isTablet, isCompact),
                  ], isTablet),
                ],
              ),
            ),
            SizedBox(height: spacing),
            // Logout Button
            SizedBox(
              width: double.infinity,
              height: buttonHeight,
              child: ElevatedButton.icon(
                onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LogInScreen()));
                },
                icon: Icon(
                  Icons.logout,
                  color: Colors.white,
                  size: iconSize,
                ),
                label: Text(
                  'Logout',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: subtitleSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorTheme.secondaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyles.subText(
            weight: FontWeight.bold,
            color: ColorTheme.white,
          ),
        ),
        SizedBox(height: 10),
        ...children,
      ],
    );
  }

  Widget _buildSettingsTile(String title, String value, IconData icon, bool isTablet, bool isCompact) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: isTablet ? 20 : (isCompact ? 12 : 16), 
          vertical: isTablet ? 12 : (isCompact ? 6 : 8)
        ),
        leading: Container(
          width: isTablet ? 48 : (isCompact ? 32 : 40),
          height: isTablet ? 48 : (isCompact ? 32 : 40),
          decoration: BoxDecoration(
            color: ColorTheme.secondaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: ColorTheme.secondaryColor, width: 1),
          ),
          child: Icon(
            icon, 
            color: ColorTheme.secondaryColor,
            size: isTablet ? 24 : (isCompact ? 16 : 20),
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: isTablet ? 18 : (isCompact ? 14 : 16),
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Container(
          constraints: BoxConstraints(
            maxWidth: isTablet ? 150 : (isCompact ? 80 : 120),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 16 : (isCompact ? 8 : 12), 
            vertical: isTablet ? 8 : (isCompact ? 4 : 6)
          ),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey[600]!, width: 1),
          ),
          child: Text(
            value, 
            style: GoogleFonts.montserrat(
              color: Colors.grey[300],
              fontSize: isTablet ? 16 : (isCompact ? 10 : 14),
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        onTap: () {},
      ),
    );
  }
}