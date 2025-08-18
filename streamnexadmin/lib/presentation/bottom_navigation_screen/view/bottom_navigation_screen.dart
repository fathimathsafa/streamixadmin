import 'package:flutter/material.dart';
import 'package:streamnexadmin/presentation/content_managment_screen/view/content_managment_screen.dart';
import 'package:streamnexadmin/presentation/dashboard_screen/view/dash_board_screen.dart';
import 'package:streamnexadmin/presentation/settings/view/settings_screen.dart';
import 'package:streamnexadmin/presentation/user_managment_screen/view/user_managment_screen.dart';
import 'package:streamnexadmin/presentation/video_adding_screen/view/video_adding_screen.dart';
import 'package:streamnexadmin/core/constants/color_constants.dart';

class BottomNavigationScreen extends StatefulWidget {
  @override
  _BottomNavigationScreenState createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    DashboardScreen(),
    ContentManagementScreen(),
    UserManagementScreen(),
    AddVideoScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTheme.mainColor,
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[850],
        selectedItemColor: ColorTheme.secondaryColor,
        unselectedItemColor: Colors.grey[400],
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.movie),
            label: 'Content',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_camera_back),
            label: 'Add Video',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}