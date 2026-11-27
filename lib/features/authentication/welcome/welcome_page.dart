
import '../registration/registration_page.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../login/login_page.dart';
import '../../driver/driver_portal_page.dart';
import '../../driver/driver_registration_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.headerGradient,
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 25,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 25),

                          // ShareTrip Logo
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: Colors.white24,
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.hub_outlined,
                              color: Colors.white,
                              size: 52,
                            ),
                          ),

                          const SizedBox(height: 25),

                          const Text(
                            'STUDENT RIDE PORTAL',
                            style: TextStyle(
                              fontSize: 12,
                              letterSpacing: 2,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                            ),
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            'ShareTrip',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            'Share the Ride. Connect with Students.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),

                          const SizedBox(height: 22),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified_user_outlined,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                SizedBox(width: 7),
                                Text(
                                  'School-verified community rides',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 65),

                          // Login Button
                          SizedBox(
                            width: 260,
                            height: 46,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: AppColors.buttonGradient,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const StudentLoginPage(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  'Log In',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Separate Driver Portal
                          SizedBox(
                            width: 260,
                            height: 46,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const DriverLoginPage(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.directions_car_outlined, size: 18),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.white.withValues(alpha: 0.07),
                                side: const BorderSide(color: Colors.white24),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              label: const Text(
                                'Driver Portal',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Register Button
                          SizedBox(
                            width: 260,
                            height: 46,
                            child: OutlinedButton(
                            onPressed: () async {
                                final role = await showModalBottomSheet<String>(
                                  context: context,
                                  builder: (sheetContext) => SafeArea(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          const Text('Register as', textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 14),
                                          OutlinedButton.icon(
                                            onPressed: () => Navigator.pop(sheetContext, 'student'),
                                            icon: const Icon(Icons.school_outlined),
                                            label: const Text('Student'),
                                          ),
                                          OutlinedButton.icon(
                                            onPressed: () => Navigator.pop(sheetContext, 'driver'),
                                            icon: const Icon(Icons.drive_eta_outlined),
                                            label: const Text('Driver'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                                if (!context.mounted || role == null) return;
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (_) => role == 'driver'
                                    ? const DriverRegistrationPage()
                                    : const StudentRegistrationPage(),
                                ));
                            },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.07),
                                side: const BorderSide(
                                  color: Colors.white24,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                'Register',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 35),

                          const Text(
                            'A safer and easier way to share your ride.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
