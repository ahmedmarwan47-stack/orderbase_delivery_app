import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

/// Host-side pixel analyzer for a real iOS simulator screenshot of the Apple
/// Music screen. Scans the capsule's right cap / gap / button region for
/// straight vertical discontinuities (the recurring "flat seam").
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pngPath = String.fromEnvironment('SEAM_PNG');
  const outPath = String.fromEnvironment('SEAM_OUT', defaultValue: '');

  test('scan screenshot for straight vertical discontinuities', () async {
    expect(pngPath, isNotEmpty, reason: 'pass --dart-define=SEAM_PNG=...');
    final bytes = File(pngPath).readAsBytesSync();

    late ui.Image image;
    await TestWidgetsFlutterBinding.instance.runAsync(() async {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      image = frame.image;
    });
    final w = image.width;
    final h = image.height;

    ByteData? data;
    await TestWidgetsFlutterBinding.instance.runAsync(() async {
      data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    });
    final rgba = data!.buffer.asUint8List();

    const dpr = 3.0;
    final barTopPx = 2610; // measured from device layout (see report)
    final barHeightPx = 84 * dpr; // 64 + 20 gap

    final lum = List<double>.filled(w * h, 0.0);
    for (var i = 0; i < w * h; i++) {
      final o = i * 4;
      lum[i] = 0.2126 * rgba[o] / 255 +
          0.7152 * rgba[o + 1] / 255 +
          0.0722 * rgba[o + 2] / 255;
    }

    // Bar-local logical coords: bar box top at barTopPx, width 440.
    double localX(int px) => (px / dpr);
    double localY(int py) => ((py - barTopPx) / dpr);

    final b = StringBuffer();
    b.writeln('image=${w}x$h dpr=$dpr');
    b.writeln(
      'expected (logical): capsule [22..342] apex (342,32); gap '
      '342..354; button [354..418]; button padded-box left edge 330.',
    );
    b.writeln(
      'expected (px): capsule right apex x=1026 y=2712; gap '
      '1026..1062; button idx 1062..1254; pad edge 990.',
    );

    // ---- (1) ASCII zoom: 1 char per physical pixel ----
    // x px 940..1110 (logical 313..370), y px 2620..2800.
    final chars = ' .:-=+*#%@';
    final x0 = 900, x1 = 1130, y0 = 2616, y1 = 2810;
    b.writeln('--- ASCII zoom $x0..$x1 x $y0..$y1 (1 char = 1 device px) ---');
    for (var py = y0; py < y1; py++) {
      b.write('${(localY(py)).toStringAsFixed(0).padLeft(4)}|');
      for (var px = x0; px < x1; px++) {
        final lumv = lum[py * w + px].clamp(0.0, 1.0);
        b.write(chars[(lumv * 9).round()]);
      }
      b.write('|${(localX(x1)).toStringAsFixed(0)}');
      b.writeln();
    }
    b.writeln();

    // ---- (2) straight vertical discontinuity detection in ROI ----
    // ROI: logical x 300..440 (px 900..1320), logical y 0..64.
    final pxx0 = 900, pxx1 = 1320;
    const magFloor = 0.012;
    const superMag = 0.03;
    final spikesAll = <({int c, int r, double m})>[];
    final rowEdges = <int, List<int>>{};
    for (var py = barTopPx; py < barTopPx + barHeightPx; py++) {
      final edges = <int>[];
      for (var c = pxx0; c < pxx1 - 1; c++) {
        final g = (lum[py * w + c + 1] - lum[py * w + c]).abs();
        if (g >= magFloor) spikesAll.add((c: c, r: py, m: g));
        if (g >= superMag) edges.add(c);
      }
      if (edges.isNotEmpty) rowEdges[(py / 2).round()] = edges;
    }

    final byCol = <int, List<int>>{};
    rowEdges.forEach((row, cols) {
      for (final c in cols) {
        byCol.putIfAbsent(c, () => []).add(row);
      }
    });

    final lines = <({double x, int y0, int y1, int n, double maxM})>[];
    for (final e in byCol.entries) {
      final ys = e.value..sort();
      var start = 0;
      for (var i = 1; i <= ys.length; i++) {
        final cont = i == ys.length || ys[i] - ys[i - 1] <= 1;
        if (!cont || i == ys.length) {
          final n = i - start;
          if (n >= 5) {
            double maxM = 0;
            for (final s in spikesAll) {
              if (s.c == e.key &&
                  s.r >= ys[start] * 2 &&
                  s.r <= ys[i - 1] * 2 + 1 &&
                  s.m > maxM) {
                maxM = s.m;
              }
            }
            lines.add((
              x: localX(e.key),
              y0: localY(ys[start] * 2).round(),
              y1: localY(ys[i - 1] * 2 + 1).round(),
              n: n,
              maxM: maxM,
            ));
          }
          start = i;
        }
      }
    }
    lines.sort((a, b) => b.maxM.compareTo(a.maxM));

    b.writeln(
      '--- straight vertical discontinuities (runs>=5 rows, '
      'column-identical) in x=300..440 y=0..64 ---',
    );
    for (final l in lines) {
      b.writeln(
        '  x=${l.x.toStringAsFixed(2)}pt  yLocal ${l.y0}..${l.y1}  '
        'n=${l.n}  maxMag=${l.maxM.toStringAsFixed(3)}',
      );
    }

    // ---- (3) capsule right-edge silhouette ----
    // For rows y 4..60 expect edge x(y) ~ 310+sqrt(32^2-(y-32)^2)
    b.writeln('--- capsule right-cap profile vs model ---');
    b.writeln('  y | measuredEdgeX(near expected) | modelX | fit?');
    double totalErr = 0;
    int nPts = 0;
    for (var y = 2; y <= 62; y += 2) {
      final py = (barTopPx + y * dpr).round();
      // model
      final dy = y - 32.0;
      final modelX = (310 + math.sqrt(math.max(0.0, 1024 - dy * dy)));
      // measure rightmost strong gradient in x 302..345
      double? edge;
      double best = 0;
      for (var c = pxx0 + 6; c < (1026).clamp(0, w); c++) {
        final g = (lum[py * w + c + 1] - lum[py * w + c]).abs();
        final pre = c > 0 ? lum[py * w + c - 1] : 0;
        final cur = lum[py * w + c];
        final nxt = lum[py * w + c + 1];
        final isLocalExt =
            (cur > pre && cur >= nxt) || (cur < pre && cur <= nxt);
        if (g >= 0.03 && isLocalExt && g > best) {
          best = g;
          edge = c + 0.5;
        }
      }
      if (edge != null) {
        final ex = localX(edge.round());
        final err = (ex - modelX).abs();
        final fit = err <= 3.0 ? 'OK' : 'DEVIAT';
        totalErr += err;
        nPts++;
        b.writeln(
          '  ${y.toString().padLeft(2)} | '
          '${edge.toStringAsFixed(1)}px(${ex.toStringAsFixed(1)}) '
          '| ${modelX.toStringAsFixed(1)} | $fit',
        );
      } else {
        b.writeln('  ${y.toString().padLeft(2)} | no strong edge found');
      }
    }
    if (nPts > 0) {
      b.writeln('mean |x-model| = ${(totalErr / nPts).toStringAsFixed(2)}pt');
    }

    final text = b.toString();
    if (outPath.isNotEmpty) {
      File(outPath).writeAsStringSync(text);
      stdout.writeln('wrote report to $outPath');
    }
  }, skip: pngPath.isEmpty ? 'Requires --dart-define=SEAM_PNG=...' : null);
}
