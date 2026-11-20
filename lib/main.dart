
import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/authentication/welcome/welcome_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ShareTripApp());
}

class ShareTripApp extends StatelessWidget {
  const ShareTripApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShareTrip Student',

      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,

      home: const WelcomePage(),
    );
  }
}
