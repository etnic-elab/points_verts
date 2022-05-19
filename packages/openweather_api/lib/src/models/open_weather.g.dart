// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: implicit_dynamic_parameter

part of 'open_weather.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenWeather _$OpenWeatherFromJson(Map<String, dynamic> json) => $checkedCreate(
      'OpenWeather',
      json,
      ($checkedConvert) {
        final val = OpenWeather(
          count: $checkedConvert('cnt', (v) => v as int?),
          weathers: $checkedConvert(
              'list',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => Weather.fromJson(e as Map<String, dynamic>))
                  .toList()),
          city: $checkedConvert(
              'city',
              (v) =>
                  v == null ? null : City.fromJson(v as Map<String, dynamic>)),
        );
        return val;
      },
      fieldKeyMap: const {'count': 'cnt', 'weathers': 'list'},
    );

Weather _$WeatherFromJson(Map<String, dynamic> json) => $checkedCreate(
      'Weather',
      json,
      ($checkedConvert) {
        final val = Weather(
          main: $checkedConvert(
              'main',
              (v) =>
                  v == null ? null : Main.fromJson(v as Map<String, dynamic>)),
          details: $checkedConvert(
              'weather',
              (v) => (v as List<dynamic>?)
                  ?.map(
                      (e) => WeatherDetail.fromJson(e as Map<String, dynamic>))
                  .toList()),
          cloudiness: $checkedConvert(
            'cloudiness',
            (v) => v as int?,
            readValue: Weather._readClouds,
          ),
          wind: $checkedConvert(
              'wind',
              (v) =>
                  v == null ? null : Wind.fromJson(v as Map<String, dynamic>)),
          visibility: $checkedConvert('visibility', (v) => v as int?),
          probabilityOfPrecipitation: $checkedConvert('pop', (v) => v as int?),
          partOfDay: $checkedConvert(
            'part_of_day',
            (v) =>
                $enumDecodeNullable(_$PartOfDayEnumMap, v,
                    unknownValue: PartOfDay.unknown) ??
                PartOfDay.unknown,
            readValue: Weather._readPartOfDay,
          ),
          date: $checkedConvert(
              'dt_txt', (v) => v == null ? null : DateTime.parse(v as String)),
        );
        return val;
      },
      fieldKeyMap: const {
        'details': 'weather',
        'probabilityOfPrecipitation': 'pop',
        'partOfDay': 'part_of_day',
        'date': 'dt_txt'
      },
    );

const _$PartOfDayEnumMap = {
  PartOfDay.day: 'd',
  PartOfDay.night: 'n',
  PartOfDay.unknown: 'unknown',
};

Main _$MainFromJson(Map<String, dynamic> json) => $checkedCreate(
      'Main',
      json,
      ($checkedConvert) {
        final val = Main(
          temp: $checkedConvert('temp', (v) => (v as num?)?.toDouble()),
          feelsLike:
              $checkedConvert('feels_like', (v) => (v as num?)?.toDouble()),
          tempMin: $checkedConvert('temp_min', (v) => (v as num?)?.toDouble()),
          tempMax: $checkedConvert('temp_max', (v) => (v as num?)?.toDouble()),
          pressure: $checkedConvert('pressure', (v) => v as int?),
          seaLevel: $checkedConvert('sea_level', (v) => v as int?),
          grndLevel: $checkedConvert('grnd_level', (v) => v as int?),
          humidity: $checkedConvert('humidity', (v) => v as int?),
        );
        return val;
      },
      fieldKeyMap: const {
        'feelsLike': 'feels_like',
        'tempMin': 'temp_min',
        'tempMax': 'temp_max',
        'seaLevel': 'sea_level',
        'grndLevel': 'grnd_level'
      },
    );

WeatherDetail _$WeatherDetailFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'WeatherDetail',
      json,
      ($checkedConvert) {
        final val = WeatherDetail(
          id: $checkedConvert('id', (v) => v as int?),
          weatherGroup: $checkedConvert(
              'main',
              (v) =>
                  $enumDecodeNullable(_$WeatherGroupEnumMap, v,
                      unknownValue: WeatherGroup.unknown) ??
                  WeatherGroup.unknown),
          description: $checkedConvert('description', (v) => v as String?),
          icon: $checkedConvert('icon', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {'weatherGroup': 'main'},
    );

const _$WeatherGroupEnumMap = {
  WeatherGroup.thunderstorm: 'Thunderstorm',
  WeatherGroup.drizzle: 'Drizzle',
  WeatherGroup.rain: 'Rain',
  WeatherGroup.snow: 'Snow',
  WeatherGroup.mist: 'Mist',
  WeatherGroup.smoke: 'Smoke',
  WeatherGroup.haze: 'Haze',
  WeatherGroup.dust: 'Dust',
  WeatherGroup.fog: 'Fog',
  WeatherGroup.sand: 'Sand',
  WeatherGroup.ash: 'Ash',
  WeatherGroup.squall: 'Squall',
  WeatherGroup.tornado: 'Tornado',
  WeatherGroup.clear: 'Clear',
  WeatherGroup.clouds: 'Clouds',
  WeatherGroup.unknown: 'unknown',
};

Wind _$WindFromJson(Map<String, dynamic> json) => $checkedCreate(
      'Wind',
      json,
      ($checkedConvert) {
        final val = Wind(
          speed: $checkedConvert('speed', (v) => (v as num?)?.toDouble()),
          deg: $checkedConvert('deg', (v) => v as int?),
          gust: $checkedConvert('gust', (v) => (v as num?)?.toDouble()),
        );
        return val;
      },
    );

City _$CityFromJson(Map<String, dynamic> json) => $checkedCreate(
      'City',
      json,
      ($checkedConvert) {
        final val = City(
          id: $checkedConvert('id', (v) => v as int?),
          name: $checkedConvert('name', (v) => v as String?),
          latLng: $checkedConvert(
              'coord',
              (v) => v == null
                  ? null
                  : LatLng.fromJson(v as Map<String, dynamic>)),
          country: $checkedConvert('country', (v) => v as String?),
          population: $checkedConvert('population', (v) => v as int?),
          timezone: $checkedConvert('timezone', (v) => v as int?),
          sunrise: $checkedConvert(
              'sunrise', (v) => const UnixUtcConverter().fromJson(v as int?)),
          sunset: $checkedConvert(
              'sunset', (v) => const UnixUtcConverter().fromJson(v as int?)),
        );
        return val;
      },
      fieldKeyMap: const {'latLng': 'coord'},
    );

LatLng _$LatLngFromJson(Map<String, dynamic> json) => $checkedCreate(
      'LatLng',
      json,
      ($checkedConvert) {
        final val = LatLng(
          latitude: $checkedConvert('lat', (v) => (v as num?)?.toDouble()),
          longitude: $checkedConvert('lon', (v) => (v as num?)?.toDouble()),
        );
        return val;
      },
      fieldKeyMap: const {'latitude': 'lat', 'longitude': 'lon'},
    );
