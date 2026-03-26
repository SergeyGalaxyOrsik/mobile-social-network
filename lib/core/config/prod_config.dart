import 'package:mobile_social_network/core/config/app_config.dart';

class ProdAppConfig extends AppConfig {
  const ProdAppConfig();

  @override
  String get apiBaseUrl => 'https://api.example.com';

  @override
  String get presignedUploadOrigin => '';

  @override
  String get environmentLabel => 'prod';
}
