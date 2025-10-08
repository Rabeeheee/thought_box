class EnvConfig {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://api.exconvert.com',
  );
  
  static const String accessKey = String.fromEnvironment(
    'ACCESS_KEY',
    defaultValue: '270ca084-96a82de7-ae4aff0f-60b941d9',
  );
  
  static const bool useMockData = String.fromEnvironment(
    'USE_MOCK',
    defaultValue: 'false',
  ) == 'true';
}