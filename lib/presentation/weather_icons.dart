/// Weather Icons by Erik Flowers (https://erikflowers.github.io/weather-icons/),
/// font licensed under SIL OFL 1.1. Code points taken from the weather_icons
/// package, which can no longer compile since IconData became a final class.
///
/// flutter:
///   fonts:
///    - family:  WeatherIcons
///      fonts:
///       - asset: fonts/WeatherIcons.ttf
library;

import 'package:flutter/widgets.dart';

class WeatherIcons {
  WeatherIcons._();

  static const _kFontFam = 'WeatherIcons';

  static const IconData thunderstorm = IconData(0xf01e, fontFamily: _kFontFam);
  static const IconData lightning = IconData(0xf016, fontFamily: _kFontFam);
  static const IconData sprinkle = IconData(0xf01c, fontFamily: _kFontFam);
  static const IconData rain = IconData(0xf019, fontFamily: _kFontFam);
  static const IconData rainMix = IconData(0xf017, fontFamily: _kFontFam);
  static const IconData showers = IconData(0xf01a, fontFamily: _kFontFam);
  static const IconData stormShowers = IconData(0xf01d, fontFamily: _kFontFam);
  static const IconData snow = IconData(0xf01b, fontFamily: _kFontFam);
  static const IconData sleet = IconData(0xf0b5, fontFamily: _kFontFam);
  static const IconData smoke = IconData(0xf062, fontFamily: _kFontFam);
  static const IconData dayHaze = IconData(0xf0b6, fontFamily: _kFontFam);
  static const IconData dust = IconData(0xf063, fontFamily: _kFontFam);
  static const IconData fog = IconData(0xf014, fontFamily: _kFontFam);
  static const IconData cloudyGusts = IconData(0xf011, fontFamily: _kFontFam);
  static const IconData tornado = IconData(0xf056, fontFamily: _kFontFam);
  static const IconData daySunny = IconData(0xf00d, fontFamily: _kFontFam);
  static const IconData cloudy = IconData(0xf013, fontFamily: _kFontFam);
  static const IconData hurricane = IconData(0xf073, fontFamily: _kFontFam);
  static const IconData snowflakeCold = IconData(0xf076, fontFamily: _kFontFam);
  static const IconData hot = IconData(0xf072, fontFamily: _kFontFam);
  static const IconData windy = IconData(0xf021, fontFamily: _kFontFam);
  static const IconData hail = IconData(0xf015, fontFamily: _kFontFam);
  static const IconData strongWind = IconData(0xf050, fontFamily: _kFontFam);
  static const IconData na = IconData(0xf07b, fontFamily: _kFontFam);
}

/// Draws a [WeatherIcons] glyph inside a box wide enough to hold it.
///
/// The glyphs are not centred or square, so a plain [Icon] draws them
/// outside its bounds.
class WeatherIcon extends StatelessWidget {
  const WeatherIcon(this.icon, {super.key, this.size, this.color});

  final IconData icon;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final iconSize = size ?? iconTheme.size ?? 24;
    var iconColor = color ?? iconTheme.color;
    final opacity = iconTheme.opacity;
    if (iconColor != null && opacity != null && opacity != 1.0) {
      iconColor = iconColor.withValues(alpha: iconColor.a * opacity);
    }

    return SizedBox(
      width: iconSize * 1.5,
      child: Center(
        child: RichText(
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
          text: TextSpan(
            text: String.fromCharCode(icon.codePoint),
            style: TextStyle(
              inherit: false,
              color: iconColor,
              fontSize: iconSize,
              fontFamily: icon.fontFamily,
            ),
          ),
        ),
      ),
    );
  }
}
