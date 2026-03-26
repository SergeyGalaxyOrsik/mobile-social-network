import 'package:flutter/foundation.dart';

import 'package:mobile_social_network/core/config/app_config.dart';
import 'package:mobile_social_network/core/config/dev_config.dart';
import 'package:mobile_social_network/core/config/prod_config.dart';

AppConfig resolveAppConfig() {
  const overrideUrl = String.fromEnvironment('API_BASE_URL');
  const overridePresignedOrigin = String.fromEnvironment(
    'PRESIGNED_UPLOAD_ORIGIN',
  );
  const env = String.fromEnvironment('APP_ENV', defaultValue: '');

  AppConfig base;
  if (env == 'prod') {
    base = const ProdAppConfig();
  } else if (env == 'dev') {
    base = const DevAppConfig();
  } else {
    base = kReleaseMode ? const ProdAppConfig() : const DevAppConfig();
  }

  final hasApiOverride = overrideUrl.isNotEmpty;
  final hasPresignedOverride = overridePresignedOrigin.isNotEmpty;
  if (!hasApiOverride && !hasPresignedOverride) {
    return base;
  }
  return _OverrideAppConfig(
    base: base,
    apiBaseUrl: hasApiOverride ? overrideUrl : base.apiBaseUrl,
    presignedUploadOrigin: hasPresignedOverride
        ? overridePresignedOrigin.trim()
        : base.presignedUploadOrigin,
  );
}

class _OverrideAppConfig extends AppConfig {
  _OverrideAppConfig({
    required this.base,
    required this.apiBaseUrl,
    required this.presignedUploadOrigin,
  });

  final AppConfig base;
  @override
  final String apiBaseUrl;
  @override
  final String presignedUploadOrigin;

  @override
  String get environmentLabel => '${base.environmentLabel}+override';
}
