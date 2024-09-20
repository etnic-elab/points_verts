enum TemperatureUnits { kelvin, celsius, fahrenheit }

class Temperature {
  const Temperature(this.value, this.units);

  factory Temperature.fromJson(Map<String, dynamic> json) {
    return Temperature(
      json['value'] as double,
      TemperatureUnits.values.firstWhere(
        (e) => e.toString().split('.').last == json['units'],
      ),
    );
  }

  final double value;
  final TemperatureUnits units;

  Temperature to(TemperatureUnits targetUnits) {
    if (units == targetUnits) return this;

    switch (units) {
      case TemperatureUnits.kelvin:
        switch (targetUnits) {
          case TemperatureUnits.celsius:
            return Temperature(
              value - 273.15,
              TemperatureUnits.celsius,
            );
          case TemperatureUnits.fahrenheit:
            return Temperature(
              (value - 273.15) * 9 / 5 + 32,
              TemperatureUnits.fahrenheit,
            );
          case TemperatureUnits.kelvin:
            return this;
        }
      case TemperatureUnits.celsius:
        switch (targetUnits) {
          case TemperatureUnits.kelvin:
            return Temperature(
              value + 273.15,
              TemperatureUnits.kelvin,
            );
          case TemperatureUnits.fahrenheit:
            return Temperature(
              value * 9 / 5 + 32,
              TemperatureUnits.fahrenheit,
            );
          case TemperatureUnits.celsius:
            return this;
        }
      case TemperatureUnits.fahrenheit:
        switch (targetUnits) {
          case TemperatureUnits.kelvin:
            return Temperature(
              (value - 32) * 5 / 9 + 273.15,
              TemperatureUnits.kelvin,
            );
          case TemperatureUnits.celsius:
            return Temperature(
              (value - 32) * 5 / 9,
              TemperatureUnits.celsius,
            );
          case TemperatureUnits.fahrenheit:
            return this;
        }
    }
  }

  // Convenience methods
  Temperature toKelvin() => to(TemperatureUnits.kelvin);
  Temperature toCelsius() => to(TemperatureUnits.celsius);
  Temperature toFahrenheit() => to(TemperatureUnits.fahrenheit);

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'units': units.toString().split('.').last,
    };
  }

  @override
  String toString() {
    return '$value ${units.toString().split('.').last}';
  }
}
