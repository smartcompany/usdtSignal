import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:usdt_signal/api_service.dart';
import 'package:usdt_signal/kimchi_fx_delta.dart';
import 'package:usdt_signal/l10n/app_localizations.dart';
import 'package:usdt_signal/utils.dart';

/// 시뮬·전략 다이얼로그에서 USD/KRW를 찾습니다. 시간봉이면 같은 시각(시)까지 맞춥니다.
double? lookupUsdKrwForKimchiDialog({
  required List<ChartData> rates,
  required DateTime date,
  required bool hourlyGranularity,
}) {
  if (hourlyGranularity) {
    for (final c in rates) {
      if (c.time.year == date.year &&
          c.time.month == date.month &&
          c.time.day == date.day &&
          c.time.hour == date.hour) {
        return c.value;
      }
    }
    return null;
  }
  for (final c in rates) {
    if (date.isSameDate(c.time)) return c.value;
  }
  return null;
}

String _fmtSignedDelta(double d) {
  final abs = d.abs().toStringAsFixed(2);
  if (d > 0) return '+$abs';
  if (d < 0) return '\u2212$abs';
  return '0';
}

/// 김프 전략 설명: 보정 설정이 꺼져 있으면 기존 요약 한 줄만 표시합니다.
Widget buildKimchiStrategyExplanationContent({
  required BuildContext context,
  required AppLocalizations l10n,
  required double buyBase,
  required double sellBase,
  double? fx,
}) {
  final cs = Theme.of(context).colorScheme;
  final bodyStyle = TextStyle(
    fontSize: 15,
    height: 1.45,
    color: cs.onSurface,
  );
  final smallStyle = TextStyle(
    fontSize: 12.5,
    height: 1.42,
    color: cs.onSurfaceVariant,
  );

  final summary = Text(
    l10n.kimchiStrategyComment(
      double.parse(buyBase.toStringAsFixed(1)),
      double.parse(sellBase.toStringAsFixed(1)),
    ),
    style: bodyStyle,
  );

  if (!SimulationCondition.instance.kimchiFxDeltaCorrectionEnabled) {
    return summary;
  }

  final children = <Widget>[
    Text(
      l10n.kimchiStrategyDetailSettingsLine(
        buyBase.toStringAsFixed(1),
        sellBase.toStringAsFixed(1),
      ),
      style: bodyStyle.copyWith(fontWeight: FontWeight.w600),
    ),
    const SizedBox(height: 8),
  ];

  if (fx != null && fx > 0) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final nf = NumberFormat('#,##0.##', locale);
    final d = KimchiFxDeltaStore.instance.deltaForFx(fx);
    final buyA = buyBase - d;
    final sellA = sellBase - d;
    children.addAll([
      Text(
        l10n.kimchiStrategyDetailFxLine(nf.format(fx)),
        style: bodyStyle,
      ),
      const SizedBox(height: 6),
      Text(
        l10n.kimchiStrategyDetailDeltaLine(_fmtSignedDelta(d)),
        style: bodyStyle,
      ),
      const SizedBox(height: 6),
      Text(
        l10n.kimchiStrategyDetailAppliedLine(
          buyA.toStringAsFixed(2),
          sellA.toStringAsFixed(2),
        ),
        style: bodyStyle.copyWith(
          color: cs.primary.withValues(alpha: 0.92),
        ),
      ),
      const SizedBox(height: 10),
      Text(l10n.kimchiStrategyDetailFootnote, style: smallStyle),
      const SizedBox(height: 12),
    ]);
  } else {
    children.addAll([
      Text(l10n.kimchiStrategyDetailDeltaUnavailable, style: smallStyle),
      const SizedBox(height: 12),
    ]);
  }

  children.add(summary);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: children,
  );
}
