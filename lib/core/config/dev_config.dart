import 'package:flutter/foundation.dart';

import 'package:mobile_social_network/core/config/app_config.dart';

class DevAppConfig extends AppConfig {
  const DevAppConfig();

  static const int _defaultPort = 3000;

  @override
  String get apiBaseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:$_defaultPort';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:$_defaultPort';
      default:
        return 'http://127.0.0.1:$_defaultPort';
    }
  }

  @override
  String get presignedUploadOrigin => 'http://127.0.0.1:9000';

  @override
  String get environmentLabel => 'dev';
}
