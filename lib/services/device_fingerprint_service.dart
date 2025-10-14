import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;

class DeviceFingerprintService {
  // Change this to your production server URL
  static const String baseUrl = 'http://localhost:3000';
  
  /// Collect device fingerprint data
  static Future<Map<String, dynamic>> collectFingerprint() async {
    final deviceInfo = DeviceInfoPlugin();
    
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return {
        'userAgent': 'Android ${androidInfo.version.release}',
        'screenResolution': '${androidInfo.displayMetrics.widthPx}x${androidInfo.displayMetrics.heightPx}',
        'timezone': DateTime.now().timeZoneName,
        'language': Platform.localeName,
        'platform': 'Android',
        'colorDepth': 24, // Standard for modern devices
        'pixelRatio': androidInfo.displayMetrics.densityDpi / 160,
      };
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return {
        'userAgent': '${iosInfo.systemName} ${iosInfo.systemVersion}',
        'screenResolution': '${iosInfo.model}', // iOS doesn't expose exact resolution easily
        'timezone': DateTime.now().timeZoneName,
        'language': Platform.localeName,
        'platform': 'iOS',
        'colorDepth': 24,
        'pixelRatio': 2.0, // Most iOS devices are 2x or 3x
      };
    }
    
    // Fallback for other platforms
    return {
      'userAgent': Platform.operatingSystem,
      'screenResolution': 'unknown',
      'timezone': DateTime.now().timeZoneName,
      'language': Platform.localeName,
      'platform': Platform.operatingSystem,
      'colorDepth': 24,
      'pixelRatio': 1.0,
    };
  }
  
  /// Check for deferred deep link on server
  static Future<String?> checkDeferredDeepLink() async {
    try {
      // Collect device fingerprint
      final fingerprint = await collectFingerprint();
      
      print('Checking for deferred link with fingerprint: ${fingerprint['platform']}');
      
      // Send to server
      final response = await http.post(
        Uri.parse('$baseUrl/api/check-deferred-link'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'fingerprint': fingerprint}),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          print('Deferred link found: ${data['universityId']}');
          return data['universityId'];
        } else {
          print('No deferred link found: ${data['message']}');
        }
      } else {
        print('Server error: ${response.statusCode}');
      }
      
      return null;
    } catch (e) {
      print('Error checking deferred link: $e');
      return null;
    }
  }
}

