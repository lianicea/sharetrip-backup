
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/sharetrip_auth_service.dart';

class SchoolEmailOtpPage extends StatefulWidget {
  final String email;

  const SchoolEmailOtpPage({
    super.key,
    required this.email,
  });

  @override
  State<SchoolEmailOtpPage> createState() => _SchoolEmailOtpPageState();
}

class _SchoolEmailOtpPageState extends State<SchoolEmailOtpPage> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());

  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

  Timer? _timer;

  int secondsRemaining = 60;

  String? errorMessage;

  bool _isVerifying = false;
  bool _isResending = false;

  String get enteredOtp =>
      _controllers.map((controller) => controller.text).join();

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (secondsRemaining <= 1) {
          setState(() => secondsRemaining = 0);
          timer.cancel();
        } else {
          setState(() => secondsRemaining--);
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();

    for (final controller in _controllers) {
      controller.dispose();
    }

    for (final node in _focusNodes) {
      node.dispose();
    }

    super.dispose();
  }

  void _clearOtp() {
    for (final controller in _controllers) {
      controller.clear();
    }

    _focusNodes[0].requestFocus();
  }

  void _onOtpChanged(String value, int index) {
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');

      for (int i = 0; i < 6; i++) {
        _controllers[i].text =
            i < digits.length ? digits[i] : '';
      }

      final nextIndex = digits.length.clamp(0, 5);

      _focusNodes[nextIndex].requestFocus();

      setState(() => errorMessage = null);
      return;
    }

    setState(() => errorMessage = null);

    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else if (index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  String _friendlyOtpError(String message) {
    final lower = message.toLowerCase();

    if (lower.contains('expired')) {
      return 'Your verification code has expired. Request a new one.';
    }

    if (lower.contains('invalid') ||
        lower.contains('token') ||
        lower.contains('otp')) {
      return 'Incorrect verification code. Please try again.';
    }

    if (lower.contains('rate limit') ||
        lower.contains('too many')) {
      return 'Too many attempts. Please wait before trying again.';
    }

    return message;
  }

  Future<void> _verifyOtp() async {
    if (_isVerifying) return;

    if (enteredOtp.length != 6) {
      setState(() {
        errorMessage = 'Please enter all 6 digits of your code.';
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      errorMessage = null;
    });

    try {
      await ShareTripAuthService.instance.verifySignupOtp(
        email: widget.email,
        token: enteredOtp,
      );

      if (!mounted) return;

      _timer?.cancel();
      _showSuccessDialog();
    } on AuthException catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = _friendlyOtpError(error.message);
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage =
            error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  Future<void> _resendOtp() async {
    if (secondsRemaining > 0 || _isResending) return;

    setState(() {
      _isResending = true;
      errorMessage = null;
    });

    try {
      await ShareTripAuthService.instance.resendSignupOtp(
        widget.email,
      );

      if (!mounted) return;

      _clearOtp();

      setState(() {
        secondsRemaining = 60;
      });

      _startTimer();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'A new verification code has been sent to your email.',
          ),
          backgroundColor: Color(0xFF16A36A),
        ),
      );
    } on AuthException catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = _friendlyOtpError(error.message);
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage =
            error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  String get formattedTime {
    final minutes = secondsRemaining ~/ 60;
    final seconds = secondsRemaining % 60;

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5F7EE),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF16A36A),
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Email Verified!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 21,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Your CMDI school email has been successfully verified. Welcome to the ShareTrip community!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  Navigator.pop(context, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue to ShareTrip',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _otpInputBox(int index) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: SizedBox(
          height: 57,
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 6,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(
                  color: AppColors.border,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide(
                  color: errorMessage == null
                      ? AppColors.border
                      : AppColors.danger,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
            onChanged: (value) => _onOtpChanged(value, index),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(25, 30, 25, 35),
      decoration: const BoxDecoration(
        gradient: AppColors.buttonGradient,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.directions_car_rounded,
                color: Colors.white,
                size: 27,
              ),
              const SizedBox(width: 9),
              const Text(
                'ShareTrip',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'SECURE VERIFICATION',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Text(
            'One more step!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Verify your school email and join our school-verified community.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 25,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 420,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () =>
                                  Navigator.pop(context, false),
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Text(
                              'Email Verification',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              gradient: AppColors.buttonGradient,
                              borderRadius: BorderRadius.circular(23),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.18),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.mark_email_read_rounded,
                              color: Colors.white,
                              size: 39,
                            ),
                          ),
                        ),
                        const SizedBox(height: 23),
                        const Center(
                          child: Text(
                            'Check your inbox',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 9),
                        const Center(
                          child: Text(
                            'We sent a 6-digit verification code to:',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0EAFF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              widget.email,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 35),
                        const Text(
                          'ENTER VERIFICATION CODE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.7,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: List.generate(
                            6,
                            (index) => _otpInputBox(index),
                          ),
                        ),
                        if (errorMessage != null) ...[
                          const SizedBox(height: 13),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: AppColors.danger,
                                size: 17,
                              ),
                              const SizedBox(width: 7),
                              Expanded(
                                child: Text(
                                  errorMessage!,
                                  style: const TextStyle(
                                    color: AppColors.danger,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 25),
                        Center(
                          child: Column(
                            children: [
                              const Text(
                                'Your code expires soon',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.timer_outlined,
                                    color: secondsRemaining == 0
                                        ? AppColors.danger
                                        : AppColors.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 7),
                                  Text(
                                    formattedTime,
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: secondsRemaining == 0
                                          ? AppColors.danger
                                          : AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),
                        SizedBox(
                          width: double.infinity,
                          height: 51,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: AppColors.buttonGradient,
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: ElevatedButton(
                              onPressed:
                                  _isVerifying ? null : _verifyOtp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                disabledBackgroundColor:
                                    Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13),
                                ),
                              ),
                              child: _isVerifying
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Verify Email',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              const Text(
                                "Didn't receive the code?",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              TextButton(
                                onPressed:
                                    secondsRemaining == 0 &&
                                            !_isResending
                                        ? _resendOtp
                                        : null,
                                child: Text(
                                  _isResending
                                      ? 'Sending...'
                                      : 'Resend Code',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: secondsRemaining == 0
                                        ? AppColors.primary
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0EAFF),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFE3D7FF),
                            ),
                          ),
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.shield_rounded,
                                color: AppColors.primary,
                                size: 23,
                              ),
                              SizedBox(width: 11),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Your account security matters',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      'Never share your verification code with anyone. ShareTrip will never ask you to disclose your OTP.',
                                      style: TextStyle(
                                        fontSize: 11,
                                        height: 1.5,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),
                        const Center(
                          child: Text(
                            'SHARE THE RIDE. CONNECT WITH STUDENTS.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 9,
                              letterSpacing: 0.8,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
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
