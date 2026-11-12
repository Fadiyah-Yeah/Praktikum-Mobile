
class AppConfig {
  AppConfig._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
  );

  static const String supabaseKey = String.fromEnvironment(
    'SUPABASE_KEY',
  );

  static const String apiBaseUrl =
      'https://rickandmortyapi.com/api';
}