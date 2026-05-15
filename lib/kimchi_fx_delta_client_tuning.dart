import 'dart:convert';

/// 클라이언트가 저장하는 김프 델타 보정 덮어쓰기(JSON 직렬화).
class KimchiFxDeltaClientTuning {
  KimchiFxDeltaClientTuning({
    required this.method,
    required this.affineFxReference,
    required this.affineBiasPp,
    required this.affineKPpPerFxPercent,
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
  final double? affineClampMin;
  final double? affineClampMax;
  final List<double> bucketDeltas;

  Map<String, dynamic> toJson() => {
    'method': method,
    'affine': {
      'fx_reference': affineFxReference,
      'bias_pp': affineBiasPp,
      'k_pp_per_fx_percent': affineKPpPerFxPercent,
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
    double ref = 1450;
    double bias = 0;
    double k = 0;
    double? cmin;
    double? cmax;
    if (aff is Map<String, dynamic>) {
      ref = (aff['fx_reference'] as num?)?.toDouble() ?? ref;
      bias = (aff['bias_pp'] as num?)?.toDouble() ?? 0;
      k = (aff['k_pp_per_fx_percent'] as num?)?.toDouble() ?? 0;
      cmin = (aff['clamp_min'] as num?)?.toDouble();
      cmax = (aff['clamp_max'] as num?)?.toDouble();
    }
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
      affineClampMin: cmin,
      affineClampMax: cmax,
      bucketDeltas: bd,
    );
  }
}
