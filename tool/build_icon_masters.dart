// Rebuilds the launcher-icon masters from the 812x812 raster artwork.
//
//     dart run tool/build_icon_masters.dart
//
// Outputs, all into assets/launcher_icons/ (gitignored - they live in the
// points_verts_assets repo):
//
//   logo.svg                        resolution-independent vector master
//   icon_1024x1024.png              full-bleed colour, transparent corners
//   icon_1024x1024_dark.png         inset, for the iOS 18+ dark appearance
//   icon_1024x1024_monochrome.png   silhouette, for Android themed icons
//
// This is an authoring-time step, not a build step: run it when the artwork
// changes, then commit the results to points_verts_assets. Nothing in the
// normal build depends on it.
//
// Why the trace exists: no vector original of the mark is available - not in
// the repo, not on the public site, and the Adeps logo downloads sit behind a
// file-transfer portal. 812x812 was the largest artwork we had, below the
// 1024x1024 iOS wants, so every generated iOS icon was an upscale.
//
// The mark decomposes into three primitives, so this is a targeted trace
// rather than a general-purpose autotrace:
//
//   * a disc            - fitted circle, filled with a horizontal gradient
//                         sampled column by column from the raster
//   * a sun             - flat-coloured circle, fitted the same way
//   * the white furrows - the only free-form geometry; extracted as the 0.5
//                         iso-contour of the whiteness field with sub-pixel
//                         interpolation (marching squares), so the trace lands
//                         on the artwork's own anti-aliased edges rather than
//                         on pixel corners
//
// Everything is clipped to the disc, which means the furrow contours don't
// have to be accurate where they run off the edge of the mark. The PNGs are
// rasterised from that same geometry - scanline fill at 4x supersampling -
// so the vector and the bitmaps can't drift apart.

import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart';

const _source = 'assets/launcher_icons/icon_812x812.png';
const _dir = 'assets/launcher_icons';

/// Size of the generated PNG masters. iOS wants a 1024x1024 app icon.
const _masterSize = 1024;

/// Supersampling factor used when rasterising. 4x is enough that the edges
/// match the artwork's own anti-aliasing.
const _supersample = 4;

/// Fraction of the canvas the mark fills in the dark variant, leaving the rest
/// transparent so the system's dark background frames it. Full-bleed here would
/// mean the only thing changing between light and dark is the corners, which is
/// what made the icon look like it wasn't adapting at all.
const _darkMarkScale = 0.80;

/// CompanyColors.darkGreen, matching background_color_ios and
/// adaptive_icon_background in flutter_launcher_icons.yaml.
const _brandGreen = [0x24, 0x67, 0x39];

/// Whiteness is measured as min(r,g,b): every green in the artwork sits at or
/// below 94, white is 255, so the midpoint separates them with a wide margin.
const _isoLevel = 174.0;

/// Douglas-Peucker tolerance in source pixels. Small enough to stay under the
/// artwork's own anti-aliasing, large enough to keep the file reasonable.
const _simplifyEpsilon = 0.30;

/// Flat colour of the sun, and the box it lives in (used to tell it apart from
/// the similarly-coloured left end of the disc gradient).
const _sunColor = (r: 0x72, g: 0xAF, b: 0x24);
const _sunBox = (x0: 300, y0: 200, x1: 520, y1: 420);

void main() {
  final file = File(_source);
  if (!file.existsSync()) {
    stderr.writeln('Missing $_source - see the "Missing Assets" section of README.md.');
    exit(1);
  }
  final img = decodePng(file.readAsBytesSync())!;
  final w = img.width, h = img.height;
  stdout.writeln('source $_source  ${w}x$h');

  final disc = _fitCircle(img, (p) => p.a >= 128);
  stdout.writeln('disc  centre=(${_f(disc.cx)}, ${_f(disc.cy)}) r=${_f(disc.r)} '
      'circularity=${_f(disc.maxInside - disc.minOutside)}px');

  final sun = _fitCircle(img, (p) {
    if (p.a < 250) return false;
    if (p.x < _sunBox.x0 || p.x > _sunBox.x1 || p.y < _sunBox.y0 || p.y > _sunBox.y1) return false;
    return (p.r - _sunColor.r).abs() < 20 &&
        (p.g - _sunColor.g).abs() < 20 &&
        (p.b - _sunColor.b).abs() < 20;
  });
  stdout.writeln('sun   centre=(${_f(sun.cx)}, ${_f(sun.cy)}) r=${_f(sun.r)} '
      'circularity=${_f(sun.maxInside - sun.minOutside)}px');

  final stops = _gradientStops(img);
  stdout.writeln('gradient: ${stops.length} stops, '
      '${stops.first.color} -> ${stops.last.color}');

  final loops = _traceWhiteContours(img);
  final rawPoints = loops.fold<int>(0, (n, l) => n + l.length);
  final simplified = [
    for (final loop in loops)
      if (_rdp(loop, _simplifyEpsilon).length >= 4) _rdp(loop, _simplifyEpsilon),
  ];
  final keptPoints = simplified.fold<int>(0, (n, l) => n + l.length);
  stdout.writeln('furrows: ${loops.length} contours, $rawPoints points -> '
      '${simplified.length} contours, $keptPoints points');

  _write('$_dir/logo.svg', _svg(w, h, disc, sun, stops, simplified));

  final art = (
    disc: disc,
    sun: sun,
    stops: stops,
    loops: simplified,
    srcWidth: w,
  );
  _writePng('$_dir/icon_1024x1024.png', _raster(art, markScale: 1));
  _writePng('$_dir/icon_1024x1024_dark.png', _raster(art, markScale: _darkMarkScale));
  _writePng(
    '$_dir/icon_1024x1024_monochrome.png',
    _raster(art, markScale: 1, monochrome: true),
  );

  // Google Play's listing icon is uploaded by hand in the Play Console - it is
  // not taken from the app bundle the way the App Store takes its icon from the
  // build. This renders what the launcher actually shows on Android: the
  // adaptive icon's brand-green background with the foreground at the 16% inset
  // that mipmap-anydpi-v26/ic_launcher.xml applies.
  _writePng(
    '$_dir/play_store_icon_512.png',
    _raster(art, markScale: 1 - 2 * 0.16, size: 512, background: _brandGreen),
  );
}

void _write(String path, String contents) {
  File(path).writeAsStringSync(contents);
  stdout.writeln('wrote $path (${(File(path).lengthSync() / 1024).toStringAsFixed(1)} KiB)');
}

void _writePng(String path, Image image) {
  File(path).writeAsBytesSync(encodePng(image));
  stdout.writeln('wrote $path (${image.width}x${image.height}, '
      '${(File(path).lengthSync() / 1024).toStringAsFixed(1)} KiB)');
}

String _f(double v) => v.toStringAsFixed(2);

// ---------------------------------------------------------------------------
// Circle fitting
// ---------------------------------------------------------------------------

typedef Circle = ({double cx, double cy, double r, double maxInside, double minOutside});

/// Centroid + equal-area radius of the pixels matching [test]. Also reports how
/// far the shape strays from that circle, so the caller can see whether
/// approximating it as a circle is honest.
Circle _fitCircle(Image img, bool Function(Pixel) test) {
  var n = 0;
  var sx = 0.0, sy = 0.0;
  for (final p in img) {
    if (test(p)) {
      n++;
      sx += p.x;
      sy += p.y;
    }
  }
  final cx = sx / n, cy = sy / n, r = sqrt(n / pi);

  var maxInside = 0.0, minOutside = double.infinity;
  for (final p in img) {
    final d = sqrt(pow(p.x - cx, 2) + pow(p.y - cy, 2));
    if (test(p)) {
      if (d > maxInside) maxInside = d;
    } else if (d < minOutside) {
      minOutside = d;
    }
  }
  return (cx: cx, cy: cy, r: r, maxInside: maxInside, minOutside: minOutside);
}

// ---------------------------------------------------------------------------
// Gradient
// ---------------------------------------------------------------------------

typedef Stop = ({double offset, String color});

/// The disc gradient runs left to right. Rather than assume a two-stop ramp -
/// the red channel bottoms out at 0 partway across, so a straight interpolation
/// doesn't fit - this samples the median body colour of every column and emits
/// the curve as a series of stops.
List<Stop> _gradientStops(Image img) {
  final columns = <int, List<List<int>>>{};
  for (final p in img) {
    if (p.a < 250) continue;
    final mn = [p.r, p.g, p.b].reduce(min);
    final mx = [p.r, p.g, p.b].reduce(max);
    if (mn > 200 && mx - mn < 30) continue; // white furrow
    if (p.x >= _sunBox.x0 && p.x <= _sunBox.x1 && p.y >= _sunBox.y0 && p.y <= _sunBox.y1) {
      if ((p.r - _sunColor.r).abs() < 20 &&
          (p.g - _sunColor.g).abs() < 20 &&
          (p.b - _sunColor.b).abs() < 20) {
        continue; // sun
      }
    }
    (columns[p.x.toInt()] ??= []).add([p.r.toInt(), p.g.toInt(), p.b.toInt()]);
  }

  // Only trust columns with enough body pixels; the extreme left and right of
  // the disc are thin slivers dominated by anti-aliasing.
  final trusted = columns.keys.where((x) => columns[x]!.length >= 100).toList()..sort();
  final median = <int, List<int>>{};
  for (final x in trusted) {
    final px = columns[x]!;
    median[x] = [
      for (var ch = 0; ch < 3; ch++)
        (px.map((c) => c[ch]).toList()..sort())[px.length ~/ 2],
    ];
  }

  // Smooth out per-column quantisation noise.
  const window = 9;
  List<int> smoothed(int x) {
    final acc = [0, 0, 0];
    var n = 0;
    for (var i = x - window; i <= x + window; i++) {
      final m = median[i];
      if (m == null) continue;
      for (var ch = 0; ch < 3; ch++) {
        acc[ch] += m[ch];
      }
      n++;
    }
    return [for (var ch = 0; ch < 3; ch++) (acc[ch] / n).round()];
  }

  final lo = trusted.first, hi = trusted.last;
  // Extrapolate past the trusted range using the local slope, so the slivers at
  // each edge of the disc continue the ramp instead of flattening.
  final loA = smoothed(lo), loB = smoothed(lo + 60);
  final hiA = smoothed(hi - 60), hiB = smoothed(hi);

  List<int> colorAt(int x) {
    if (x < lo) {
      return [
        for (var ch = 0; ch < 3; ch++)
          (loA[ch] + (loA[ch] - loB[ch]) * (lo - x) / 60).round().clamp(0, 255),
      ];
    }
    if (x > hi) {
      return [
        for (var ch = 0; ch < 3; ch++)
          (hiB[ch] + (hiB[ch] - hiA[ch]) * (x - hi) / 60).round().clamp(0, 255),
      ];
    }
    return smoothed(x);
  }

  const count = 33;
  return [
    for (var i = 0; i < count; i++)
      () {
        final x = (i * (img.width - 1) / (count - 1)).round();
        final c = colorAt(x);
        return (offset: i / (count - 1), color: '#${_hex(c[0])}${_hex(c[1])}${_hex(c[2])}');
      }(),
  ];
}

String _hex(int v) => v.toRadixString(16).padLeft(2, '0').toUpperCase();

// ---------------------------------------------------------------------------
// Contour tracing (marching squares with linear interpolation)
// ---------------------------------------------------------------------------

class _Pt {
  const _Pt(this.x, this.y);
  final double x;
  final double y;
}

/// Extracts the white furrows as closed sub-pixel contours.
///
/// The field is min(r,g,b) over the raster with alpha ignored: outside the disc
/// the artwork's own RGB is near-white, so the transparent corners join up with
/// the furrows into one region. That's harmless - the result is clipped to the
/// disc - and it keeps every contour closed.
List<List<_Pt>> _traceWhiteContours(Image img) {
  final w = img.width, h = img.height;
  // Padded by one cell of "not white" so contours touching the border close.
  final fw = w + 2, fh = h + 2;
  final field = Float32List(fw * fh);
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      final p = img.getPixel(x, y);
      field[(y + 1) * fw + (x + 1)] =
          [p.r, p.g, p.b].reduce(min).toDouble();
    }
  }

  final points = <String, _Pt>{};
  final next = <String, List<String>>{};

  double at(int i, int j) => field[j * fw + i];

  // Interpolated crossing on the horizontal lattice edge (i,j)-(i+1,j).
  String hEdge(int i, int j) {
    final key = 'H:$i:$j';
    if (!points.containsKey(key)) {
      final a = at(i, j), b = at(i + 1, j);
      final t = (_isoLevel - a) / (b - a);
      points[key] = _Pt(i + t - 1, j - 1.0);
    }
    return key;
  }

  // Interpolated crossing on the vertical lattice edge (i,j)-(i,j+1).
  String vEdge(int i, int j) {
    final key = 'V:$i:$j';
    if (!points.containsKey(key)) {
      final a = at(i, j), b = at(i, j + 1);
      final t = (_isoLevel - a) / (b - a);
      points[key] = _Pt(i - 1.0, j + t - 1);
    }
    return key;
  }

  void link(String from, String to) => (next[from] ??= []).add(to);

  for (var j = 0; j < fh - 1; j++) {
    for (var i = 0; i < fw - 1; i++) {
      final v0 = at(i, j), v1 = at(i + 1, j), v2 = at(i + 1, j + 1), v3 = at(i, j + 1);
      var code = 0;
      if (v0 > _isoLevel) code |= 1;
      if (v1 > _isoLevel) code |= 2;
      if (v2 > _isoLevel) code |= 4;
      if (v3 > _isoLevel) code |= 8;
      if (code == 0 || code == 15) continue;

      String top() => hEdge(i, j);
      String bottom() => hEdge(i, j + 1);
      String left() => vEdge(i, j);
      String right() => vEdge(i + 1, j);

      switch (code) {
        case 1:
          link(left(), top());
        case 2:
          link(top(), right());
        case 3:
          link(left(), right());
        case 4:
          link(right(), bottom());
        case 5:
          // Saddle: resolve with the cell average.
          if ((v0 + v1 + v2 + v3) / 4 > _isoLevel) {
            link(left(), top());
            link(right(), bottom());
          } else {
            link(left(), bottom());
            link(right(), top());
          }
        case 6:
          link(top(), bottom());
        case 7:
          link(left(), bottom());
        case 8:
          link(bottom(), left());
        case 9:
          link(bottom(), top());
        case 10:
          if ((v0 + v1 + v2 + v3) / 4 > _isoLevel) {
            link(top(), right());
            link(bottom(), left());
          } else {
            link(top(), left());
            link(bottom(), right());
          }
        case 11:
          link(bottom(), right());
        case 12:
          link(right(), left());
        case 13:
          link(right(), top());
        case 14:
          link(top(), left());
      }
    }
  }

  // Chain the directed segments into closed loops.
  final loops = <List<_Pt>>[];
  final visited = <String>{};
  for (final start in next.keys) {
    if (visited.contains(start)) continue;
    final loop = <_Pt>[];
    var cursor = start;
    while (true) {
      if (visited.contains(cursor)) break;
      visited.add(cursor);
      loop.add(points[cursor]!);
      final outs = next[cursor];
      if (outs == null || outs.isEmpty) break;
      cursor = outs.firstWhere((k) => !visited.contains(k), orElse: () => outs.first);
      if (cursor == start) break;
    }
    if (loop.length >= 8) loops.add(loop);
  }
  return loops;
}

/// Ramer-Douglas-Peucker, applied to a closed ring.
List<_Pt> _rdp(List<_Pt> pts, double epsilon) {
  if (pts.length < 3) return pts;
  final keep = List<bool>.filled(pts.length, false);
  keep[0] = true;
  keep[pts.length - 1] = true;

  final stack = <List<int>>[
    [0, pts.length - 1],
  ];
  while (stack.isNotEmpty) {
    final range = stack.removeLast();
    final first = range[0], last = range[1];
    var maxDist = 0.0, index = -1;
    for (var i = first + 1; i < last; i++) {
      final d = _perpendicularDistance(pts[i], pts[first], pts[last]);
      if (d > maxDist) {
        maxDist = d;
        index = i;
      }
    }
    if (maxDist > epsilon && index > 0) {
      keep[index] = true;
      stack.add([first, index]);
      stack.add([index, last]);
    }
  }
  return [
    for (var i = 0; i < pts.length; i++)
      if (keep[i]) pts[i],
  ];
}

double _perpendicularDistance(_Pt p, _Pt a, _Pt b) {
  final dx = b.x - a.x, dy = b.y - a.y;
  final len = sqrt(dx * dx + dy * dy);
  if (len == 0) return sqrt(pow(p.x - a.x, 2) + pow(p.y - a.y, 2));
  return ((p.x - a.x) * dy - (p.y - a.y) * dx).abs() / len;
}

// ---------------------------------------------------------------------------
// Rasterising
// ---------------------------------------------------------------------------

typedef Artwork = ({
  Circle disc,
  Circle sun,
  List<Stop> stops,
  List<List<_Pt>> loops,
  int srcWidth,
});

/// Renders the traced geometry to a PNG, so the bitmaps can't drift away from
/// logo.svg the way separately-exported assets do.
///
/// [markScale] is the fraction of the canvas the disc fills; the remainder
/// stays transparent. [monochrome] knocks the furrows and the sun out of a
/// solid black disc, which is the silhouette Android themed icons want.
Image _raster(
  Artwork art, {
  required double markScale,
  bool monochrome = false,
  int size = _masterSize,
  List<int>? background,
}) {
  const ss = _supersample;
  const samples = ss * ss;

  // Source space -> canvas space. The disc is centred and scaled to markScale.
  final scale = (size * markScale / 2) / art.disc.r;
  final centre = size / 2;
  final discR2 = art.disc.r * art.disc.r;
  final sunR2 = art.sun.r * art.sun.r;
  final lut = _gradientLut(art.stops, art.srcWidth);

  final out = Image(width: size, height: size, numChannels: 4);
  if (background != null) {
    fill(out, color: ColorRgba8(background[0], background[1], background[2], 255));
  }
  final acc = Float64List(size * 4);

  for (var oy = 0; oy < size; oy++) {
    acc.fillRange(0, acc.length, 0);

    for (var sy = 0; sy < ss; sy++) {
      final ys = ((oy + (sy + 0.5) / ss) - centre) / scale + art.disc.cy;
      final crossings = _rowCrossings(art.loops, ys);

      // Crossings are sorted and x increases monotonically across the row, so
      // a single walking pointer resolves the even-odd test in O(1) per sample.
      var next = 0;
      var inFurrow = false;
      final dy = ys - art.disc.cy;
      final dyy = dy * dy;
      final sdy = ys - art.sun.cy;
      final sdyy = sdy * sdy;

      for (var ox = 0; ox < size; ox++) {
        for (var sx = 0; sx < ss; sx++) {
          final xs = ((ox + (sx + 0.5) / ss) - centre) / scale + art.disc.cx;
          while (next < crossings.length && crossings[next] <= xs) {
            inFurrow = !inFurrow;
            next++;
          }

          final dx = xs - art.disc.cx;
          if (dx * dx + dyy > discR2) continue; // outside the mark

          final sdx = xs - art.sun.cx;
          final inSun = sdx * sdx + sdyy <= sunR2;

          double r, g, b;
          if (monochrome) {
            if (inFurrow || inSun) continue; // knocked out
            r = g = b = 0;
          } else if (inFurrow) {
            r = g = b = 255;
          } else if (inSun) {
            r = _sunColor.r.toDouble();
            g = _sunColor.g.toDouble();
            b = _sunColor.b.toDouble();
          } else {
            final i = xs.round().clamp(0, art.srcWidth - 1) * 3;
            r = lut[i].toDouble();
            g = lut[i + 1].toDouble();
            b = lut[i + 2].toDouble();
          }

          final o = ox * 4;
          acc[o] += r;
          acc[o + 1] += g;
          acc[o + 2] += b;
          acc[o + 3] += 1;
        }
      }
    }

    for (var ox = 0; ox < size; ox++) {
      final o = ox * 4;
      final covered = acc[o + 3];
      if (covered == 0) continue;
      final a = covered / samples;
      final r = acc[o] / covered, g = acc[o + 1] / covered, b = acc[o + 2] / covered;
      if (background == null) {
        out.setPixelRgba(ox, oy, r.round(), g.round(), b.round(), (a * 255).round());
      } else {
        out.setPixelRgba(
          ox,
          oy,
          (r * a + background[0] * (1 - a)).round(),
          (g * a + background[1] * (1 - a)).round(),
          (b * a + background[2] * (1 - a)).round(),
          255,
        );
      }
    }
  }
  return out;
}

/// Sorted x positions where the furrow contours cross scanline [y].
List<double> _rowCrossings(List<List<_Pt>> loops, double y) {
  final xs = <double>[];
  for (final loop in loops) {
    for (var i = 0; i < loop.length; i++) {
      final a = loop[i];
      final b = loop[(i + 1) % loop.length];
      if ((a.y <= y) == (b.y <= y)) continue;
      xs.add(a.x + (y - a.y) / (b.y - a.y) * (b.x - a.x));
    }
  }
  xs.sort();
  return xs;
}

/// Flattens the gradient stops into one RGB triple per source column.
Uint8List _gradientLut(List<Stop> stops, int n) {
  final lut = Uint8List(n * 3);
  for (var i = 0; i < n; i++) {
    final t = i / (n - 1);
    var k = 0;
    while (k < stops.length - 2 && stops[k + 1].offset < t) {
      k++;
    }
    final a = _parseHex(stops[k].color);
    final b = _parseHex(stops[k + 1].color);
    final span = stops[k + 1].offset - stops[k].offset;
    final f = span <= 0 ? 0.0 : ((t - stops[k].offset) / span).clamp(0.0, 1.0);
    for (var ch = 0; ch < 3; ch++) {
      lut[i * 3 + ch] = (a[ch] + (b[ch] - a[ch]) * f).round();
    }
  }
  return lut;
}

List<int> _parseHex(String hex) {
  final v = int.parse(hex.substring(1), radix: 16);
  return [(v >> 16) & 0xFF, (v >> 8) & 0xFF, v & 0xFF];
}

// ---------------------------------------------------------------------------
// SVG output
// ---------------------------------------------------------------------------

String _svg(
  int w,
  int h,
  Circle disc,
  Circle sun,
  List<Stop> stops,
  List<List<_Pt>> loops,
) {
  String n(double v) {
    final s = v.toStringAsFixed(2);
    return s.endsWith('.00') ? s.substring(0, s.length - 3) : s;
  }

  final path = StringBuffer();
  for (final loop in loops) {
    path.write('M${n(loop.first.x)} ${n(loop.first.y)}');
    for (final p in loop.skip(1)) {
      path.write('L${n(p.x)} ${n(p.y)}');
    }
    path.write('Z');
  }

  final stopTags = stops
      .map((s) => '      <stop offset="${(s.offset * 100).toStringAsFixed(3)}%" '
          'stop-color="${s.color}"/>')
      .join('\n');

  // No width/height attributes: the master should take the size of whatever
  // renders it, rather than defaulting to the traced raster's dimensions.
  return '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 $w $h">
  <!-- Traced from icon_812x812.png by tool/trace_logo_svg.dart. -->
  <defs>
    <linearGradient id="disc-fill" gradientUnits="userSpaceOnUse" x1="0" y1="0" x2="$w" y2="0">
$stopTags
    </linearGradient>
    <clipPath id="disc-clip">
      <circle cx="${n(disc.cx)}" cy="${n(disc.cy)}" r="${n(disc.r)}"/>
    </clipPath>
  </defs>
  <g clip-path="url(#disc-clip)">
    <circle cx="${n(disc.cx)}" cy="${n(disc.cy)}" r="${n(disc.r)}" fill="url(#disc-fill)"/>
    <circle cx="${n(sun.cx)}" cy="${n(sun.cy)}" r="${n(sun.r)}" fill="#72AF24"/>
    <path fill="#FFFFFF" fill-rule="evenodd" d="$path"/>
  </g>
</svg>
''';
}
