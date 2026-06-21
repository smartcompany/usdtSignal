import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:usdt_signal/kimchi_fx_delta.dart';
import 'package:usdt_signal/l10n/app_localizations.dart';

/// 환율 비율식 보정: USD/KRW 1300~1600 구간에서 Δ(pp) 곡선 미리보기.
class KimchiFxDeltaAffinePreviewChart extends StatefulWidget {
  const KimchiFxDeltaAffinePreviewChart({
    super.key,
    required this.model,
    this.height = 200,
  });

  final KimchiFxDeltaAffineRatio model;
  final double height;

  static const double fxMin = 1300;
  static const double fxMax = 1600;

  @override
  State<KimchiFxDeltaAffinePreviewChart> createState() =>
      _KimchiFxDeltaAffinePreviewChartState();
}

class _KimchiFxDeltaAffinePreviewChartState
    extends State<KimchiFxDeltaAffinePreviewChart> {
  static const _padLeft = 44.0;
  static const _padRight = 12.0;
  static const _padTop = 12.0;
  static const _padBottom = 28.0;
  static const _steps = 300;

  Offset? _hoverLocal;

  List<({double fx, double delta})> _samplePoints() {
    final m = widget.model;
    return List.generate(_steps + 1, (i) {
      final t = i / _steps;
      final fx =
          KimchiFxDeltaAffinePreviewChart.fxMin +
          (KimchiFxDeltaAffinePreviewChart.fxMax -
                  KimchiFxDeltaAffinePreviewChart.fxMin) *
              t;
      return (fx: fx, delta: m.deltaForFx(fx));
    });
  }

  ({double min, double max}) _deltaRange(
    List<({double fx, double delta})> pts,
  ) {
    if (pts.isEmpty) return (min: -1.0, max: 1.0);
    var min = pts.first.delta;
    var max = pts.first.delta;
    for (final p in pts) {
      if (p.delta < min) min = p.delta;
      if (p.delta > max) max = p.delta;
    }
    if ((max - min).abs() < 0.05) {
      min -= 0.5;
      max += 0.5;
    } else {
      final pad = (max - min) * 0.08;
      min -= pad;
      max += pad;
    }
    return (min: min, max: max);
  }

  Rect _plotRect(Size size) => Rect.fromLTWH(
    _padLeft,
    _padTop,
    size.width - _padLeft - _padRight,
    size.height - _padTop - _padBottom,
  );

  double _fxFromDx(double dx, Rect plot) {
    final t = ((dx - plot.left) / plot.width).clamp(0.0, 1.0);
    return KimchiFxDeltaAffinePreviewChart.fxMin +
        (KimchiFxDeltaAffinePreviewChart.fxMax -
                KimchiFxDeltaAffinePreviewChart.fxMin) *
            t;
  }

  Offset _pointOnPlot(
    double fx,
    double delta,
    Rect plot,
    ({double min, double max}) yRange,
  ) {
    final xT =
        (fx - KimchiFxDeltaAffinePreviewChart.fxMin) /
        (KimchiFxDeltaAffinePreviewChart.fxMax -
            KimchiFxDeltaAffinePreviewChart.fxMin);
    final ySpan = yRange.max - yRange.min;
    final yT = ySpan == 0 ? 0.5 : (delta - yRange.min) / ySpan;
    return Offset(
      plot.left + plot.width * xT,
      plot.bottom - plot.height * yT,
    );
  }

  double _xForFx(double fx, Rect plot) {
    final t =
        (fx - KimchiFxDeltaAffinePreviewChart.fxMin) /
        (KimchiFxDeltaAffinePreviewChart.fxMax -
            KimchiFxDeltaAffinePreviewChart.fxMin);
    return plot.left + plot.width * t;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final nfFx = NumberFormat('#,##0', localeTag);
    final nfDelta = NumberFormat('+#,##0.00;-#,##0.00', localeTag);
    final nfAxisDelta = NumberFormat('#,##0.0', localeTag);
    final axisLabelStyle = TextStyle(
      fontSize: 10,
      color: cs.onSurfaceVariant,
    );

    final points = _samplePoints();
    final yRange = _deltaRange(points);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          loc.kimchiFxDeltaPreviewTitle,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: widget.height,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(constraints.maxWidth, widget.height);
              final plot = _plotRect(size);

              double? hoverFx;
              double? hoverDelta;
              if (_hoverLocal != null && plot.contains(_hoverLocal!)) {
                hoverFx = _fxFromDx(_hoverLocal!.dx, plot);
                hoverDelta = widget.model.deltaForFx(hoverFx);
              }

              return Listener(
                onPointerDown: (e) =>
                    setState(() => _hoverLocal = e.localPosition),
                onPointerMove: (e) =>
                    setState(() => _hoverLocal = e.localPosition),
                onPointerUp: (_) => setState(() => _hoverLocal = null),
                child: MouseRegion(
                  onHover: (e) =>
                      setState(() => _hoverLocal = e.localPosition),
                  onExit: (_) => setState(() => _hoverLocal = null),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CustomPaint(
                        size: size,
                        painter: _AffineDeltaChartPainter(
                          points: points,
                          yRange: yRange,
                          plot: plot,
                          hoverLocal: _hoverLocal,
                          hoverFx: hoverFx,
                          hoverDelta: hoverDelta,
                          lineColor: cs.primary,
                          gridColor: cs.outline.withValues(alpha: 0.25),
                          crosshairColor: cs.secondary,
                        ),
                      ),
                      Positioned(
                        left: 2,
                        top: plot.top - 2,
                        child: Text(
                          '${nfAxisDelta.format(yRange.max)} pp',
                          style: axisLabelStyle,
                        ),
                      ),
                      Positioned(
                        left: 2,
                        top: plot.bottom - 14,
                        child: Text(
                          '${nfAxisDelta.format(yRange.min)} pp',
                          style: axisLabelStyle,
                        ),
                      ),
                      for (final fx in [1300.0, 1400.0, 1500.0, 1600.0])
                        Positioned(
                          left: _xForFx(fx, plot) - 18,
                          top: plot.bottom + 4,
                          width: 36,
                          child: Text(
                            nfFx.format(fx),
                            textAlign: TextAlign.center,
                            style: axisLabelStyle,
                          ),
                        ),
                      if (hoverFx != null &&
                          hoverDelta != null &&
                          _hoverLocal != null)
                        _HoverTooltip(
                          anchor: _pointOnPlot(
                            hoverFx,
                            hoverDelta,
                            plot,
                            yRange,
                          ),
                          size: size,
                          fxLabel: loc.kimchiFxDeltaPreviewFx(
                            nfFx.format(hoverFx.round()),
                          ),
                          deltaLabel: loc.kimchiFxDeltaPreviewDelta(
                            nfDelta.format(hoverDelta),
                          ),
                          background: cs.surfaceContainerHighest,
                          borderColor: cs.outline.withValues(alpha: 0.45),
                          textColor: cs.onSurface,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HoverTooltip extends StatelessWidget {
  const _HoverTooltip({
    required this.anchor,
    required this.size,
    required this.fxLabel,
    required this.deltaLabel,
    required this.background,
    required this.borderColor,
    required this.textColor,
  });

  final Offset anchor;
  final Size size;
  final String fxLabel;
  final String deltaLabel;
  final Color background;
  final Color borderColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    const w = 168.0;
    const h = 52.0;
    var left = anchor.dx - w / 2;
    var top = anchor.dy - h - 12;
    if (left < 4) left = 4;
    if (left + w > size.width - 4) left = size.width - w - 4;
    if (top < 4) top = anchor.dy + 12;

    return Positioned(
      left: left,
      top: top,
      child: IgnorePointer(
        child: Container(
          width: w,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: background.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                fxLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                deltaLabel,
                style: TextStyle(fontSize: 12, color: textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AffineDeltaChartPainter extends CustomPainter {
  _AffineDeltaChartPainter({
    required this.points,
    required this.yRange,
    required this.plot,
    required this.hoverLocal,
    required this.hoverFx,
    required this.hoverDelta,
    required this.lineColor,
    required this.gridColor,
    required this.crosshairColor,
  });

  final List<({double fx, double delta})> points;
  final ({double min, double max}) yRange;
  final Rect plot;
  final Offset? hoverLocal;
  final double? hoverFx;
  final double? hoverDelta;
  final Color lineColor;
  final Color gridColor;
  final Color crosshairColor;

  Offset _toPixel(double fx, double delta) {
    final xT =
        (fx - KimchiFxDeltaAffinePreviewChart.fxMin) /
        (KimchiFxDeltaAffinePreviewChart.fxMax -
            KimchiFxDeltaAffinePreviewChart.fxMin);
    final ySpan = yRange.max - yRange.min;
    final yT = ySpan == 0 ? 0.5 : (delta - yRange.min) / ySpan;
    return Offset(
      plot.left + plot.width * xT,
      plot.bottom - plot.height * yT,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final border = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRect(plot, border);

    if (yRange.min < 0 && yRange.max > 0) {
      final zeroY = _toPixel(KimchiFxDeltaAffinePreviewChart.fxMin, 0).dy;
      canvas.drawLine(
        Offset(plot.left, zeroY),
        Offset(plot.right, zeroY),
        Paint()
          ..color = gridColor
          ..strokeWidth = 1,
      );
    }

    for (final fx in [1300.0, 1400.0, 1500.0, 1600.0]) {
      final x = _toPixel(fx, yRange.min).dx;
      canvas.drawLine(
        Offset(x, plot.top),
        Offset(x, plot.bottom),
        Paint()
          ..color = gridColor
          ..strokeWidth = 0.5,
      );
    }

    if (points.length >= 2) {
      final path = Path();
      final first = _toPixel(points.first.fx, points.first.delta);
      path.moveTo(first.dx, first.dy);
      for (var i = 1; i < points.length; i++) {
        final pt = _toPixel(points[i].fx, points[i].delta);
        path.lineTo(pt.dx, pt.dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = lineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeJoin = StrokeJoin.round,
      );
    }

    if (hoverLocal != null &&
        hoverFx != null &&
        hoverDelta != null &&
        plot.contains(hoverLocal!)) {
      final marker = _toPixel(hoverFx!, hoverDelta!);
      canvas.drawLine(
        Offset(marker.dx, plot.top),
        Offset(marker.dx, plot.bottom),
        Paint()
          ..color = crosshairColor.withValues(alpha: 0.7)
          ..strokeWidth = 1,
      );
      canvas.drawCircle(marker, 5, Paint()..color = lineColor);
      canvas.drawCircle(
        marker,
        5,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AffineDeltaChartPainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.yRange != yRange ||
      oldDelegate.hoverLocal != hoverLocal ||
      oldDelegate.hoverFx != hoverFx ||
      oldDelegate.lineColor != lineColor;
}
