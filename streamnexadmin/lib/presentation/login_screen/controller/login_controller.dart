
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:streamnexadmin/core/constants/color_constants.dart';
import 'package:streamnexadmin/presentation/bottom_navigation_screen/view/bottom_navigation_screen.dart';

class LoginController extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  bool get isPasswordVisible => _isPasswordVisible;
  bool get isLoading => _isLoading;

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> handleSignIn(BuildContext context) async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    _setLoading(true);
    try {
      final email = emailController.text.trim();
      final password = passwordController.text;
      print('🔐 Attempting admin login for: $email');

      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        print('✅ User authenticated: ${user.uid}');
        final adminDoc = await FirebaseFirestore.instance.collection('admins').doc(user.uid).get();
        if (adminDoc.exists) {
          print('✅ User is admin - proceeding to admin panel');
          _showSnackBar(context, 'Welcome back, Admin!');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => BottomNavigationScreen()),
          );
        } else {
          print('❌ User is not an admin - logging out');
          await FirebaseAuth.instance.signOut();
          _showSnackBar(context, 'Access denied. This is an admin-only application.', isError: true);
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Login failed. Please try again.';
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Admin account not found. Please check your email.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          errorMessage = 'Please enter a valid email address.';
          break;
        case 'user-disabled':
          errorMessage = 'This admin account has been disabled.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed attempts. Please try again later.';
          break;
        case 'invalid-credential':
          errorMessage = 'Invalid credentials. Please check your email and password.';
          break;
      }
      _showSnackBar(context, errorMessage, isError: true);
    } catch (e) {
      print('Login error: $e');
      _showSnackBar(context, 'Login failed. Please check your internet connection.', isError: true);
    } finally {
      _setLoading(false);
    }
  }

  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final margin = isTablet ? 24.0 : 16.0;
    final borderRadius = isTablet ? 12.0 : 8.0;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.error : Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red : ColorTheme.secondaryColor,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(margin),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
        duration: Duration(seconds: isError ? 4 : 3),
      ),
    );
  }
}