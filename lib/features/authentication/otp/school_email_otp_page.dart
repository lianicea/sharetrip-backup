
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';

class SchoolEmailOtpPage extends StatefulWidget {
  final String email;

  const SchoolEmailOtpPage({
    super.key,
    required this.email,
  });

  @override
  State<SchoolEmailOtpPage> createState() =>
      _SchoolEmailOtpPageState();
}

class _SchoolEmailOtpPageState
    extends State<SchoolEmailOtpPage> {

  // ==========================================
  // OTP CONTROLLERS
  // ==========================================

  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());

  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

  Timer? _timer;

  int secondsRemaining = 60;

  String? errorMessage;

  // Local prototype code only.
  static const String demoOtp = '123456';

  // ==========================================
  // INITIALIZE TIMER
  // ==========================================

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
          setState(() {
            secondsRemaining = 0;
          });

          timer.cancel();
        } else {
          setState(() {
            secondsRemaining--;
          });
        }
      },
    );
  }

  // ==========================================
  // DISPOSE
  // ==========================================

  @override
  void dispose() {
    _timer?.cancel();

    for (final controller in _controllers) {
      controller.dispose();
    }

    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }

    super.dispose();
  }

  // ==========================================
  // GET ENTERED OTP
  // ==========================================

  String get enteredOtp {
    return _controllers
        .map((controller) => controller.text)
        .join();
  }

  // ==========================================
  // OTP INPUT CHANGE
  // ==========================================

  void _onOtpChanged(String value, int index) {
    setState(() {
      errorMessage = null;
    });

    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  // ==========================================
  // VERIFY OTP
  // ==========================================

  void _verifyOtp() {
    if (enteredOtp.length != 6) {
      setState(() {
        errorMessage = 'Please enter the complete 6-digit code.';
      });
      return;
    }

    if (secondsRemaining == 0) {
      setState(() {
        errorMessage = 'Your OTP has expired. Please request a new code.';
      });
      return;
    }

    if (enteredOtp != demoOtp) {
      setState(() {
        errorMessage = 'Incorrect verification code. Please try again.';
      });

      return;
    }

    _timer?.cancel();

    _showSuccessDialog();
  }

  // ==========================================
  // SUCCESS DIALOG
  // ==========================================

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,

      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 65,
                height: 65,

                decoration: BoxDecoration(
                  color: const Color(0xFFE5F7EE),
                  borderRadius: BorderRadius.circular(50),
                ),

                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 42,
                ),
              ),

              const SizedBox(height: 17),

              const Text(
                'Email Verified!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 9),

              const Text(
                'Demo verification successful. Actual student account creation will be connected after backend setup.',
                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 12,
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
                ),

                child: const Text('Continue'),
              ),
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // RESEND OTP
  // ==========================================

  void _resendOtp() {
    if (secondsRemaining > 0) return;

    for (final controller in _controllers) {
      controller.clear();
    }

    setState(() {
      secondsRemaining = 60;
      errorMessage = null;
    });

    _startTimer();

    _focusNodes[0].requestFocus();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Demo OTP reset. No actual email was sent.',
        ),
      ),
    );
  }

  // ==========================================
  // FORMAT TIMER
  // ==========================================

  String get formattedTime {
    final minutes = secondsRemaining ~/ 60;
    final seconds = secondsRemaining % 60;

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  // ==========================================
  // OTP INPUT BOX
  // ==========================================

  Widget _otpInputBox(int index) {
    return SizedBox(
      width: 43,
      height: 51,

      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],

        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,

        maxLength: 1,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],

        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),

        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: Colors.white,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide: const BorderSide(
              color: AppColors.border,
            ),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide: BorderSide(
              color: errorMessage == null
                  ? AppColors.border
                  : AppColors.danger,
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 1.5,
            ),
          ),
        ),

        onChanged: (value) {
          _onOtpChanged(value, index);
        },
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

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context, false);
          },

          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 19,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 15,
          ),

          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 380,
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // LOGO

                  Container(
                    width: 70,
                    height: 70,

                    decoration: BoxDecoration(
                      gradient: AppColors.buttonGradient,
                      borderRadius: BorderRadius.circular(21),
                    ),

                    child: const Icon(
                      Icons.mark_email_read_outlined,
                      color: Colors.white,
                      size: 37,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // TITLE

                  const Text(
                    'Verify your email',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'We sent a six-digit verification code to:',
                    textAlign: TextAlign.center,

                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // EMAIL

                  Text(
                    widget.email,
                    textAlign: TextAlign.center,

                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 35),

                  // OTP LABEL

                  const Align(
                    alignment: Alignment.centerLeft,

                    child: Text(
                      'ENTER VERIFICATION CODE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 13),

                  // SIX OTP BOXES

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: List.generate(
                      6,
                      (index) => _otpInputBox(index),
                    ),
                  ),

                  // ERROR MESSAGE

                  if (errorMessage != null) ...[
                    const SizedBox(height: 12),

                    Align(
                      alignment: Alignment.centerLeft,

                      child: Text(
                        errorMessage!,
                        style: const TextStyle(
                          color: AppColors.danger,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 28),

                  // TIMER

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        color: AppColors.primary,
                        size: 19,
                      ),

                      const SizedBox(width: 7),

                      Text(
                        formattedTime,
                        style: TextStyle(
                          color: secondsRemaining == 0
                              ? AppColors.danger
                              : AppColors.primary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // VERIFY BUTTON

                  SizedBox(
                    width: 260,
                    height: 44,

                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppColors.buttonGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: ElevatedButton(
                        onPressed: _verifyOtp,

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
                          'Verify Email',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // RESEND CODE

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Didn't receive the code?",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      TextButton(
                        onPressed: secondsRemaining == 0
                            ? _resendOtp
                            : null,

                        child: Text(
                          'Resend Code',
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

                  const SizedBox(height: 17),

                  // DEMO NOTICE

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),

                    decoration: BoxDecoration(
                      color: const Color(0xFFF0EAFF),
                      borderRadius: BorderRadius.circular(11),
                    ),

                    child: const Column(
                      children: [
                        Text(
                          'DEMO MODE',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),

                        SizedBox(height: 5),

                        Text(
                          'Use 123456 to test verification. No actual OTP email is sent yet.',
                          textAlign: TextAlign.center,

                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
