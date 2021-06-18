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

The Mapbox and OpenWeather API keys should be defined in a `.env` file in root folder:

```properties
MAPBOX_TOKEN=token
OPENWEATHER_TOKEN=token
```

Information about the keystore should be set in the `android/key.properties`:

```properties
storePassword=<password>
keyPassword=<password>
keyAlias=key
storeFile=<path>/key.jks
```

The release can then be build with the following command for android (use Xcode for iOS):

```bash
flutter build appbundle
```
