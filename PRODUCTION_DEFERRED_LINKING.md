# Production Deferred Deep Linking Implementation

Complete guide for implementing server-side deferred deep linking for both Android and iOS.

## Architecture Overview

```
User clicks link → Server generates token → Stores token + destination
                                          ↓
                            Redirect to App Store with token
                                          ↓
                            User installs app
                                          ↓
                App first launch → Reads install referrer (Android) or clipboard (iOS)
                                          ↓
                            App pings server with token
                                          ↓
                            Server returns destination
                                          ↓
                            App navigates to destination
```

---

## Part 1: Server-Side Implementation

### 1.1 Database Schema (Use PostgreSQL/MongoDB/Redis)

```sql
-- PostgreSQL Example
CREATE TABLE deferred_links (
    token VARCHAR(64) PRIMARY KEY,
    university_id VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    used_at TIMESTAMP,
    device_info JSONB,
    expires_at TIMESTAMP DEFAULT NOW() + INTERVAL '7 days'
);

-- Index for performance
CREATE INDEX idx_expires_at ON deferred_links(expires_at);
```

### 1.2 Server Endpoints (Node.js/Express)

```javascript
// server.js additions

const crypto = require('crypto');
const { Pool } = require('pg'); // or use Redis

// Database connection
const pool = new Pool({
  connectionString: process.env.DATABASE_URL
});

// Generate unique token
function generateToken() {
  return crypto.randomBytes(32).toString('hex');
}

// ===== ENDPOINT 1: Create Deferred Link =====
app.get('/uni/:universityId', async (req, res) => {
  const { universityId } = req.params;
  const university = universities[universityId.toLowerCase()];

  if (!university) {
    return res.status(404).send('University not found');
  }

  // Generate token
  const token = generateToken();

  // Store in database
  await pool.query(
    'INSERT INTO deferred_links (token, university_id) VALUES ($1, $2)',
    [token, universityId]
  );

  const deepLink = `unilinker://university/${universityId.toLowerCase()}`;

  // Detect platform
  const userAgent = req.headers['user-agent'] || '';
  const isAndroid = /android/i.test(userAgent);
  const isIOS = /iphone|ipad|ipod/i.test(userAgent);

  // Render page with smart app store redirects
  res.send(`
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Opening ${university.name} in UniLinker...</title>
      <style>
        /* Same styling as before */
      </style>
      <script>
        const deepLink = '${deepLink}';
        const token = '${token}';
        const isAndroid = ${isAndroid};
        const isIOS = ${isIOS};

        // Try to open the app
        let appOpened = false;
        window.location.href = deepLink;

        // Detect if app opened
        document.addEventListener('visibilitychange', function() {
          if (document.hidden) {
            appOpened = true;
          }
        });

        // If app didn't open, redirect to store
        setTimeout(function() {
          if (!appOpened && !document.hidden) {
            if (isAndroid) {
              // Android Play Store with install referrer
              const playStoreUrl = 'https://play.google.com/store/apps/details?id=com.unilinker.app&referrer=deferred_token%3D' + token;
              window.location.href = playStoreUrl;
            } else if (isIOS) {
              // iOS App Store
              const appStoreUrl = 'https://apps.apple.com/app/unilinker/id123456789';

              // Store token in clipboard for iOS (workaround)
              navigator.clipboard.writeText('unilinker_token:' + token);

              window.location.href = appStoreUrl;
            } else {
              // Show manual install prompt
              document.getElementById('install-prompt').style.display = 'block';
            }
          }
        }, 2500);
      </script>
    </head>
    <body>
      <div class="container">
        <h1>Opening ${university.name}...</h1>
        <div id="install-prompt" style="display: none;">
          <p>Install UniLinker to view ${university.name}</p>
          ${isAndroid ? `<a href="https://play.google.com/store/apps/details?id=com.unilinker.app&referrer=deferred_token%3D${token}">Download on Google Play</a>` : ''}
          ${isIOS ? `<a href="https://apps.apple.com/app/unilinker/id123456789">Download on App Store</a>` : ''}
        </div>
      </div>
    </body>
    </html>
  `);
});

// ===== ENDPOINT 2: Resolve Deferred Link =====
app.get('/api/resolve-deferred-link/:token', async (req, res) => {
  const { token } = req.params;

  try {
    // Query database
    const result = await pool.query(
      `SELECT university_id, used_at, expires_at
       FROM deferred_links
       WHERE token = $1`,
      [token]
    );

    if (result.rows.length === 0) {
      return res.json({ success: false, message: 'Token not found' });
    }

    const link = result.rows[0];

    // Check if expired
    if (new Date() > new Date(link.expires_at)) {
      return res.json({ success: false, message: 'Token expired' });
    }

    // Check if already used
    if (link.used_at) {
      return res.json({ success: false, message: 'Token already used' });
    }

    // Mark as used
    await pool.query(
      'UPDATE deferred_links SET used_at = NOW() WHERE token = $1',
      [token]
    );

    // Return destination
    res.json({
      success: true,
      universityId: link.university_id,
      deepLink: `unilinker://university/${link.university_id}`
    });

  } catch (error) {
    console.error('Error resolving deferred link:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// ===== ENDPOINT 3: Analytics (Optional) =====
app.post('/api/track-install', async (req, res) => {
  const { token, deviceInfo } = req.body;

  await pool.query(
    'UPDATE deferred_links SET device_info = $1 WHERE token = $2',
    [deviceInfo, token]
  );

  res.json({ success: true });
});
```

---

## Part 2: Android Implementation

### 2.1 Add Dependencies (android/app/build.gradle)

```gradle
dependencies {
    // Install Referrer API
    implementation 'com.android.installreferrer:installreferrer:2.2'

    // Existing dependencies...
}
```

### 2.2 Read Install Referrer (Create InstallReferrerHelper.kt)

```kotlin
// android/app/src/main/kotlin/com/unilinker/app/InstallReferrerHelper.kt

package com.unilinker.app

import android.content.Context
import com.android.installreferrer.api.InstallReferrerClient
import com.android.installreferrer.api.InstallReferrerStateListener
import io.flutter.plugin.common.MethodChannel

class InstallReferrerHelper(private val context: Context) {

    fun getInstallReferrer(result: MethodChannel.Result) {
        val referrerClient = InstallReferrerClient.newBuilder(context).build()

        referrerClient.startConnection(object : InstallReferrerStateListener {
            override fun onInstallReferrerSetupFinished(responseCode: Int) {
                when (responseCode) {
                    InstallReferrerClient.InstallReferrerResponse.OK -> {
                        try {
                            val response = referrerClient.installReferrer
                            val referrer = response.installReferrer

                            // Parse: deferred_token=abc123
                            val token = extractToken(referrer)

                            result.success(token)
                            referrerClient.endConnection()
                        } catch (e: Exception) {
                            result.error("ERROR", e.message, null)
                        }
                    }
                    else -> {
                        result.success(null)
                        referrerClient.endConnection()
                    }
                }
            }

            override fun onInstallReferrerServiceDisconnected() {
                result.success(null)
            }
        })
    }

    private fun extractToken(referrer: String): String? {
        // Parse: deferred_token=abc123
        val match = Regex("deferred_token=([^&]+)").find(referrer)
        return match?.groupValues?.get(1)
    }
}
```

### 2.3 Register Method Channel (MainActivity.kt)

```kotlin
// android/app/src/main/kotlin/com/unilinker/app/MainActivity.kt

package com.unilinker.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.unilinker.app/deferred_link"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getInstallReferrer" -> {
                        val helper = InstallReferrerHelper(this)
                        helper.getInstallReferrer(result)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
```

---

## Part 3: iOS Implementation

### 3.1 Universal Links Setup (Info.plist)

```xml
<!-- ios/Runner/Info.plist -->
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:unilinker.app</string>
    <string>applinks:www.unilinker.app</string>
</array>
```

### 3.2 Apple App Site Association File

Create and host at: `https://unilinker.app/.well-known/apple-app-site-association`

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAM_ID.com.unilinker.app",
        "paths": ["/uni/*"]
      }
    ]
  }
}
```

### 3.3 Handle Universal Links (AppDelegate.swift)

```swift
// ios/Runner/AppDelegate.swift

import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

  private var deferredToken: String?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(
      name: "com.unilinker.app/deferred_link",
      binaryMessenger: controller.binaryMessenger
    )

    channel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in

      if call.method == "getDeferredToken" {
        // Check clipboard for token (workaround method)
        if let token = self.checkClipboardForToken() {
          result(token)
        } else {
          result(nil)
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Universal Links handler
  override func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {

    if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
      if let url = userActivity.webpageURL {
        // Extract token from URL: https://unilinker.app/uni/harvard?token=abc123
        if let token = extractToken(from: url) {
          self.deferredToken = token
        }
      }
    }

    return true
  }

  private func extractToken(from url: URL) -> String? {
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
      return nil
    }
    return components.queryItems?.first(where: { $0.name == "token" })?.value
  }

  private func checkClipboardForToken() -> String? {
    // Check if clipboard contains our token
    if let clipboard = UIPasteboard.general.string {
      if clipboard.hasPrefix("unilinker_token:") {
        let token = clipboard.replacingOccurrences(of: "unilinker_token:", with: "")
        // Clear clipboard after reading
        UIPasteboard.general.string = ""
        return token
      }
    }
    return nil
  }
}
```

---

## Part 4: Flutter App Implementation

### 4.1 Add Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  go_router: ^14.6.2
  shared_preferences: ^2.2.2
  http: ^1.1.0

  # Platform-specific
  device_info_plus: ^9.1.0  # For device ID (optional)
```

### 4.2 Create Deferred Link Service

```dart
// lib/services/deferred_link_service.dart

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DeferredLinkService {
  static const platform = MethodChannel('com.unilinker.app/deferred_link');
  static const String baseUrl = 'https://unilinker.app'; // Your production URL

  /// Check for deferred deep link on app launch
  static Future<String?> checkDeferredDeepLink() async {
    final prefs = await SharedPreferences.getInstance();

    // Only check on first launch
    final isFirstLaunch = prefs.getBool('first_launch') ?? true;
    if (!isFirstLaunch) {
      return null;
    }

    try {
      // Get platform-specific token
      String? token;

      // Android: Read install referrer
      if (await _isAndroid()) {
        token = await platform.invokeMethod('getInstallReferrer');
      }
      // iOS: Check clipboard or universal link
      else if (await _isIOS()) {
        token = await platform.invokeMethod('getDeferredToken');
      }

      if (token != null && token.isNotEmpty) {
        // Resolve token with server
        final universityId = await _resolveToken(token);

        // Mark first launch as complete
        await prefs.setBool('first_launch', false);

        return universityId;
      }

      // Mark first launch as complete even if no token
      await prefs.setBool('first_launch', false);
      return null;

    } catch (e) {
      print('Error checking deferred deep link: $e');
      await prefs.setBool('first_launch', false);
      return null;
    }
  }

  /// Resolve token with server
  static Future<String?> _resolveToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/resolve-deferred-link/$token'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['universityId'];
        }
      }
      return null;
    } catch (e) {
      print('Error resolving token: $e');
      return null;
    }
  }

  static Future<bool> _isAndroid() async {
    try {
      return Theme.of(NavigationService.navigatorKey.currentContext!).platform == TargetPlatform.android;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> _isIOS() async {
    try {
      return Theme.of(NavigationService.navigatorKey.currentContext!).platform == TargetPlatform.iOS;
    } catch (e) {
      return false;
    }
  }
}
```

### 4.3 Update Main App (main.dart)

```dart
// lib/main.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'services/deferred_link_service.dart';
// ... other imports

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check for deferred deep link
  final universityId = await DeferredLinkService.checkDeferredDeepLink();

  // Set initial location if deferred link exists
  final initialLocation = universityId != null
      ? '/university/$universityId'
      : '/';

  runApp(MyApp(initialLocation: initialLocation));
}

class MyApp extends StatelessWidget {
  final String initialLocation;

  const MyApp({super.key, required this.initialLocation});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'UniLinker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      routerConfig: _createRouter(initialLocation),
    );
  }

  GoRouter _createRouter(String initialLocation) {
    return GoRouter(
      initialLocation: initialLocation,
      redirect: (context, state) {
        final uri = state.uri;
        if (uri.scheme == 'unilinker') {
          final host = uri.host;
          final path = uri.path;
          return '/$host$path';
        }
        return null;
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomePage()),
        GoRoute(path: '/universities', builder: (context, state) => const UniversityPage()),
        GoRoute(
          path: '/university/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']?.toLowerCase();
            final universities = getAllUniversities();
            final university = universities.firstWhere(
              (uni) => uni.shortName.toLowerCase() == id,
              orElse: () => universities[0],
            );
            return UniversityDetailPage(university: university);
          },
        ),
      ],
    );
  }
}
```

---

## Part 5: Testing

### 5.1 Local Testing with ngrok

```bash
# Expose local server to internet
npx ngrok http 3000

# Output: https://abc123.ngrok.io
# Use this URL in testing
```

### 5.2 Test Flow

```bash
# 1. Uninstall app
adb uninstall com.unilinker.app

# 2. Open link in browser (use ngrok URL)
# https://abc123.ngrok.io/uni/harvard

# 3. Redirects to Play Store with token:
# market://details?id=com.unilinker.app&referrer=deferred_token%3Dabc123

# 4. Install app (or sideload for testing)
flutter build apk
adb install build/app/outputs/flutter-apk/app-release.apk

# 5. Open app - should navigate to Harvard automatically ✅
```

---

## Part 6: Production Checklist

### Server
- [ ] Deploy to production (Heroku, AWS, Google Cloud)
- [ ] Use PostgreSQL/Redis for token storage
- [ ] Set up SSL certificate (HTTPS required)
- [ ] Configure CORS if needed
- [ ] Add rate limiting to prevent abuse
- [ ] Set token expiration (7 days recommended)
- [ ] Add analytics tracking

### Android
- [ ] Publish app to Google Play Store
- [ ] Configure Play Store listing with correct package ID
- [ ] Test install referrer in production
- [ ] Add Firebase for better tracking (optional)

### iOS
- [ ] Publish app to Apple App Store
- [ ] Upload apple-app-site-association file
- [ ] Verify with Apple: https://search.validator.apple.com/
- [ ] Test universal links in production
- [ ] Add Firebase Dynamic Links (alternative)

### App
- [ ] Add error handling for network failures
- [ ] Add loading states during token resolution
- [ ] Track deferred link conversions
- [ ] Add fallback for expired tokens
- [ ] Test first launch vs regular launch

---

## Part 7: Alternative: Use Branch.io (Recommended for Beginners)

Branch.io handles all of this automatically:

```yaml
# pubspec.yaml
dependencies:
  flutter_branch_sdk: ^6.0.0
```

```dart
// Setup in 10 minutes
await FlutterBranchSdk.init();

// Create link
BranchUniversalObject buo = BranchUniversalObject(
  canonicalIdentifier: 'university/harvard',
  title: 'Harvard University',
);

BranchLinkProperties lp = BranchLinkProperties();
BranchResponse response = await buo.generateLink(lp);

// Handle deferred link
FlutterBranchSdk.initSession().listen((data) {
  if (data.containsKey('university_id')) {
    // Navigate to university
  }
});
```

Branch.io Free Tier:
- 10,000 monthly active users
- Full attribution
- Works iOS + Android
- No server code needed

---

## Summary

**Custom Implementation:**
- Full control
- No third-party dependencies
- More complex setup
- Requires server maintenance

**Branch.io/AppsFlyer:**
- Quick setup (2 hours)
- Automatic attribution
- Analytics included
- Free tier available

**Recommendation:** Start with Branch.io for MVP, build custom solution if you need specific features or want to avoid vendor lock-in.
