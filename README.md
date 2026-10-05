# ADEPS - Points Verts

A Flutter application for displaying future ADEPS walks.

This app uses the [ODWB platform API](https://www.odwb.be/explore/dataset/points-verts-de-ladeps/) to retrieve walk data.

## Features

- Display walks by date in list or map view
- Show walks alphabetically in a directory-style list
- Calculate distance between your current position and walks (requires location permission)
- Calculate distance and time from your home to walks (requires setting home address in app settings)
- Display 5-day weather forecasts for walks
- Launch navigation to selected walks
- Receive notifications about the nearest walk one day in advance (requires setting home address in app settings)

## Setup and Configuration

### Map API Configuration

The app supports multiple map providers for different functionalities. You can configure separate providers for API calls (MAP_API) and for displaying the interactive map (INTERACTIVE_MAP).

#### Map API Provider (for API calls)

Choose one of the following providers and add the corresponding configuration to your `.env` file:

1. Google Maps

   ```properties
   MAP_API=google
   MAP_API_KEY=your_google_api_key
   MAP_API_WEBSITE=https://developers.google.com/maps?hl=fr
   MAP_API_NAME=Google Maps
   ```

2. Mapbox

   ```properties
   MAP_API=mapbox
   MAP_API_KEY=your_mapbox_token
   MAP_API_WEBSITE=https://www.mapbox.com/
   MAP_API_NAME=Mapbox
   ```

3. Azure Maps
   ```properties
   MAP_API=azure
   MAP_API_KEY=your_azure_maps_key
   MAP_API_WEBSITE=https://azure.microsoft.com/fr-fr/products/azure-maps/
   MAP_API_NAME=Azure Maps
   ```

#### Interactive Map Provider

Choose one of the following providers for the interactive map display and add the configuration to your `.env` file:

1. Google Maps

   ```properties
   INTERACTIVE_MAP=google
   INTERACTIVE_MAP_API=your_google_api_key
   ```

2. Mapbox

   ```properties
   INTERACTIVE_MAP=mapbox
   INTERACTIVE_MAP_API=your_mapbox_token
   ```

3. Azure Maps
   ```properties
   INTERACTIVE_MAP=azure
   INTERACTIVE_MAP_API=your_azure_maps_key
   ```

Note: The MAP_API and INTERACTIVE_MAP providers do not need to be the same. You can mix and match based on your requirements and preferences.

### Additional Google Maps Configuration

If you're using Google Maps for either MAP_API or INTERACTIVE_MAP, you'll need to set up platform-specific API keys:

1. Android-restricted key:

   - Enable `Maps SDK for Android` API
   - Add to `android/local.properties`:
     ```properties
     googleMaps.apiKey=your_android_api_key
     ```

2. iOS-restricted key:

   - Enable `Maps SDK for iOS` API
   - Create `ios/Runner/GoogleMaps.plist`:
     ```xml
     <?xml version="1.0" encoding="UTF-8"?>
     <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
     <plist version="1.0">
     <dict>
     <key>API_KEY</key>
     <string>your_ios_api_key</string>
     </dict>
     </plist>
     ```

3. Unrestricted key (if using Google for MAP_API):
   - Enable `Distance Matrix API`, `Geocoding API`, `Maps Static API`, and `Places API`
   - Use this key for the MAP_API_KEY in the `.env` file

### Weather API Configuration

Add your OpenWeather API key to `.env`:

```properties
OPENWEATHER_TOKEN=your_openweather_api_key
```

### Firebase Configuration

1. Follow the [Firebase Flutter setup guide](https://firebase.google.com/docs/flutter/setup)
2. Add Firebase configuration to `.env`:
   ```properties
   FIREBASE_ANDROID_APP_ID=android_app_id
   FIREBASE_ANDROID_API_KEY=android_api_key
   FIREBASE_IOS_APP_ID=ios_app_id
   FIREBASE_IOS_API_KEY=ios_api_key
   FIREBASE_IOS_CLIENT_ID=ios_client_id
   FIREBASE_IOS_BUNDLE_ID=ios_bundle_id
   FIREBASE_PROJECT_ID=project_id
   FIREBASE_SENDER_ID=sender_id
   FIREBASE_STORAGE_BUCKET=storage_bucket
   ```

### Android Keystore Configuration

Add keystore information to `android/key.properties`:

```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=key
storeFile=/path/to/your/key.jks
```

## Building and Releasing

Clone [points_verts_assets](https://github.com/etnic-elab/points_verts_assets)
next to this repo (it holds the artwork, see [Missing Assets](#missing-assets)),
then build with `tool/release.sh`:

```bash
tool/release.sh ios            # on macOS; produces build/ios/archive/Runner.xcarchive
bash tool/release.sh android   # from Git Bash on Windows, or directly on macOS/Linux
```

Extra arguments are passed to `flutter build`. The script runs these steps in
order and stops at the first problem:

1. Checks `../points_verts_assets` is not behind its remote.
2. `dart run tool/build_brand_assets.dart --check`: the brand images must still
   match the SVG master.
3. `bash tool/sync_assets.sh`: copies the artwork into this repo.
4. `dart run flutter_native_splash:create` and `dart run flutter_launcher_icons`.
5. On iOS, runs `ios/Scripts/verify_app_icons.sh`.
6. Builds the app bundle or the IPA.

**Don't skip steps 3 and 4 when building by hand.** The generated icons and
splash images are gitignored, so a machine that never ran them (a fresh clone,
or the Mac you archive from) still has whatever was left on disk. Version 1.7.1
shipped the old white, non-adapting icon this way. The `Verify App Icons` build
phase fails non-debug iOS builds when icons are missing.

### Changing the logo

The single source is `assets/brand/app_icon.svg` in points_verts_assets (the
designer's file). After replacing it:

```bash
dart run tool/build_brand_assets.dart   # renders every PNG into points_verts_assets
```

Commit the results in points_verts_assets, then run a release build as above.
The generator renders with [resvg](https://github.com/yisibl/resvg-js) through
`npx`, so it needs Node.js. Builds themselves don't.

The Play Store listing icon (`assets/store/play_store_icon_512.png` in
points_verts_assets) is uploaded by hand in the Play Console. The App Store
takes its icon from the build.

## Initial Walk Dataset

To include an initial offline dataset, place a JSON file named `walk_data.json` in the `assets` folder. This file should follow the ODWB schema.

## Missing Assets

Due to copyright restrictions, the artwork is not included in this repository.
It lives in points_verts_assets, and `tool/sync_assets.sh` copies it here:

- Flutter (`assets/`):

  ```
  assets/{light,dark}/app_logo.png         app icon tile (app bar, About)
  assets/{light,dark}/logo.png             green disc, the walk symbol
  assets/{light,dark}/logo-annule.png      the same, for cancelled walks
  assets/launcher_icons/                   launcher-icon masters
  assets/splash/                           splash image
  ```

- Android:

  ```
  android/app/src/main/res/drawable-*/ic_notification.png
  ```

Everything else that is gitignored (the launcher icons and splash images under
`android/app/src/main/res` and `ios/Runner/Assets.xcassets`) is generated from
the files above by `flutter_launcher_icons` and `flutter_native_splash`.

Please ensure you have the necessary rights to use any replacement assets.
