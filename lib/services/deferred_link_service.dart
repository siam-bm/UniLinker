import 'package:shared_preferences/shared_preferences.dart';
import 'device_fingerprint_service.dart';

class DeferredLinkService {
  static const String _firstLaunchKey = 'first_launch';
  
  /// Check for deferred deep link on first app launch
  static Future<String?> checkForDeferredLink() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if this is the first launch
    final isFirstLaunch = prefs.getBool(_firstLaunchKey) ?? true;
    
    if (!isFirstLaunch) {
      print('Not first launch, skipping deferred link check');
      return null;
    }
    
    print('First launch detected, checking for deferred link...');
    
    try {
      // Check server for deferred deep link using device fingerprint
      final universityId = await DeviceFingerprintService.checkDeferredDeepLink();
      
      // Mark first launch as complete (regardless of result)
      await prefs.setBool(_firstLaunchKey, false);
      
      if (universityId != null) {
        print('Deferred link resolved: $universityId');
        return universityId;
      } else {
        print('No deferred link found');
        return null;
      }
    } catch (e) {
      print('Error checking deferred link: $e');
      // Mark first launch as complete even on error
      await prefs.setBool(_firstLaunchKey, false);
      return null;
    }
  }
  
  /// Reset first launch flag (useful for testing)
  static Future<void> resetFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstLaunchKey, true);
    print('First launch flag reset');
  }
}

