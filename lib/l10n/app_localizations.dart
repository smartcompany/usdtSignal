import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ko'),
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @usdt.
  ///
  /// In ko, this message translates to:
  /// **'테더'**
  String get usdt;

  /// No description provided for @exchangeRate.
  ///
  /// In ko, this message translates to:
  /// **'환율'**
  String get exchangeRate;

  /// No description provided for @gimchiPremiem.
  ///
  /// In ko, this message translates to:
  /// **'김치 프리미엄'**
  String get gimchiPremiem;

  /// No description provided for @xrpFundingRateTitle.
  ///
  /// In ko, this message translates to:
  /// **'XRP 펀딩피(Y)'**
  String get xrpFundingRateTitle;

  /// No description provided for @fundingRateInterval.
  ///
  /// In ko, this message translates to:
  /// **'({hours}h)'**
  String fundingRateInterval(Object hours);

  /// No description provided for @fundingRateSourceBinance.
  ///
  /// In ko, this message translates to:
  /// **'Binance'**
  String get fundingRateSourceBinance;

  /// No description provided for @fundingRateSourceBybit.
  ///
  /// In ko, this message translates to:
  /// **'Bybit'**
  String get fundingRateSourceBybit;

  /// No description provided for @fundingRateLoading.
  ///
  /// In ko, this message translates to:
  /// **'펀딩피 불러오는 중...'**
  String get fundingRateLoading;

  /// No description provided for @fundingRateFailed.
  ///
  /// In ko, this message translates to:
  /// **'펀딩피를 불러오지 못했습니다'**
  String get fundingRateFailed;

  /// No description provided for @cancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get cancel;

  /// No description provided for @changeStrategy.
  ///
  /// In ko, this message translates to:
  /// **'김프 전략 변경'**
  String get changeStrategy;

  /// No description provided for @close.
  ///
  /// In ko, this message translates to:
  /// **'닫기'**
  String get close;

  /// No description provided for @failedToSaveAlarm.
  ///
  /// In ko, this message translates to:
  /// **'알림 설정을 저장하는데 실패했습니다.'**
  String get failedToSaveAlarm;

  /// No description provided for @failedToload.
  ///
  /// In ko, this message translates to:
  /// **'데이터를 불러오는데 실패했습니다.\n다시 시도하시겠습니까?'**
  String get failedToload;

  /// No description provided for @loadingFail.
  ///
  /// In ko, this message translates to:
  /// **'불러오기 실패'**
  String get loadingFail;

  /// No description provided for @moveToSetting.
  ///
  /// In ko, this message translates to:
  /// **'설정으로 이동'**
  String get moveToSetting;

  /// No description provided for @needPermission.
  ///
  /// In ko, this message translates to:
  /// **'알림 권한 필요'**
  String get needPermission;

  /// No description provided for @permissionRequiredMessage.
  ///
  /// In ko, this message translates to:
  /// **'알림을 받으려면 기기 설정에서 알림 권한을 허용해야 합니다.\n설정으로 이동하시겠습니까?'**
  String get permissionRequiredMessage;

  /// No description provided for @no.
  ///
  /// In ko, this message translates to:
  /// **'아니오'**
  String get no;

  /// No description provided for @yes.
  ///
  /// In ko, this message translates to:
  /// **'예'**
  String get yes;

  /// No description provided for @useTrendBasedStrategy.
  ///
  /// In ko, this message translates to:
  /// **'추세 기반 전략 사용'**
  String get useTrendBasedStrategy;

  /// No description provided for @error.
  ///
  /// In ko, this message translates to:
  /// **'에러'**
  String get error;

  /// No description provided for @dash.
  ///
  /// In ko, this message translates to:
  /// **'-'**
  String get dash;

  /// No description provided for @kimchiStrategy.
  ///
  /// In ko, this message translates to:
  /// **'김프 전략'**
  String get kimchiStrategy;

  /// No description provided for @viewAllStrategyHistory.
  ///
  /// In ko, this message translates to:
  /// **'전체 전략 히스토리 보기'**
  String get viewAllStrategyHistory;

  /// No description provided for @kimchiStrategyHistory.
  ///
  /// In ko, this message translates to:
  /// **'김프 매매 전략 히스토리'**
  String get kimchiStrategyHistory;

  /// No description provided for @aiStrategyHistory.
  ///
  /// In ko, this message translates to:
  /// **'AI 매매 전략 히스토리'**
  String get aiStrategyHistory;

  /// No description provided for @strategy.
  ///
  /// In ko, this message translates to:
  /// **'전략'**
  String get strategy;

  /// No description provided for @noStrategyData.
  ///
  /// In ko, this message translates to:
  /// **'전략 데이터가 없습니다'**
  String get noStrategyData;

  /// No description provided for @seeAdsAndStrategy.
  ///
  /// In ko, this message translates to:
  /// **'광고 보고 매매 전략 보기'**
  String get seeAdsAndStrategy;

  /// No description provided for @todayStrategyAfterAds.
  ///
  /// In ko, this message translates to:
  /// **'광고 보고 매매 전략 보기'**
  String get todayStrategyAfterAds;

  /// No description provided for @todayStrategyDirect.
  ///
  /// In ko, this message translates to:
  /// **'바로 전략 보기'**
  String get todayStrategyDirect;

  /// No description provided for @aiReturn.
  ///
  /// In ko, this message translates to:
  /// **'AI 매매 수익률'**
  String get aiReturn;

  /// No description provided for @gimchiReturn.
  ///
  /// In ko, this message translates to:
  /// **'김프 매매 수익률'**
  String get gimchiReturn;

  /// No description provided for @throwTestException.
  ///
  /// In ko, this message translates to:
  /// **'throwTestException'**
  String get throwTestException;

  /// No description provided for @throw_test_exception.
  ///
  /// In ko, this message translates to:
  /// **'테스트 예외 발생'**
  String get throw_test_exception;

  /// No description provided for @usdtSignal.
  ///
  /// In ko, this message translates to:
  /// **'테더 시그널'**
  String get usdtSignal;

  /// No description provided for @usdt_signal.
  ///
  /// In ko, this message translates to:
  /// **'테더 매매 알리미'**
  String get usdt_signal;

  /// No description provided for @buyWin.
  ///
  /// In ko, this message translates to:
  /// **'현재 매수 구간입니다'**
  String get buyWin;

  /// No description provided for @sellWin.
  ///
  /// In ko, this message translates to:
  /// **'현재 매도 구간입니다'**
  String get sellWin;

  /// No description provided for @justSee.
  ///
  /// In ko, this message translates to:
  /// **'현재 관망 구간입니다'**
  String get justSee;

  /// No description provided for @aiStrategy.
  ///
  /// In ko, this message translates to:
  /// **'AI 매매 전략'**
  String get aiStrategy;

  /// No description provided for @gimchiStrategy.
  ///
  /// In ko, this message translates to:
  /// **'김프 매매 전략'**
  String get gimchiStrategy;

  /// No description provided for @buy.
  ///
  /// In ko, this message translates to:
  /// **'매수'**
  String get buy;

  /// No description provided for @sell.
  ///
  /// In ko, this message translates to:
  /// **'매도'**
  String get sell;

  /// No description provided for @gain.
  ///
  /// In ko, this message translates to:
  /// **'수익률'**
  String get gain;

  /// No description provided for @runSimulation.
  ///
  /// In ko, this message translates to:
  /// **'수익률 시뮬레이션'**
  String get runSimulation;

  /// No description provided for @seeStrategy.
  ///
  /// In ko, this message translates to:
  /// **'전략 보기'**
  String get seeStrategy;

  /// No description provided for @aiTradingSimulation.
  ///
  /// In ko, this message translates to:
  /// **'AI 매매 시뮬레이션 (100 만원 기준)'**
  String get aiTradingSimulation;

  /// No description provided for @gimchTradingSimulation.
  ///
  /// In ko, this message translates to:
  /// **'김프 매매 시뮬레이션 (100 만원 기준)'**
  String get gimchTradingSimulation;

  /// No description provided for @finalKRW.
  ///
  /// In ko, this message translates to:
  /// **'최종원화'**
  String get finalKRW;

  /// No description provided for @tradingPerioid.
  ///
  /// In ko, this message translates to:
  /// **'매매기간'**
  String get tradingPerioid;

  /// No description provided for @stackedFinalKRW.
  ///
  /// In ko, this message translates to:
  /// **'누적 최종 원화'**
  String get stackedFinalKRW;

  /// No description provided for @simulationMdd.
  ///
  /// In ko, this message translates to:
  /// **'MDD'**
  String get simulationMdd;

  /// No description provided for @simulationMddHelpTooltip.
  ///
  /// In ko, this message translates to:
  /// **'MDD 설명'**
  String get simulationMddHelpTooltip;

  /// No description provided for @simulationMddHelpBody.
  ///
  /// In ko, this message translates to:
  /// **'최대 낙폭(MDD)은 시뮬 기간 안에서 매일 기록한 장부 평가금의 고점(피크) 대비, 가장 크게 내려간 비율입니다.\n\n현금일 때는 그날 원화 잔액을, 테더를 보유 중이면 그날 종가로 환산한 평가금을 씁니다. 업비트 수수료 등 시뮬 설정은 반영하지만, 슬리피지·세금 등은 넣지 않았으므로 실제 계좌의 MDD와 다를 수 있습니다.'**
  String get simulationMddHelpBody;

  /// No description provided for @currencyWonSuffix.
  ///
  /// In ko, this message translates to:
  /// **'원'**
  String get currencyWonSuffix;

  /// No description provided for @totalGain.
  ///
  /// In ko, this message translates to:
  /// **'총 수익률'**
  String get totalGain;

  /// No description provided for @annualAvgReturn.
  ///
  /// In ko, this message translates to:
  /// **'연 평균 수익률'**
  String get annualAvgReturn;

  /// No description provided for @extimatedYearGain.
  ///
  /// In ko, this message translates to:
  /// **'추정 연 수익률'**
  String get extimatedYearGain;

  /// No description provided for @annualYieldDescription.
  ///
  /// In ko, this message translates to:
  /// **'추정 연 수익률은 현재 매매 내역의 수익률을 복리 기준으로 1년치로 환산한 값입니다.\n\n예를 들어, 6개월 동안 5%의 수익률을 얻었다면, 이를 1년 기준으로 환산하면 약 10.25%의 연 수익률이 됩니다.'**
  String get annualYieldDescription;

  /// No description provided for @chartTrendAnalysis.
  ///
  /// In ko, this message translates to:
  /// **'차트 추세 분석'**
  String get chartTrendAnalysis;

  /// No description provided for @aiSell.
  ///
  /// In ko, this message translates to:
  /// **'AI 매도'**
  String get aiSell;

  /// No description provided for @kimchiPremiumSell.
  ///
  /// In ko, this message translates to:
  /// **'김프 매도'**
  String get kimchiPremiumSell;

  /// No description provided for @aiBuy.
  ///
  /// In ko, this message translates to:
  /// **'AI 매수'**
  String get aiBuy;

  /// No description provided for @kimchiPremiumBuy.
  ///
  /// In ko, this message translates to:
  /// **'김프 매수'**
  String get kimchiPremiumBuy;

  /// No description provided for @changeFromPreviousDay.
  ///
  /// In ko, this message translates to:
  /// **'전일 대비: {change}%'**
  String changeFromPreviousDay(Object change);

  /// No description provided for @kimchiPremiumPercent.
  ///
  /// In ko, this message translates to:
  /// **'김치 프리미엄(%)'**
  String get kimchiPremiumPercent;

  /// No description provided for @resetChart.
  ///
  /// In ko, this message translates to:
  /// **'차트 리셋'**
  String get resetChart;

  /// No description provided for @backToPreviousChart.
  ///
  /// In ko, this message translates to:
  /// **'차트 이전'**
  String get backToPreviousChart;

  /// No description provided for @kimchiPremium.
  ///
  /// In ko, this message translates to:
  /// **'김치 프리미엄'**
  String get kimchiPremium;

  /// No description provided for @aiBuySell.
  ///
  /// In ko, this message translates to:
  /// **'AI 매수/매도'**
  String get aiBuySell;

  /// No description provided for @kimchiPremiumBuySell.
  ///
  /// In ko, this message translates to:
  /// **'김프 매수/매도'**
  String get kimchiPremiumBuySell;

  /// No description provided for @kimchiPremiumBackground.
  ///
  /// In ko, this message translates to:
  /// **'김치 프리미엄 배경'**
  String get kimchiPremiumBackground;

  /// No description provided for @kimchiPremiumBackgroundDescriptionTooltip.
  ///
  /// In ko, this message translates to:
  /// **'김치 프리미엄 배경 설명'**
  String get kimchiPremiumBackgroundDescriptionTooltip;

  /// No description provided for @whatIsKimchiPremiumBackground.
  ///
  /// In ko, this message translates to:
  /// **'김치 프리미엄 배경이란?'**
  String get whatIsKimchiPremiumBackground;

  /// No description provided for @kimchiPremiumBackgroundDescription.
  ///
  /// In ko, this message translates to:
  /// **'차트의 배경색은 김치 프리미엄 값에 따라 달라집니다. 프리미엄이 높을수록 빨간색, 낮을수록 파란색에 가깝게 표시되어 김치 프리미엄에 따른 매수 매도 시점을 시각적으로 파악할 수 있습니다. 이 기능은 김치 프리미엄의 변동성을 한눈에 파악하는 데 도움을 줍니다.'**
  String get kimchiPremiumBackgroundDescription;

  /// No description provided for @confirm.
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get confirm;

  /// No description provided for @chatRoom.
  ///
  /// In ko, this message translates to:
  /// **'토론방'**
  String get chatRoom;

  /// No description provided for @gimchBaseTrade.
  ///
  /// In ko, this message translates to:
  /// **'김프 기준 매매'**
  String get gimchBaseTrade;

  /// No description provided for @aiBaseTrade.
  ///
  /// In ko, this message translates to:
  /// **'AI 전략 매매'**
  String get aiBaseTrade;

  /// No description provided for @seeWithChart.
  ///
  /// In ko, this message translates to:
  /// **'차트로 보기'**
  String get seeWithChart;

  /// No description provided for @buyBase.
  ///
  /// In ko, this message translates to:
  /// **'매수 기준(%)'**
  String get buyBase;

  /// No description provided for @sellBase.
  ///
  /// In ko, this message translates to:
  /// **'매도 기준(%)'**
  String get sellBase;

  /// No description provided for @sameAsAI.
  ///
  /// In ko, this message translates to:
  /// **'AI와 동일 일정 적용'**
  String get sameAsAI;

  /// No description provided for @kimchiStartDate.
  ///
  /// In ko, this message translates to:
  /// **'시작 일정'**
  String get kimchiStartDate;

  /// No description provided for @kimchiEndDate.
  ///
  /// In ko, this message translates to:
  /// **'종료 일정'**
  String get kimchiEndDate;

  /// No description provided for @kimchiResetDateRange.
  ///
  /// In ko, this message translates to:
  /// **'전체 일정'**
  String get kimchiResetDateRange;

  /// No description provided for @failedToSaveSettings.
  ///
  /// In ko, this message translates to:
  /// **'설정 저장에 실패했습니다.'**
  String get failedToSaveSettings;

  /// No description provided for @buyPrice.
  ///
  /// In ko, this message translates to:
  /// **'매수 가격'**
  String get buyPrice;

  /// No description provided for @sellPrice.
  ///
  /// In ko, this message translates to:
  /// **'매도 가격'**
  String get sellPrice;

  /// No description provided for @expectedGain.
  ///
  /// In ko, this message translates to:
  /// **'기대 수익률'**
  String get expectedGain;

  /// No description provided for @summary.
  ///
  /// In ko, this message translates to:
  /// **'요약'**
  String get summary;

  /// 김치 프리미엄 매수/매도 전략 설명
  ///
  /// In ko, this message translates to:
  /// **'김치 프리미엄이 {buyThreshold}% 이하일 때 매수, {sellThreshold}% 이상일 때 매도 전략입니다.'**
  String kimchiStrategyComment(double buyThreshold, double sellThreshold);

  /// No description provided for @strategySummaryEmpty.
  ///
  /// In ko, this message translates to:
  /// **'전략 요약 정보가 없습니다.'**
  String get strategySummaryEmpty;

  /// No description provided for @kimchiStrategyDetailSettingsLine.
  ///
  /// In ko, this message translates to:
  /// **'설정값(보정 후 김프) · 매수 ≤{buyPct}% · 매도 ≥{sellPct}%'**
  String kimchiStrategyDetailSettingsLine(String buyPct, String sellPct);

  /// No description provided for @kimchiStrategyDetailFxLine.
  ///
  /// In ko, this message translates to:
  /// **'이 시점 환율 · {fx}원'**
  String kimchiStrategyDetailFxLine(String fx);

  /// No description provided for @kimchiStrategyDetailDeltaLine.
  ///
  /// In ko, this message translates to:
  /// **'구간 보정(Δ) · {deltaSigned} pp'**
  String kimchiStrategyDetailDeltaLine(String deltaSigned);

  /// No description provided for @kimchiStrategyDetailAppliedLine.
  ///
  /// In ko, this message translates to:
  /// **'가격선 적용(설정 − Δ) · 매수 {buyApp}% · 매도 {sellApp}%'**
  String kimchiStrategyDetailAppliedLine(String buyApp, String sellApp);

  /// No description provided for @kimchiStrategyDetailDeltaUnavailable.
  ///
  /// In ko, this message translates to:
  /// **'(이 시점 환율을 찾지 못해 구간 Δ·가격선 비율은 생략됩니다)'**
  String get kimchiStrategyDetailDeltaUnavailable;

  /// No description provided for @kimchiStrategyDetailFootnote.
  ///
  /// In ko, this message translates to:
  /// **'가격선 비율은 시뮬과 같이 환율×(1+값/100)에 들어갑니다. 설정 %는 「보정 후 김프」 기준입니다.'**
  String get kimchiStrategyDetailFootnote;

  /// No description provided for @sellIfCurrentPrice.
  ///
  /// In ko, this message translates to:
  /// **'현재가 매도시'**
  String get sellIfCurrentPrice;

  /// No description provided for @onboardingTitle1.
  ///
  /// In ko, this message translates to:
  /// **'테더(USDT)의 숨겨진 차이'**
  String get onboardingTitle1;

  /// No description provided for @onboardingBody1.
  ///
  /// In ko, this message translates to:
  /// **'해외에서는 1 USDT = 1 USD지만, 한국 거래소에서는 환율과 \'김치 프리미엄\'으로 인해 실제 가격이 달라집니다. 이 차이를 잘 활용하면 수익을 만들 수 있어요.'**
  String get onboardingBody1;

  /// No description provided for @onboardingImageDesc1.
  ///
  /// In ko, this message translates to:
  /// **'한국 USDT 가격 = 환율 + 김치 프리미엄'**
  String get onboardingImageDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In ko, this message translates to:
  /// **'김치 프리미엄으로 수익 만들기'**
  String get onboardingTitle2;

  /// No description provided for @onboardingBody2.
  ///
  /// In ko, this message translates to:
  /// **'한국에서 테더가 해외보다 비싸게 거래될 때(김치 프리미엄) 매도하면 수익이 됩니다. 우리 앱이 김치 프리미엄과 환율을 실시간으로 분석해 최적의 매수/매도 타이밍을 찾아드립니다.'**
  String get onboardingBody2;

  /// No description provided for @onboardingImageDesc2.
  ///
  /// In ko, this message translates to:
  /// **'저가에 매수 → 프리미엄 높을 때 매도 → 수익 실현'**
  String get onboardingImageDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In ko, this message translates to:
  /// **'AI와 김치 프리미엄, 두 가지 전략'**
  String get onboardingTitle3;

  /// No description provided for @onboardingBody3.
  ///
  /// In ko, this message translates to:
  /// **'AI가 분석한 매매 전략과 김치 프리미엄 기반 전략 중 선택해 알림을 받을 수 있습니다. 실시간 차트로 현재 상황을 한눈에 확인하고, 각 전략의 과거 수익률도 비교해보세요.'**
  String get onboardingBody3;

  /// No description provided for @onboardingImageDesc3.
  ///
  /// In ko, this message translates to:
  /// **'AI 전략 알림 + 김치 프리미엄 전략 알림'**
  String get onboardingImageDesc3;

  /// No description provided for @onboardingTitle4.
  ///
  /// In ko, this message translates to:
  /// **'과거 데이터로 검증된 수익률'**
  String get onboardingTitle4;

  /// No description provided for @onboardingBody4.
  ///
  /// In ko, this message translates to:
  /// **'100만원으로 시작했다면 얼마나 벌 수 있었을까? 실제 과거 데이터로 각 전략의 수익률을 시뮬레이션해보고, 어떤 방법이 더 효과적인지 비교해보세요.'**
  String get onboardingBody4;

  /// No description provided for @onboardingImageDesc4.
  ///
  /// In ko, this message translates to:
  /// **'AI 수익률 vs 김치 프리미엄 수익률 비교'**
  String get onboardingImageDesc4;

  /// No description provided for @previous.
  ///
  /// In ko, this message translates to:
  /// **'이전'**
  String get previous;

  /// No description provided for @start.
  ///
  /// In ko, this message translates to:
  /// **'시작하기'**
  String get start;

  /// No description provided for @next.
  ///
  /// In ko, this message translates to:
  /// **'다음'**
  String get next;

  /// No description provided for @selectReceiveAlert.
  ///
  /// In ko, this message translates to:
  /// **'받을 알림을 선택하세요'**
  String get selectReceiveAlert;

  /// No description provided for @selectReceiveAlertSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'수신할 알림 유형을 선택하세요'**
  String get selectReceiveAlertSubtitle;

  /// No description provided for @aIalert.
  ///
  /// In ko, this message translates to:
  /// **'AI 분석 알림 받기'**
  String get aIalert;

  /// No description provided for @aIalertDescription.
  ///
  /// In ko, this message translates to:
  /// **'AI가 분석한 매매 전략을 알림으로 받습니다'**
  String get aIalertDescription;

  /// No description provided for @gimpAlert.
  ///
  /// In ko, this message translates to:
  /// **'김프 알림 받기'**
  String get gimpAlert;

  /// No description provided for @gimpAlertDescription.
  ///
  /// In ko, this message translates to:
  /// **'김치 프리미엄 기반 매매 전략을 알림으로 받습니다'**
  String get gimpAlertDescription;

  /// No description provided for @turnOffAlert.
  ///
  /// In ko, this message translates to:
  /// **'알림 끄기'**
  String get turnOffAlert;

  /// No description provided for @unFilled.
  ///
  /// In ko, this message translates to:
  /// **'미체결'**
  String get unFilled;

  /// No description provided for @coinInfoSite.
  ///
  /// In ko, this message translates to:
  /// **'코인 정보 사이트'**
  String get coinInfoSite;

  /// No description provided for @adClickInstruction.
  ///
  /// In ko, this message translates to:
  /// **'X 클릭 후 매수/매도 시그널 확인'**
  String get adClickInstruction;

  /// No description provided for @removeAdsCta.
  ///
  /// In ko, this message translates to:
  /// **'광고 없이 매매 전략 보기'**
  String get removeAdsCta;

  /// No description provided for @removeAdsTitle.
  ///
  /// In ko, this message translates to:
  /// **'광고 없이 보기'**
  String get removeAdsTitle;

  /// No description provided for @removeAdsSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'더 깔끔하게 매매 전략을 확인하세요.'**
  String get removeAdsSubtitle;

  /// No description provided for @removeAdsDescription.
  ///
  /// In ko, this message translates to:
  /// **'결제 후에는 광고 시청 없이 바로 매매 전략을 확인할 수 있습니다.'**
  String get removeAdsDescription;

  /// No description provided for @purchaseButton.
  ///
  /// In ko, this message translates to:
  /// **'구매하기'**
  String get purchaseButton;

  /// No description provided for @restoreButton.
  ///
  /// In ko, this message translates to:
  /// **'구매 복원'**
  String get restoreButton;

  /// No description provided for @restoreSuccess.
  ///
  /// In ko, this message translates to:
  /// **'성공'**
  String get restoreSuccess;

  /// No description provided for @restoreNoPurchases.
  ///
  /// In ko, this message translates to:
  /// **'복원할 구매 내역이 없습니다'**
  String get restoreNoPurchases;

  /// No description provided for @adLoadingMessage.
  ///
  /// In ko, this message translates to:
  /// **'광고를 불러오는 중입니다. 잠시 후 다시 시도해 주세요.'**
  String get adLoadingMessage;

  /// No description provided for @privacyPolicy.
  ///
  /// In ko, this message translates to:
  /// **'개인정보 처리 방침'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In ko, this message translates to:
  /// **'약관'**
  String get termsOfService;

  /// No description provided for @nextBuyPoint.
  ///
  /// In ko, this message translates to:
  /// **'다음 매수 시점'**
  String get nextBuyPoint;

  /// No description provided for @nextSellPoint.
  ///
  /// In ko, this message translates to:
  /// **'다음 매도 시점'**
  String get nextSellPoint;

  /// No description provided for @priceLabel.
  ///
  /// In ko, this message translates to:
  /// **'가격'**
  String get priceLabel;

  /// No description provided for @basePremium.
  ///
  /// In ko, this message translates to:
  /// **'기준 프리미엄'**
  String get basePremium;

  /// No description provided for @kimchiPremiumShort.
  ///
  /// In ko, this message translates to:
  /// **'김프'**
  String get kimchiPremiumShort;

  /// No description provided for @tradeTimeline.
  ///
  /// In ko, this message translates to:
  /// **'매매 타임라인'**
  String get tradeTimeline;

  /// No description provided for @performanceMetrics.
  ///
  /// In ko, this message translates to:
  /// **'성과 지표'**
  String get performanceMetrics;

  /// No description provided for @initialCapital.
  ///
  /// In ko, this message translates to:
  /// **'초기 자본: {amount}'**
  String initialCapital(String amount);

  /// No description provided for @editInitialCapitalTitle.
  ///
  /// In ko, this message translates to:
  /// **'모의 투자 초기 자본'**
  String get editInitialCapitalTitle;

  /// No description provided for @editInitialCapitalHint.
  ///
  /// In ko, this message translates to:
  /// **'1만 원 이상 10억 원 이하로 입력하세요.'**
  String get editInitialCapitalHint;

  /// No description provided for @initialCapitalInvalid.
  ///
  /// In ko, this message translates to:
  /// **'유효한 금액(숫자)을 입력해 주세요.'**
  String get initialCapitalInvalid;

  /// No description provided for @finalValue.
  ///
  /// In ko, this message translates to:
  /// **'최종 가치'**
  String get finalValue;

  /// No description provided for @aiSimulatedTradeTitle.
  ///
  /// In ko, this message translates to:
  /// **'AI 모의 투자'**
  String get aiSimulatedTradeTitle;

  /// No description provided for @kimchiSimulatedTradeTitle.
  ///
  /// In ko, this message translates to:
  /// **'김프 모의 투자'**
  String get kimchiSimulatedTradeTitle;

  /// No description provided for @shareSimulationButton.
  ///
  /// In ko, this message translates to:
  /// **'공유하기'**
  String get shareSimulationButton;

  /// No description provided for @simulationCompoundInterestTitle.
  ///
  /// In ko, this message translates to:
  /// **'복리 계산'**
  String get simulationCompoundInterestTitle;

  /// No description provided for @simulationCompoundInterestHelpTooltip.
  ///
  /// In ko, this message translates to:
  /// **'복리 계산 설명'**
  String get simulationCompoundInterestHelpTooltip;

  /// No description provided for @simulationCompoundInterestHelpBody.
  ///
  /// In ko, this message translates to:
  /// **'켜면 매도 후 누적 금액으로 다시 매수합니다. 끄면 매수마다 초기 자본만 사용합니다.'**
  String get simulationCompoundInterestHelpBody;

  /// No description provided for @profitRate.
  ///
  /// In ko, this message translates to:
  /// **'수익률'**
  String get profitRate;

  /// No description provided for @evaluationAmount.
  ///
  /// In ko, this message translates to:
  /// **'평가금액'**
  String get evaluationAmount;

  /// No description provided for @fee.
  ///
  /// In ko, this message translates to:
  /// **'수수료'**
  String get fee;

  /// 업비트 수수료 적용 안내
  ///
  /// In ko, this message translates to:
  /// **'업비트 수수료 적용 (매수 {buyFee}%, 매도 {sellFee}%)'**
  String upbitFeeApplied(double buyFee, double sellFee);

  /// 수수료 금액 표시
  ///
  /// In ko, this message translates to:
  /// **'수수료: ₩{amount}'**
  String feeWithAmount(String amount);

  /// No description provided for @chartGranularityDaily.
  ///
  /// In ko, this message translates to:
  /// **'하루 단위'**
  String get chartGranularityDaily;

  /// No description provided for @chartGranularityHourly.
  ///
  /// In ko, this message translates to:
  /// **'시간 단위'**
  String get chartGranularityHourly;

  /// No description provided for @hourlyChartLoadFailed.
  ///
  /// In ko, this message translates to:
  /// **'시간봉 데이터를 불러오지 못했습니다.'**
  String get hourlyChartLoadFailed;

  /// No description provided for @hourlyGranularityIntroTitle.
  ///
  /// In ko, this message translates to:
  /// **'시간 단위 안내'**
  String get hourlyGranularityIntroTitle;

  /// No description provided for @hourlyGranularityIntroBody.
  ///
  /// In ko, this message translates to:
  /// **'시간 단위는 시간봉 기준으로 업비트 USDT와 원·달러 환율을 맞춰 김치 프리미엄 시뮬레이션을 실행합니다. 제공 구간은 최대 약 {maxDays}일로 제한되지만, 하루 단위보다 촘촘한 시점에서 가격을 맞추므로 일봉에서만 볼 때 생길 수 있는 시점·평균화에 따른 오차를 줄이는 데 도움이 됩니다. 기간은 짧아지지만 더 정밀한 해석이 필요할 때 활용해 보세요.'**
  String hourlyGranularityIntroBody(int maxDays);

  /// No description provided for @hourlyGranularityNewBadgeSemanticLabel.
  ///
  /// In ko, this message translates to:
  /// **'새 기능: 시간 단위 차트 안내'**
  String get hourlyGranularityNewBadgeSemanticLabel;

  /// No description provided for @kimchiFxBuyMaxLabel.
  ///
  /// In ko, this message translates to:
  /// **'매수 최대 환율(₩)'**
  String get kimchiFxBuyMaxLabel;

  /// No description provided for @kimchiFxBuyMaxHint.
  ///
  /// In ko, this message translates to:
  /// **'예: 2,000'**
  String get kimchiFxBuyMaxHint;

  /// No description provided for @kimchiFxSellMinLabel.
  ///
  /// In ko, this message translates to:
  /// **'매도 최저 환율(₩)'**
  String get kimchiFxSellMinLabel;

  /// No description provided for @kimchiFxSellMinHint.
  ///
  /// In ko, this message translates to:
  /// **'예: 0'**
  String get kimchiFxSellMinHint;

  /// No description provided for @kimchiFxRateLimitHelpTitle.
  ///
  /// In ko, this message translates to:
  /// **'설명'**
  String get kimchiFxRateLimitHelpTitle;

  /// No description provided for @kimchiFxRateLimitHelpTooltip.
  ///
  /// In ko, this message translates to:
  /// **'설명 보기'**
  String get kimchiFxRateLimitHelpTooltip;

  /// No description provided for @kimchiFxBuyMaxHelpBody.
  ///
  /// In ko, this message translates to:
  /// **'환율이 설정된 이상 보다 높을 경우 매수를 방지 해서 수익률을 개선합니다'**
  String get kimchiFxBuyMaxHelpBody;

  /// No description provided for @kimchiFxSellMinHelpBody.
  ///
  /// In ko, this message translates to:
  /// **'설정된 환율보다 낮을 경우 매도를 방지해서 수익률을 개선 할 수 있습니다'**
  String get kimchiFxSellMinHelpBody;

  /// No description provided for @kimchiBuyThresholdHelpBody.
  ///
  /// In ko, this message translates to:
  /// **'김치 프리미엄(한국 USDT가 달러 환율 대비 얼마나 비싼지)이 입력한 % 이하일 때 매수 신호를 검토합니다. 값을 낮추면 더 싸게 보일 때만 매수하려 하고, 높이면 상대적으로 더 일찍 매수하는 설정에 가깝습니다.'**
  String get kimchiBuyThresholdHelpBody;

  /// No description provided for @kimchiSellThresholdHelpBody.
  ///
  /// In ko, this message translates to:
  /// **'김치 프리미엄이 입력한 % 이상일 때 매도 신호를 검토합니다. 값을 높이면 프리미엄이 더 커졌을 때만 매도하려 하고, 낮추면 비교적 작은 프리미엄에서도 매도 후보가 됩니다.'**
  String get kimchiSellThresholdHelpBody;

  /// No description provided for @kimchiFxDeltaCorrectionLabel.
  ///
  /// In ko, this message translates to:
  /// **'환율별 김프 보정'**
  String get kimchiFxDeltaCorrectionLabel;

  /// No description provided for @kimchiFxDeltaMethodSubtitleQuintiles.
  ///
  /// In ko, this message translates to:
  /// **'구간표'**
  String get kimchiFxDeltaMethodSubtitleQuintiles;

  /// No description provided for @kimchiFxDeltaMethodSubtitleAffine.
  ///
  /// In ko, this message translates to:
  /// **'환율 비율식'**
  String get kimchiFxDeltaMethodSubtitleAffine;

  /// No description provided for @kimchiFxDeltaMethodSubtitleLoading.
  ///
  /// In ko, this message translates to:
  /// **'불러오는 중…'**
  String get kimchiFxDeltaMethodSubtitleLoading;

  /// No description provided for @kimchiFxDeltaCorrectionHelpBody.
  ///
  /// In ko, this message translates to:
  /// **'켜면 서버 `/api/kimchi-fx-delta`의 델타를 받아 김프 임계에 맞춥니다(JSON은 퀀타일 구간표 또는 환율 비율식 affine_fx_ratio). 보정 후 김프(%) ≈ 원시 김프 + 델타이며, 시뮬·차트 김프 매매선·오늘의 코멘트에 동일하게 적용됩니다.'**
  String get kimchiFxDeltaCorrectionHelpBody;

  /// No description provided for @kimchiFxDeltaTuningDetail.
  ///
  /// In ko, this message translates to:
  /// **'세부 설정'**
  String get kimchiFxDeltaTuningDetail;

  /// No description provided for @kimchiFxDeltaTuningTitle.
  ///
  /// In ko, this message translates to:
  /// **'김프 델타 보정 세부 설정'**
  String get kimchiFxDeltaTuningTitle;

  /// No description provided for @kimchiFxDeltaTuningUseOverride.
  ///
  /// In ko, this message translates to:
  /// **'앱에서 서버 값 덮어쓰기'**
  String get kimchiFxDeltaTuningUseOverride;

  /// No description provided for @kimchiFxDeltaTuningMethod.
  ///
  /// In ko, this message translates to:
  /// **'계산 방식'**
  String get kimchiFxDeltaTuningMethod;

  /// No description provided for @kimchiFxDeltaTuningMethodQuintiles.
  ///
  /// In ko, this message translates to:
  /// **'구간표 (equal_count_quintiles)'**
  String get kimchiFxDeltaTuningMethodQuintiles;

  /// No description provided for @kimchiFxDeltaTuningMethodAffine.
  ///
  /// In ko, this message translates to:
  /// **'환율 비율식 (affine_fx_ratio)'**
  String get kimchiFxDeltaTuningMethodAffine;

  /// No description provided for @kimchiFxDeltaTuningFxReference.
  ///
  /// In ko, this message translates to:
  /// **'기준 환율 (fx_reference)'**
  String get kimchiFxDeltaTuningFxReference;

  /// No description provided for @kimchiFxDeltaTuningKPerFxPercent.
  ///
  /// In ko, this message translates to:
  /// **'k_pp_per_fx_percent'**
  String get kimchiFxDeltaTuningKPerFxPercent;

  /// No description provided for @kimchiFxDeltaTuningBiasPp.
  ///
  /// In ko, this message translates to:
  /// **'bias_pp'**
  String get kimchiFxDeltaTuningBiasPp;

  /// No description provided for @kimchiFxDeltaTuningClampMin.
  ///
  /// In ko, this message translates to:
  /// **'clamp_min (비우면 없음)'**
  String get kimchiFxDeltaTuningClampMin;

  /// No description provided for @kimchiFxDeltaTuningClampMax.
  ///
  /// In ko, this message translates to:
  /// **'clamp_max (비우면 없음)'**
  String get kimchiFxDeltaTuningClampMax;

  /// No description provided for @kimchiFxDeltaTuningDeltaPp.
  ///
  /// In ko, this message translates to:
  /// **'Δ(pp)'**
  String get kimchiFxDeltaTuningDeltaPp;

  /// No description provided for @kimchiFxDeltaTuningApply.
  ///
  /// In ko, this message translates to:
  /// **'적용'**
  String get kimchiFxDeltaTuningApply;

  /// No description provided for @kimchiFxDeltaTuningReset.
  ///
  /// In ko, this message translates to:
  /// **'서버 기본만 사용'**
  String get kimchiFxDeltaTuningReset;

  /// No description provided for @kimchiFxDeltaTuningNoPayload.
  ///
  /// In ko, this message translates to:
  /// **'서버 델타 JSON을 불러오지 못했습니다. 네트워크 후 다시 시도하세요.'**
  String get kimchiFxDeltaTuningNoPayload;

  /// No description provided for @kimchiFxDeltaTuningSaved.
  ///
  /// In ko, this message translates to:
  /// **'저장했습니다.'**
  String get kimchiFxDeltaTuningSaved;

  /// No description provided for @kimchiFxDeltaTuningSaveFailed.
  ///
  /// In ko, this message translates to:
  /// **'저장에 실패했습니다.'**
  String get kimchiFxDeltaTuningSaveFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
