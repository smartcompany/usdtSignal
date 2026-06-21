import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:usdt_signal/api_service.dart';
import 'package:usdt_signal/kimchi_fx_delta_client_tuning.dart';
import 'package:usdt_signal/utils.dart';

/// `delta_add_pp = bias_pp + k * x + k_hi * max(0, x - x_onset)²`
/// where `x = ((fx / fx_reference) - 1) * 100` (percent from ref).
/// [highFxOnsetInclusive] 이상에서 2차항으로 Δ가 더 빠르게 커져 고환율 매도에 유리합니다.
class KimchiFxDeltaAffineRatio {
  KimchiFxDeltaAffineRatio({
    required this.fxReference,
    required this.biasPp,
    required this.kPpPerFxPercent,
    this.highFxOnsetInclusive,
    this.kHiPpPerFxPercentSquared = 0,
    this.clampMin,
    this.clampMax,
  });

  final double fxReference;
  final double biasPp;
  final double kPpPerFxPercent;
  /// 이 환율(₩) 이상에서 2차 가속. `null`이면 선형만.
  final double? highFxOnsetInclusive;
  /// `max(0, x - x_onset)²` 계수 (pp / %²).
  final double kHiPpPerFxPercentSquared;
  final double? clampMin;
  final double? clampMax;

  static KimchiFxDeltaAffineRatio? tryParse(Map<String, dynamic> m) {
    final type = m['type'] as String?;
    if (type != 'affine_ratio') return null;
    final ref = (m['fx_reference'] as num?)?.toDouble();
    if (ref == null || ref <= 0) return null;
    final k = (m['k_pp_per_fx_percent'] as num?)?.toDouble();
    if (k == null) return null;
    final bias = (m['bias_pp'] as num?)?.toDouble();
    if (bias == null) return null;
    final cmin = (m['clamp_min'] as num?)?.toDouble();
    final cmax = (m['clamp_max'] as num?)?.toDouble();
    final onset = (m['high_fx_onset_inclusive'] as num?)?.toDouble();
    final kHi = (m['k_hi_pp_per_fx_percent_squared'] as num?)?.toDouble() ?? 0;
    return KimchiFxDeltaAffineRatio(
      fxReference: ref,
      biasPp: bias,
      kPpPerFxPercent: k,
      highFxOnsetInclusive: onset != null && onset > 0 ? onset : null,
      kHiPpPerFxPercentSquared: kHi,
      clampMin: cmin,
      clampMax: cmax,
    );
  }

  double _fxPctFromRef(double fx) => (fx / fxReference - 1.0) * 100.0;

  double deltaForFx(double fx) {
    if (fx <= 0 || fxReference <= 0) return biasPp;
    final x = _fxPctFromRef(fx);
    var d = biasPp + kPpPerFxPercent * x;
    if (highFxOnsetInclusive != null &&
        kHiPpPerFxPercentSquared != 0 &&
        fx >= highFxOnsetInclusive!) {
      final xOnset = _fxPctFromRef(highFxOnsetInclusive!);
      final xHi = math.max(0.0, x - xOnset);
      d += kHiPpPerFxPercentSquared * xHi * xHi;
    }
    if (clampMin != null) d = math.max(d, clampMin!);
    if (clampMax != null) d = math.min(d, clampMax!);
    return d;
  }
}

/// 서버 `/api/kimchi-fx-delta` 페이로드. `prem_adj = prem_raw + delta_add_pp`.
///
/// JSON에는 [buckets]와 [delta_model]을 같이 둘 수 있고, [method]만 바꿔
/// `equal_count_quintiles`(구간표) ↔ `affine_fx_ratio`(비율식) 전환합니다.
class KimchiFxDeltaPayload {
  KimchiFxDeltaPayload({
    required this.buckets,
    this.formulaModel,
    this.method = 'equal_count_quintiles',
  });

  final List<KimchiFxDeltaBucket> buckets;
  final KimchiFxDeltaAffineRatio? formulaModel;
  final String method;

  static KimchiFxDeltaPayload? tryParse(Map<String, dynamic>? json) {
    if (json == null) return null;
    final method = json['method'] as String?;
    if (method != KimchiFxDeltaClientTuning.methodQuintiles &&
        method != KimchiFxDeltaClientTuning.methodAffine) {
      return null;
    }
    final resolvedMethod = method!;

    KimchiFxDeltaAffineRatio? formula;
    final dm = json['delta_model'];
    if (dm is Map<String, dynamic>) {
      formula = KimchiFxDeltaAffineRatio.tryParse(
        Map<String, dynamic>.from(dm),
      );
    }

    final list = _parseBuckets(json['buckets']);

    if (resolvedMethod == KimchiFxDeltaClientTuning.methodAffine) {
      if (formula == null) return null;
      return KimchiFxDeltaPayload(
        buckets: list,
        formulaModel: formula,
        method: resolvedMethod,
      );
    }

    if (list.isEmpty) return null;
    return KimchiFxDeltaPayload(
      buckets: list,
      formulaModel: formula,
      method: resolvedMethod,
    );
  }

  static List<KimchiFxDeltaBucket> _parseBuckets(dynamic raw) {
    if (raw is! List) return const [];
    final list = <KimchiFxDeltaBucket>[];
    for (final item in raw) {
      if (item is! Map<String, dynamic>) continue;
      final b = KimchiFxDeltaBucket.tryParse(Map<String, dynamic>.from(item));
      if (b != null) list.add(b);
    }
    list.sort((a, b) => a.order.compareTo(b.order));
    return list;
  }

  double deltaForFx(double fx) {
    if (method == 'affine_fx_ratio' && formulaModel != null) {
      return formulaModel!.deltaForFx(fx);
    }
    for (var i = 0; i < buckets.length; i++) {
      final b = buckets[i];
      if (b.contains(fx)) return b.deltaAddPp;
    }
    if (buckets.isEmpty) return 0;
    final first = buckets.first;
    final last = buckets.last;
    if (fx < first.fxMinInclusive) return first.deltaAddPp;
    if (fx > last.upperBoundInclusive) return last.deltaAddPp;
    return 0;
  }

  /// 서버 [base]에 클라이언트 [tuning]을 덮어씁니다(구간 FX 경계는 서버 그대로).
  static KimchiFxDeltaPayload mergeClientTuning(
    KimchiFxDeltaPayload base,
    KimchiFxDeltaClientTuning tuning,
  ) {
    if (tuning.method == KimchiFxDeltaClientTuning.methodAffine) {
      final f = tuning.toAffineRatio();
      return KimchiFxDeltaPayload(
        buckets: base.buckets,
        formulaModel: f,
        method: KimchiFxDeltaClientTuning.methodAffine,
      );
    }
    final out = <KimchiFxDeltaBucket>[];
    for (var i = 0; i < base.buckets.length; i++) {
      final b = base.buckets[i];
      final d =
          i < tuning.bucketDeltas.length
              ? tuning.bucketDeltas[i]
              : b.deltaAddPp;
      out.add(b.copyWith(deltaAddPp: d));
    }
    return KimchiFxDeltaPayload(
      buckets: out,
      formulaModel: base.formulaModel,
      method: KimchiFxDeltaClientTuning.methodQuintiles,
    );
  }
}

extension KimchiFxDeltaPayloadClientSnapshot on KimchiFxDeltaPayload {
  KimchiFxDeltaClientTuning? toClientTuningSnapshot() =>
      serverDefaultsForMethod(method);

  /// 서버 JSON 기준, [method]에 해당하는 필드만 서버 기본값으로 채웁니다.
  /// 서버에 필요한 필드가 없으면 `null`.
  KimchiFxDeltaClientTuning? serverDefaultsForMethod(String method) {
    if (method == KimchiFxDeltaClientTuning.methodAffine) {
      final f = formulaModel;
      if (f == null) return null;
      return KimchiFxDeltaClientTuning(
        method: KimchiFxDeltaClientTuning.methodAffine,
        affineFxReference: f.fxReference,
        affineBiasPp: f.biasPp,
        affineKPpPerFxPercent: f.kPpPerFxPercent,
        affineHighFxOnsetInclusive: f.highFxOnsetInclusive,
        affineKHiPpPerFxPercentSquared: f.kHiPpPerFxPercentSquared,
        affineClampMin: f.clampMin,
        affineClampMax: f.clampMax,
        bucketDeltas: buckets.map((e) => e.deltaAddPp).toList(),
      );
    }

    if (method != KimchiFxDeltaClientTuning.methodQuintiles || buckets.isEmpty) {
      return null;
    }

    final f = formulaModel;
    if (f == null) return null;

    return KimchiFxDeltaClientTuning(
      method: KimchiFxDeltaClientTuning.methodQuintiles,
      affineFxReference: f.fxReference,
      affineBiasPp: f.biasPp,
      affineKPpPerFxPercent: f.kPpPerFxPercent,
      affineHighFxOnsetInclusive: f.highFxOnsetInclusive,
      affineKHiPpPerFxPercentSquared: f.kHiPpPerFxPercentSquared,
      affineClampMin: f.clampMin,
      affineClampMax: f.clampMax,
      bucketDeltas: buckets.map((e) => e.deltaAddPp).toList(),
    );
  }
}

class KimchiFxDeltaBucket {
  KimchiFxDeltaBucket({
    required this.order,
    required this.fxMinInclusive,
    required this.fxMaxExclusive,
    required this.fxMaxInclusive,
    required this.deltaAddPp,
  });

  final int order;
  final double fxMinInclusive;
  final double? fxMaxExclusive;
  final double? fxMaxInclusive;
  final double deltaAddPp;

  double get upperBoundInclusive =>
      fxMaxInclusive ??
      (fxMaxExclusive != null ? fxMaxExclusive! - 1e-9 : fxMinInclusive);

  static KimchiFxDeltaBucket? tryParse(Map<String, dynamic> m) {
    final order = (m['order'] as num?)?.toInt() ?? 0;
    final min = (m['fx_min_inclusive'] as num?)?.toDouble();
    final dex = (m['fx_max_exclusive'] as num?)?.toDouble();
    final din = (m['fx_max_inclusive'] as num?)?.toDouble();
    final d = (m['delta_add_pp'] as num?)?.toDouble();
    if (min == null || d == null) return null;
    if (dex == null && din == null) return null;
    return KimchiFxDeltaBucket(
      order: order,
      fxMinInclusive: min,
      fxMaxExclusive: dex,
      fxMaxInclusive: din,
      deltaAddPp: d,
    );
  }

  bool contains(double fx) {
    if (fx < fxMinInclusive) return false;
    if (fxMaxExclusive != null) {
      return fx < fxMaxExclusive!;
    }
    if (fxMaxInclusive != null) {
      return fx <= fxMaxInclusive!;
    }
    return false;
  }

  KimchiFxDeltaBucket copyWith({double? deltaAddPp}) {
    return KimchiFxDeltaBucket(
      order: order,
      fxMinInclusive: fxMinInclusive,
      fxMaxExclusive: fxMaxExclusive,
      fxMaxInclusive: fxMaxInclusive,
      deltaAddPp: deltaAddPp ?? this.deltaAddPp,
    );
  }
}

/// 서버에서 한 번 받아 재사용. [ensureLoaded]는 idempotent.
class KimchiFxDeltaStore {
  KimchiFxDeltaStore._internal();
  static final KimchiFxDeltaStore instance = KimchiFxDeltaStore._internal();

  KimchiFxDeltaPayload? _payload;
  String? _loadError;
  Future<void>? _inflight;

  KimchiFxDeltaPayload? get payload => _payload;

  /// 네트워크 실패·JSON 파싱 실패 시 메시지. 성공 후에는 `null`.
  String? get loadError => _loadError;

  bool get hasPayload => _payload != null;

  /// 서버 JSON + (옵션) 클라이언트 덮어쓰기 반영본.
  KimchiFxDeltaPayload? get effectivePayload {
    final base = _payload;
    if (base == null) return null;
    final t = SimulationCondition.instance.kimchiFxDeltaClientTuning;
    if (t == null) return base;
    return KimchiFxDeltaPayload.mergeClientTuning(base, t);
  }

  void clearMemoryCache() {
    _payload = null;
    _loadError = null;
    _inflight = null;
  }

  Future<void> ensureLoaded(ApiService api) async {
    if (_payload != null) return;
    if (_inflight != null) {
      await _inflight;
      return;
    }
    _inflight = _load(api);
    try {
      await _inflight;
    } finally {
      _inflight = null;
    }
  }

  Future<void> _load(ApiService api) async {
    _loadError = null;
    try {
      final map = await api.fetchKimchiFxDeltaPayload();
      if (map == null) {
        _payload = null;
        _loadError = 'fetch_failed';
        return;
      }
      _payload = KimchiFxDeltaPayload.tryParse(map);
      if (_payload == null) {
        _loadError = 'parse_failed';
      }
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('KimchiFxDeltaStore load failed: $e');
      }
      _payload = null;
      _loadError = 'fetch_failed';
    }
  }

  /// 설정에서 꺼져 있으면 0. 켜져 있는데 payload 없으면 `null`.
  double? deltaForFxWhenEnabled(double fx) {
    if (!SimulationCondition.instance.kimchiFxDeltaCorrectionEnabled) {
      return 0;
    }
    return effectivePayload?.deltaForFx(fx);
  }

  double? deltaForFx(double fx) => effectivePayload?.deltaForFx(fx);
}
