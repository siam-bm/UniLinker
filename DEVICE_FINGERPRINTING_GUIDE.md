# Device Fingerprinting for Deferred Deep Linking

This implementation uses device fingerprinting to track install attribution across iOS and Android.

## How It Works

### 1. User Clicks Link (Pre-Install)
- Browser collects device fingerprint (user agent, screen resolution, timezone, language, platform)
- Fingerprint is sent to server via `/api/store-deferred-link`
- Server creates SHA-256 hash of fingerprint and stores mapping: `hash → university destination`
- Browser attempts to open app (fails if not installed)
- User clicks install button → App Store

### 2. User Installs App

### 3. App First Launch (Post-Install)
- Flutter app collects same device fingerprint data
- Fingerprint sent to server via `/api/check-deferred-link`
- Server generates same hash, looks up destination
- Returns university ID to app
- App navigates to correct university page

## Architecture

```
Browser (Pre-Install)
    ↓
Device Fingerprint Collection
    ↓
Server: Hash & Store (fingerprint → destination)
    ↓
[User Installs App]
    ↓
Flutter App (First Launch)
    ↓
Device Fingerprint Collection
    ↓
Server: Hash & Match
    ↓
Return Destination
    ↓
Navigate to University
```

## Server Components

### Storage
- In-memory Map (production: use Redis/PostgreSQL)
- Key: SHA-256 hash of device fingerprint
- Value: {destination, timestamp, fingerprint, used}

### Endpoints

**POST /api/store-deferred-link**
- Stores device fingerprint with destination
- Returns success confirmation

**POST /api/check-deferred-link**
- Accepts device fingerprint from app
- Returns destination if match found
- Marks as used (one-time use)

## Flutter Components

### Services

**DeviceFingerprintService**
- Collects device information (OS, screen, language, timezone)
- Sends fingerprint to server
- Handles platform differences (Android/iOS)

**DeferredLinkService**
- Manages first launch detection using SharedPreferences
- Coordinates fingerprint check on first launch only
- Returns university ID if match found

### Main App Integration
- Async main() function
- Checks for deferred link before app starts
- Sets initial route based on result

## Testing

### Prerequisites
```bash
# 1. Install dependencies
flutter pub get

# 2. Start server
cd deeplink-server
npm install
npm start
```

### Test Flow

**Step 1: Uninstall app**
```bash
adb uninstall com.unilinker.app
```

**Step 2: Open link in browser**
- Open Chrome on Android emulator
- Navigate to: `http://10.0.2.2:3000/uni/harvard`
- Browser collects fingerprint and stores on server
- Click "Download & Install App"

**Step 3: Build and install app**
```bash
flutter build apk
adb install build/app/outputs/flutter-apk/app-release.apk
```

**Step 4: Launch app**
- App opens for first time
- Collects device fingerprint
- Matches with server
- **Should navigate to Harvard automatically** ✅

### Verify Server Logs
Server should show:
```
Stored deferred link: 1a2b3c4d... -> harvard
Resolved deferred link: 1a2b3c4d... -> harvard
```

### Testing Tips

**Reset First Launch Flag:**
```dart
// In Flutter DevTools console or add temporary button
await DeferredLinkService.resetFirstLaunch();
```

**Change Server URL for Testing:**
```dart
// lib/services/device_fingerprint_service.dart
static const String baseUrl = 'http://10.0.2.2:3000'; // Android emulator
// or
static const String baseUrl = 'http://localhost:3000'; // iOS simulator
```

## Configuration

### Android
No special configuration needed. Works out of the box.

### iOS
For production, update the base URL:
```dart
static const String baseUrl = 'https://yourserver.com';
```

iOS Simulator: Use `http://localhost:3000`
iOS Real Device: Use your computer's local IP or ngrok

## Limitations

### Fingerprint Accuracy
- **High accuracy**: Same device, same browser, within minutes
- **Medium accuracy**: Same device, different browser
- **Low accuracy**: Very common device configurations

### Privacy Considerations
- Device fingerprinting may have privacy implications
- Consider adding user consent
- Data is temporary (7-day expiration)
- Hashed for security

### Known Issues
- Fingerprint collision possible with identical devices
- Browser/app environment differences may cause mismatches
- Requires network connection on first launch

## Production Deployment

### Server Requirements
1. **Database**: Replace Map with Redis/PostgreSQL
2. **HTTPS**: SSL certificate required for production
3. **Rate Limiting**: Prevent abuse
4. **Cleanup Job**: Remove expired links (>7 days)

### Recommended Database Schema
```sql
CREATE TABLE deferred_links (
    fingerprint_hash VARCHAR(64) PRIMARY KEY,
    university_id VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    used_at TIMESTAMP,
    expires_at TIMESTAMP DEFAULT NOW() + INTERVAL '7 days',
    fingerprint_data JSONB
);

CREATE INDEX idx_expires_at ON deferred_links(expires_at);
```

### Environment Variables
```bash
# .env file
DATABASE_URL=postgresql://...
REDIS_URL=redis://...
BASE_URL=https://unilinker.app
```

## Comparison with Other Solutions

| Method | Accuracy | Complexity | Cost | Privacy |
|--------|----------|-----------|------|---------|
| Device Fingerprinting | 85-95% | Medium | Free | Medium |
| Branch.io | 95-99% | Low | $0-500/mo | High |
| Clipboard | 90% | Low | Free | Low |
| Universal Links | 100% | High | Free | High |

## Troubleshooting

### No Deferred Link Found
1. Check server logs for fingerprint storage
2. Verify app can reach server (check URL)
3. Check Flutter console for fingerprint details
4. Ensure first launch flag is set correctly

### Wrong University Opens
1. Clear server storage: restart server
2. Reset first launch: `DeferredLinkService.resetFirstLaunch()`
3. Try fresh install

### Server Connection Failed
1. Check firewall settings
2. Verify port forwarding: `adb reverse tcp:3000 tcp:3000`
3. Check base URL in Flutter service

## Future Improvements

1. **Fallback Methods**: Combine with clipboard or smart links
2. **Analytics**: Track success rate of fingerprint matching
3. **Machine Learning**: Improve matching algorithm
4. **Cookie Sync**: Use cookies as secondary verification
5. **QR Codes**: Embed fingerprint hash in QR for offline matching

## Credits

Implementation based on device fingerprinting best practices for install attribution.

