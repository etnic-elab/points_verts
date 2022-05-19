import 'package:flutter_test/flutter_test.dart';
import 'package:openweather_api/openweather_api.dart';

void main() {
  group('Point', () {
    group('fromJson', () {
      test('returns Enum.unknown for unsupported enums', () {
        expect(
          OpenWeather.fromJson(const <String, dynamic>{
            "cod": "200",
            "message": 0,
            "cnt": 40,
            "list": [
              {
                "dt": 1647345600,
                "main": {
                  "temp": 286.88,
                  "feels_like": 285.93,
                  "temp_min": 286.74,
                  "temp_max": 286.88,
                  "pressure": 1021,
                  "sea_level": 1021,
                  "grnd_level": 1018,
                  "humidity": 62,
                  "temp_kf": 0.14
                },
                "weather": [
                  {
                    "id": 804,
                    "main": "Unknown",
                    "description": "overcast clouds",
                    "icon": "04d"
                  }
                ],
                "clouds": {"all": 85},
                "wind": {"speed": 3.25, "deg": 134, "gust": 4.45},
                "visibility": 10000,
                "pop": 0,
                "sys": {"pod": "Unknown"},
                "dt_txt": "2022-03-15 12:00:00"
              }
            ],
            "city": {
              "id": 2643743,
              "name": "London",
              "coord": {"lat": 51.5073, "lon": -0.1277},
              "country": "GB",
              "population": 1000000,
              "timezone": 0,
              "sunrise": 1647324903,
              "sunset": 1647367441
            }
          }),
          isA<OpenWeather>().having(
            (o) => o.weathers,
            'weathers',
            isA<List<Weather>>().having(
              (l) => l.first,
              'first_weather',
              isA<Weather>()
                  .having(
                      (w) => w.partOfDay, 'partOfDayAbbr', PartOfDay.unknown)
                  .having(
                    (w) => w.details,
                    'details',
                    isA<List<WeatherDetail>>().having(
                      (l) => l.first,
                      'first_detail',
                      isA<WeatherDetail>().having((d) => d.weatherGroup,
                          'weatherGroup', WeatherGroup.unknown),
                    ),
                  ),
            ),
          ),
        );
      });
    });
  });

  group('PartOfDayX', () {
    const partOfDay = PartOfDay.day;
    test('abbr returns correct string abbreviation', () {
      expect(partOfDay.abbr, 'd');
    });
  });

  group('WeatherGroupX', () {
    const weatherState = WeatherGroup.drizzle;
    test('name returns correct string abbreviation', () {
      expect(weatherState.name, 'Drizzle');
    });
  });
}
