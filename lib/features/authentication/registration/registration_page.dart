
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../student/home/student_home_page.dart';
import '../otp/school_email_otp_page.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/sharetrip_auth_service.dart';

class StudentRegistrationPage extends StatefulWidget {
  const StudentRegistrationPage({super.key});

  @override
  State<StudentRegistrationPage> createState() =>
      _StudentRegistrationPageState();
}

class _StudentRegistrationPageState
    extends State<StudentRegistrationPage> {
  final _stepOneKey = GlobalKey<FormState>();
  final _stepTwoKey = GlobalKey<FormState>();

  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _contactController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  int currentStep = 1;

  String? selectedCourse;

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _isCreatingAccount = false;

  // ==========================================
  // PASSWORD REQUIREMENTS
  // ==========================================

  bool get hasMinLength =>
      _passwordController.text.length >= 8;

  bool get hasUppercase =>
      RegExp(r'[A-Z]').hasMatch(_passwordController.text);

  bool get hasNumber =>
      RegExp(r'[0-9]').hasMatch(_passwordController.text);

  // ==========================================
  // DISPOSE
  // ==========================================

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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

  Widget _fieldLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }

  // ==========================================
  // HEADER
  // ==========================================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(23, 18, 23, 25),
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.13),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white24,
                  ),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 19,
                  ),
                  onPressed: () {
                    if (_isCreatingAccount) return;

                    if (currentStep == 2) {
                      setState(() {
                        currentStep = 1;
                      });
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 3),
                    const Text(
                      'STUDENT RIDE PORTAL',
                      style: TextStyle(
                        color: Color(0xFFD9C9FF),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'ShareTrip',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 29,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                    Text(
                      'Share the Ride. Connect with Students.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 19),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.white24,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  color: Color(0xFF00D6A0),
                  size: 16,
                ),
                SizedBox(width: 7),
                Text(
                  'School-verified community rides',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // PROGRESS INDICATOR
  // ==========================================

  Widget _buildProgress() {
    final progress = currentStep == 1 ? 0.5 : 1.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step $currentStep of 2',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // STEP 1: STUDENT INFORMATION
  // ==========================================

  Widget _buildStepOne() {
    return Form(
      key: _stepOneKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel('Full Name'),
          const SizedBox(height: 7),
          TextFormField(
            controller: _nameController,
            style: const TextStyle(fontSize: 13),
            textCapitalization: TextCapitalization.words,
            decoration: _inputDecoration(
              hint: 'Juan Dela Cruz',
              icon: Icons.person_outline,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your full name.';
              }
              if (value.trim().length < 3) {
                return 'Please enter a valid name.';
              }
              return null;
            },
          ),

          const SizedBox(height: 19),

          _fieldLabel('School Email'),
          const SizedBox(height: 7),
          TextFormField(
            controller: _emailController,
            style: const TextStyle(fontSize: 13),
            keyboardType: TextInputType.emailAddress,
            decoration: _inputDecoration(
              hint: 'name@cmdi.edu.ph',
              icon: Icons.email_outlined,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your school email.';
              }

              final email = value.trim();

              final isValidSchoolEmail = RegExp(
                r'^[A-Z0-9._%+-]+@cmdi\.edu\.ph$',
                caseSensitive: false,
              ).hasMatch(email);

              if (!isValidSchoolEmail) {
                return 'Use your CMDI school email (@cmdi.edu.ph).';
              }

              return null;
            },
          ),

          const SizedBox(height: 19),

          _fieldLabel('Contact Number'),
          const SizedBox(height: 7),
          TextFormField(
            controller: _contactController,
            style: const TextStyle(fontSize: 13),
            keyboardType: TextInputType.phone,
            maxLength: 11,
            decoration: _inputDecoration(
              hint: '09XXXXXXXXX',
              icon: Icons.phone_outlined,
            ).copyWith(
              counterText: '',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your contact number.';
              }

              if (!RegExp(r'^09[0-9]{9}$')
                  .hasMatch(value.trim())) {
                return 'Enter a valid 11-digit mobile number.';
              }

              return null;
            },
          ),

          const SizedBox(height: 19),

          _fieldLabel('Course'),
          const SizedBox(height: 7),
          DropdownButtonFormField<String>(
            value: selectedCourse,
            isExpanded: true,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
            ),
            decoration: _inputDecoration(
              hint: 'Select your course',
              icon: Icons.school_outlined,
            ),
            items: const [
              DropdownMenuItem(
                value: 'BS Information Accountancy Information Systems',
                child: Text(
                  'BS Information Accountancy Information System',
                  style: TextStyle(fontSize: 13),
                ),
              ),
              DropdownMenuItem(
                value: 'BS Information Systems',
                child: Text(
                  'BS Information Systems',
                  style: TextStyle(fontSize: 13),
                ),
              ),
              DropdownMenuItem(
                value: 'BS Business Entrepreneurship',
                child: Text(
                  'BS Business Entrepreneurship',
                  style: TextStyle(fontSize: 13),
                ),
              ),
              DropdownMenuItem(
                value: 'BS Accountancy',
                child: Text(
                  'BS Accountancy',
                  style: TextStyle(fontSize: 13),
                ),
              ),
              DropdownMenuItem(
                value: 'BS Tourism Management',
                child: Text(
                  'BS Tourism Management',
                  style: TextStyle(fontSize: 13),
                ),
              ),
              DropdownMenuItem(
                value: 'BS Criminology',
                child: Text(
                  'BS Criminology',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
            onChanged: (value) {
              setState(() {
                selectedCourse = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select your course.';
              }
              return null;
            },
          ),

          const SizedBox(height: 27),

          Center(
            child: SizedBox(
              width: 280,
              height: 44,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.buttonGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: _continueToStepTwo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 15),
        ],
      ),
    );
  }

  // ==========================================
  // CONTINUE TO STEP 2
  // ==========================================

  void _continueToStepTwo() {
    if (_stepOneKey.currentState?.validate() ?? false) {
      setState(() {
        currentStep = 2;
      });
    }
  }

  // ==========================================
  // PASSWORD REQUIREMENT ITEM
  // ==========================================

  Widget _passwordRequirement(
    String text,
    bool isSatisfied,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            isSatisfied
                ? Icons.check_circle
                : Icons.circle_outlined,
            size: 15,
            color: isSatisfied
                ? AppColors.success
                : AppColors.textSecondary,
          ),
          const SizedBox(width: 9),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: isSatisfied
                  ? AppColors.success
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // STEP 2: SET UP PASSWORD
  // ==========================================

  Widget _buildStepTwo() {
    return Form(
      key: _stepTwoKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel('Enter a Password'),
          const SizedBox(height: 7),
          TextFormField(
            controller: _passwordController,
            obscureText: !_showPassword,
            style: const TextStyle(fontSize: 13),
            onChanged: (_) {
              setState(() {});
            },
            decoration: _inputDecoration(
              hint: 'Create a secure password',
              icon: Icons.lock_outline,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _showPassword = !_showPassword;
                  });
                },
                icon: Icon(
                  _showPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please create a password.';
              }
              if (value.length < 8) {
                return 'Password must have at least 8 characters.';
              }
              if (!RegExp(r'[A-Z]').hasMatch(value)) {
                return 'Include at least one uppercase letter.';
              }
              if (!RegExp(r'[0-9]').hasMatch(value)) {
                return 'Include at least one number.';
              }
              return null;
            },
          ),

          const SizedBox(height: 19),

          _fieldLabel('Re-enter Your Password'),
          const SizedBox(height: 7),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: !_showConfirmPassword,
            style: const TextStyle(fontSize: 13),
            decoration: _inputDecoration(
              hint: 'Confirm your password',
              icon: Icons.lock_outline,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _showConfirmPassword =
                        !_showConfirmPassword;
                  });
                },
                icon: Icon(
                  _showConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password.';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match.';
              }
              return null;
            },
          ),

          const SizedBox(height: 19),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Password Requirements',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 11),
                _passwordRequirement(
                  'At least 8 characters',
                  hasMinLength,
                ),
                _passwordRequirement(
                  'One uppercase letter',
                  hasUppercase,
                ),
                _passwordRequirement(
                  'One number',
                  hasNumber,
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          Center(
            child: SizedBox(
              width: 280,
              height: 44,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.buttonGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: _isCreatingAccount
                      ? null
                      : _createAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.transparent,
                    disabledForegroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isCreatingAccount
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 15),
        ],
      ),
    );
  }

  // ==========================================
  // CREATE ACCOUNT ACTION
  // ==========================================

  Future<void> _createAccount() async {
    if (_isCreatingAccount) return;

    if (!(_stepTwoKey.currentState?.validate() ?? false)) {
      return;
    }

    final fullName = _nameController.text.trim();
    final email = _emailController.text.trim().toLowerCase();
    final contactNumber = _contactController.text.trim();
    final course = selectedCourse ?? '';

    setState(() {
      _isCreatingAccount = true;
    });

    try {
      // CREATE SUPABASE ACCOUNT

      await ShareTripAuthService.instance.signUp(
        fullName: fullName,
        email: email,
        password: _passwordController.text,
        role: 'student',
        profileDetails: <String, dynamic>{
          'contact_number': contactNumber,
          'course': course,
        },
      );

      if (!mounted) return;

      // SCHOOL EMAIL OTP VERIFICATION

      final verified = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => SchoolEmailOtpPage(
            email: email,
          ),
        ),
      );

      if (!mounted || verified != true) return;

      // CHECK AUTHENTICATED USER

      final user =
          ShareTripAuthService.instance.currentUser;

      if (user == null) {
        throw Exception(
          'Email verified, but no authenticated session was found. '
          'Please log in using your school email.',
        );
      }

      // SAVE STUDENT PROFILE DETAILS

      await ShareTripAuthService.instance.saveProfileDetails(
        userId: user.id,
        details: <String, dynamic>{
          'contact_number': contactNumber,
          'course': course,
        },
      );

      if (!mounted) return;

      // NAVIGATE TO STUDENT HOME

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

      _showRegistrationError(
        _friendlyAuthError(error.message),
      );
    } catch (error) {
      if (!mounted) return;

      _showRegistrationError(
        error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingAccount = false;
        });
      }
    }
  }

  // ==========================================
  // FRIENDLY AUTH ERRORS
  // ==========================================

  String _friendlyAuthError(String message) {
    final lower = message.toLowerCase();

    if (lower.contains('already registered') ||
        lower.contains('already been registered') ||
        lower.contains('user already')) {
      return 'This school email is already registered. Please log in instead.';
    }

    if (lower.contains('password')) {
      return 'Your password does not meet the account security requirements.';
    }

    if (lower.contains('error sending confirmation email') ||
        lower.contains('sending confirmation email') ||
        lower.contains('smtp')) {
      return 'Supabase could not send the verification email. Configure SMTP in Supabase Authentication settings. Details: $message';
    }

    return message;
  }

  // ==========================================
  // SHOW REGISTRATION ERROR
  // ==========================================

  void _showRegistrationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ==========================================
  // BUILD PAGE
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 22,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 430,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentStep == 1
                              ? 'Create your account'
                              : 'Set Up Password',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.7,
                          ),
                        ),

                        const SizedBox(height: 7),

                        Text(
                          currentStep == 1
                              ? 'Use your school details to join the verified ShareTrip community.'
                              : 'Protect your ShareTrip account with a secure password.',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 23),

                        _buildProgress(),

                        const SizedBox(height: 23),

                        if (currentStep == 1)
                          _buildStepOne()
                        else
                          _buildStepTwo(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
