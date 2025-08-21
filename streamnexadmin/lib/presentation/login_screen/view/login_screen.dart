import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:streamnexadmin/core/constants/text_styles.dart';
import 'package:streamnexadmin/core/constants/color_constants.dart';
import 'package:streamnexadmin/presentation/login_screen/controller/login_controller.dart';

class LogInScreen extends StatelessWidget {
  LogInScreen({Key? key}) : super(key: key);

  final LoginController controller = LoginController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final padding = isTablet ? 32.0 : 24.0;
    final spacing = isTablet ? 40.0 : 60.0;
    final smallSpacing = isTablet ? 10.0 : 10.0;
    final buttonHeight = isTablet ? 64.0 : 56.0;
    final fontSize = isTablet ? 32.0 : 28.0;
    final buttonFontSize = isTablet ? 18.0 : 16.0;
    final borderRadius = isTablet ? 12.0 : 8.0;

    return Scaffold(
      backgroundColor: ColorTheme.mainColor,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            return SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: spacing),

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

                      Text(
                        'Admin Login',
                        style: TextStyles.signupHeadding(size: isTablet ? 24 : 20),
                      ),

                      SizedBox(height: smallSpacing),

                      Text(
                        'Access your streaming platform dashboard',
                        style: TextStyles.subText1(),
                      ),

                      SizedBox(height: spacing),

                      _buildTextField(
                        context: context,
                        controller: controller.emailController,
                        focusNode: controller.emailFocus,
                        nextFocusNode: controller.passwordFocus,
                        label: 'Admin Email',
                        hint: 'Enter admin email',
                        keyboardType: TextInputType.emailAddress,
                        isTablet: isTablet,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Email is required';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: smallSpacing),

                      _buildTextField(
                        context: context,
                        controller: controller.passwordController,
                        focusNode: controller.passwordFocus,
                        label: 'Admin Password',
                        hint: 'Enter admin password',
                        isPassword: true,
                        isPasswordVisible: controller.isPasswordVisible,
                        isTablet: isTablet,
                        onTogglePassword: controller.togglePasswordVisibility,
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

                      SizedBox(
                        width: double.infinity,
                        height: buttonHeight,
                        child: ElevatedButton(
                          onPressed: controller.isLoading
                              ? null
                              : () => controller.handleSignIn(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorTheme.secondaryColor,
                            disabledBackgroundColor: Colors.grey[400],
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(borderRadius),
                            ),
                          ),
                          child: controller.isLoading
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
                                  style: TextStyles.buttonText(),
                                ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
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
          textInputAction: nextFocusNode != null ? TextInputAction.next : TextInputAction.done,
          onFieldSubmitted: (_) {
            if (nextFocusNode != null) {
              FocusScope.of(context).requestFocus(nextFocusNode);
            } else if (isPassword) {
              // Submit on Enter when on password field
              this.controller.handleSignIn(context);
            }
          },
          style: TextStyle(fontSize: fieldFontSize, color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.montserrat(fontSize: fieldFontSize, color: Colors.grey[500]),
            suffixIcon: isPassword
                ? IconButton(
                    onPressed: onTogglePassword,
                    icon: Icon(
                      isPasswordVisible ? Icons.visibility : Icons.visibility_off,
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
}

