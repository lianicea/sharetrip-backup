
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase authentication for ShareTrip Student and Driver accounts.
class ShareTripAuthService {
  ShareTripAuthService._();

  static final ShareTripAuthService instance =
      ShareTripAuthService._();

  static const String schoolEmailDomain = '@cmdi.edu.ph';

  SupabaseClient get _client => Supabase.instance.client;

  /// Normalize email by removing spaces and converting to lowercase.
  static String normalizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  /// Validate official CMDI school email.
  static bool isValidSchoolEmail(String email) {
    final normalizedEmail = normalizeEmail(email);

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@cmdi\.edu\.ph$',
      caseSensitive: false,
    );

    return emailRegex.hasMatch(normalizedEmail);
  }

  /// Register a new ShareTrip student or driver account.
  Future<AuthResponse> signUp({
    required String fullName,
    required String email,
    required String password,
    required String role,
    Map<String, dynamic> profileDetails =
        const <String, dynamic>{},
  }) async {
    final normalizedEmail = normalizeEmail(email);

    if (!isValidSchoolEmail(normalizedEmail)) {
      throw const AuthException(
        'Use your official CMDI school email (@cmdi.edu.ph).',
      );
    }

    if (fullName.trim().isEmpty) {
      throw const AuthException(
        'Please enter your complete name.',
      );
    }

    if (role != 'student' && role != 'driver') {
      throw const AuthException(
        'Invalid ShareTrip account role.',
      );
    }

    if (password.length < 8) {
      throw const AuthException(
        'Password must contain at least 8 characters.',
      );
    }

    return await _client.auth.signUp(
      email: normalizedEmail,
      password: password,
      data: <String, dynamic>{
        'full_name': fullName.trim(),
        'role': role,
        'details': profileDetails,
      },
    );
  }

  /// Verify signup OTP.
  Future<AuthResponse> verifySignupOtp({
    required String email,
    required String token,
  }) {
    return _client.auth.verifyOTP(
      email: normalizeEmail(email),
      token: token.trim(),
      type: OtpType.signup,
    );
  }

  /// Resend signup OTP.
  Future<void> resendSignupOtp(String email) {
    return _client.auth.resend(
      type: OtpType.signup,
      email: normalizeEmail(email),
    );
  }

  /// Sign in an existing account.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = normalizeEmail(email);

    if (!isValidSchoolEmail(normalizedEmail)) {
      throw const AuthException(
        'Use your official CMDI school email (@cmdi.edu.ph).',
      );
    }

    return _client.auth.signInWithPassword(
      email: normalizedEmail,
      password: password,
    );
  }

  /// Retrieve the user's profile.
  Future<Map<String, dynamic>> getProfile(
    String userId,
  ) async {
    final row = await _client
        .from('profiles')
        .select(
          'id, email, full_name, role, details, avatar_url',
        )
        .eq('id', userId)
        .maybeSingle();

    if (row == null) {
      throw const AuthException(
        'Profile was not found.',
      );
    }

    return Map<String, dynamic>.from(row);
  }

  /// Update additional profile details.
  Future<void> saveProfileDetails({
    required String userId,
    required Map<String, dynamic> details,
  }) async {
    await _client
        .from('profiles')
        .update(<String, dynamic>{
          'details': details,
        })
        .eq('id', userId);
  }

  /// Sign out current user.
  Future<void> signOut() {
    return _client.auth.signOut();
  }

  /// Current authenticated user.
  User? get currentUser => _client.auth.currentUser;

  /// Current authenticated session.
  Session? get currentSession => _client.auth.currentSession;
}
