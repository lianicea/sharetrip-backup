
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/sharetrip_auth_service.dart';
import '../../student/home/student_home_page.dart';

class StudentLoginPage extends StatefulWidget {
  const StudentLoginPage({super.key});

  @override
  State<StudentLoginPage> createState() => _StudentLoginPageState();
}

class _StudentLoginPageState extends State<StudentLoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoggingIn = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ==========================================
  // INPUT DECORATION
  // ==========================================

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 13,
        color: AppColors.textSecondary,
      ),
      prefixIcon: Icon(
        icon,
        size: 18,
        color: AppColors.textSecondary,
      ),
      prefixIconConstraints: const BoxConstraints(
        minWidth: 42,
        minHeight: 42,
      ),
      suffixIcon: suffixIcon,
      suffixIconConstraints: const BoxConstraints(
        minWidth: 42,
        minHeight: 42,
      ),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 12,
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.3,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.danger,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.danger,
        ),
      ),
    );
  }

  // ==========================================
  // FIELD LABEL
  // ==========================================

  Widget _fieldLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }

  // ==========================================
  // LOGIN ERROR HANDLING
  // ==========================================

  String _friendlyLoginError(String message) {
    final lower = message.toLowerCase();

    if (lower.contains('invalid login credentials')) {
      return 'Incorrect school email or password. Please try again.';
    }

    if (lower.contains('email not confirmed') ||
        lower.contains('email_not_confirmed')) {
      return 'Your school email is not verified yet. Please complete OTP verification.';
    }

    if (lower.contains('network') ||
        lower.contains('socketexception')) {
      return 'Unable to connect. Please check your internet connection.';
    }

    if (lower.contains('too many requests') ||
        lower.contains('rate limit')) {
      return 'Too many login attempts. Please wait and try again.';
    }

    return message;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ==========================================
  // LOGIN ACTION
  // ==========================================

  Future<void> _login() async {
    if (_isLoggingIn) return;

    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final email = ShareTripAuthService.normalizeEmail(
      _emailController.text,
    );

    final password = _passwordController.text;

    setState(() {
      _isLoggingIn = true;
    });

    try {
      // Authenticate using Supabase.
      final response =
          await ShareTripAuthService.instance.signIn(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user == null) {
        throw const AuthException(
          'Unable to retrieve your account. Please try again.',
        );
      }

      // Retrieve the authenticated user's profile.
      final profile =
          await ShareTripAuthService.instance.getProfile(
        user.id,
      );

      // Make sure this is a student account.
      final role = (profile['role'] ?? '')
          .toString()
          .toLowerCase();

      if (role != 'student') {
        await ShareTripAuthService.instance.signOut();

        if (!mounted) return;

        _showError(
          'This account is not registered as a student. Please use the correct login portal.',
        );
        return;
      }

      // Check whether the account has verified its email.
      if (user.emailConfirmedAt == null) {
        await ShareTripAuthService.instance.signOut();

        if (!mounted) return;

        _showError(
          'Your school email is not verified. Please complete OTP verification.',
        );
        return;
      }

      final fullName =
          (profile['full_name'] ?? 'Student').toString();

      final details = profile['details'] is Map
          ? Map<String, dynamic>.from(profile['details'] as Map)
          : <String, dynamic>{};

      final course = (details['course'] ?? '').toString();

      if (!mounted) return;

      // Navigate to Student Home.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => StudentHomePage(
            studentName: fullName,
            schoolEmail: email,
            course: course,
          ),
        ),
        (route) => false,
      );
    } on AuthException catch (error) {
      if (!mounted) return;

      _showError(
        _friendlyLoginError(error.message),
      );
    } catch (error) {
      if (!mounted) return;

      _showError(
        error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingIn = false;
        });
      }
    }
  }

  // ==========================================
  // BUILD PAGE
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 19,
            color: AppColors.textPrimary,
          ),
          onPressed: _isLoggingIn
              ? null
              : () => Navigator.pop(context),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 12,
          ),

          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 380,
              ),

              child: Form(
                key: _formKey,

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // LOGO

                    Center(
                      child: Container(
                        width: 65,
                        height: 65,
                        decoration: BoxDecoration(
                          gradient: AppColors.buttonGradient,
                          borderRadius: BorderRadius.circular(19),
                        ),
                        child: const Icon(
                          Icons.hub_outlined,
                          color: Colors.white,
                          size: 37,
                        ),
                      ),
                    ),

                    const SizedBox(height: 17),

                    // HEADING

                    const Center(
                      child: Text(
                        'Welcome Back!',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Center(
                      child: Text(
                        'Log in to your ShareTrip student account.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // SCHOOL EMAIL

                    _fieldLabel('School Email'),

                    const SizedBox(height: 7),

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      enabled: !_isLoggingIn,
                      style: const TextStyle(
                        fontSize: 13,
                      ),
                      decoration: _inputDecoration(
                        hint: 'name@cmdi.edu.ph',
                        icon: Icons.email_outlined,
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Please enter your school email.';
                        }

                        if (!ShareTripAuthService.isValidSchoolEmail(
                          value,
                        )) {
                          return 'Use your CMDI school email (@cmdi.edu.ph).';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 19),

                    // PASSWORD

                    _fieldLabel('Password'),

                    const SizedBox(height: 7),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      textInputAction: TextInputAction.done,
                      enabled: !_isLoggingIn,
                      onFieldSubmitted: (_) => _login(),
                      style: const TextStyle(
                        fontSize: 13,
                      ),
                      decoration: _inputDecoration(
                        hint: 'Enter your password',
                        icon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: _isLoggingIn
                              ? null
                              : () {
                                  setState(() {
                                    _isPasswordVisible =
                                        !_isPasswordVisible;
                                  });
                                },
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 27),

                    // LOGIN BUTTON

                    Center(
                      child: SizedBox(
                        width: 260,
                        height: 44,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: AppColors.buttonGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ElevatedButton(
                            onPressed:
                                _isLoggingIn ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              disabledBackgroundColor:
                                  Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoggingIn
                                ? const SizedBox(
                                    width: 19,
                                    height: 19,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Log In',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // SCHOOL VERIFICATION

                    const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            color: AppColors.primary,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'School-verified community rides',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
