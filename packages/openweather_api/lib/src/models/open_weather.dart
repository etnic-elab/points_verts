import 'package:json_annotation/json_annotation.dart';

part 'open_weather.g.dart';

@JsonSerializable()
class OpenWeather {
  OpenWeather({
    this.count,
    this.weathers,
    this.city,
  });

  factory OpenWeather.fromJson(Map<String, dynamic> json) =>
      _$OpenWeatherFromJson(json);

  //A number of timestamps returned in the API response
  @JsonKey(name: 'cnt')
  int? count;
  @JsonKey(name: 'list')
  List<Weather>? weathers;
  City? city;
}

enum PartOfDay {
  @JsonValue('d')
  day,
  @JsonValue('n')
  night,
  unknown
}

extension PartOfDayX on PartOfDay {
  String? get abbr => _$PartOfDayEnumMap[this];
}

@JsonSerializable()
class Weather {
  Weather({
    this.main,
    this.details,
    this.cloudiness,
    this.wind,
    this.visibility,
    this.probabilityOfPrecipitation,
    this.partOfDay = PartOfDay.unknown,
    this.date,
  });

  factory Weather.fromJson(Map<String, dynamic> json) =>
      _$WeatherFromJson(json);

  static _readClouds(Map map, _) => map['clouds']?['all'];
  static _readPartOfDay(Map map, _) => map['sys']?['pod'];

  Main? main;
  @JsonKey(name: 'weather')
  List<WeatherDetail>? details;
  // Cloudiness, %
  @JsonKey(readValue: _readClouds)
  int? cloudiness;
  Wind? wind;
  //Average visibility, metres. The maximum value of the visibility is 10km
  int? visibility;
  //Probability of precipitation. The values of the parameter vary between 0 and 1, where 0 is equal to 0%, 1 is equal to 100%
  @JsonKey(name: 'pop')
  int? probabilityOfPrecipitation;
  //Part of the day
  @JsonKey(readValue: _readPartOfDay, unknownEnumValue: PartOfDay.unknown)
  PartOfDay partOfDay;
  //Time of data forecasted
  @JsonKey(name: 'dt_txt')
  DateTime? date;
}

@JsonSerializable()
class Main {
  Main({
    this.temp,
    this.feelsLike,
    this.tempMin,
    this.tempMax,
    this.pressure,
    this.seaLevel,
    this.grndLevel,
    this.humidity,
  });

  factory Main.fromJson(Map<String, dynamic> json) => _$MainFromJson(json);

  //Temperature. Unit Default: Kelvin, Metric: Celsius, Imperial: Fahrenheit.
  double? temp;
  //This temperature parameter accounts for the human perception of weather. Unit Default: Kelvin, Metric: Celsius, Imperial: Fahrenheit.
  double? feelsLike;
  //Minimum temperature at the moment of calculation.
  //This is minimal forecasted temperature (within large megalopolises and urban areas), use this parameter optionally.
  //Unit Default: Kelvin, Metric: Celsius, Imperial: Fahrenheit.
  double? tempMin;
  //Maximum temperature at the moment of calculation.
  //This is maximal forecasted temperature (within large megalopolises and urban areas), use this parameter optionally.
  //Unit Default: Kelvin, Metric: Celsius, Imperial: Fahrenheit.
  double? tempMax;
  //Atmospheric pressure on the sea level by default, hPa
  int? pressure;
  //Atmospheric pressure on the sea level, hPa
  int? seaLevel;
  //Atmospheric pressure on the ground level, hPa
  int? grndLevel;
  //Humidity, %
  int? humidity;
}

enum WeatherGroup {
  @JsonValue('Thunderstorm')
  thunderstorm,
  @JsonValue('Drizzle')
  drizzle,
  @JsonValue('Rain')
  rain,
  @JsonValue('Snow')
  snow,
  @JsonValue('Mist')
  mist,
  @JsonValue('Smoke')
  smoke,
  @JsonValue('Haze')
  haze,
  @JsonValue('Dust')
  dust,
  @JsonValue('Fog')
  fog,
  @JsonValue('Sand')
  sand,
  @JsonValue('Ash')
  ash,
  @JsonValue('Squall')
  squall,
  @JsonValue('Tornado')
  tornado,
  @JsonValue('Clear')
  clear,
  @JsonValue('Clouds')
  clouds,
  unknown
}

extension WeatherGroupX on WeatherGroup {
  String? get name => _$WeatherGroupEnumMap[this];
}

@JsonSerializable()
class WeatherDetail {
  WeatherDetail({
    this.id,
    this.weatherGroup = WeatherGroup.unknown,
    this.description,
    this.icon,
  });

  factory WeatherDetail.fromJson(Map<String, dynamic> json) =>
      _$WeatherDetailFromJson(json);

  //Weather condition id
  int? id;
  //Group of weather parameters (Rain, Snow, Extreme etc.)
  @JsonKey(name: 'main', unknownEnumValue: WeatherGroup.unknown)
  WeatherGroup weatherGroup;
  //Weather condition within the group. You can get the output in your language.
  String? description;
  //Weather icon id
  String? icon;
}

@JsonSerializable()
class Wind {
  Wind({this.speed, this.deg, this.gust});

  factory Wind.fromJson(Map<String, dynamic> json) => _$WindFromJson(json);

  // Wind speed. Unit Default: meter/sec, Metric: meter/sec, Imperial: miles/hour.
  double? speed;
  //Wind direction, degrees (meteorological)
  int? deg;
  //Wind gust. Unit Default: meter/sec, Metric: meter/sec, Imperial: miles/hour
  double? gust;
}

@JsonSerializable()
class City {
  City({
    this.id,
    this.name,
    this.latLng,
    this.country,
    this.population,
    this.timezone,
    this.sunrise,
    this.sunset,
  });

  factory City.fromJson(Map<String, dynamic> json) => _$CityFromJson(json);

  //City ID
  int? id;
  //City name
  String? name;
  @JsonKey(name: 'coord')
  LatLng? latLng;
  //Country code (GB, JP etc.)
  String? country;
  // population count
  int? population;
  //Shift in seconds from UTC
  int? timezone;
  //Sunrise time, Unix, UTC
  @UnixUtcConverter()
  DateTime? sunrise;
  //Sunset time, Unix, UTC
  @UnixUtcConverter()
  DateTime? sunset;
}

@JsonSerializable()
class LatLng {
  LatLng({this.latitude, this.longitude});

  factory LatLng.fromJson(Map<String, dynamic> json) => _$LatLngFromJson(json);

  //City geo location, latitude
  @JsonKey(name: 'lat')
  double? latitude;
  //City geo location, longitude
  @JsonKey(name: 'lon')
  double? longitude;
}

class UnixUtcConverter implements JsonConverter<DateTime?, int?> {
  const UnixUtcConverter();

  @override
  int? toJson(DateTime? date) {
    if (date == null) return null;
    return (date.millisecondsSinceEpoch / 1000).round();
  }

  @override
  DateTime? fromJson(int? jsonInt) {
    if (jsonInt == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(jsonInt * 1000);
  }
}
