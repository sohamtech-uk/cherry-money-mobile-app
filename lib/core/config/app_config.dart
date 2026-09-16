class AppConfig {
  final String environment;
  final String apiBaseUrl;
  final String iosKey;
  final String androidKey;
  const AppConfig({
    this.environment = const String.fromEnvironment(
      'CHERRY_ENV',
      defaultValue: 'development',
    ),
    String apiBaseUrl = const String.fromEnvironment('CHERRY_API_BASE_URL'),
    this.iosKey = const String.fromEnvironment('REVENUECAT_IOS_API_KEY'),
    this.androidKey = const String.fromEnvironment(
      'REVENUECAT_ANDROID_API_KEY',
    ),
  }) : apiBaseUrl = apiBaseUrl == ''
           ? (environment == 'production'
                 ? 'https://cherrymoney.co.uk/api/'
                 : 'https://dev.cherrymoney.co.uk/api/')
           : apiBaseUrl;
  static const proEntitlement = 'pro';
  static const businessEntitlement = 'business';
  bool get valid =>
      ['development', 'production'].contains(environment) &&
      Uri.tryParse(apiBaseUrl)?.scheme == 'https' &&
      apiBaseUrl.endsWith('/');
}
