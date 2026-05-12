import 'package:flutter/foundation.dart';
import 'package:usdt_signal/api_service.dart';
import 'package:usdt_signal/utils.dart';

/// 서버 `/api/kimchi-fx-delta` 페이로드. `prem_adj = prem_raw + delta_add_pp`.
class KimchiFxDeltaPayload {
  KimchiFxDeltaPayload({required this.buckets});

  final List<KimchiFxDeltaBucket> buckets;

  static KimchiFxDeltaPayload? tryParse(Map<String, dynamic>? json) {
    if (json == null) return null;
    final raw = json['buckets'];
    if (raw is! List) return null;
    final list = <KimchiFxDeltaBucket>[];
    for (final item in raw) {
      if (item is! Map<String, dynamic>) continue;
      final b = KimchiFxDeltaBucket.tryParse(Map<String, dynamic>.from(item));
      if (b != null) list.add(b);
    }
    list.sort((a, b) => a.order.compareTo(b.order));
    if (list.isEmpty) return null;
    return KimchiFxDeltaPayload(buckets: list);
  }

  double deltaForFx(double fx) {
    for (var i = 0; i < buckets.length; i++) {
      final b = buckets[i];
      if (b.contains(fx)) return b.deltaAddPp;
    }
    final first = buckets.first;
    final last = buckets.last;
    if (fx < first.fxMinInclusive) return first.deltaAddPp;
    if (fx > last.upperBoundInclusive) return last.deltaAddPp;
    return 0;
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
      fxMaxInclusive ?? (fxMaxExclusive != null ? fxMaxExclusive! - 1e-9 : fxMinInclusive);

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
}

/// 서버에서 한 번 받아 재사용. [ensureLoaded]는 idempotent.
class KimchiFxDeltaStore {
  KimchiFxDeltaStore._internal();
  static final KimchiFxDeltaStore instance = KimchiFxDeltaStore._internal();

  KimchiFxDeltaPayload? _payload;
  Future<void>? _inflight;

  KimchiFxDeltaPayload? get payload => _payload;

  void clearMemoryCache() {
    _payload = null;
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
    try {
      final map = await api.fetchKimchiFxDeltaPayload();
      _payload = KimchiFxDeltaPayload.tryParse(map);
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('KimchiFxDeltaStore load failed: $e');
      }
      _payload = null;
    }
  }

  /// 설정에서 꺼져 있으면 0.
  double deltaForFxWhenEnabled(double fx) {
    if (!SimulationCondition.instance.kimchiFxDeltaCorrectionEnabled) {
      return 0;
    }
    return deltaForFx(fx);
  }

  double deltaForFx(double fx) => _payload?.deltaForFx(fx) ?? 0;
}

