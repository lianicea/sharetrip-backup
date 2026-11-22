
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ProfilePage extends StatelessWidget {
  final String studentName;
  final String schoolEmail;
  final String course;

  const ProfilePage({
    super.key,
    required this.studentName,
    required this.schoolEmail,
    required this.course,
  });

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Sign Out?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Are you sure you want to sign out?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      _showMessage(
        context,
        'Connect this action to your authentication flow.',
      );
    }
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _studentInfo(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Container(
            width: 37,
            height: 37,
            decoration: BoxDecoration(
              color: const Color(0xFFF0EAFF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 19,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = AppColors.primary,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 21,
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // PROFILE HEADER
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 25),
          decoration: const BoxDecoration(
            gradient: AppColors.headerGradient,
          ),
          child: const Text(
            'My Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // STUDENT INFORMATION
                _sectionTitle('STUDENT INFORMATION'),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(17),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 65,
                        height: 65,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0EAFF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: AppColors.primary,
                          size: 35,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        studentName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'STUDENT ACCOUNT',
                        style: TextStyle(
                          fontSize: 9,
                          letterSpacing: 1,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: AppColors.border),
                      const SizedBox(height: 15),

                      _studentInfo(
                        'School Email',
                        schoolEmail,
                        Icons.email_outlined,
                      ),
                      _studentInfo(
                        'School',
                        'CARD-MRI Development Institute',
                        Icons.school_outlined,
                      ),
                      _studentInfo(
                        'Course/Program',
                        course,
                        Icons.menu_book_outlined,
                      ),
                      _studentInfo(
                        'Year Level',
                        '3rd Year',
                        Icons.calendar_today_outlined,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // ACCOUNT MENU
                _sectionTitle('ACCOUNT'),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      _menuItem(
                        context,
                        icon: Icons.favorite_border,
                        title: 'Saved Places',
                        onTap: () => _showMessage(
                          context,
                          'Saved Places page is coming next.',
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.border),
                      _menuItem(
                        context,
                        icon: Icons.history,
                        title: 'Ride History',
                        onTap: () => _showMessage(
                          context,
                          'Ride History is coming next.',
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.border),
                      _menuItem(
                        context,
                        icon: Icons.edit_outlined,
                        title: 'Edit Profile',
                        onTap: () => _showMessage(
                          context,
                          'Edit Profile page is coming next.',
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.border),
                      _menuItem(
                        context,
                        icon: Icons.notifications_none,
                        title: 'Notifications',
                        onTap: () => _showMessage(
                          context,
                          'Use the Notifications tab below.',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // SUPPORT AND SETTINGS
                _sectionTitle('PREFERENCES & SUPPORT'),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      _menuItem(
                        context,
                        icon: Icons.shield_outlined,
                        title: 'Privacy & Safety',
                        onTap: () => _showMessage(
                          context,
                          'Privacy & Safety page is coming next.',
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.border),
                      _menuItem(
                        context,
                        icon: Icons.settings_outlined,
                        title: 'Settings',
                        onTap: () => _showMessage(
                          context,
                          'Settings page is coming next.',
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.border),
                      _menuItem(
                        context,
                        icon: Icons.help_outline,
                        title: 'Help & Support',
                        onTap: () => _showMessage(
                          context,
                          'Help & Support page is coming next.',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // SIGN OUT
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmSignOut(context),
                    icon: const Icon(
                      Icons.logout,
                      color: Colors.red,
                      size: 19,
                    ),
                    label: const Text(
                      'Sign Out',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
