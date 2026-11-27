
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/backend_config.dart';
import 'core/theme/app_theme.dart';
import 'features/authentication/welcome/welcome_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!BackendConfig.supabaseConfigured) {
    debugPrint('Supabase configuration is missing.');
    runApp(const ShareTripApp(supabaseReady: false));
    return;
  }

  try {
    await Supabase.initialize(
      url: BackendConfig.supabaseUrl,
      publishableKey: BackendConfig.supabasePublishableKey,
    );

    debugPrint('Supabase initialized successfully.');

    runApp(const ShareTripApp(supabaseReady: true));
  } catch (error) {
    debugPrint('Supabase initialization failed: $error');
    runApp(const ShareTripApp(supabaseReady: false));
  }
}

class ShareTripApp extends StatelessWidget {
  final bool supabaseReady;

  const ShareTripApp({
    super.key,
    this.supabaseReady = true,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShareTrip Student',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: supabaseReady
          ? const WelcomePage()
          : const SupabaseErrorPage(),
    );
  }
}

class SupabaseErrorPage extends StatelessWidget {
  const SupabaseErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.cloud_off_rounded,
                size: 60,
                color: Colors.red,
              ),
              SizedBox(height: 16),
              Text(
                'Backend Connection Unavailable',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Please check your Supabase URL and Publishable Key.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
