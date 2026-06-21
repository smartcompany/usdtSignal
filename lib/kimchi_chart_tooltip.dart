import 'package:intl/intl.dart';
import 'package:usdt_signal/kimchi_fx_delta.dart';
import 'package:usdt_signal/l10n/app_localizations.dart';
import 'package:usdt_signal/simulation_model.dart';
import 'package:usdt_signal/utils.dart';

/// 차트 툴팁용 매수/매도 추천 2줄 (시뮬·가격선과 동일한 Δ·임계값).
String? kimchiTradeRecommendLinesForTooltip({
  required AppLocalizations l10n,
  required String localeTag,
  required double exchangeRate,
}) {
  if (exchangeRate <= 0) return null;
  if (SimulationCondition.instance.kimchiFxDeltaCorrectionEnabled &&
      KimchiFxDeltaStore.instance.effectivePayload == null) {
    return null;
  }

  final prices = SimulationModel.getKimchiTradingPrices(
    exchangeRateValue: exchangeRate,
  );
  if (prices.buyPrice <= 0 && prices.sellPrice <= 0) return null;

  final (buyTh, sellTh) = SimulationModel.getKimchiThresholds(
    trendData: null,
    exchangeRates: null,
    targetDate: null,
  );
  final d =
      KimchiFxDeltaStore.instance.deltaForFxWhenEnabled(exchangeRate) ?? 0.0;
  final buyPrem = buyTh - d;
  final sellPrem = sellTh - d;

  final nfPrice = NumberFormat('#,##0.#', localeTag);
  final nfPrem = NumberFormat('+#,##0.00;-#,##0.00', localeTag);

  return '${l10n.chartTooltipBuyRecommend(nfPrice.format(prices.buyPrice), nfPrem.format(buyPrem))}\n'
      '${l10n.chartTooltipSellRecommend(nfPrice.format(prices.sellPrice), nfPrem.format(sellPrem))}';
}
