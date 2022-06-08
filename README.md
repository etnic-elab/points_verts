# ADEPS - Points Verts

Small Flutter application displaying future ADEPS' walks.

Uses the [ODWB platform API](https://www.odwb.be/explore/dataset/points-verts-de-ladeps/) to retrieve data.

# Features

- Display walks list by date, either in list form or on a map
- Display walks list alphabetically, in directory-style
- Calculate distance between your position and the walks (requires to allow the app to use your position)
- Calculate distance and time between your home and the walks (requires to set home address in settings)
- Display forecast weathers 5 days before the walks
- Launch navigation to the selected walk
- Display a notification the day before with the nearest walk (requires to set home address in settings)

# Planned features

- Share walk infos button?

# Releasing the application

1. Google Map API:

1.1 Generate 3 API keys:

- API key restricted to Android App. Select `Maps SDK for Android` API. Define the key in `android/local.properties`:

```properties
googleMaps.apiKey=api_key
```

- API key restricted to IOS App. Select `Maps SDK for IOS` API. Define the key in a `GoogleMaps.plist` file in `ios/Runner` folder:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<key>API_KEY</key>
<string>api_key</string>
</dict>
</plist>
```

- API key with no platform restriction. Select `Distance Matrix API`, `Geocoding API`, `Maps Static API`, `Places API` API's. Define the key in a `.env` file in root folder:

```properties
GOOGLEMAPS_API_KEY=api_key
```

1.2 Define the MAP_API as `Google` in a `.env` file in root folder:

```properties
MAP_API=Google
```

2. MapBox API:

Define the MAP_API as `MapBox` and the API token in a `.env` file in root folder:

```properties
MAP=MapBox
MAPBOX_TOKEN=token
```

3. The OpenWeather API key should be defined in a `.env` file in root folder:

```properties
OPENWEATHER_TOKEN=token
```

4. Information about the keystore should be set in the `android/key.properties`:

```properties
storePassword=<password>
keyPassword=<password>
keyAlias=key
storeFile=<path>/key.jks
```

5. To generate the splash screen before release, use the following command:

```bash
flutter pub run flutter_native_splash:create
```

6. To generate the launcher_icons before release, use the following command:

```bash
flutter pub run flutter_launcher_icons:main
```

7. The release can then be build with the following command for android (use Xcode for iOS):

```bash
flutter build appbundle
```

# Initial walk dataset

If you want the app to load an initial dataset without connecting to the internet, place a JSON
file called `walk_data.json` in `assets` folder. This JSON must follows the schema of ODWB.

# App assets and icons

Due to copyright issues => below assets, files and folders are not included:

Android:

```
android/app/src/main/res/drawable*/ic_notification.png
android/app/src/main/res/mimap*/ic_launcher_foreground.png
android/app/src/main/ic_launcher-playstore.png
```

iOS:

```
ios/Runner/Assets.xcassets/AppIcon.appiconset
```

Flutter:

```
assets/dark/logo.png
assets/dark/logo-annule.png
assets/dark/splash.png
assets/light/logo.png
assets/light/logo-annule.png
assets/light/splash.png
```
