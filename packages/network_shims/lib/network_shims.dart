import 'dart:io' show SecurityContext;

import 'src/certificate_pinning.dart' as pinning;
import 'src/models.dart';
import 'src/secure_http_client.dart';

// لا تصدّر أي ملف يعتمد على Request/StreamedResponse مخصّصين أو على dart:_http

export 'src/models.dart';

export 'src/secure_http_client.dart';

SecureHttpClient? getSecureHttpClient({
  required List<CertificatePinningPolicy> pinningPolicies,
  SecurityContext? securityContext,
  Duration connectTimeout = const Duration(seconds: 10),
  Duration idleTimeout = const Duration(seconds: 30),
  bool allowUnpinnedClients = false,
}) {
  return pinning.getSecureHttpClient(
    pinningPolicies: pinningPolicies,
    securityContext: securityContext,
    connectTimeout: connectTimeout,
    idleTimeout: idleTimeout,
    allowUnpinnedClients: allowUnpinnedClients,
  );
}

