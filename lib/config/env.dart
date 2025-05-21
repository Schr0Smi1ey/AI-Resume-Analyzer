class Env {
  static String get aiApiKey {
    const key = String.fromEnvironment('OPENROUTER_API_KEY');
    if (key.isEmpty) throw Exception('API key not set');
    return key;
  }
}
