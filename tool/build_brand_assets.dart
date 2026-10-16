// Renders every brand image the app needs from the designer's vector master.
//
//     dart run tool/build_brand_assets.dart            # (re)write the images
//     dart run tool/build_brand_assets.dart --check    # fail if any is stale
//
// Input:  <assets-repo>/assets/brand/app_icon.svg
// Output: into the points_verts_assets repo (default ../points_verts_assets,
//         override with --assets-repo <dir>), at these paths:
//
//   App icon - the whole artwork:
//   assets/launcher_icons/icon_1024.png             full art, opaque navy - iOS
//                                                   light icon and App Store icon
//   assets/launcher_icons/icon_1024_foreground.png  art on transparent - Android
//                                                   adaptive foreground, iOS dark
//                                                   and (desaturated) iOS tinted
//   assets/launcher_icons/icon_1024_monochrome.png  white silhouette - Android
//                                                   13+ themed icon (alpha only)
//   assets/store/play_store_icon_512.png            full art - uploaded by hand in
//                                                   the Play Console
//   assets/splash/splash_icon.png                   art clipped to a circle, on
//                                                   1152x1152 - every splash
//   assets/{light,dark}/app_logo.png                rounded tile - app bar, About
//
//   Walk symbol - the shoe tread taken from the artwork:
//   assets/{light,dark}/logo.png                    walk marker and list icon
//   assets/{light,dark}/logo-annule.png             the same, cancelled walk
//   android/app/src/main/res/drawable-*/ic_notification.png
//                                                   notification icon, 24-96 px
//   web/walk_marker*_32.png                         static-map markers, uploaded
//                                                   by hand to the public website
//
// This is an authoring-time step: run it when the SVG changes and commit the
// results to points_verts_assets. tool/release.sh runs --check so a release
// can't go out with images that no longer match the SVG.
//
// Rasterising is done by resvg (pinned, through npx), the only accurate SVG
// renderer that installs with nothing more than node. Every image is derived
// from the master's own shapes by editing SVG text, so none can drift from it;
// if the designer's file changes shape enough that an edit no longer applies,
// the script stops rather than render something subtly wrong.

import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart';

const _resvg = '@resvg/resvg-js-cli@2.6.2-beta.1';

/// The SVG's own square size (viewBox 0 0 1024 1024).
const _artSize = 1024;

/// Android 12+ splash icon: a 1152 px image whose content must fit a centred
/// 768 px circle. Every other splash reuses it so all platforms look the same.
const _splashCanvas = 1152;
const _splashCircle = 768;

/// Corner radius of the in-app tile, as a fraction of its size - the iOS app
/// icon's proportion, so the tile reads as "the app icon".
const _tileCornerRatio = 0.2237;
const _tileSize = 256;

/// The icon's navy, and the reds of CompanyColors.red / lightRed: a cancelled
/// walk is marked in the deeper red on light maps, the brighter one on dark.
const _navy = '#002f69';
const _white = '#fff';
const _red = '#d7272e';
const _lightRed = '#f03b33';

/// The walk symbol: the white shoe tread at the bottom of the icon. It is
/// found by its first shape rather than by position, so a redrawn icon stops
/// the script instead of quietly picking other shapes.
const _treadFirstShape = 'M687.44,843.5';
const _treadShapeCount = 12;

/// Walk markers are drawn at 21-40 px in the app; 256 px keeps them sharp on
/// 3x screens without bloating the bundle.
const _markerSize = 256;

/// The public static-map markers keep the size of the ones they replace.
const _webMarkerSize = 32;

/// Android notification icon: 24 dp, at each density.
const _notificationSizes = {
  'mdpi': 24,
  'hdpi': 36,
  'xhdpi': 48,
  'xxhdpi': 72,
  'xxxhdpi': 96,
};

typedef _Box = ({double x, double y, double size});

void main(List<String> args) {
  final check = args.contains('--check');
  final repoArg = args.indexOf('--assets-repo');
  final repo = repoArg >= 0 ? args[repoArg + 1] : '../points_verts_assets';
  final source = File('$repo/assets/brand/app_icon.svg');
  if (!source.existsSync()) {
    stderr.writeln('Missing ${source.path} - is points_verts_assets checked out next to this repo?');
    exit(1);
  }
  final svg = source.readAsStringSync();

  final tmp = Directory.systemTemp.createTempSync('brand_assets');
  var stale = 0;
  try {
    final transparent = _withoutBackground(svg);
    final tread = _treadShapes(svg);
    final treadBox = _squareBounds(tread, tmp);
    final marker = _marker(tread, treadBox);

    final outputs = <String, ({String svg, int width})>{
      'assets/launcher_icons/icon_1024.png': (svg: svg, width: _artSize),
      'assets/launcher_icons/icon_1024_foreground.png': (svg: transparent, width: _artSize),
      'assets/launcher_icons/icon_1024_monochrome.png': (svg: _monochrome(transparent), width: _artSize),
      'assets/store/play_store_icon_512.png': (svg: svg, width: 512),
      'assets/splash/splash_icon.png': (svg: _splash(transparent), width: _splashCanvas),
      'assets/light/app_logo.png': (svg: _tile(svg), width: _tileSize),
      'assets/dark/app_logo.png': (svg: _tile(svg), width: _tileSize),
      'assets/light/logo.png': (svg: marker, width: _markerSize),
      'assets/dark/logo.png': (svg: marker, width: _markerSize),
      'assets/light/logo-annule.png': (svg: _marker(tread, treadBox, cancelledIn: _red), width: _markerSize),
      'assets/dark/logo-annule.png': (svg: _marker(tread, treadBox, cancelledIn: _lightRed), width: _markerSize),
      'web/walk_marker_32.png': (svg: marker, width: _webMarkerSize),
      'web/walk_marker_cancelled_light_32.png': (svg: _marker(tread, treadBox, cancelledIn: _red), width: _webMarkerSize),
      'web/walk_marker_cancelled_dark_32.png': (svg: _marker(tread, treadBox, cancelledIn: _lightRed), width: _webMarkerSize),
      for (final MapEntry(key: density, value: size) in _notificationSizes.entries)
        'android/app/src/main/res/drawable-$density/ic_notification.png': (svg: _notification(tread, treadBox), width: size),
    };

    for (final MapEntry(key: path, value: out) in outputs.entries) {
      final rendered = _render(out.svg, out.width, tmp);
      final target = File('$repo/$path');
      if (check) {
        if (!target.existsSync() || !_samePixels(target.readAsBytesSync(), rendered)) {
          stderr.writeln('stale: ${target.path}');
          stale++;
        }
      } else {
        target.parent.createSync(recursive: true);
        target.writeAsBytesSync(rendered);
        stdout.writeln('wrote ${target.path}');
      }
    }
  } finally {
    tmp.deleteSync(recursive: true);
  }

  if (stale > 0) {
    stderr.writeln('$stale brand image(s) out of date. Run: dart run tool/build_brand_assets.dart');
    exit(1);
  }
  if (check) stdout.writeln('Brand images match ${source.path}.');
}

/// The navy square is the only `<rect>`; without it the art sits on transparent,
/// which is what Android's adaptive foreground and iOS's dark icon expect.
String _withoutBackground(String svg) =>
    _replaceOnce(svg, RegExp(r'<rect class="st0"[^>]*/>\s*'), '', 'the background <rect class="st0">');

/// Android themed icons only use alpha, so every shape just has to be opaque.
String _monochrome(String transparent) =>
    _replaceOnce(transparent, RegExp(r'fill:\s*#ed9e41'), 'fill: #fff', 'the orange fill (.st2)');

/// Clips the art to a circle and shrinks it into the 768 px safe circle of a
/// 1152 px canvas, by widening the viewBox around the same artwork.
String _splash(String transparent) {
  const pad = (_artSize * _splashCanvas / _splashCircle - _artSize) / 2;
  const span = _artSize + 2 * pad;
  final clipped = _clip(transparent, '<circle cx="512" cy="512" r="512"/>');
  return _replaceOnce(
    clipped,
    RegExp(r'viewBox="0 0 1024 1024"'),
    'viewBox="${-pad} ${-pad} $span $span"',
    'viewBox="0 0 1024 1024"',
  );
}

String _tile(String svg) {
  const r = _artSize * _tileCornerRatio;
  return _clip(svg, '<rect width="1024" height="1024" rx="$r" ry="$r"/>');
}

/// Wraps everything after `</defs>` in a group clipped to [shape].
String _clip(String svg, String shape) {
  final withClip = _replaceOnce(
    svg,
    RegExp(r'</defs>'),
    '<clipPath id="brand-clip">$shape</clipPath></defs><g clip-path="url(#brand-clip)">',
    '</defs>',
  );
  return _replaceOnce(withClip, RegExp(r'</svg>\s*$'), '</g></svg>', '</svg>');
}

/// The shapes of the shoe tread, in drawing order.
List<String> _treadShapes(String svg) {
  final body = svg.substring(svg.indexOf('</defs>'));
  final shapes = RegExp(r'<(?:path|polygon)\b[^>]*/>').allMatches(body).map((m) => m[0]!).toList();
  final first = shapes.indexWhere((s) => s.contains('d="$_treadFirstShape'));
  if (first < 0 || first + _treadShapeCount > shapes.length) {
    stderr.writeln('Could not find the shoe tread (first shape "$_treadFirstShape") in the SVG. '
        'The source changed shape - update tool/build_brand_assets.dart.');
    exit(1);
  }
  return shapes.sublist(first, first + _treadShapeCount);
}

/// The square, in SVG units, centred on what [shapes] actually paint. Measured
/// by rendering them, since the path data is relative and has curves.
_Box _squareBounds(List<String> shapes, Directory tmp) {
  final png = _render(_document('0 0 $_artSize $_artSize', _filled(shapes, _white)), _artSize, tmp);
  final image = decodePng(Uint8List.fromList(png))!;
  var (minX, minY, maxX, maxY) = (image.width, image.height, -1, -1);
  for (final p in image) {
    if (p.a == 0) continue;
    minX = min(minX, p.x);
    minY = min(minY, p.y);
    maxX = max(maxX, p.x);
    maxY = max(maxY, p.y);
  }
  final width = maxX - minX + 1, height = maxY - minY + 1;
  final side = max(width, height).toDouble();
  return (x: minX - (side - width) / 2, y: minY - (side - height) / 2, size: side);
}

String _document(String viewBox, String content) =>
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="$viewBox">$content</svg>';

/// Shapes lifted from the master keep their class, which only meant something
/// next to the master's own <style>; the group's fill paints them instead.
String _filled(List<String> shapes, String fill) => '<g fill="$fill">${shapes.join()}</g>';

String _viewBox(_Box box, {double pad = 0}) =>
    '${box.x - pad} ${box.y - pad} ${box.size + 2 * pad} ${box.size + 2 * pad}';

/// The walk marker, on a 100-unit square: the tread in white on a navy disc
/// with a thin white outline - the same build as the green disc it replaces,
/// so it stands out on light and dark maps alike. A cancelled walk swaps the
/// outline for a ring and a slash in [cancelledIn].
String _marker(List<String> tread, _Box box, {String? cancelledIn}) {
  // The tread is about 1.6 times wider than tall, so at 64 units wide it still
  // clears the cancelled ring's inner edge (radius 40).
  final art = '<svg x="18" y="18" width="64" height="64" viewBox="${_viewBox(box)}">'
      '${_filled(tread, _white)}</svg>';
  if (cancelledIn == null) {
    return _document('0 0 100 100',
        '<circle cx="50" cy="50" r="50" fill="$_white"/><circle cx="50" cy="50" r="45" fill="$_navy"/>$art');
  }
  // The slash runs along the diagonal and stops where it meets the ring.
  const end = 45 / sqrt2;
  return _document(
    '0 0 100 100',
    '<circle cx="50" cy="50" r="50" fill="$_navy"/>$art'
        '<circle cx="50" cy="50" r="45" fill="none" stroke="$cancelledIn" stroke-width="10"/>'
        '<line x1="${50 - end}" y1="${50 - end}" x2="${50 + end}" y2="${50 + end}" '
        'stroke="$cancelledIn" stroke-width="10"/>',
  );
}

/// The notification icon: Android only uses its alpha, so the tread is a
/// white silhouette, inside the 22 dp live area of the 24 dp canvas.
String _notification(List<String> tread, _Box box) =>
    _document(_viewBox(box, pad: box.size / 22), _filled(tread, _white));

String _replaceOnce(String s, RegExp pattern, String replacement, String what) {
  final count = pattern.allMatches(s).length;
  if (count != 1) {
    stderr.writeln('Expected exactly one $what in the SVG, found $count. '
        'The source changed shape - update tool/build_brand_assets.dart.');
    exit(1);
  }
  return s.replaceFirst(pattern, replacement);
}

List<int> _render(String svg, int width, Directory tmp) {
  final input = File('${tmp.path}/in.svg')..writeAsStringSync(svg);
  final output = File('${tmp.path}/out.png');
  final result = Process.runSync(
    'npx',
    ['-y', _resvg, '--no-system-font', '--fit-width', '$width', input.path, output.path],
    runInShell: true,
  );
  if (result.exitCode != 0 || !output.existsSync()) {
    stderr
      ..writeln('resvg failed (exit ${result.exitCode}):')
      ..writeln(result.stdout)
      ..writeln(result.stderr);
    exit(1);
  }
  final bytes = output.readAsBytesSync();
  output.deleteSync();
  return bytes;
}

/// Compares decoded pixels rather than file bytes, so a different PNG encoder
/// setting alone doesn't count as stale.
bool _samePixels(List<int> a, List<int> b) {
  final x = decodePng(Uint8List.fromList(a))?.convert(numChannels: 4);
  final y = decodePng(Uint8List.fromList(b))?.convert(numChannels: 4);
  if (x == null || y == null || x.width != y.width || x.height != y.height) return false;
  final xb = x.toUint8List(), yb = y.toUint8List();
  for (var i = 0; i < xb.length; i++) {
    if (xb[i] != yb[i]) return false;
  }
  return true;
}
