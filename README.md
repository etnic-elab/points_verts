# Points Verts

Small Flutter application displaying future Adeps' walks. Non official.

# Features

- Display walks list by date, either in list form or on a map
- Calculate distance between your position and the walks (requires to allow the app to use your position)
- Launch navigation to the selected walk

# Planned features

- Notifications indicating where the nearest walk is on Sunday morning or Saturday night?
- Weather forecast for each location?
- Share walk infos button?

# Releasing the application

The Mapbox API key should be defined in a `.env` file in root folder:

```properties
MAPBOX_TOKEN=token
```

Information about the keystore should be set in the `android/key.properties`:

```properties
storePassword=<password>
keyPassword=<password>
keyAlias=key
storeFile=<path>/key.jks
```
