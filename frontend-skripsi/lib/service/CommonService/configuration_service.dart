import 'dart:io';
import 'package:flutter/foundation.dart';

class UrlConfig {
  static final String baseUrl = _initBaseUrl();

  static String _initBaseUrl() {
    if (kDebugMode) {
      if (kIsWeb || Platform.isIOS) {
        return 'http://localhost:3005'; 
      } 
      else if (Platform.isAndroid) {
        return 'http://10.0.2.2:3005';
      } 
      else {
        return 'http://192.168.x.x:3005'; 
      }
    } 
    else {
      return 'https://buat-prod.com';
    }
  }

  static Uri getApiUrl(String endpoint) {
    return Uri.parse('$baseUrl/$endpoint');
  }
}
