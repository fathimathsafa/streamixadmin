import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:streamnexadmin/core/constants/color_constants.dart';
import 'package:streamnexadmin/core/constants/text_styles.dart';
import 'package:streamnexadmin/presentation/login_screen/view/login_screen.dart';

class SettingsScreen extends StatelessWidget {
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
                    _buildSettingsTile('Platform Name', 'StreamNex Admin', Icons.business),
                    _buildSettingsTile('Version', 'v2.1.0', Icons.info),
                    _buildSettingsTile('Server Status', 'Online', Icons.cloud),
                  ], isTablet),
                  SizedBox(height: spacing),
                  // _buildSettingsSection('Security', [
                  //   _buildSettingsTile('Two-Factor Auth', 'Enabled', Icons.security),
                  //   _buildSettingsTile('Session Timeout', '30 minutes', Icons.timer),
                  //   _buildSettingsTile('Login Attempts', '5', Icons.lock),
                  // ], isTablet),
                  SizedBox(height: spacing),
                  _buildSettingsSection('Content', [
                    _buildSettingsTile('Auto Approval', 'Disabled', Icons.auto_awesome),
                    _buildSettingsTile('File Size Limit', '2GB', Icons.storage),
                    _buildSettingsTile('Supported Formats', 'MP4, AVI, MOV', Icons.video_file),
                  ], isTablet),
                ],
              ),
            ),
            SizedBox(height: spacing),
            // Logout Button
            SizedBox(
              width: double.infinity,
              height: isTablet ? 60 : 50,
              child: ElevatedButton.icon(
                onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LogInScreen()));
                },
                icon: Icon(
                  Icons.logout,
                  color: Colors.white,
                  size: isTablet ? 24 : 20,
                ),
                label: Text(
                  'Logout',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: isTablet ? 18 : 16,
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

  Widget _buildSettingsTile(String title, String value, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: ColorTheme.secondaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: ColorTheme.secondaryColor, width: 1),
          ),
          child: Icon(
            icon, 
            color: ColorTheme.secondaryColor,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey[600]!, width: 1),
          ),
          child: Text(
            value, 
            style: GoogleFonts.montserrat(
              color: Colors.grey[300],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        onTap: () {},
      ),
    );
  }
}