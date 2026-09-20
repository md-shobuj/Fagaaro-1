import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

class CertPinningHelper {
  // Pinned SHA-256 fingerprints of the server's leaf/intermediate certificates.
  // Format: lowercase hex string without colons.
  // ALWAYS include at least one backup fingerprint to prevent breaking the app on cert rotation.
  static const List<String> _allowedFingerprints = [
    'e0f6c2c8f8b3df9e623194a28f801ad4bfd91d6cb257008ff773b06061be9c4b', // Primary Fingerprint example
    'a5d9472feea98a964f434771f2ff26194b15c92823a9d90161a0fb62d2946bd7', // Backup Fingerprint example
  ];

  /// Configures SSL Certificate Pinning on the [Dio] instance.
  /// If [enablePinning] is true and [kDebugMode] is false, we restrict connection
  /// only to certificates whose SHA-256 fingerprint matches [_allowedFingerprints].
  static void setupPinning(Dio dio, {required bool enablePinning}) {
    if (kIsWeb) return; // Certificate pinning is handled by the browser on the web.

    if (dio.httpClientAdapter is! IOHttpClientAdapter) return;

    (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (client) {
      if (enablePinning && !kDebugMode) {
        // Enforce pinning by starting with an empty SecurityContext that has NO trusted roots.
        // This forces every SSL connection to fail standard OS trust verification,
        // triggering [badCertificateCallback] where we perform our fingerprint check.
        final context = SecurityContext(withTrustedRoots: false);
        final secureClient = HttpClient(context: context);

        secureClient.badCertificateCallback = (X509Certificate cert, String host, int port) {
          final derBytes = cert.der;
          final fingerprint = sha256.convert(derBytes).toString().toLowerCase().replaceAll(':', '');

          if (_allowedFingerprints.contains(fingerprint)) {
            return true; // Trusted certificate match
          }
          return false; // Connection rejected
        };
        
        // Match timeout configs
        secureClient.connectionTimeout = dio.options.connectTimeout;
        return secureClient;
      } else {
        // For development or if pinning is explicitly disabled:
        // Allow using standard OS trust roots, and if a proxy certificate (Charles/Proxyman) is used,
        // we allow it so developers can inspect network traffic.
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        return client;
      }
    };
  }
}
