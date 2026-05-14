import 'dart:math';
import 'kimchi_fx_delta.dart';
import 'utils.dart';
import 'simulation_page.dart';
import 'api_service.dart';

class SimulationModel {
  // 임계값 조정 민감도 계수 (필요시 손쉽게 조정 가능)
  static const double buyTrendCoefficient = 0.6; // 매수: 추세 반응 강도
  static const double buyMa5Coefficient = 0.3; // 매수: MA5 반응 강도
  static const double sellTrendCoefficient = 1.2; // 매도: 추세 반응 강도
  static const double sellMa5Coefficient = 0.5; // 매도: MA5 반응 강도
  // 특정 날짜부터 usdtMap 데이터를 조회하는 함수
  static List<MapEntry<DateTime, dynamic>> getEntriesFromDate(
    Map<DateTime, dynamic> usdtMap,
    DateTime? startDate,
  ) {
    if (startDate == null) {
      // startDate가 null인 경우 전체 데이터를 반환
      return usdtMap.entries.toList();
    }

    // 날짜 오름차순 정렬
    final sortedEntries =
        usdtMap.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

    // 특정 날짜 이후의 데이터 필터링
    return sortedEntries
        .where((entry) => entry.key.compareTo(startDate) >= 0)
        .toList();
  }

  /// 일별 장부 평가금(현금 또는 보유 시 종가 기준 USDT 평가). `buyPrice <= 0`이면 현금만.
  static double _bookEquityKrw(
    DateTime date,
    Map<DateTime, USDTChartData> usdtMap,
    DateTime? buyDate,
    double buyPrice,
    double totalKRW,
  ) {
    if (buyDate == null || buyPrice <= 0) return totalKRW;
    final close = usdtMap[date]?.close ?? 0.0;
    return (totalKRW / buyPrice) * close;
  }

  static double _bookEquityKrwGimchi(
    DateTime date,
    Map<DateTime, USDTChartData> usdtMap,
    double? buyPrice,
    double totalKRW,
  ) {
    if (buyPrice == null || buyPrice <= 0) return totalKRW;
    final close = usdtMap[date]?.close ?? 0.0;
    return (totalKRW / buyPrice) * close;
  }

  /// 피크 대비 최대 낙폭(%). `equity`가 비어 있으면 0.
  static double maxDrawdownPercent(List<double> equitySeries) {
    if (equitySeries.isEmpty) return 0;
    var peak = equitySeries.first;
    var maxDd = 0.0;
    for (final e in equitySeries) {
      if (e > peak) peak = e;
      if (peak <= 0) continue;
      final dd = (peak - e) / peak;
      if (dd > maxDd) maxDd = dd;
    }
    if (maxDd.isNaN || maxDd.isInfinite) return 0;
    return maxDd * 100;
  }

  // simResults 생성 로직을 별도 함수로 분리
  static List<SimulationResult> simulateResults(
    List<ChartData> usdExchangeRates,
    List<StrategyMap> strategyList,
    Map<DateTime, USDTChartData> usdtMap, {
    double initialKRW = 1000000,
    double? buyFee,
    double? sellFee,
    bool? useCompoundInterest,
    List<double>? dailyEquityOut,
  }) {
    final compound =
        useCompoundInterest ?? SimulationCondition.instance.simulationCompoundInterest;
    // 날짜 오름차순 정렬
    strategyList.sort((a, b) {
      final dateA = a['analysis_date'];
      final dateB = b['analysis_date'];
      if (dateA == null || dateB == null) return 0;
      return dateA.compareTo(dateB);
    });

    final Map<DateTime, StrategyMap> strategyMap = {
      for (var strat in strategyList)
        if (strat['analysis_date'] != null)
          DateTime.parse(strat['analysis_date']): strat,
    };

    // 2. usdExchangeRateMap 생성
    final usdExchangeRateMap = {
      for (var rate in usdExchangeRates) rate.time: rate.value,
    };

    List<SimulationResult> simResults = [];
    double totalKRW = initialKRW;
    SimulationResult? unselledResult;

    DateTime? sellDate;
    DateTime? buyDate;
    DateTime? strategyDate = DateTime.parse(
      strategyList.first['analysis_date'],
    );

    final filteredEntries = getEntriesFromDate(usdtMap, strategyDate);

    Map<String, dynamic>? strategy = strategyMap[strategyDate];
    double buyPrice = 0;

    for (final entry in filteredEntries) {
      final date = entry.key;
      final newStrategy = strategyMap[date];
      if (newStrategy != null) {
        strategy = newStrategy;
        strategyDate = date;
      }

      final double? buyStrategyPrice = _toDouble(strategy?['buy_price']);
      final double? sellStrategyPrice = _toDouble(strategy?['sell_price']);
      final lowPrice = usdtMap[date]?.low ?? 0;
      final highPrice = usdtMap[date]?.high ?? 0;

      if (buyStrategyPrice == null || sellStrategyPrice == null) {
        dailyEquityOut?.add(
          _bookEquityKrw(date, usdtMap, buyDate, buyPrice, totalKRW),
        );
        continue;
      }

      if (buyDate == null && sellDate == null) {
        if (lowPrice <= buyStrategyPrice) {
          buyDate = date;
          // 매수 예상가가 고가 보다 낮은 경우는 고가로 매수가 현실적
          buyPrice = min(buyStrategyPrice, highPrice);
          // 수수료 적용: 실제 매수 금액 = 매수 금액 * (1 + 수수료율)
          if (buyFee != null && buyFee > 0) {
            buyPrice = buyPrice * (1 + buyFee / 100);
          }
        }
        if (buyDate == null) {
          dailyEquityOut?.add(
            _bookEquityKrw(date, usdtMap, buyDate, buyPrice, totalKRW),
          );
          continue;
        }
      }

      final high = usdtMap[date]?.high ?? 0;
      final canSell = _isSellCondition(usdtMap, date, buyDate!);

      if (canSell && high >= sellStrategyPrice) {
        sellDate = date;

        // 매도 예상가가 저가 보다 높은 경우는 저가로 매도가 현실적
        final sellPrice = max(sellStrategyPrice, lowPrice);

        totalKRW = _addResultCard(
          sellDate,
          date,
          buyPrice,
          sellPrice,
          totalKRW,
          simResults,
          buyDate,
          usdExchangeRateMap,
          initialKRW: initialKRW,
          useCompoundInterest: compound,
          buyFee: buyFee,
          sellFee: sellFee,
        );

        buyDate = null;
        sellDate = null;
        unselledResult = null;
      } else {
        final usdtPrice = usdtMap[date]?.close;
        final usdtCount = totalKRW / buyPrice;
        final finalKRW = usdtCount * (usdtPrice ?? 0);

        unselledResult = SimulationResult(
          analysisDate: date,
          buyDate: buyDate,
          buyPrice: buyPrice,
          sellDate: null,
          sellPrice: null,
          profit: 0,
          profitRate: 0,
          finalKRW: finalKRW,
          finalUSDT: usdtCount,
          usdExchangeRateAtBuy: usdExchangeRateMap[buyDate],
          usdExchangeRateAtSell: null, // 매도 시점은 아직 없음
        );
      }
      dailyEquityOut?.add(
        _bookEquityKrw(date, usdtMap, buyDate, buyPrice, totalKRW),
      );
    }

    if (unselledResult != null) {
      simResults.add(unselledResult);
    }

    return simResults;
  }

  static double _addResultCard(
    DateTime sellDate,
    DateTime date,
    double buyPrice,
    double? sellPrice,
    double totalKRW,
    List<SimulationResult> simResults,
    DateTime? buyDate,
    Map<DateTime, double> usdExchangeRateMap, {
    required double initialKRW,
    required bool useCompoundInterest,
    double? buyFee,
    double? sellFee,
  }) {
    print('Sell condition met: sellDate=$sellDate anaysisDate=$date');

    double usdtAmount = totalKRW / buyPrice;

    // 매도 시 수수료 적용: 실제 매도 금액 = 매도 금액 * (1 - 수수료율)
    double actualSellPrice = sellPrice ?? 0;
    if (sellFee != null && sellFee > 0) {
      final originalPrice = actualSellPrice;
      actualSellPrice = actualSellPrice * (1 - sellFee / 100);
      print(
        '매도 수수료 적용: 원래 가격=$originalPrice, 수수료율=$sellFee%, 실제 매도 가격=$actualSellPrice',
      );
    } else {
      print('매도 수수료 미적용: sellFee=$sellFee');
    }

    final soldKrw = usdtAmount * actualSellPrice; // 매도 시 최종 원화
    final profit = soldKrw - totalKRW;
    final profitRate = profit / totalKRW * 100;
    totalKRW = useCompoundInterest ? soldKrw : initialKRW; // 복리 vs 매수마다 초기 자본만
    print(
      'Transaction complete: finalKRW=$soldKrw, profit=$profit, profitRate=$profitRate, sellPrice(원래)=${sellPrice ?? 0}, actualSellPrice(수수료적용)=$actualSellPrice',
    );

    simResults.add(
      SimulationResult(
        analysisDate: date,
        buyDate: buyDate!,
        buyPrice: buyPrice,
        sellDate: sellDate,
        sellPrice: sellPrice,
        profit: profit,
        profitRate: profitRate,
        finalKRW: soldKrw,
        finalUSDT: null,
        usdExchangeRateAtBuy: usdExchangeRateMap[buyDate],
        usdExchangeRateAtSell: usdExchangeRateMap[sellDate],
      ),
    );
    return totalKRW;
  }

  // 김치 프리미엄 추세, 환율 추세, USDT 추세를 고려해 김치 프리미엄 매매 전략을 생성하는 함수

  static (double, double) getKimchiThresholds({
    required Map<String, double>? trendData,
    List<ChartData>? exchangeRates,
    DateTime? targetDate,
  }) {
    final buyThreshold = SimulationCondition.instance.kimchiBuyThreshold;
    final sellThreshold = SimulationCondition.instance.kimchiSellThreshold;
    return (buyThreshold, sellThreshold);
  }

  // 김치 시뮬레이션 결과 계산
  static List<SimulationResult> gimchiSimulateResults(
    List<ChartData> usdExchangeRates,
    List<StrategyMap> strategyList,
    Map<DateTime, USDTChartData> usdtMap,
    Map<DateTime, Map<String, double>>? premiumTrends, {
    double initialKRW = 1000000,
    double? buyFee,
    double? sellFee,
    bool? useCompoundInterest,
    List<double>? dailyEquityOut,
  }) {
    final compound =
        useCompoundInterest ?? SimulationCondition.instance.simulationCompoundInterest;
    List<SimulationResult> simResults = [];
    double totalKRW = initialKRW;
    SimulationResult? unselledResult;

    DateTime? sellDate;
    DateTime? buyDate;
    double? buyPrice;
    double? sellPrice;

    // 날짜 오름차순 정렬
    final sortedDates = usdtMap.keys.toList()..sort();

    // 날짜 오름차순 정렬
    strategyList.sort((a, b) {
      final dateA = a['analysis_date'];
      final dateB = b['analysis_date'];
      if (dateA == null || dateB == null) return 0;
      return dateA.compareTo(dateB);
    });

    final kimchiStartDate = SimulationCondition.instance.kimchiStartDate;
    final kimchiEndDate = SimulationCondition.instance.kimchiEndDate;
    if (kimchiStartDate != null) {
      sortedDates.removeWhere(
        (date) =>
            date.isBefore(kimchiStartDate) &&
            !date.isSameDate(kimchiStartDate),
      );
    }
    if (kimchiEndDate != null) {
      sortedDates.removeWhere(
        (date) =>
            date.isAfter(kimchiEndDate) && !date.isSameDate(kimchiEndDate),
      );
    }

    final usdExchangeRatesMap = {
      for (var rate in usdExchangeRates) rate.time: rate.value,
    };

    final fxBuyMax = SimulationCondition.instance.kimchiFxBuyMax;
    final fxSellMin = SimulationCondition.instance.kimchiFxSellMin;

    // premiumTrends는 매개변수로 받은 서버 데이터 사용

    for (final date in sortedDates) {
      final usdtDay = usdtMap[date];
      final usdExchangeRate = usdExchangeRatesMap[date] ?? 0.0;
      final usdtLow = usdtDay?.low ?? 0.0;
      final usdtHigh = usdtDay?.high ?? 0.0;

      double buyTargetPrice = 0.0;
      double sellTargetPrice = 0.0;

      final (buyThreshold, sellThreshold) = getKimchiThresholds(
        trendData: premiumTrends?[date],
        exchangeRates: usdExchangeRates,
        targetDate: date,
      );

      final d =
          KimchiFxDeltaStore.instance.deltaForFxWhenEnabled(usdExchangeRate);
      buyTargetPrice =
          usdExchangeRate * (1 + (buyThreshold - d) / 100);
      sellTargetPrice =
          usdExchangeRate * (1 + (sellThreshold - d) / 100);

      // 매수 조건: 프리미엄 buyThreshold% 미만, 아직 매수 안한 상태
      if (buyPrice == null) {
        // 매도 대기 상태가 아니어야 매수
        if (sellPrice == null) {
          final fxBlocksBuy =
              fxBuyMax > 0 &&
              usdExchangeRate > 0 &&
              usdExchangeRate >= fxBuyMax;
          if (!fxBlocksBuy && buyTargetPrice >= usdtLow) {
            // 100원에 매수 하려고 했는데 고가가 90원이라면 그냥 90원에 매수 하겠지
            buyPrice = min(buyTargetPrice, usdtHigh);
            // 수수료 적용: 실제 매수 금액 = 매수 금액 * (1 + 수수료율)
            if (buyFee != null && buyFee > 0) {
              buyPrice = buyPrice * (1 + buyFee / 100);
            }
            buyDate = date;

            print(
              'Buy condition met: buyDate=$buyDate, buyPrice=$buyPrice, buyTargetPrice=$buyTargetPrice, usdtLow=$usdtLow',
            );
          }
        }
      }

      if (buyPrice == null) {
        dailyEquityOut?.add(
          _bookEquityKrwGimchi(date, usdtMap, buyPrice, totalKRW),
        );
        continue;
      }

      bool canSell = _isSellCondition(usdtMap, date, buyDate);

      final fxBlocksSell =
          fxSellMin > 0 &&
          usdExchangeRate > 0 &&
          usdExchangeRate <= fxSellMin;

      // 매도 조건: 프리미엄 sellThreshold% 초과, 이미 매수한 상태
      if (canSell && !fxBlocksSell && sellTargetPrice <= usdtHigh) {
        sellDate = date;
        // 매도 가격이 100원인데 저가가 110원 이면 그냥 110원에 매도 그래서 둘중 높은값
        sellPrice = max(sellTargetPrice, usdtLow);
        // 매도 시 수수료 적용: 실제 매도 금액 = 매도 금액 * (1 - 수수료율)
        double actualSellPrice = sellPrice;
        if (sellFee != null && sellFee > 0) {
          final originalPrice = actualSellPrice;
          actualSellPrice = actualSellPrice * (1 - sellFee / 100);
          print(
            '매도 수수료 적용: 원래 가격=$originalPrice, 수수료율=$sellFee%, 실제 매도 가격=$actualSellPrice',
          );
        } else {
          print('매도 수수료 미적용: sellFee=$sellFee');
        }
        print(
          'Sell condition met: sellDate=$sellDate, buyDate=$buyDate, buyPrice=$buyPrice, sellPrice(원래)=$sellPrice, actualSellPrice(수수료적용)=$actualSellPrice',
        );

        // 수익 계산
        final usdtAmount = totalKRW / buyPrice;
        final finalKRW = usdtAmount * actualSellPrice;
        final profit = finalKRW - totalKRW;
        final profitRate = profit / totalKRW * 100;

        simResults.add(
          SimulationResult(
            analysisDate: date,
            buyDate: buyDate,
            buyPrice: buyPrice,
            sellDate: sellDate,
            sellPrice: sellPrice,
            profit: profit,
            profitRate: profitRate,
            finalKRW: finalKRW,
            finalUSDT: null,
            usdExchangeRateAtBuy: usdExchangeRatesMap[buyDate],
            usdExchangeRateAtSell: usdExchangeRatesMap[sellDate],
          ),
        );

        // 다음 거래: 복리면 매도 후 금액, 아니면 초기 자본만 매수에 사용
        totalKRW = compound ? finalKRW : initialKRW;
        dailyEquityOut?.add(totalKRW);
        buyDate = null;
        buyPrice = null;
        sellPrice = null;
        unselledResult = null;
      } else {
        final usdtPrice = usdtMap[date]?.close;
        final usdtCount = totalKRW / buyPrice;
        final finalKRW = usdtCount * (usdtPrice ?? 0);

        unselledResult = SimulationResult(
          analysisDate: date,
          buyDate: buyDate,
          buyPrice: buyPrice,
          sellDate: null,
          sellPrice: null,
          profit: 0,
          profitRate: 0,
          finalKRW: finalKRW,
          finalUSDT: usdtCount,
          usdExchangeRateAtBuy: usdExchangeRatesMap[buyDate],
          usdExchangeRateAtSell: null,
        );
        dailyEquityOut?.add(
          _bookEquityKrwGimchi(date, usdtMap, buyPrice, totalKRW),
        );
      }
    }

    if (unselledResult != null) {
      simResults.add(unselledResult);
    }

    return simResults;
  }

  static bool _isSellCondition(
    Map<dynamic, dynamic> usdtMap,
    DateTime date,
    DateTime? buyDate,
  ) {
    final open = usdtMap[date]?.open ?? 0;
    final close = usdtMap[date]?.close ?? 0;
    final canSell = (buyDate == date) ? (open < close) : true;

    return canSell;
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  /// 비복리: 완료된 매도마다 `profit` 합산 + 미매도 구간은 평가금(`finalKRW - initialKRW`).
  static double nonCompoundTotalProfitKrw(
    List<SimulationResult> results,
    double initialKRW,
  ) {
    var sum = 0.0;
    for (final r in results) {
      if (r.sellDate != null) {
        sum += r.profit;
      } else {
        sum += r.finalKRW - initialKRW;
      }
    }
    return sum;
  }

  /// 총 수익률(%). 복리는 마지막 누적 대비, 비복리는 라운드별 손익 합 / 초기자본.
  static double totalReturnPercent(
    List<SimulationResult> results,
    double initialKRW, {
    bool? useCompoundInterest,
  }) {
    if (results.isEmpty || initialKRW <= 0) return 0;
    final compound =
        useCompoundInterest ??
        SimulationCondition.instance.simulationCompoundInterest;
    if (compound) {
      return (results.last.finalKRW / initialKRW - 1) * 100;
    }
    return (nonCompoundTotalProfitKrw(results, initialKRW) / initialKRW) * 100;
  }

  /// 누적(또는 평가) 최종 원화. 비복리는 초기자본 + 실현·평가 손익 합.
  static double totalEndingWealthKrw(
    List<SimulationResult> results,
    double initialKRW, {
    bool? useCompoundInterest,
  }) {
    if (results.isEmpty) return initialKRW;
    final compound =
        useCompoundInterest ??
        SimulationCondition.instance.simulationCompoundInterest;
    if (compound) {
      return results.last.finalKRW;
    }
    return initialKRW + nonCompoundTotalProfitKrw(results, initialKRW);
  }

  // 시뮬레이션 결과를 기반으로 수익률 데이터를 계산하는 내부 함수
  static SimulationYieldData _calculateYieldData(
    List<SimulationResult> results, {
    required double initialKRW,
    bool? useCompoundInterest,
  }) {
    if (results.isEmpty) {
      return SimulationYieldData(
        totalReturn: 0.0,
        tradingDays: 0,
        annualYield: 0.0,
      );
    }

    final firstDate = results.first.buyDate;
    final lastDate = results.last.analysisDate;

    if (firstDate == null) {
      return SimulationYieldData(
        totalReturn: 0.0,
        tradingDays: 0,
        annualYield: 0.0,
      );
    }

    final days = lastDate.difference(firstDate).inDays;
    final totalReturn = totalReturnPercent(
      results,
      initialKRW,
      useCompoundInterest: useCompoundInterest,
    );
    final annualYield = calculateAnnualYield(
      results,
      initialKRW: initialKRW,
      useCompoundInterest: useCompoundInterest,
    );

    return SimulationYieldData(
      totalReturn: totalReturn,
      tradingDays: days,
      annualYield: annualYield,
    );
  }

  // results를 입력으로 받아 annualYield를 리턴하는 static 함수
  static double calculateAnnualYield(
    List<SimulationResult> results, {
    required double initialKRW,
    bool? useCompoundInterest,
  }) {
    if (results.isEmpty) return 0.0;

    final firstDate = results.first.buyDate;
    final lastDate = results.last.analysisDate;
    if (firstDate == null) return 0.0;

    final days = lastDate.difference(firstDate).inDays;
    if (days < 1) return 0.0;

    final years = days / 365.0;
    final compound =
        useCompoundInterest ??
        SimulationCondition.instance.simulationCompoundInterest;
    final double wealthRatio = compound
        ? results.last.finalKRW / initialKRW
        : (initialKRW + nonCompoundTotalProfitKrw(results, initialKRW)) /
            initialKRW;
    final annualYield =
        (years > 0) ? (pow(wealthRatio, 1 / years) - 1) * 100 : 0.0;

    return (annualYield.isNaN || annualYield.isInfinite ? 0.0 : annualYield)
        .toDouble();
  }

  static SimulationYieldData getYieldForAISimulation(
    List<ChartData> usdExchangeRates,
    List<StrategyMap> strategyList,
    Map<DateTime, USDTChartData> usdtMap, {
    double initialKRW = 1000000,
    double? buyFee,
    double? sellFee,
    bool? useCompoundInterest,
  }) {
    final results = SimulationModel.simulateResults(
      usdExchangeRates,
      strategyList,
      usdtMap,
      initialKRW: initialKRW,
      buyFee: buyFee,
      sellFee: sellFee,
      useCompoundInterest: useCompoundInterest,
    );
    return _calculateYieldData(
      results,
      initialKRW: initialKRW,
      useCompoundInterest: useCompoundInterest,
    );
  }

  // 김치 시뮬레이션 수익률 계산
  static SimulationYieldData? getYieldForGimchiSimulation(
    List<ChartData> usdExchangeRates,
    List<StrategyMap> strategyList,
    Map<DateTime, USDTChartData> usdtMap,
    Map<DateTime, Map<String, double>>? premiumTrends, {
    double initialKRW = 1000000,
    double? buyFee,
    double? sellFee,
    bool? useCompoundInterest,
  }) {
    final simResults = gimchiSimulateResults(
      usdExchangeRates,
      strategyList,
      usdtMap,
      premiumTrends,
      initialKRW: initialKRW,
      buyFee: buyFee,
      sellFee: sellFee,
      useCompoundInterest: useCompoundInterest,
    );

    return _calculateYieldData(
      simResults,
      initialKRW: initialKRW,
      useCompoundInterest: useCompoundInterest,
    );
  }

  // 다음 매수/매도 시점 가져오기 (현재 가격 기준으로 하나만 반환)
  static ({double price, bool isBuy, double kimchiPremium})?
  getNextTradingPoint({
    required SimulationType simulationType,
    StrategyMap? latestStrategy,
    List<ChartData>? exchangeRates,
    List<USDTChartData>? usdtChartData,
    Map<DateTime, Map<String, double>>? premiumTrends,
    double? currentPrice,
  }) {
    if (currentPrice == null || currentPrice == 0) {
      return null;
    }

    // 현재 환율 (김프 계산용)
    final currentExchangeRate =
        (exchangeRates != null && exchangeRates.isNotEmpty)
            ? exchangeRates.last.value
            : 0.0;

    switch (simulationType) {
      case SimulationType.ai:
        if (latestStrategy == null) {
          return null;
        }
        final buyPrice = (latestStrategy['buy_price'] as num?)?.toDouble() ?? 0;
        final sellPrice =
            (latestStrategy['sell_price'] as num?)?.toDouble() ?? 0;

        if (buyPrice == 0 || sellPrice == 0) {
          return null;
        }

        if (currentPrice > buyPrice) {
          final kp =
              currentExchangeRate != 0
                  ? ((buyPrice - currentExchangeRate) /
                      currentExchangeRate *
                      100)
                  : 0.0;
          return (price: buyPrice, isBuy: true, kimchiPremium: kp);
        } else {
          final kp =
              currentExchangeRate != 0
                  ? ((sellPrice - currentExchangeRate) /
                      currentExchangeRate *
                      100)
                  : 0.0;
          return (price: sellPrice, isBuy: false, kimchiPremium: kp);
        }

      case SimulationType.kimchi:
        if (exchangeRates == null || exchangeRates.isEmpty) {
          return null;
        }
        if (usdtChartData == null || usdtChartData.isEmpty) {
          return null;
        }

        final exchangeRateValue = exchangeRates.last.value;
        if (exchangeRateValue == 0) {
          return null;
        }

        final fxBuyMax = SimulationCondition.instance.kimchiFxBuyMax;
        final fxSellMin = SimulationCondition.instance.kimchiFxSellMin;
        final fxBlocksBuyKimchi =
            fxBuyMax > 0 &&
            exchangeRateValue > 0 &&
            exchangeRateValue >= fxBuyMax;
        final fxBlocksSellKimchi =
            fxSellMin > 0 &&
            exchangeRateValue > 0 &&
            exchangeRateValue <= fxSellMin;

        // 오늘 날짜 (targetDate로 사용)
        final todayUsdtTime = usdtChartData.last.time;

        // 김치 프리미엄 임계값 가져오기 (추세 기반 전략 제거)
        final (buyThreshold, sellThreshold) = getKimchiThresholds(
          trendData: null,
          exchangeRates: exchangeRates,
          targetDate: todayUsdtTime,
        );

        final dAdj =
            KimchiFxDeltaStore.instance.deltaForFxWhenEnabled(exchangeRateValue);

        // 김치 프리미엄 매수/매도 가격 계산 (환율 구간 보정 적용 시 임계 = 설정값 − delta)
        final buyPriceKimchi =
            exchangeRateValue * (1 + (buyThreshold - dAdj) / 100);
        final sellPriceKimchi =
            exchangeRateValue * (1 + (sellThreshold - dAdj) / 100);

        if (buyPriceKimchi == 0 || sellPriceKimchi == 0) {
          return null;
        }

        if (currentPrice > buyPriceKimchi) {
          if (fxBlocksBuyKimchi) {
            return null;
          }
          return (
            price: buyPriceKimchi,
            isBuy: true,
            kimchiPremium: buyThreshold - dAdj,
          );
        }
        if (fxBlocksSellKimchi) {
          return null;
        }
        return (
          price: sellPriceKimchi,
          isBuy: false,
          kimchiPremium: sellThreshold - dAdj,
        );
    }
  }

  // 김치 프리미엄 매수/매도 가격 계산 (main.dart의 _buildTodayComment와 동일한 로직)
  static ({double buyPrice, double sellPrice}) getKimchiTradingPrices({
    required double exchangeRateValue,
    Map<DateTime, Map<String, double>>? premiumTrends,
    DateTime? targetDate,
    List<ChartData>? exchangeRates,
  }) {
    // 추세 기반 전략 제거 - 항상 기본 임계값 사용
    final (buyThreshold, sellThreshold) = getKimchiThresholds(
      trendData: null,
      exchangeRates: exchangeRates,
      targetDate: targetDate,
    );

    final d = KimchiFxDeltaStore.instance.deltaForFxWhenEnabled(exchangeRateValue);
    final buyPrice =
        exchangeRateValue * (1 + (buyThreshold - d) / 100);
    final sellPrice =
        exchangeRateValue * (1 + (sellThreshold - d) / 100);

    return (buyPrice: buyPrice, sellPrice: sellPrice);
  }

  static double _getKimchiBuyPrice({
    List<ChartData>? exchangeRates,
    List<USDTChartData>? usdtChartData,
    Map<DateTime, Map<String, double>>? premiumTrends,
    DateTime? targetDate,
  }) {
    if (exchangeRates == null || exchangeRates.isEmpty) return 0;
    final exchangeRateValue = exchangeRates.last.value;
    if (exchangeRateValue == 0) return 0;

    // 추세 기반 전략 제거 - 항상 기본 임계값 사용
    final (buyThreshold, _) = getKimchiThresholds(
      trendData: null,
      exchangeRates: exchangeRates,
      targetDate: targetDate,
    );
    final d = KimchiFxDeltaStore.instance.deltaForFxWhenEnabled(exchangeRateValue);
    return exchangeRateValue * (1 + (buyThreshold - d) / 100);
  }

  static double _getKimchiSellPrice({
    List<ChartData>? exchangeRates,
    List<USDTChartData>? usdtChartData,
    Map<DateTime, Map<String, double>>? premiumTrends,
    DateTime? targetDate,
  }) {
    if (exchangeRates == null || exchangeRates.isEmpty) return 0;
    final exchangeRateValue = exchangeRates.last.value;
    if (exchangeRateValue == 0) return 0;

    // 추세 기반 전략 제거 - 항상 기본 임계값 사용
    final (_, sellThreshold) = getKimchiThresholds(
      trendData: null,
      exchangeRates: exchangeRates,
      targetDate: targetDate,
    );
    final d = KimchiFxDeltaStore.instance.deltaForFxWhenEnabled(exchangeRateValue);
    return exchangeRateValue * (1 + (sellThreshold - d) / 100);
  }
}
