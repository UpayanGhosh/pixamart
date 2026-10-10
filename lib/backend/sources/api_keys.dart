/// API keys are injected at build time, never committed:
///   flutter build apk --dart-define-from-file=api_keys.json
class ApiKeys {
  static const String pexels = String.fromEnvironment('PEXELS_API_KEY');
  static const String unsplash = String.fromEnvironment('UNSPLASH_ACCESS_KEY');
  static const String pixabay = String.fromEnvironment('PIXABAY_API_KEY');
}
