# Deep Link Testing Guide for UniLinker

This guide explains how to test the deep linking functionality in the UniLinker app.

## What is Deep Linking?

Deep linking allows you to open specific pages in the app using URLs. For example:
- `unilinker://university/harvard` opens Harvard's detail page
- `unilinker://university/buet` opens BUET's detail page
- `unilinker://university/uiu` opens UIU's detail page

## Setup

### 1. Start the Deep Link Server

```bash
cd deeplink-server
npm install
npm start
```

The server will start on `http://localhost:3000`

### 2. Run the Flutter App

```bash
flutter run
```

Make sure your emulator/device is running before this command.

## Testing Methods

### Method 1: ADB Commands (Easiest for Android Emulator)

Open a new terminal and run these commands:

```bash
# Test Harvard page
adb shell am start -W -a android.intent.action.VIEW -d "unilinker://university/harvard"

# Test BUET page
adb shell am start -W -a android.intent.action.VIEW -d "unilinker://university/buet"

# Test UIU page
adb shell am start -W -a android.intent.action.VIEW -d "unilinker://university/uiu"
```

**What happens:**
- The app will launch (if not already running)
- Navigate directly to the university detail page
- Works even if the app is in the background

### Method 2: Web Interface

1. Start the server: `cd deeplink-server && npm start`
2. Open your browser to `http://localhost:3000`
3. You'll see a beautiful interface with all universities
4. Click on any university card
5. Click "Copy Link" to copy the deep link
6. Click "Open in App" to test the deep link

### Method 3: Direct HTTP Links

These URLs will redirect to the deep link:

- `http://localhost:3000/uni/harvard`
- `http://localhost:3000/uni/buet`
- `http://localhost:3000/uni/uiu`

You can:
- Share these links
- Use them in QR codes
- Test them from your emulator's browser (with port forwarding)

## Port Forwarding for Emulator Testing

If you want to test HTTP links from within the emulator's browser:

```bash
adb reverse tcp:3000 tcp:3000
```

Now you can open `http://localhost:3000` in the emulator's Chrome browser.

## Deep Link Format

### Custom Scheme Links
```
unilinker://university/{id}
```

Where `{id}` can be:
- `harvard` (case-insensitive)
- `buet` (case-insensitive)
- `uiu` (case-insensitive)

### HTTP Links (with redirect)
```
http://localhost:3000/uni/{id}
```

## Supported Routes

The app supports these deep link routes:

| Route | Description | Example |
|-------|-------------|---------|
| `/` | Home page | `unilinker://` |
| `/universities` | Universities list | `unilinker://universities` |
| `/university/:id` | University detail | `unilinker://university/harvard` |

## API Usage

### Get All Universities

```bash
curl http://localhost:3000/api/universities
```

### Generate Deep Link

```bash
curl http://localhost:3000/api/generate-link/harvard
```

Response:
```json
{
  "university": {
    "name": "Harvard University",
    "shortName": "Harvard",
    "location": "Cambridge, Massachusetts, USA"
  },
  "deepLink": "unilinker://university/harvard",
  "webLink": "http://localhost:3000/uni/harvard"
}
```

## Troubleshooting

### Deep link doesn't open the app

1. **Check if app is installed:**
   ```bash
   adb shell pm list packages | grep unilinker
   ```

2. **Verify deep link configuration:**
   ```bash
   adb shell dumpsys package | grep -A 20 "unilinker"
   ```

3. **Try rebuilding the app:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

### App opens but doesn't navigate to the right page

1. Check the Flutter console for errors
2. Verify the university ID is correct (lowercase: harvard, buet, uiu)
3. Make sure go_router is properly configured in `lib/main.dart`

### Server not accessible from emulator

1. Set up port forwarding:
   ```bash
   adb reverse tcp:3000 tcp:3000
   ```

2. Verify server is running:
   ```bash
   curl http://localhost:3000/health
   ```

## Production Deployment

For production, you would:

1. **Get a domain:** e.g., `unilinker.app`
2. **Update AndroidManifest.xml:** Change `android:host="unilinker.app"`
3. **Update Info.plist:** Add your domain to associated domains
4. **Deploy server:** Host the Node.js server on a cloud platform
5. **Enable HTTPS:** Use SSL certificates for secure links
6. **Add verification files:** For Android App Links and iOS Universal Links

## Example Use Cases

### Share University Link

Generate a shareable link:
```javascript
const link = `https://unilinker.app/uni/harvard`;
// Share via social media, email, SMS, etc.
```

### QR Code for Marketing

Generate QR code containing:
```
https://unilinker.app/uni/harvard
```

When scanned:
- Opens browser → redirects to deep link → opens app → shows Harvard page

### Push Notifications

Include deep link in notification payload:
```json
{
  "notification": {
    "title": "New Harvard Programs Available",
    "body": "Check out the latest programs",
    "click_action": "unilinker://university/harvard"
  }
}
```

## Development Tips

- Use ADB commands for quick testing during development
- Use the web interface for demos and sharing with team
- Test on both cold start (app not running) and warm start (app in background)
- Verify deep links work after app is killed and restarted

## Need Help?

If you encounter issues:
1. Check the Flutter console output
2. Check the Node.js server logs
3. Use `adb logcat` to see Android system logs
4. Verify your deep link format is correct