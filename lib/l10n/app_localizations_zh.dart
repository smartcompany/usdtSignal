// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get usdt => 'USDT';

  @override
  String get exchangeRate => '汇率';

  @override
  String get gimchiPremiem => '韩元溢价';

  @override
  String get xrpFundingRateTitle => 'XRP 资金费率(Y)';

  @override
  String fundingRateInterval(Object hours) {
    return '(${hours}h)';
  }

  @override
  String get fundingRateSourceBinance => 'Binance';

  @override
  String get fundingRateSourceBybit => 'Bybit';

  @override
  String get fundingRateLoading => '正在加载资金费率...';

  @override
  String get fundingRateFailed => '无法加载资金费率';

  @override
  String get cancel => '取消';

  @override
  String get changeStrategy => '更改泡菜溢价策略';

  @override
  String get close => '关闭';

  @override
  String get failedToSaveAlarm => '无法保存通知设置。';

  @override
  String get failedToload => '数据加载失败。\n是否要重试？';

  @override
  String get loadingFail => '加载失败';

  @override
  String get moveToSetting => '前往设置';

  @override
  String get needPermission => '需要通知权限';

  @override
  String get permissionRequiredMessage => '要接收通知，需要在设备设置中允许通知权限。\n是否要前往设置？';

  @override
  String get no => '否';

  @override
  String get yes => '是';

  @override
  String get useTrendBasedStrategy => '使用基于趋势的策略';

  @override
  String get error => '错误';

  @override
  String get dash => '-';

  @override
  String get kimchiStrategy => '韩元溢价策略';

  @override
  String get viewAllStrategyHistory => '查看所有策略历史';

  @override
  String get kimchiStrategyHistory => '韩元溢价交易策略历史';

  @override
  String get aiStrategyHistory => 'AI交易策略历史';

  @override
  String get strategy => '策略';

  @override
  String get noStrategyData => '没有策略数据';

  @override
  String get seeAdsAndStrategy => '观看广告后查看策略';

  @override
  String get todayStrategyAfterAds => '观看广告并查看策略';

  @override
  String get todayStrategyDirect => '立即查看策略';

  @override
  String get aiReturn => 'AI交易收益率';

  @override
  String get gimchiReturn => '泡菜溢价交易收益率';

  @override
  String get throwTestException => '抛出测试异常';

  @override
  String get throw_test_exception => '抛出测试异常';

  @override
  String get usdtSignal => 'USDT 信号';

  @override
  String get usdt_signal => 'USDT 信号';

  @override
  String get buyWin => '当前是买入有利的区间';

  @override
  String get sellWin => '当前是卖出有利的区间';

  @override
  String get justSee => '当前是观望区间';

  @override
  String get aiStrategy => 'AI 策略';

  @override
  String get gimchiStrategy => '韩元溢价策略';

  @override
  String get buy => '买入';

  @override
  String get sell => '卖出';

  @override
  String get gain => '收益率';

  @override
  String get runSimulation => '运行模拟';

  @override
  String get seeStrategy => '查看策略';

  @override
  String get aiTradingSimulation => 'AI交易模拟（以100万韩元为基准）';

  @override
  String get gimchTradingSimulation => '泡菜溢价交易模拟（以100万韩元为基准）';

  @override
  String get finalKRW => '最终韩元';

  @override
  String get tradingPerioid => '交易期间';

  @override
  String get stackedFinalKRW => '累计最终韩元';

  @override
  String get simulationMdd => 'MDD';

  @override
  String get simulationMddHelpTooltip => 'MDD 说明';

  @override
  String get simulationMddHelpBody =>
      '最大回撤（MDD）指在模拟区间内，按日记录的账面权益相对历史峰值的最大跌幅比例。\n\n持有现金时用当日韩元余额；持有 USDT 时按当日收盘价折算估值。已按模拟设置计入手续费，但不包含滑点、税费等，因此可能与真实账户的最大回撤不同。';

  @override
  String get currencyWonSuffix => ' 韩元';

  @override
  String get totalGain => '总收益率';

  @override
  String get annualAvgReturn => '年化平均收益';

  @override
  String get extimatedYearGain => '预估年收益率';

  @override
  String get annualYieldDescription =>
      '预估年收益率是将当前交易记录的收益率按复利基准换算为一年期的值。\n\n例如，如果在6个月内获得5%的收益率，换算为一年基准则约为10.25%的年收益率。';

  @override
  String get chartTrendAnalysis => '图表趋势分析';

  @override
  String get aiSell => 'AI 卖出';

  @override
  String get kimchiPremiumSell => '泡菜溢价卖出';

  @override
  String get aiBuy => 'AI 买入';

  @override
  String get kimchiPremiumBuy => '泡菜溢价买入';

  @override
  String changeFromPreviousDay(Object change) {
    return '较前一日变化：$change%';
  }

  @override
  String get kimchiPremiumPercent => '泡菜溢价 (%)';

  @override
  String get resetChart => '重置图表';

  @override
  String get backToPreviousChart => '上一张图表';

  @override
  String get kimchiPremium => '泡菜溢价';

  @override
  String get aiBuySell => 'AI 买入/卖出';

  @override
  String get kimchiPremiumBuySell => '泡菜溢价买入/卖出';

  @override
  String get kimchiPremiumBackground => '泡菜溢价背景';

  @override
  String get kimchiPremiumBackgroundDescriptionTooltip => '泡菜溢价背景说明';

  @override
  String get whatIsKimchiPremiumBackground => '什么是泡菜溢价背景？';

  @override
  String get kimchiPremiumBackgroundDescription =>
      '图表背景颜色根据泡菜溢价数值而变化。溢价越高背景越红，越低则偏蓝。此功能可帮助你根据泡菜溢价的高低来直观判断买卖时机，一目了然地把握其波动性。';

  @override
  String get confirm => '确认';

  @override
  String get chatRoom => '聊天室';

  @override
  String get gimchBaseTrade => '韩元溢价基准交易';

  @override
  String get aiBaseTrade => 'AI 基准交易';

  @override
  String get seeWithChart => '使用图表查看';

  @override
  String get buyBase => '买入基准（%）';

  @override
  String get sellBase => '卖出基准（%）';

  @override
  String get sameAsAI => '与AI使用相同的时间设置';

  @override
  String get kimchiStartDate => '开始日期';

  @override
  String get kimchiEndDate => '结束日期';

  @override
  String get kimchiResetDateRange => '全部期间';

  @override
  String get failedToSaveSettings => '保存设置失败。';

  @override
  String get buyPrice => '买入价格';

  @override
  String get sellPrice => '卖出价格';

  @override
  String get expectedGain => '预期收益率';

  @override
  String get summary => '摘要';

  @override
  String kimchiStrategyComment(double buyThreshold, double sellThreshold) {
    return '当泡菜溢价低于 $buyThreshold% 时买入，高于 $sellThreshold% 时卖出。';
  }

  @override
  String get strategySummaryEmpty => '暂无策略摘要。';

  @override
  String kimchiStrategyDetailSettingsLine(String buyPct, String sellPct) {
    return '设定 · 买入阈值 $buyPct% · 卖出阈值 $sellPct%（按调整后溢价）';
  }

  @override
  String kimchiStrategyDetailFxLine(String fx) {
    return '该时点汇率 · $fx 韩元';
  }

  @override
  String kimchiStrategyDetailDeltaLine(String deltaSigned) {
    return '区间修正(Δ) · $deltaSigned 个百分点';
  }

  @override
  String kimchiStrategyDetailAppliedLine(String buyApp, String sellApp) {
    return '价格线采用(设定 − Δ) · 买 $buyApp% · 卖 $sellApp%';
  }

  @override
  String get kimchiStrategyDetailDeltaUnavailable =>
      '（未查到该时点汇率，暂不显示区间 Δ 与价格线比例。）';

  @override
  String get kimchiStrategyDetailFootnote =>
      '与模拟一致：目标韩元价 = 汇率×(1+上式/100)。阈值按「调整后溢价」比较。';

  @override
  String get sellIfCurrentPrice => '当前价格卖出';

  @override
  String get onboardingTitle1 => 'USDT的隐藏价差';

  @override
  String get onboardingBody1 =>
      '虽然海外1 USDT = 1 USD，但韩国交易所因汇率和“泡菜溢价”而价格不同。了解这个差异可以帮助您盈利。';

  @override
  String get onboardingImageDesc1 => '韩国USDT价格 = 汇率 + 泡菜溢价';

  @override
  String get onboardingTitle2 => '利用泡菜溢价盈利';

  @override
  String get onboardingBody2 =>
      '当USDT在韩国比海外交易价格更高（泡菜溢价）时，卖出可以获利。我们的应用实时分析泡菜溢价和汇率，为您找到最佳买卖时机。';

  @override
  String get onboardingImageDesc2 => '低价买入 → 溢价高时卖出 → 实现盈利';

  @override
  String get onboardingTitle3 => '两种策略：AI和泡菜溢价';

  @override
  String get onboardingBody3 => '选择AI分析的交易策略或泡菜溢价策略接收通知。实时查看图表，比较各策略的历史收益。';

  @override
  String get onboardingImageDesc3 => 'AI策略提醒 + 泡菜溢价策略提醒';

  @override
  String get onboardingTitle4 => '用过去数据验证的收益';

  @override
  String get onboardingBody4 => '如果从100万韩元开始会怎样？使用实际过去数据模拟各策略的收益，比较哪种方法更有效。';

  @override
  String get onboardingImageDesc4 => 'AI收益率 vs 泡菜溢价收益率对比';

  @override
  String get previous => '上一步';

  @override
  String get start => '开始使用';

  @override
  String get next => '下一步';

  @override
  String get selectReceiveAlert => '选择要接收的通知';

  @override
  String get selectReceiveAlertSubtitle => '选择要接收的通知类型';

  @override
  String get aIalert => 'AI 通知';

  @override
  String get aIalertDescription => '接收AI分析的交易策略通知';

  @override
  String get gimpAlert => '泡菜溢价通知';

  @override
  String get gimpAlertDescription => '接收基于泡菜溢价的交易策略通知';

  @override
  String get turnOffAlert => '关闭通知';

  @override
  String get unFilled => '未成交';

  @override
  String get coinInfoSite => '币种信息网站';

  @override
  String get adClickInstruction => '点击 X 后查看买卖信号';

  @override
  String get removeAdsCta => '无广告查看交易策略';

  @override
  String get removeAdsTitle => '无广告查看';

  @override
  String get removeAdsSubtitle => '更专注地查看交易策略。';

  @override
  String get removeAdsDescription => '支付后，无需观看广告即可立即查看交易策略。';

  @override
  String get purchaseButton => '购买';

  @override
  String get restoreButton => '恢复购买';

  @override
  String get restoreSuccess => '成功';

  @override
  String get restoreNoPurchases => '没有可恢复的购买记录';

  @override
  String get adLoadingMessage => '正在加载广告，请稍后再试。';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get termsOfService => '条款';

  @override
  String get nextBuyPoint => '下一个买入点';

  @override
  String get nextSellPoint => '下一个卖出点';

  @override
  String get priceLabel => '价格';

  @override
  String get basePremium => '基准溢价';

  @override
  String get kimchiPremiumShort => '溢价';

  @override
  String get tradeTimeline => '交易时间线';

  @override
  String get performanceMetrics => '绩效指标';

  @override
  String initialCapital(String amount) {
    return '初始资金: $amount';
  }

  @override
  String get editInitialCapitalTitle => '模拟初始资金';

  @override
  String get editInitialCapitalHint => '请输入 1 万至 10 亿韩元之间的金额。';

  @override
  String get initialCapitalInvalid => '请输入有效数字。';

  @override
  String get finalValue => '최종 가치';

  @override
  String get aiSimulatedTradeTitle => 'AI 모의 투자';

  @override
  String get kimchiSimulatedTradeTitle => '김프 모의 투자';

  @override
  String get shareSimulationButton => '分享';

  @override
  String get simulationCompoundInterestTitle => '复利计算';

  @override
  String get simulationCompoundInterestHelpTooltip => '复利说明';

  @override
  String get simulationCompoundInterestHelpBody =>
      '开启：卖出后用累计资金再买入。关闭：每次买入仅使用初始资金。';

  @override
  String get profitRate => '收益率';

  @override
  String get evaluationAmount => '评估金额';

  @override
  String get fee => '手续费';

  @override
  String upbitFeeApplied(double buyFee, double sellFee) {
    return '已应用Upbit手续费 (买入 $buyFee%, 卖出 $sellFee%)';
  }

  @override
  String feeWithAmount(String amount) {
    return '手续费: ₩$amount';
  }

  @override
  String get chartGranularityDaily => '按日';

  @override
  String get chartGranularityHourly => '按小时';

  @override
  String get hourlyChartLoadFailed => '小时线图表数据加载失败。';

  @override
  String get hourlyGranularityIntroTitle => '关于「按小时」';

  @override
  String hourlyGranularityIntroBody(int maxDays) {
    return '按小时模式会按小时对齐 Upbit USDT 与美元兑韩元汇率，用于泡菜溢价模拟。可回看区间最长约 $maxDays 天，但比按日更细的时间粒度能减少仅靠日K时可能出现的时点与均价偏差。若更在意精度而非更长历史，可选择按小时查看。';
  }

  @override
  String get hourlyGranularityNewBadgeSemanticLabel => '新功能：按小时图表说明';

  @override
  String get kimchiFxBuyMaxLabel => '买入最高汇率(₩)';

  @override
  String get kimchiFxBuyMaxHint => '例如 2,000';

  @override
  String get kimchiFxSellMinLabel => '卖出最低汇率(₩)';

  @override
  String get kimchiFxSellMinHint => '例如 0';

  @override
  String get kimchiFxRateLimitHelpTitle => '说明';

  @override
  String get kimchiFxRateLimitHelpTooltip => '查看说明';

  @override
  String get kimchiFxBuyMaxHelpBody => '当汇率高于或等于设定值时跳过买入，有助于改善收益。';

  @override
  String get kimchiFxSellMinHelpBody => '当汇率低于或等于设定值时跳过卖出，有助于改善收益。';

  @override
  String get kimchiBuyThresholdHelpBody =>
      '当韩国 USDT 相对美元兑韩元汇率的泡菜溢价小于或等于该百分比时，会考虑买入。数值越低越偏向“更便宜才买”，越高则越早考虑买入。';

  @override
  String get kimchiSellThresholdHelpBody =>
      '当溢价大于或等于该百分比时，会考虑卖出。数值越高需要溢价更大才卖，越低则对较小溢价也可能卖出。';

  @override
  String get kimchiFxDeltaCorrectionLabel => '按汇率的泡菜溢价调整';

  @override
  String get kimchiFxDeltaMethodSubtitleQuintiles => '区间表';

  @override
  String get kimchiFxDeltaMethodSubtitleAffine => '汇率比例式';

  @override
  String get kimchiFxDeltaMethodSubtitleLoading => '加载中…';

  @override
  String get kimchiFxDeltaCorrectionHelpBody =>
      '开启后从服务端 `/api/kimchi-fx-delta` 读取 Δ（JSON 可为 USD/KRW 分段或 affine_fx_ratio 汇率比例式），与阈值比较前先加到原始泡菜溢价上（近似：调整后 ≈ 原始 + Δ）。对泡菜模拟、图表买卖线与当日点评一致生效。';

  @override
  String get kimchiFxDeltaTuningDetail => '详细设置';

  @override
  String get kimchiFxDeltaTuningTitle => '泡菜溢价 Δ 详细设置';

  @override
  String get kimchiFxDeltaTuningMethod => '计算方式';

  @override
  String get kimchiFxDeltaTuningMethodQuintiles =>
      '分段表 (equal_count_quintiles)';

  @override
  String get kimchiFxDeltaTuningMethodAffine => '汇率比例 (affine_fx_ratio)';

  @override
  String get kimchiFxDeltaTuningFxReference => '基准汇率 (fx_reference)';

  @override
  String get kimchiFxDeltaTuningKPerFxPercent => 'k_pp_per_fx_percent';

  @override
  String get kimchiFxDeltaTuningBiasPp => 'bias_pp';

  @override
  String get kimchiFxDeltaTuningClampMin => 'clamp_min（留空=不限制）';

  @override
  String get kimchiFxDeltaTuningClampMax => 'clamp_max（留空=不限制）';

  @override
  String get kimchiFxDeltaTuningDeltaPp => 'Δ (百分点)';

  @override
  String get kimchiFxDeltaTuningApply => '应用';

  @override
  String get kimchiFxDeltaTuningReset => '恢复服务端默认';

  @override
  String get kimchiFxDeltaTuningNoPayload => '无法加载服务端 Δ JSON，请检查网络后重试。';

  @override
  String get kimchiFxDeltaTuningSaved => '已保存。';

  @override
  String get kimchiFxDeltaTuningSaveFailed => '保存失败。';
}
