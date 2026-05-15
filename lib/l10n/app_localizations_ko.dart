// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get usdt => '테더';

  @override
  String get exchangeRate => '환율';

  @override
  String get gimchiPremiem => '김치 프리미엄';

  @override
  String get xrpFundingRateTitle => 'XRP 펀딩피(Y)';

  @override
  String fundingRateInterval(Object hours) {
    return '(${hours}h)';
  }

  @override
  String get fundingRateSourceBinance => 'Binance';

  @override
  String get fundingRateSourceBybit => 'Bybit';

  @override
  String get fundingRateLoading => '펀딩피 불러오는 중...';

  @override
  String get fundingRateFailed => '펀딩피를 불러오지 못했습니다';

  @override
  String get cancel => '취소';

  @override
  String get changeStrategy => '김프 전략 변경';

  @override
  String get close => '닫기';

  @override
  String get failedToSaveAlarm => '알림 설정을 저장하는데 실패했습니다.';

  @override
  String get failedToload => '데이터를 불러오는데 실패했습니다.\n다시 시도하시겠습니까?';

  @override
  String get loadingFail => '불러오기 실패';

  @override
  String get moveToSetting => '설정으로 이동';

  @override
  String get needPermission => '알림 권한 필요';

  @override
  String get permissionRequiredMessage =>
      '알림을 받으려면 기기 설정에서 알림 권한을 허용해야 합니다.\n설정으로 이동하시겠습니까?';

  @override
  String get no => '아니오';

  @override
  String get yes => '예';

  @override
  String get useTrendBasedStrategy => '추세 기반 전략 사용';

  @override
  String get error => '에러';

  @override
  String get dash => '-';

  @override
  String get kimchiStrategy => '김프 전략';

  @override
  String get viewAllStrategyHistory => '전체 전략 히스토리 보기';

  @override
  String get kimchiStrategyHistory => '김프 매매 전략 히스토리';

  @override
  String get aiStrategyHistory => 'AI 매매 전략 히스토리';

  @override
  String get strategy => '전략';

  @override
  String get noStrategyData => '전략 데이터가 없습니다';

  @override
  String get seeAdsAndStrategy => '광고 보고 매매 전략 보기';

  @override
  String get todayStrategyAfterAds => '광고 보고 매매 전략 보기';

  @override
  String get todayStrategyDirect => '바로 전략 보기';

  @override
  String get aiReturn => 'AI 매매 수익률';

  @override
  String get gimchiReturn => '김프 매매 수익률';

  @override
  String get throwTestException => 'throwTestException';

  @override
  String get throw_test_exception => '테스트 예외 발생';

  @override
  String get usdtSignal => '테더 시그널';

  @override
  String get usdt_signal => '테더 매매 알리미';

  @override
  String get buyWin => '현재 매수 구간입니다';

  @override
  String get sellWin => '현재 매도 구간입니다';

  @override
  String get justSee => '현재 관망 구간입니다';

  @override
  String get aiStrategy => 'AI 매매 전략';

  @override
  String get gimchiStrategy => '김프 매매 전략';

  @override
  String get buy => '매수';

  @override
  String get sell => '매도';

  @override
  String get gain => '수익률';

  @override
  String get runSimulation => '수익률 시뮬레이션';

  @override
  String get seeStrategy => '전략 보기';

  @override
  String get aiTradingSimulation => 'AI 매매 시뮬레이션 (100 만원 기준)';

  @override
  String get gimchTradingSimulation => '김프 매매 시뮬레이션 (100 만원 기준)';

  @override
  String get finalKRW => '최종원화';

  @override
  String get tradingPerioid => '매매기간';

  @override
  String get stackedFinalKRW => '누적 최종 원화';

  @override
  String get simulationMdd => 'MDD';

  @override
  String get simulationMddHelpTooltip => 'MDD 설명';

  @override
  String get simulationMddHelpBody =>
      '최대 낙폭(MDD)은 시뮬 기간 안에서 매일 기록한 장부 평가금의 고점(피크) 대비, 가장 크게 내려간 비율입니다.\n\n현금일 때는 그날 원화 잔액을, 테더를 보유 중이면 그날 종가로 환산한 평가금을 씁니다. 업비트 수수료 등 시뮬 설정은 반영하지만, 슬리피지·세금 등은 넣지 않았으므로 실제 계좌의 MDD와 다를 수 있습니다.';

  @override
  String get currencyWonSuffix => '원';

  @override
  String get totalGain => '총 수익률';

  @override
  String get annualAvgReturn => '연 평균 수익률';

  @override
  String get extimatedYearGain => '추정 연 수익률';

  @override
  String get annualYieldDescription =>
      '추정 연 수익률은 현재 매매 내역의 수익률을 복리 기준으로 1년치로 환산한 값입니다.\n\n예를 들어, 6개월 동안 5%의 수익률을 얻었다면, 이를 1년 기준으로 환산하면 약 10.25%의 연 수익률이 됩니다.';

  @override
  String get chartTrendAnalysis => '차트 추세 분석';

  @override
  String get aiSell => 'AI 매도';

  @override
  String get kimchiPremiumSell => '김프 매도';

  @override
  String get aiBuy => 'AI 매수';

  @override
  String get kimchiPremiumBuy => '김프 매수';

  @override
  String changeFromPreviousDay(Object change) {
    return '전일 대비: $change%';
  }

  @override
  String get kimchiPremiumPercent => '김치 프리미엄(%)';

  @override
  String get resetChart => '차트 리셋';

  @override
  String get backToPreviousChart => '차트 이전';

  @override
  String get kimchiPremium => '김치 프리미엄';

  @override
  String get aiBuySell => 'AI 매수/매도';

  @override
  String get kimchiPremiumBuySell => '김프 매수/매도';

  @override
  String get kimchiPremiumBackground => '김치 프리미엄 배경';

  @override
  String get kimchiPremiumBackgroundDescriptionTooltip => '김치 프리미엄 배경 설명';

  @override
  String get whatIsKimchiPremiumBackground => '김치 프리미엄 배경이란?';

  @override
  String get kimchiPremiumBackgroundDescription =>
      '차트의 배경색은 김치 프리미엄 값에 따라 달라집니다. 프리미엄이 높을수록 빨간색, 낮을수록 파란색에 가깝게 표시되어 김치 프리미엄에 따른 매수 매도 시점을 시각적으로 파악할 수 있습니다. 이 기능은 김치 프리미엄의 변동성을 한눈에 파악하는 데 도움을 줍니다.';

  @override
  String get confirm => '확인';

  @override
  String get chatRoom => '토론방';

  @override
  String get gimchBaseTrade => '김프 기준 매매';

  @override
  String get aiBaseTrade => 'AI 전략 매매';

  @override
  String get seeWithChart => '차트로 보기';

  @override
  String get buyBase => '매수 기준(%)';

  @override
  String get sellBase => '매도 기준(%)';

  @override
  String get sameAsAI => 'AI와 동일 일정 적용';

  @override
  String get kimchiStartDate => '시작 일정';

  @override
  String get kimchiEndDate => '종료 일정';

  @override
  String get kimchiResetDateRange => '전체 일정';

  @override
  String get failedToSaveSettings => '설정 저장에 실패했습니다.';

  @override
  String get buyPrice => '매수 가격';

  @override
  String get sellPrice => '매도 가격';

  @override
  String get expectedGain => '기대 수익률';

  @override
  String get summary => '요약';

  @override
  String kimchiStrategyComment(double buyThreshold, double sellThreshold) {
    return '김치 프리미엄이 $buyThreshold% 이하일 때 매수, $sellThreshold% 이상일 때 매도 전략입니다.';
  }

  @override
  String get strategySummaryEmpty => '전략 요약 정보가 없습니다.';

  @override
  String kimchiStrategyDetailSettingsLine(String buyPct, String sellPct) {
    return '설정값(보정 후 김프) · 매수 ≤$buyPct% · 매도 ≥$sellPct%';
  }

  @override
  String kimchiStrategyDetailFxLine(String fx) {
    return '이 시점 환율 · $fx원';
  }

  @override
  String kimchiStrategyDetailDeltaLine(String deltaSigned) {
    return '구간 보정(Δ) · $deltaSigned pp';
  }

  @override
  String kimchiStrategyDetailAppliedLine(String buyApp, String sellApp) {
    return '가격선 적용(설정 − Δ) · 매수 $buyApp% · 매도 $sellApp%';
  }

  @override
  String get kimchiStrategyDetailDeltaUnavailable =>
      '(이 시점 환율을 찾지 못해 구간 Δ·가격선 비율은 생략됩니다)';

  @override
  String get kimchiStrategyDetailFootnote =>
      '가격선 비율은 시뮬과 같이 환율×(1+값/100)에 들어갑니다. 설정 %는 「보정 후 김프」 기준입니다.';

  @override
  String get sellIfCurrentPrice => '현재가 매도시';

  @override
  String get onboardingTitle1 => '테더(USDT)의 숨겨진 차이';

  @override
  String get onboardingBody1 =>
      '해외에서는 1 USDT = 1 USD지만, 한국 거래소에서는 환율과 \'김치 프리미엄\'으로 인해 실제 가격이 달라집니다. 이 차이를 잘 활용하면 수익을 만들 수 있어요.';

  @override
  String get onboardingImageDesc1 => '한국 USDT 가격 = 환율 + 김치 프리미엄';

  @override
  String get onboardingTitle2 => '김치 프리미엄으로 수익 만들기';

  @override
  String get onboardingBody2 =>
      '한국에서 테더가 해외보다 비싸게 거래될 때(김치 프리미엄) 매도하면 수익이 됩니다. 우리 앱이 김치 프리미엄과 환율을 실시간으로 분석해 최적의 매수/매도 타이밍을 찾아드립니다.';

  @override
  String get onboardingImageDesc2 => '저가에 매수 → 프리미엄 높을 때 매도 → 수익 실현';

  @override
  String get onboardingTitle3 => 'AI와 김치 프리미엄, 두 가지 전략';

  @override
  String get onboardingBody3 =>
      'AI가 분석한 매매 전략과 김치 프리미엄 기반 전략 중 선택해 알림을 받을 수 있습니다. 실시간 차트로 현재 상황을 한눈에 확인하고, 각 전략의 과거 수익률도 비교해보세요.';

  @override
  String get onboardingImageDesc3 => 'AI 전략 알림 + 김치 프리미엄 전략 알림';

  @override
  String get onboardingTitle4 => '과거 데이터로 검증된 수익률';

  @override
  String get onboardingBody4 =>
      '100만원으로 시작했다면 얼마나 벌 수 있었을까? 실제 과거 데이터로 각 전략의 수익률을 시뮬레이션해보고, 어떤 방법이 더 효과적인지 비교해보세요.';

  @override
  String get onboardingImageDesc4 => 'AI 수익률 vs 김치 프리미엄 수익률 비교';

  @override
  String get previous => '이전';

  @override
  String get start => '시작하기';

  @override
  String get next => '다음';

  @override
  String get selectReceiveAlert => '받을 알림을 선택하세요';

  @override
  String get selectReceiveAlertSubtitle => '수신할 알림 유형을 선택하세요';

  @override
  String get aIalert => 'AI 분석 알림 받기';

  @override
  String get aIalertDescription => 'AI가 분석한 매매 전략을 알림으로 받습니다';

  @override
  String get gimpAlert => '김프 알림 받기';

  @override
  String get gimpAlertDescription => '김치 프리미엄 기반 매매 전략을 알림으로 받습니다';

  @override
  String get turnOffAlert => '알림 끄기';

  @override
  String get unFilled => '미체결';

  @override
  String get coinInfoSite => '코인 정보 사이트';

  @override
  String get adClickInstruction => 'X 클릭 후 매수/매도 시그널 확인';

  @override
  String get removeAdsCta => '광고 없이 매매 전략 보기';

  @override
  String get removeAdsTitle => '광고 없이 보기';

  @override
  String get removeAdsSubtitle => '더 깔끔하게 매매 전략을 확인하세요.';

  @override
  String get removeAdsDescription => '결제 후에는 광고 시청 없이 바로 매매 전략을 확인할 수 있습니다.';

  @override
  String get purchaseButton => '구매하기';

  @override
  String get restoreButton => '구매 복원';

  @override
  String get restoreSuccess => '성공';

  @override
  String get restoreNoPurchases => '복원할 구매 내역이 없습니다';

  @override
  String get adLoadingMessage => '광고를 불러오는 중입니다. 잠시 후 다시 시도해 주세요.';

  @override
  String get privacyPolicy => '개인정보 처리 방침';

  @override
  String get termsOfService => '약관';

  @override
  String get nextBuyPoint => '다음 매수 시점';

  @override
  String get nextSellPoint => '다음 매도 시점';

  @override
  String get priceLabel => '가격';

  @override
  String get basePremium => '기준 프리미엄';

  @override
  String get kimchiPremiumShort => '김프';

  @override
  String get tradeTimeline => '매매 타임라인';

  @override
  String get performanceMetrics => '성과 지표';

  @override
  String initialCapital(String amount) {
    return '초기 자본: $amount';
  }

  @override
  String get editInitialCapitalTitle => '모의 투자 초기 자본';

  @override
  String get editInitialCapitalHint => '1만 원 이상 10억 원 이하로 입력하세요.';

  @override
  String get initialCapitalInvalid => '유효한 금액(숫자)을 입력해 주세요.';

  @override
  String get finalValue => '최종 가치';

  @override
  String get aiSimulatedTradeTitle => 'AI 모의 투자';

  @override
  String get kimchiSimulatedTradeTitle => '김프 모의 투자';

  @override
  String get shareSimulationButton => '공유하기';

  @override
  String get simulationCompoundInterestTitle => '복리 계산';

  @override
  String get simulationCompoundInterestHelpTooltip => '복리 계산 설명';

  @override
  String get simulationCompoundInterestHelpBody =>
      '켜면 매도 후 누적 금액으로 다시 매수합니다. 끄면 매수마다 초기 자본만 사용합니다.';

  @override
  String get profitRate => '수익률';

  @override
  String get evaluationAmount => '평가금액';

  @override
  String get fee => '수수료';

  @override
  String upbitFeeApplied(double buyFee, double sellFee) {
    return '업비트 수수료 적용 (매수 $buyFee%, 매도 $sellFee%)';
  }

  @override
  String feeWithAmount(String amount) {
    return '수수료: ₩$amount';
  }

  @override
  String get chartGranularityDaily => '하루 단위';

  @override
  String get chartGranularityHourly => '시간 단위';

  @override
  String get hourlyChartLoadFailed => '시간봉 데이터를 불러오지 못했습니다.';

  @override
  String get hourlyGranularityIntroTitle => '시간 단위 안내';

  @override
  String hourlyGranularityIntroBody(int maxDays) {
    return '시간 단위는 시간봉 기준으로 업비트 USDT와 원·달러 환율을 맞춰 김치 프리미엄 시뮬레이션을 실행합니다. 제공 구간은 최대 약 $maxDays일로 제한되지만, 하루 단위보다 촘촘한 시점에서 가격을 맞추므로 일봉에서만 볼 때 생길 수 있는 시점·평균화에 따른 오차를 줄이는 데 도움이 됩니다. 기간은 짧아지지만 더 정밀한 해석이 필요할 때 활용해 보세요.';
  }

  @override
  String get hourlyGranularityNewBadgeSemanticLabel => '새 기능: 시간 단위 차트 안내';

  @override
  String get kimchiFxBuyMaxLabel => '매수 최대 환율(₩)';

  @override
  String get kimchiFxBuyMaxHint => '예: 2,000';

  @override
  String get kimchiFxSellMinLabel => '매도 최저 환율(₩)';

  @override
  String get kimchiFxSellMinHint => '예: 0';

  @override
  String get kimchiFxRateLimitHelpTitle => '설명';

  @override
  String get kimchiFxRateLimitHelpTooltip => '설명 보기';

  @override
  String get kimchiFxBuyMaxHelpBody =>
      '환율이 설정된 이상 보다 높을 경우 매수를 방지 해서 수익률을 개선합니다';

  @override
  String get kimchiFxSellMinHelpBody =>
      '설정된 환율보다 낮을 경우 매도를 방지해서 수익률을 개선 할 수 있습니다';

  @override
  String get kimchiBuyThresholdHelpBody =>
      '김치 프리미엄(한국 USDT가 달러 환율 대비 얼마나 비싼지)이 입력한 % 이하일 때 매수 신호를 검토합니다. 값을 낮추면 더 싸게 보일 때만 매수하려 하고, 높이면 상대적으로 더 일찍 매수하는 설정에 가깝습니다.';

  @override
  String get kimchiSellThresholdHelpBody =>
      '김치 프리미엄이 입력한 % 이상일 때 매도 신호를 검토합니다. 값을 높이면 프리미엄이 더 커졌을 때만 매도하려 하고, 낮추면 비교적 작은 프리미엄에서도 매도 후보가 됩니다.';

  @override
  String get kimchiFxDeltaCorrectionLabel => '환율별 김프 보정';

  @override
  String get kimchiFxDeltaMethodSubtitleQuintiles => '구간표';

  @override
  String get kimchiFxDeltaMethodSubtitleAffine => '환율 비율식';

  @override
  String get kimchiFxDeltaMethodSubtitleLoading => '불러오는 중…';

  @override
  String get kimchiFxDeltaCorrectionHelpBody =>
      '켜면 서버 `/api/kimchi-fx-delta`의 델타를 받아 김프 임계에 맞춥니다(JSON은 퀀타일 구간표 또는 환율 비율식 affine_fx_ratio). 보정 후 김프(%) ≈ 원시 김프 + 델타이며, 시뮬·차트 김프 매매선·오늘의 코멘트에 동일하게 적용됩니다.';

  @override
  String get kimchiFxDeltaTuningDetail => '세부 설정';

  @override
  String get kimchiFxDeltaTuningTitle => '김프 델타 보정 세부 설정';

  @override
  String get kimchiFxDeltaTuningUseOverride => '앱에서 서버 값 덮어쓰기';

  @override
  String get kimchiFxDeltaTuningMethod => '계산 방식';

  @override
  String get kimchiFxDeltaTuningMethodQuintiles =>
      '구간표 (equal_count_quintiles)';

  @override
  String get kimchiFxDeltaTuningMethodAffine => '환율 비율식 (affine_fx_ratio)';

  @override
  String get kimchiFxDeltaTuningFxReference => '기준 환율 (fx_reference)';

  @override
  String get kimchiFxDeltaTuningKPerFxPercent => 'k_pp_per_fx_percent';

  @override
  String get kimchiFxDeltaTuningBiasPp => 'bias_pp';

  @override
  String get kimchiFxDeltaTuningClampMin => 'clamp_min (비우면 없음)';

  @override
  String get kimchiFxDeltaTuningClampMax => 'clamp_max (비우면 없음)';

  @override
  String get kimchiFxDeltaTuningDeltaPp => 'Δ(pp)';

  @override
  String get kimchiFxDeltaTuningApply => '적용';

  @override
  String get kimchiFxDeltaTuningReset => '서버 기본만 사용';

  @override
  String get kimchiFxDeltaTuningNoPayload =>
      '서버 델타 JSON을 불러오지 못했습니다. 네트워크 후 다시 시도하세요.';

  @override
  String get kimchiFxDeltaTuningSaved => '저장했습니다.';

  @override
  String get kimchiFxDeltaTuningSaveFailed => '저장에 실패했습니다.';
}
