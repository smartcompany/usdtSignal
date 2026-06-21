import 'dart:convert';

import 'package:usdt_signal/kimchi_fx_delta.dart';

/// 클라이언트가 저장하는 김프 델타 보정 덮어쓰기(JSON 직렬화).
class KimchiFxDeltaClientTuning {
  KimchiFxDeltaClientTuning({
    required this.method,
    required this.affineFxReference,
    required this.affineBiasPp,
    required this.affineKPpPerFxPercent,
    this.affineHighFxOnsetInclusive,
    this.affineKHiPpPerFxPercentSquared = 0,
    this.affineClampMin,
    this.affineClampMax,
    required this.bucketDeltas,
  });

  static const String methodQuintiles = 'equal_count_quintiles';
  static const String methodAffine = 'affine_fx_ratio';

  final String method;
  final double affineFxReference;
  final double affineBiasPp;
  final double affineKPpPerFxPercent;
  final double? affineHighFxOnsetInclusive;
  final double affineKHiPpPerFxPercentSquared;
  final double? affineClampMin;
  final double? affineClampMax;
  final List<double> bucketDeltas;

  KimchiFxDeltaAffineRatio toAffineRatio() => KimchiFxDeltaAffineRatio(
    fxReference: affineFxReference,
    biasPp: affineBiasPp,
    kPpPerFxPercent: affineKPpPerFxPercent,
    highFxOnsetInclusive: affineHighFxOnsetInclusive,
    kHiPpPerFxPercentSquared: affineKHiPpPerFxPercentSquared,
    clampMin: affineClampMin,
    clampMax: affineClampMax,
  );

  Map<String, dynamic> toJson() => {
    'method': method,
    'affine': {
      'fx_reference': affineFxReference,
      'bias_pp': affineBiasPp,
      'k_pp_per_fx_percent': affineKPpPerFxPercent,
      if (affineHighFxOnsetInclusive != null)
        'high_fx_onset_inclusive': affineHighFxOnsetInclusive,
      if (affineKHiPpPerFxPercentSquared != 0)
        'k_hi_pp_per_fx_percent_squared': affineKHiPpPerFxPercentSquared,
      if (affineClampMin != null) 'clamp_min': affineClampMin,
      if (affineClampMax != null) 'clamp_max': affineClampMax,
    },
    'bucket_deltas': bucketDeltas,
  };

  String encode() => jsonEncode(toJson());

  static KimchiFxDeltaClientTuning? tryDecode(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return tryParse(m);
    } catch (_) {
      return null;
    }
  }

  static KimchiFxDeltaClientTuning? tryParse(Map<String, dynamic> m) {
    final method = m['method'] as String?;
    if (method == null ||
        (method != methodQuintiles && method != methodAffine)) {
      return null;
    }
    final aff = m['affine'];
    if (aff is! Map<String, dynamic>) return null;

    final ref = (aff['fx_reference'] as num?)?.toDouble();
    final k = (aff['k_pp_per_fx_percent'] as num?)?.toDouble();
    if (ref == null || ref <= 0 || k == null) return null;

    final bias = (aff['bias_pp'] as num?)?.toDouble();
    if (bias == null) return null;

    final onset = (aff['high_fx_onset_inclusive'] as num?)?.toDouble();
    final kHi =
        (aff['k_hi_pp_per_fx_percent_squared'] as num?)?.toDouble() ?? 0;
    final cmin = (aff['clamp_min'] as num?)?.toDouble();
    final cmax = (aff['clamp_max'] as num?)?.toDouble();

    final bdRaw = m['bucket_deltas'];
    final bd = <double>[];
    if (bdRaw is List) {
      for (final e in bdRaw) {
        if (e is num) bd.add(e.toDouble());
      }
    }

    return KimchiFxDeltaClientTuning(
      method: method,
      affineFxReference: ref,
      affineBiasPp: bias,
      affineKPpPerFxPercent: k,
      affineHighFxOnsetInclusive:
          onset != null && onset > 0 ? onset : null,
      affineKHiPpPerFxPercentSquared: kHi,
      affineClampMin: cmin,
      affineClampMax: cmax,
      bucketDeltas: bd,
    );
  }
}
