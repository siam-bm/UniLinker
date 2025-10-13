# Deferred Deep Linking Guide

## What is Deferred Deep Linking?

**Regular Deep Linking**: User clicks link → App opens to specific page
**Deferred Deep Linking**: User clicks link → App not installed → Installs app → App opens to specific page

## How It Works

### The Process

```
1. User clicks: http://localhost:3000/uni/harvard
2. Browser tries: unilinker://university/harvard
3. App not found → Show install prompt
4. User installs app
5. App first launch → Navigate to Harvard page
```

### Technical Implementation

**Browser Side (Current Implementation)**:
```javascript
// Store intended destination in browser localStorage
localStorage.setItem('unilinker_deferred_link', 'unilinker://university/harvard');
localStorage.setItem('unilinker_deferred_university', 'harvard');
```

**Challenge**: Browser localStorage ≠ App storage (different contexts)

### Production Solutions

#### Option 1: Server-Side Tracking (Recommended)
```
1. Browser → Server: "User clicked Harvard link"
2. Server generates unique token, stores: {token: "abc123", destination: "harvard"}
3. Redirect to Play Store with token: market://details?id=com.unilinker.app&referrer=deferred_link%3Dabc123
4. After install, app pings server: "New install, any deferred links for abc123?"
5. Server responds: {destination: "harvard"}
6. App navigates to Harvard
```

#### Option 2: Firebase Dynamic Links (Deprecated but still works)
```
1. Create Dynamic Link: https://unilinker.page.link/harvard
2. Firebase handles app install tracking
3. Firebase SDK in app retrieves deferred link
4. App navigates to Harvard
```

#### Option 3: Branch.io or AppsFlyer
```
- Third-party services that handle deferred deep linking
- Track clicks, installs, and deliver deep link data
- Provide analytics and attribution
```

#### Option 4: Play Install Referrer API
```
1. Add install referrer to Play Store link
2. App reads referrer on first launch
3. Parse and navigate to destination
```

## Local Testing Guide

### Setup 1: Test with App Installed

**This works perfectly now:**

```bash
# 1. Start server
cd deeplink-server && npm start

# 2. Run app
flutter run

# 3. Test from emulator browser
# Open: http://10.0.2.2:3000/uni/harvard
# Result: App opens to Harvard page ✅
```

### Setup 2: Test Deferred Deep Linking (Simulation)

**Step 1: Prepare the link**
```bash
# Open emulator browser
# Navigate to: http://10.0.2.2:3000/uni/buet
# See "Download & Install App" button
```

**Step 2: Uninstall the app**
```bash
adb uninstall com.unilinker.app
```

**Step 3: Click the link again**
```bash
# Browser shows: "Get UniLinker" with install button
# localStorage stores: unilinker://university/buet
```

**Step 4: Build and install APK**
```bash
flutter build apk
adb install build/app/outputs/flutter-apk/app-release.apk
```

**Step 5: Test the stored link**
```bash
# After installation, manually trigger the deep link
adb shell am start -W -a android.intent.action.VIEW -d "unilinker://university/buet"
# Result: App opens to BUET page ✅
```

**Note**: True deferred deep linking (automatic navigation after install) requires server-side tracking.

### Setup 3: Full Deferred Deep Linking (Requires Implementation)

**What you'd need to add:**

1. **Server endpoint to store pending links**:
```javascript
// server.js
const pendingLinks = new Map();

app.post('/api/store-deferred-link', (req, res) => {
  const { deviceId, universityId } = req.body;
  pendingLinks.set(deviceId, universityId);
  res.json({ success: true });
});

app.get('/api/check-deferred-link/:deviceId', (req, res) => {
  const universityId = pendingLinks.get(req.params.deviceId);
  if (universityId) {
    pendingLinks.delete(req.params.deviceId);
    res.json({ universityId });
  } else {
    res.json({ universityId: null });
  }
});
```

2. **Flutter app checks on first launch**:
```dart
// lib/main.dart
import 'package:shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;

Future<void> checkDeferredDeepLink() async {
  final prefs = await SharedPreferences.getInstance();
  final isFirstLaunch = prefs.getBool('first_launch') ?? true;

  if (isFirstLaunch) {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    final deviceId = androidInfo.id;

    // Check server for pending deep link
    final response = await http.get(
      Uri.parse('http://10.0.2.2:3000/api/check-deferred-link/$deviceId')
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['universityId'] != null) {
        // Navigate to university
        router.go('/university/${data['universityId']}');
      }
    }

    prefs.setBool('first_launch', false);
  }
}
```

## Current State Summary

### ✅ What Works Now

- **Regular Deep Linking**: Click link → App opens to correct page
- **App Detection**: Browser detects if app is installed
- **Install Prompt**: Shows download option when app not found
- **Link Storage**: Browser stores intended destination

### ⚠️ What Needs Implementation for Full Deferred Deep Linking

- **Server-side link storage**: Database to store pending links
- **Device identification**: Track which device should get which link
- **First launch detection**: App checks for deferred links on first run
- **Server communication**: App pings server for pending deep links

## Testing Checklist

### Test 1: Regular Deep Linking (App Installed)
- [ ] Start server: `npm start`
- [ ] Run app: `flutter run`
- [ ] Open emulator browser: `http://10.0.2.2:3000`
- [ ] Click Harvard → Verify app opens to Harvard page
- [ ] Click BUET → Verify app opens to BUET page
- [ ] Click UIU → Verify app opens to UIU page

### Test 2: Install Detection (App Not Installed)
- [ ] Uninstall app: `adb uninstall com.unilinker.app`
- [ ] Open emulator browser: `http://10.0.2.2:3000/uni/harvard`
- [ ] Verify: Shows "Get UniLinker" with install button
- [ ] Verify: localStorage contains the deep link
- [ ] Check browser console: `localStorage.getItem('unilinker_deferred_link')`

### Test 3: Manual Deep Link After Install
- [ ] Build APK: `flutter build apk`
- [ ] Install: `adb install build/app/outputs/flutter-apk/app-release.apk`
- [ ] Trigger deep link: `adb shell am start -W -a android.intent.action.VIEW -d "unilinker://university/harvard"`
- [ ] Verify: App opens to Harvard page

## Production Deployment

For production, you'd implement one of:

1. **Custom Server Solution**
   - Cost: Low (your own server)
   - Complexity: High
   - Control: Full

2. **Branch.io**
   - Cost: Free tier available
   - Complexity: Medium (SDK integration)
   - Features: Analytics, attribution, A/B testing
   - Setup: ~2 hours

3. **AppsFlyer**
   - Cost: Paid plans
   - Complexity: Medium
   - Features: Advanced attribution, fraud prevention
   - Setup: ~3 hours

4. **Play Install Referrer**
   - Cost: Free (Google service)
   - Complexity: Low
   - Limitation: Android only
   - Setup: ~1 hour

## Recommended Approach

**For Local Testing**: Current implementation works perfectly

**For Production**:
1. Start with **Branch.io** (easiest, free tier, cross-platform)
2. If budget allows, upgrade to **AppsFlyer** for advanced features
3. Or implement **custom server solution** for full control

## Key Takeaways

- **Current implementation**: Perfect for regular deep linking
- **Deferred deep linking**: Requires server-side component
- **Local testing**: Simulated by manually triggering links after install
- **Production**: Use Branch.io or similar service for automatic deferred deep linking