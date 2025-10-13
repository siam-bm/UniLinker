# UniLinker Deep Link Server

A Node.js server for generating and testing deep links for the UniLinker Flutter app.

## Setup

1. Install dependencies:
```bash
npm install
```

2. Start the server:
```bash
npm start
```

The server will run on `http://localhost:3000`

## Features

### Web Interface
- Visit `http://localhost:3000` for an interactive link generator
- Click on any university to generate deep links
- Test links directly from the browser

### API Endpoints

**GET /**
- Interactive web interface for link generation

**GET /api/universities**
- Returns list of all universities

**GET /api/generate-link/:universityId**
- Generates deep link for a specific university
- Example: `http://localhost:3000/api/generate-link/harvard`

**GET /uni/:universityId**
- Redirects to the deep link (opens the app)
- Example: `http://localhost:3000/uni/harvard`

## Testing Deep Links

### Option 1: Using ADB (Android)

With your emulator/device running:

```bash
# Open Harvard page
adb shell am start -W -a android.intent.action.VIEW -d "unilinker://university/harvard"

# Open BUET page
adb shell am start -W -a android.intent.action.VIEW -d "unilinker://university/buet"

# Open UIU page
adb shell am start -W -a android.intent.action.VIEW -d "unilinker://university/uiu"
```

### Option 2: Using HTTP Redirect

1. Start the server: `npm start`
2. Open your browser to `http://localhost:3000`
3. Click on any university card
4. Click "Open in App" button

The browser will attempt to open the deep link, which should launch your Flutter app on the emulator/device connected via ADB forwarding.

### Option 3: Direct Links

You can also use these URLs directly:
- `http://localhost:3000/uni/harvard` - Opens Harvard page
- `http://localhost:3000/uni/buet` - Opens BUET page
- `http://localhost:3000/uni/uiu` - Opens UIU page

## Deep Link Format

**Custom Scheme:** `unilinker://university/:id`

Available IDs:
- `harvard` - Harvard University
- `buet` - Bangladesh University of Engineering and Technology
- `uiu` - United International University

## Testing in Emulator

1. Make sure your Flutter app is running in the emulator
2. Start this server: `npm start`
3. Use ADB commands to test deep links
4. Or use the web interface and port forwarding

### Port Forwarding (Optional)

To test HTTP redirects from the emulator:

```bash
adb reverse tcp:3000 tcp:3000
```

Then you can access `http://localhost:3000` from the emulator's browser.

## Example API Usage

```bash
# Get all universities
curl http://localhost:3000/api/universities

# Generate link for Harvard
curl http://localhost:3000/api/generate-link/harvard

# Response:
# {
#   "university": {
#     "name": "Harvard University",
#     "shortName": "Harvard",
#     "location": "Cambridge, Massachusetts, USA"
#   },
#   "deepLink": "unilinker://university/harvard",
#   "webLink": "http://localhost:3000/uni/harvard"
# }
```