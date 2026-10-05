// Renders every brand image the app needs from the designer's vector master.
//
//     dart run tool/build_brand_assets.dart            # (re)write the images
//     dart run tool/build_brand_assets.dart --check    # fail if any is stale
//
// Input:  <assets-repo>/assets/brand/app_icon.svg
// Output: into <assets-repo>/assets/ (the points_verts_assets repo, default
//         ../points_verts_assets, override with --assets-repo <dir>):
//
//   launcher_icons/icon_1024.png             full art, opaque navy - iOS light
//                                            icon and the App Store icon
//   launcher_icons/icon_1024_foreground.png  art on transparent - Android
//                                            adaptive foreground, iOS dark and
//                                            (desaturated) iOS tinted
//   launcher_icons/icon_1024_monochrome.png  white silhouette - Android 13+
//                                            themed icon (only alpha counts)
//   store/play_store_icon_512.png            full art - uploaded by hand in the
//                                            Play Console
//   splash/splash_icon.png                   art clipped to a circle, centred
//                                            on 1152x1152 - every splash screen
//   light/app_logo.png, dark/app_logo.png    rounded tile - app bar and About
//
// This is an authoring-time step: run it when the SVG changes and commit the
// results to points_verts_assets. tool/release.sh runs --check so a release
// can't go out with images that no longer match the SVG.
//
// Rasterising is done by resvg (pinned, through npx), the only accurate SVG
// renderer that installs with nothing more than node. The variants are derived
// by editing the SVG text, so they can't drift from the master; if the
// designer's file changes shape enough that an edit no longer applies, the
// script stops rather than render something subtly wrong.

import 'dart:io';
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

void main(List<String> args) {
  final check = args.contains('--check');
  final repoArg = args.indexOf('--assets-repo');
  final repo = repoArg >= 0 ? args[repoArg + 1] : '../points_verts_assets';
  final assets = '$repo/assets';
  final source = File('$assets/brand/app_icon.svg');
  if (!source.existsSync()) {
    stderr.writeln('Missing ${source.path} - is points_verts_assets checked out next to this repo?');
    exit(1);
  }
  final svg = source.readAsStringSync();

  final transparent = _withoutBackground(svg);
  final outputs = <String, ({String svg, int width})>{
    'launcher_icons/icon_1024.png': (svg: svg, width: _artSize),
    'launcher_icons/icon_1024_foreground.png': (svg: transparent, width: _artSize),
    'launcher_icons/icon_1024_monochrome.png': (svg: _monochrome(transparent), width: _artSize),
    'store/play_store_icon_512.png': (svg: svg, width: 512),
    'splash/splash_icon.png': (svg: _splash(transparent), width: _splashCanvas),
    'light/app_logo.png': (svg: _tile(svg), width: _tileSize),
    'dark/app_logo.png': (svg: _tile(svg), width: _tileSize),
  };

  final tmp = Directory.systemTemp.createTempSync('brand_assets');
  var stale = 0;
  try {
    for (final MapEntry(key: path, value: out) in outputs.entries) {
      final rendered = _render(out.svg, out.width, tmp);
      final target = File('$assets/$path');
      if (check) {
        if (!target.existsSync() || !_samePixels(target.readAsBytesSync(), rendered)) {
          stderr.writeln('stale: $assets/$path');
          stale++;
        }
      } else {
        target.parent.createSync(recursive: true);
        target.writeAsBytesSync(rendered);
        stdout.writeln('wrote $assets/$path');
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
