const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());
app.use(express.static('public'));

// University data (same as Flutter app)
const universities = {
  harvard: {
    name: 'Harvard University',
    shortName: 'Harvard',
    location: 'Cambridge, Massachusetts, USA',
  },
  buet: {
    name: 'Bangladesh University of Engineering and Technology',
    shortName: 'BUET',
    location: 'Dhaka, Bangladesh',
  },
  uiu: {
    name: 'United International University',
    shortName: 'UIU',
    location: 'Dhaka, Bangladesh',
  },
};

// Home page with link generator interface
app.get('/', (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>UniLinker Deep Link Generator</title>
      <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
          font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          min-height: 100vh;
          display: flex;
          justify-content: center;
          align-items: center;
          padding: 20px;
        }
        .container {
          background: white;
          border-radius: 20px;
          padding: 40px;
          max-width: 600px;
          width: 100%;
          box-shadow: 0 20px 60px rgba(0,0,0,0.3);
        }
        h1 {
          color: #667eea;
          margin-bottom: 10px;
          font-size: 32px;
        }
        .subtitle {
          color: #666;
          margin-bottom: 30px;
          font-size: 16px;
        }
        .university-grid {
          display: grid;
          gap: 15px;
          margin-bottom: 30px;
        }
        .university-card {
          border: 2px solid #e0e0e0;
          border-radius: 12px;
          padding: 20px;
          cursor: pointer;
          transition: all 0.3s ease;
          text-align: left;
        }
        .university-card:hover {
          border-color: #667eea;
          box-shadow: 0 5px 15px rgba(102, 126, 234, 0.2);
          transform: translateY(-2px);
        }
        .university-name {
          font-weight: bold;
          font-size: 18px;
          color: #333;
          margin-bottom: 5px;
        }
        .university-location {
          color: #888;
          font-size: 14px;
        }
        .link-result {
          background: #f5f5f5;
          border-radius: 8px;
          padding: 15px;
          margin-top: 20px;
          display: none;
        }
        .link-result.show {
          display: block;
        }
        .link-text {
          word-break: break-all;
          color: #667eea;
          font-weight: 500;
          margin-bottom: 10px;
        }
        .button-group {
          display: flex;
          gap: 10px;
        }
        .btn {
          padding: 10px 20px;
          border: none;
          border-radius: 8px;
          cursor: pointer;
          font-weight: 500;
          transition: all 0.3s ease;
        }
        .btn-primary {
          background: #667eea;
          color: white;
        }
        .btn-primary:hover {
          background: #5568d3;
        }
        .btn-secondary {
          background: #e0e0e0;
          color: #333;
        }
        .btn-secondary:hover {
          background: #d0d0d0;
        }
        .info-box {
          background: #e3f2fd;
          border-left: 4px solid #2196f3;
          padding: 15px;
          border-radius: 4px;
          margin-top: 20px;
        }
        .info-box h3 {
          color: #1976d2;
          margin-bottom: 8px;
          font-size: 16px;
        }
        .info-box code {
          background: #fff;
          padding: 2px 6px;
          border-radius: 3px;
          font-family: monospace;
          font-size: 13px;
        }
      </style>
    </head>
    <body>
      <div class="container">
        <h1>UniLinker</h1>
        <p class="subtitle">Generate deep links to university pages</p>

        <div class="university-grid">
          <div class="university-card" onclick="generateLink('harvard')">
            <div class="university-name">Harvard University</div>
            <div class="university-location">Cambridge, Massachusetts, USA</div>
          </div>
          <div class="university-card" onclick="generateLink('buet')">
            <div class="university-name">BUET</div>
            <div class="university-location">Dhaka, Bangladesh</div>
          </div>
          <div class="university-card" onclick="generateLink('uiu')">
            <div class="university-name">UIU</div>
            <div class="university-location">Dhaka, Bangladesh</div>
          </div>
        </div>

        <div id="linkResult" class="link-result">
          <div class="link-text" id="linkText"></div>
          <div class="button-group">
            <button class="btn btn-primary" onclick="copyLink()">Copy Link</button>
            <button class="btn btn-secondary" onclick="openLink()">Open in App</button>
          </div>
        </div>

        <div class="info-box">
          <h3>Testing Instructions</h3>
          <p><strong>Option 1: Using ADB (Android Emulator/Device)</strong></p>
          <p>Run: <code>adb shell am start -W -a android.intent.action.VIEW -d "unilinker://university/harvard"</code></p>
          <br>
          <p><strong>Option 2: HTTP Redirect</strong></p>
          <p>Click a university above, then click "Open in App"</p>
        </div>
      </div>

      <script>
        let currentLink = '';

        function generateLink(universityId) {
          const baseUrl = window.location.origin;
          const deepLink = \`unilinker://university/\${universityId}\`;
          const webLink = \`\${baseUrl}/uni/\${universityId}\`;

          currentLink = deepLink;
          document.getElementById('linkText').textContent = webLink;
          document.getElementById('linkResult').classList.add('show');
        }

        function copyLink() {
          const linkText = document.getElementById('linkText').textContent;
          navigator.clipboard.writeText(linkText).then(() => {
            alert('Link copied to clipboard!');
          });
        }

        function openLink() {
          if (currentLink) {
            window.location.href = currentLink;
          }
        }
      </script>
    </body>
    </html>
  `);
});

// API endpoint to get all universities
app.get('/api/universities', (req, res) => {
  res.json(universities);
});

// API endpoint to generate deep link
app.get('/api/generate-link/:universityId', (req, res) => {
  const { universityId } = req.params;
  const university = universities[universityId.toLowerCase()];

  if (!university) {
    return res.status(404).json({ error: 'University not found' });
  }

  const deepLink = `unilinker://university/${universityId.toLowerCase()}`;
  const webLink = `${req.protocol}://${req.get('host')}/uni/${universityId.toLowerCase()}`;

  res.json({
    university,
    deepLink,
    webLink,
  });
});

// Deep link redirect endpoint with deferred deep linking support
app.get('/uni/:universityId', (req, res) => {
  const { universityId } = req.params;
  const university = universities[universityId.toLowerCase()];

  if (!university) {
    return res.status(404).send('University not found');
  }

  const deepLink = `unilinker://university/${universityId.toLowerCase()}`;
  const apkDownloadUrl = `${req.protocol}://${req.get('host')}/download-apk`;

  // Redirect to deep link with deferred deep linking support
  res.send(`
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Opening ${university.name} in UniLinker...</title>
      <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
          font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          min-height: 100vh;
          display: flex;
          justify-content: center;
          align-items: center;
          color: white;
          text-align: center;
          padding: 20px;
        }
        .container {
          max-width: 450px;
          width: 100%;
        }
        h1 { font-size: 28px; margin-bottom: 20px; }
        p { font-size: 16px; opacity: 0.9; margin-bottom: 30px; }
        .loader {
          border: 4px solid rgba(255,255,255,0.3);
          border-radius: 50%;
          border-top: 4px solid white;
          width: 40px;
          height: 40px;
          animation: spin 1s linear infinite;
          margin: 0 auto 30px;
        }
        @keyframes spin {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }
        .install-prompt {
          display: none;
          background: rgba(255,255,255,0.15);
          border-radius: 12px;
          padding: 25px;
          backdrop-filter: blur(10px);
        }
        .install-prompt.show {
          display: block;
        }
        .install-btn {
          background: white;
          color: #667eea;
          border: none;
          padding: 15px 30px;
          border-radius: 8px;
          font-size: 16px;
          font-weight: 600;
          cursor: pointer;
          margin-top: 20px;
          transition: transform 0.2s;
          display: inline-block;
          text-decoration: none;
        }
        .install-btn:hover {
          transform: scale(1.05);
        }
        .fallback {
          margin-top: 30px;
          font-size: 14px;
          opacity: 0.8;
        }
        .fallback a {
          color: white;
          text-decoration: underline;
        }
      </style>
      <script>
        const deepLink = '${deepLink}';
        const universityId = '${universityId}';
        const apkDownloadUrl = '${apkDownloadUrl}';

        // Store the intended destination for deferred deep linking
        localStorage.setItem('unilinker_deferred_link', deepLink);
        localStorage.setItem('unilinker_deferred_university', universityId);

        // Attempt to open the app
        let appOpened = false;

        // Try to open the deep link
        window.location.href = deepLink;

        // Detect if app opened (visibility change)
        document.addEventListener('visibilitychange', function() {
          if (document.hidden) {
            appOpened = true;
          }
        });

        // Show install prompt after timeout if app didn't open
        setTimeout(function() {
          if (!appOpened && !document.hidden) {
            document.getElementById('loader-message').style.display = 'none';
            document.getElementById('install-prompt').classList.add('show');
          }
        }, 2500);
      </script>
    </head>
    <body>
      <div class="container">
        <div id="loader-message">
          <h1>Opening ${university.name}</h1>
          <p>Launching UniLinker app...</p>
          <div class="loader"></div>
        </div>

        <div id="install-prompt" class="install-prompt">
          <h1>📱 Get UniLinker</h1>
          <p>Install the UniLinker app to view ${university.name} and discover other universities!</p>
          <a href="${apkDownloadUrl}" class="install-btn">Download & Install App</a>
          <div class="fallback">
            <p>After installing, the app will automatically open to ${university.name}</p>
          </div>
        </div>
      </div>
    </body>
    </html>
  `);
});

// APK download/install page
app.get('/download-apk', (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Download UniLinker</title>
      <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
          font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          min-height: 100vh;
          display: flex;
          justify-content: center;
          align-items: center;
          color: white;
          padding: 20px;
        }
        .container {
          max-width: 500px;
          width: 100%;
          text-align: center;
        }
        h1 { font-size: 32px; margin-bottom: 20px; }
        p { font-size: 16px; opacity: 0.9; margin-bottom: 30px; line-height: 1.6; }
        .download-box {
          background: rgba(255,255,255,0.15);
          border-radius: 12px;
          padding: 30px;
          backdrop-filter: blur(10px);
          margin-bottom: 20px;
        }
        .download-btn {
          background: white;
          color: #667eea;
          border: none;
          padding: 15px 40px;
          border-radius: 8px;
          font-size: 18px;
          font-weight: 600;
          cursor: pointer;
          display: inline-block;
          text-decoration: none;
          margin: 10px;
          transition: transform 0.2s;
        }
        .download-btn:hover {
          transform: scale(1.05);
        }
        .instruction {
          background: rgba(255,255,255,0.1);
          border-radius: 8px;
          padding: 20px;
          text-align: left;
          font-size: 14px;
        }
        .instruction ol {
          margin: 15px 0 0 20px;
        }
        .instruction li {
          margin: 10px 0;
          line-height: 1.5;
        }
        code {
          background: rgba(0,0,0,0.3);
          padding: 3px 8px;
          border-radius: 4px;
          font-family: monospace;
        }
      </style>
    </head>
    <body>
      <div class="container">
        <h1>📱 Download UniLinker</h1>

        <div class="download-box">
          <p>For local testing, build and install the APK using Flutter:</p>
          <a href="#" class="download-btn" onclick="alert('Build APK using: flutter build apk'); return false;">
            📦 Build Instructions
          </a>
        </div>

        <div class="instruction">
          <strong>🔨 Build & Install APK Locally:</strong>
          <ol>
            <li>Open terminal in your Flutter project</li>
            <li>Run: <code>flutter build apk</code></li>
            <li>APK will be at: <code>build/app/outputs/flutter-apk/app-release.apk</code></li>
            <li>Install: <code>adb install build/app/outputs/flutter-apk/app-release.apk</code></li>
          </ol>
          <br>
          <strong>📱 Production Setup:</strong>
          <p style="margin-top: 10px;">In production, this page would redirect to Google Play Store or provide direct APK download.</p>
        </div>
      </div>
    </body>
    </html>
  `);
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'UniLinker Deep Link Server is running' });
});

app.listen(PORT, () => {
  console.log(`UniLinker Deep Link Server running on http://localhost:${PORT}`);
  console.log(`\nAvailable deep links:`);
  Object.keys(universities).forEach(id => {
    console.log(`  - http://localhost:${PORT}/uni/${id}`);
    console.log(`    -> unilinker://university/${id}`);
  });
  console.log(`\nAPI Documentation:`);
  console.log(`  GET  /                                - Link generator interface`);
  console.log(`  GET  /api/universities                - List all universities`);
  console.log(`  GET  /api/generate-link/:universityId - Generate deep link`);
  console.log(`  GET  /uni/:universityId                - Redirect to deep link`);
});