import 'dart:io';
import 'package:flutter/foundation.dart';

class UrlConfig {
  static final String baseUrl = _initBaseUrl();

  static String _initBaseUrl() {
    if (kDebugMode) {
      if (kIsWeb || Platform.isIOS) {
        return 'https://movix-backend-prod.up.railway.app';
      } else if (Platform.isAndroid) {
        return 'https://movix-backend-prod.up.railway.app';
      } else {
        return 'https://movix-backend-prod.up.railway.app';
      }
    } else {
      return 'https://movix-backend-prod.up.railway.app';
    }
  }

  static Uri getApiUrl(String endpoint) {
    return Uri.parse('$baseUrl/$endpoint');
  }
}
