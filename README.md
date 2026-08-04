# Celebration TV (Flutter)

- Package: `com.digitxtramedia.celebrationtv`
- Target: Android 15 (API 35)
- Ads: AdMob Banner + Native + Interstitial (30s cooldown, never over video)
- Push: Firebase Cloud Messaging (topics ready)
- Dynamic Content: Firebase Remote Config (images, playlists, live links, menu, ads toggles)

## Setup Quick Steps
1. Install Flutter (3.24+).
2. In Firebase Console (project: celebration-tv), add Android app with package `com.digitxtramedia.celebrationtv` and download `google-services.json` to `android/app/google-services.json`.
3. Open `android/app/src/main/AndroidManifest.xml` and verify the AdMob app id.
4. Run:
   ```bash
   flutter pub get
   flutter build appbundle
   ```
5. Upload the AAB in Play Console (Internal testing first).

## Remote Config Template
See `rc_template.json` at project root. Copy keys into Firebase Remote Config.
