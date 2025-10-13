# UniLinker - Essential Commands Quick Reference

## Flutter Development

### Run App
```bash
flutter run
```

### Stop App
```
Press 'q' in terminal
```

### Hot Reload
```
Press 'r' in terminal
```

### Full Restart
```
Press 'R' in terminal
```

### Build APK
```bash
flutter build apk
```

### Clean Build
```bash
flutter clean
flutter pub get
flutter run
```

## Emulator Management

### List Available Emulators
```bash
flutter emulators
```

### Launch Specific Emulator
```bash
flutter emulators --launch <emulator_id>
```

### List Running Devices
```bash
flutter devices
```

## Deep Link Testing

### Port Forwarding (Emulator → Localhost)
```bash
adb reverse tcp:3000 tcp:3000
```

### Test Deep Links with ADB
```bash
# Harvard
adb shell am start -W -a android.intent.action.VIEW -d "unilinker://university/harvard"

# BUET
adb shell am start -W -a android.intent.action.VIEW -d "unilinker://university/buet"

# UIU
adb shell am start -W -a android.intent.action.VIEW -d "unilinker://university/uiu"
```

### Emulator Access URLs
```
From Emulator Browser: http://10.0.2.2:3000
From Host Machine: http://localhost:3000
```

## Deep Link Server

### Start Server
```bash
cd deeplink-server
npm install
npm start
```

### Test Server Health
```bash
curl http://localhost:3000/health
```

### Server URLs
```
Web Interface: http://localhost:3000
Harvard Link: http://localhost:3000/uni/harvard
BUET Link: http://localhost:3000/uni/buet
UIU Link: http://localhost:3000/uni/uiu
```

## Git Workflow

### Check Status
```bash
git status
git branch
```

### Commit Changes
```bash
git add .
git commit -m "Your commit message"
git push
```

### View Changes
```bash
git diff
```

## Debugging

### View Android Logs
```bash
adb logcat | grep Flutter
```

### Check Package Installation
```bash
adb shell pm list packages | grep unilinker
```

### Verify Deep Link Configuration
```bash
adb shell dumpsys package | grep -A 20 "unilinker"
```

### Clear App Data
```bash
adb shell pm clear com.unilinker.app
```

## Development Workflow

### Standard Development Session
```bash
# 1. Start the deep link server
cd deeplink-server && npm start

# 2. Run Flutter app (in new terminal)
cd .. && flutter run

# 3. Set up port forwarding (in new terminal)
adb reverse tcp:3000 tcp:3000

# 4. Test from emulator browser
# Navigate to: http://10.0.2.2:3000
```

### Quick Test Cycle
```bash
# Make code changes → Press 'r' for hot reload
# Routing changes → Press 'R' for full restart
# Deep link test → Use ADB command or browser link
```

## Troubleshooting

### ADB Not Found (Windows)
Add to PATH: `C:\Users\<username>\AppData\Local\Android\Sdk\platform-tools`

### Deep Links Not Working
```bash
# Full restart required (not hot reload)
Press 'q' to quit
flutter run
```

### Server Port In Use
```bash
# Kill process on port 3000
netstat -ano | findstr :3000
taskkill /PID <pid> /F
```

## Quick Reference

| Action | Command |
|--------|---------|
| Run app | `flutter run` |
| Port forward | `adb reverse tcp:3000 tcp:3000` |
| Test Harvard link | `adb shell am start -W -a android.intent.action.VIEW -d "unilinker://university/harvard"` |
| Start server | `cd deeplink-server && npm start` |
| Emulator URL | `http://10.0.2.2:3000` |
| Hot reload | Press `r` |
| Full restart | Press `R` |
| Stop app | Press `q` |