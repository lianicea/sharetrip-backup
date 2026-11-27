class BackendConfig {
  static const String supabaseUrl =
      String.fromEnvironment('SUPABASE_URL');

  static const String supabasePublishableKey =
      String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  static bool get supabaseConfigured {
    return supabaseUrl.startsWith('https://') &&
        supabasePublishableKey.startsWith('sb_publishable_');
  }
}