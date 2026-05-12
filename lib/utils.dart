import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:advertising_id/advertising_id.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:usdt_signal/l10n/app_localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'api_service.dart';

AppLocalizations l10n(BuildContext context) {
  return AppLocalizations.of(context)!;
}

// 사용자 ID 가져오기/생성 함수
Future<String> getOrCreateUserId() async {
  final prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('user_id');
  if (userId == null) {
    userId = const Uuid().v4();
    await prefs.setString('user_id', userId);
  }
  return userId;
}

double gimchiPremium(double usdtPrice, double exchangerate) {
  return ((usdtPrice - exchangerate) / exchangerate * 100);
}

// iOS 시뮬레이터 여부 확인 함수
Future<bool> isIOSSimulator() async {
  if (!Platform.isIOS) return false;
  final deviceInfo = DeviceInfoPlugin();
  final iosInfo = await deviceInfo.iosInfo;
  return !iosInfo.isPhysicalDevice;
}

// IDFA 출력 함수 (iOS 전용)
Future<void> printIDFA() async {
  if (!kDebugMode) return;

  if (!Platform.isIOS) {
    print('IDFA는 iOS에서만 지원됩니다.');
    return;
  }
  try {
    final idfa = await AdvertisingId.id(true);
    print('IDFA: $idfa');
  } catch (e) {
    print('IDFA 가져오기 실패: $e');
  }
}

extension DateTimeCustomString on DateTime {
  /// 문자열이 DateTime으로 변환 가능하면 yyyy/MM/dd 포맷으로 반환, 아니면 null 반환
  String toCustomString() {
    return DateFormat('yyyy/MM/dd').format(this);
  }

  /// 시뮬/차트 라벨: 시간 봉이면 년도 없이 `M/d HH:mm`, 일봉이면 [toCustomString]과 동일 계열.
  String toSimulationUiString(bool hourlyGranularity) {
    if (hourlyGranularity) {
      return DateFormat('M/d HH:mm').format(this);
    }
    return toCustomString();
  }

  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

enum AdsStatus { unload, load, shown }

enum TodayCommentAlarmType { off, ai, kimchi }

class SimulationCondition {
  SimulationCondition._internal();
  static final SimulationCondition instance = SimulationCondition._internal();

  double _kimchiBuyThreshold = 0;
  double get kimchiBuyThreshold => _kimchiBuyThreshold;
  double _kimchiSellThreshold = 1;
  double get kimchiSellThreshold => _kimchiSellThreshold;
  DateTime? _kimchiStartDate;
  DateTime? get kimchiStartDate => _kimchiStartDate;
  DateTime? _kimchiEndDate;
  DateTime? get kimchiEndDate => _kimchiEndDate;

  /// USD/KRW가 이 값 **이상**이면 김프 매수 안 함. `0`이면 제한 없음. 기본 2,000.
  static const double defaultKimchiFxBuyMax = 2000;
  double _kimchiFxBuyMax = defaultKimchiFxBuyMax;
  double get kimchiFxBuyMax => _kimchiFxBuyMax;

  /// USD/KRW가 이 값 **이하**이면 김프 매도 안 함. `0`이면 제한 없음.
  static const double defaultKimchiFxSellMin = 0;
  double _kimchiFxSellMin = defaultKimchiFxSellMin;
  double get kimchiFxSellMin => _kimchiFxSellMin;

  double _simulationInitialKrw = 1000000;
  double get simulationInitialKrw => _simulationInitialKrw;

  /// `true`: 매도 후 누적 금액으로 재매수(복리). `false`: 매수마다 초기 자본만 사용.
  bool _simulationCompoundInterest = true;
  bool get simulationCompoundInterest => _simulationCompoundInterest;

  /// `true`: USD/KRW 구간별 델타(`/api/kimchi-fx-delta`)로 김프 임계 매칭 보정.
  bool _kimchiFxDeltaCorrectionEnabled = false;
  bool get kimchiFxDeltaCorrectionEnabled => _kimchiFxDeltaCorrectionEnabled;

  void load() {
    SharedPreferences.getInstance().then((prefs) {
      instance._kimchiBuyThreshold =
          prefs.getDouble('kimchiBuyThreshold') ?? 0;
      instance._kimchiSellThreshold =
          prefs.getDouble('kimchiSellThreshold') ?? 1;
      final startDateRaw = prefs.getString('kimchiStartDate');
      final endDateRaw = prefs.getString('kimchiEndDate');
      instance._kimchiStartDate =
          startDateRaw != null ? DateTime.tryParse(startDateRaw) : null;
      instance._kimchiEndDate =
          endDateRaw != null ? DateTime.tryParse(endDateRaw) : null;
      instance._kimchiFxBuyMax =
          prefs.getDouble('kimchiFxBuyMax') ??
          prefs.getDouble('kimchiFxNoBuyAbove') ??
          defaultKimchiFxBuyMax;
      instance._kimchiFxSellMin =
          prefs.getDouble('kimchiFxSellMin') ?? defaultKimchiFxSellMin;
      instance._simulationInitialKrw = _readSimulationInitialKrwSync(prefs);
      instance._simulationCompoundInterest =
          _readSimulationCompoundInterestSync(prefs);
      instance._kimchiFxDeltaCorrectionEnabled =
          _readKimchiFxDeltaCorrectionSync(prefs);
    });
  }

  static bool _readKimchiFxDeltaCorrectionSync(SharedPreferences prefs) {
    if (prefs.containsKey('kimchiFxDeltaCorrection')) {
      return prefs.getBool('kimchiFxDeltaCorrection') ?? false;
    }
    final raw = prefs.getString('userData');
    if (raw != null) {
      try {
        final map = Map<String, dynamic>.from(jsonDecode(raw) as Map);
        final v = map['kimchiFxDeltaCorrection'];
        if (v is bool) return v;
        if (v is int) return v != 0;
      } catch (_) {}
    }
    return false;
  }

  static bool _readSimulationCompoundInterestSync(SharedPreferences prefs) {
    if (prefs.containsKey('simulationCompoundInterest')) {
      return prefs.getBool('simulationCompoundInterest') ?? true;
    }
    final raw = prefs.getString('userData');
    if (raw != null) {
      try {
        final map = Map<String, dynamic>.from(jsonDecode(raw) as Map);
        final v = map['simulationCompoundInterest'];
        if (v is bool) return v;
        if (v is int) return v != 0;
      } catch (_) {}
    }
    return true;
  }

  static double _readSimulationInitialKrwSync(SharedPreferences prefs) {
    final direct = prefs.getDouble('simulationInitialKrw');
    if (direct != null && direct >= 10000) {
      return direct;
    }
    final raw = prefs.getString('userData');
    if (raw != null) {
      try {
        final map = Map<String, dynamic>.from(jsonDecode(raw) as Map);
        final v = map['simulationInitialKrw'];
        if (v is num && v.toDouble() >= 10000) {
          return v.toDouble();
        }
      } catch (_) {}
    }
    return 1000000;
  }

  /// 모의 투자 초기 자본 (원). SharedPreferences + 서버 userData 동기화.
  Future<double> getInitialCapitalKrw() async {
    final prefs = await SharedPreferences.getInstance();
    _simulationInitialKrw = _readSimulationInitialKrwSync(prefs);
    _simulationCompoundInterest = _readSimulationCompoundInterestSync(prefs);
    _kimchiFxDeltaCorrectionEnabled = _readKimchiFxDeltaCorrectionSync(prefs);
    return _simulationInitialKrw;
  }

  Future<bool> saveSimulationCompoundInterest(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('simulationCompoundInterest', value);
    _simulationCompoundInterest = value;
    try {
      return await ApiService.shared.saveAndSyncUserData({
        UserDataKey.simulationCompoundInterest: value,
      });
    } catch (_) {
      return false;
    }
  }

  static const double _minInitialKrw = 10000;
  static const double _maxInitialKrw = 1000000000;

  Future<bool> saveSimulationInitialKrw(double value) async {
    final clamped = value.clamp(_minInitialKrw, _maxInitialKrw);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('simulationInitialKrw', clamped);
    _simulationInitialKrw = clamped;
    try {
      return await ApiService.shared.saveAndSyncUserData({
        UserDataKey.simulationInitialKrw: clamped,
      });
    } catch (_) {
      return false;
    }
  }

  Future<void> saveKimchiBuyThreshold(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('kimchiBuyThreshold', value);
    _kimchiBuyThreshold = value;
  }

  Future<void> saveKimchiSellThreshold(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('kimchiSellThreshold', value);
    _kimchiSellThreshold = value;
  }

  Future<void> saveKimchiStartDate(DateTime? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove('kimchiStartDate');
    } else {
      await prefs.setString('kimchiStartDate', value.toIso8601String());
    }
    _kimchiStartDate = value;
  }

  Future<void> saveKimchiEndDate(DateTime? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove('kimchiEndDate');
    } else {
      await prefs.setString('kimchiEndDate', value.toIso8601String());
    }
    _kimchiEndDate = value;
  }

  Future<void> saveKimchiDateRange({
    required DateTime? startDate,
    required DateTime? endDate,
  }) async {
    await saveKimchiStartDate(startDate);
    await saveKimchiEndDate(endDate);
  }

  static const double _minKimchiFxBuyMax = 0;
  static const double _maxKimchiFxBuyMax = 999999;

  Future<void> saveKimchiFxBuyMax(double value) async {
    final v = value.clamp(_minKimchiFxBuyMax, _maxKimchiFxBuyMax);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('kimchiFxBuyMax', v);
    _kimchiFxBuyMax = v;
  }

  Future<void> saveKimchiFxSellMin(double value) async {
    final v = value.clamp(_minKimchiFxBuyMax, _maxKimchiFxBuyMax);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('kimchiFxSellMin', v);
    _kimchiFxSellMin = v;
  }

  Future<void> putKimchiFxDeltaCorrectionPrefs(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('kimchiFxDeltaCorrection', value);
    _kimchiFxDeltaCorrectionEnabled = value;
  }

  Future<String?> _getFcmToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      return null;
    }
  }
}

extension TodayCommentAlarmTypePrefs on TodayCommentAlarmType {
  static const _prefsKey = 'todayCommentAlarmType';

  /// SharedPreferences에서 값을 읽어 TodayCommentAlarmType으로 반환
  static Future<TodayCommentAlarmType> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    if (saved != null) {
      return TodayCommentAlarmType.values.firstWhere(
        (e) => e.name == saved,
        orElse: () => TodayCommentAlarmType.off,
      );
    }
    return TodayCommentAlarmType.off;
  }

  /// SharedPreferences에 값 저장
  Future<void> saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, name);
  }
}

const String _prefsHourlyGranularityIntroSeen = 'hourlyGranularityIntroSeen';

/// 시간 단위 차트 안내를 확인했는지 (UserDefaults / SharedPreferences).
Future<bool> loadHourlyGranularityIntroSeen() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_prefsHourlyGranularityIntroSeen) ?? false;
}

Future<void> saveHourlyGranularityIntroSeen(bool seen) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_prefsHourlyGranularityIntroSeen, seen);
}

// List<T>에 대해 안전하게 마지막 원소를 반환하는 extension
extension SafeList<T> on List<T> {
  T? get safeLast => isNotEmpty ? last : null;
}
