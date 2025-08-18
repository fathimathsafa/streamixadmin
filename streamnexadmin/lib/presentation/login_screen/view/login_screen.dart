import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:streamnexadmin/presentation/bottom_navigation_screen/view/bottom_navigation_screen.dart';
import 'package:streamnexadmin/core/constants/color_constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({Key? key}) : super(key: key);

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Focus nodes
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  // State variables
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Responsive values
    final isTablet = screenWidth > 600;
    final padding = isTablet ? 32.0 : 24.0;
    final spacing = isTablet ? 40.0 : 60.0;
    final smallSpacing = isTablet ? 24.0 : 16.0;
    final tinySpacing = isTablet ? 16.0 : 8.0;
    final buttonHeight = isTablet ? 64.0 : 56.0;
    final fontSize = isTablet ? 32.0 : 28.0;
    final titleFontSize = isTablet ? 36.0 : 25.0;
    final subtitleFontSize = isTablet ? 18.0 : 16.0;
    final buttonFontSize = isTablet ? 18.0 : 16.0;
    final fieldFontSize = isTablet ? 18.0 : 16.0;
    final labelFontSize = isTablet ? 16.0 : 14.0;
    final iconSize = isTablet ? 28.0 : 24.0;
    final borderRadius = isTablet ? 12.0 : 8.0;
    
    return Scaffold(
      backgroundColor: ColorTheme.mainColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: spacing),

                  // Streamix Logo
                  Center(
                    child: Text(
                      'STREAMIX',
                      style: GoogleFonts.montserrat(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w900,
                        color: ColorTheme.secondaryColor,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),

                  SizedBox(height: spacing),

                  // Title
                  Text(
                    'Admin Login',
                    style: GoogleFonts.montserrat(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height: smallSpacing),

                  // Subtitle
                  Text(
                    'Access your streaming platform dashboard',
                    style: GoogleFonts.montserrat(
                      fontSize: subtitleFontSize,
                      color: Colors.grey[400],
                    ),
                  ),

                  SizedBox(height: spacing),

                  // Email Field
                  _buildTextField(
                    controller: _emailController,
                    focusNode: _emailFocus,
                    nextFocusNode: _passwordFocus,
                    label: 'Admin Email',
                    hint: 'Enter admin email',
                    keyboardType: TextInputType.emailAddress,
                    isTablet: isTablet,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Email is required';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value!)) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: smallSpacing),

                  // Password Field
                  _buildTextField(
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    label: 'Admin Password',
                    hint: 'Enter admin password',
                    isPassword: true,
                    isPasswordVisible: _isPasswordVisible,
                    isTablet: isTablet,
                    onTogglePassword: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Password is required';
                      }
                      if (value!.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: spacing),

                  // Sign In Button
                  SizedBox(
                    width: double.infinity,
                    height: buttonHeight,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSignIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorTheme.secondaryColor,
                        disabledBackgroundColor: Colors.grey[400],
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(borderRadius),
                        ),
                      ),
                      child:
                          _isLoading
                              ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : Text(
                                'SIGN IN',
                                style: GoogleFonts.montserrat(
                                  fontSize: buttonFontSize,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                    ),
                  ),

                  SizedBox(height: smallSpacing),

                  

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocusNode,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    bool isPassword = false,
    bool isPasswordVisible = false,
    bool isTablet = false,
    VoidCallback? onTogglePassword,
    String? Function(String?)? validator,
  }) {
    final labelFontSize = isTablet ? 16.0 : 14.0;
    final fieldFontSize = isTablet ? 18.0 : 16.0;
    final iconSize = isTablet ? 24.0 : 20.0;
    final borderRadius = isTablet ? 12.0 : 8.0;
    final padding = isTablet ? 20.0 : 16.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: labelFontSize,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: isPassword && !isPasswordVisible,
          keyboardType: keyboardType,
          validator: validator,
          textInputAction:
              nextFocusNode != null
                  ? TextInputAction.next
                  : TextInputAction.done,
          onFieldSubmitted: (_) {
            if (nextFocusNode != null) {
              FocusScope.of(context).requestFocus(nextFocusNode);
            } else if (isPassword) {
              _handleSignIn();
            }
          },
          style: TextStyle(fontSize: fieldFontSize, color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.montserrat(fontSize: fieldFontSize, color: Colors.grey[500]),
            suffixIcon:
                isPassword
                    ? IconButton(
                      onPressed: onTogglePassword,
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey[400],
                        size: iconSize,
                      ),
                    )
                    : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(color: Colors.grey[600]!, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(color: ColorTheme.secondaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[900],
            contentPadding: EdgeInsets.symmetric(
              horizontal: padding,
              vertical: padding,
            ),
          ),
        ),
      ],
    );
  }


  Future<void> _handleSignIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final email = _emailController.text.trim();
        final password = _passwordController.text;

        // Simple Firebase Authentication login
        final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        final user = userCredential.user;
        if (user != null) {
          _showSnackBar('Welcome back, Admin!');
          
          // Navigate to bottom navigation screen
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (context) => BottomNavigationScreen())
          );
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
        
        _showSnackBar(errorMessage, isError: true);
        
      } catch (e) {
        print('Login error: $e');
        _showSnackBar('Login failed. Please check your internet connection.', isError: true);
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final margin = isTablet ? 24.0 : 16.0;
    final borderRadius = isTablet ? 12.0 : 8.0;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
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
