import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:usdt_signal/api_service.dart';
import 'package:usdt_signal/dialogs/liquid_glass_dialog.dart';
import 'package:usdt_signal/kimchi_fx_delta.dart';
import 'package:usdt_signal/kimchi_fx_delta_affine_preview_chart.dart';
import 'package:usdt_signal/kimchi_fx_delta_client_tuning.dart';
import 'package:usdt_signal/l10n/app_localizations.dart';
import 'package:usdt_signal/utils.dart';

String _fmtFxRange(KimchiFxDeltaBucket b, NumberFormat nf) {
  final lo = nf.format(b.fxMinInclusive);
  if (b.fxMaxExclusive != null) {
    return '[$lo, ${nf.format(b.fxMaxExclusive!)})';
  }
  if (b.fxMaxInclusive != null) {
    return '[$lo, ${nf.format(b.fxMaxInclusive!)}]';
  }
  return lo;
}

/// 다이얼로그가 [적용]으로 닫히면 `true`.
Future<bool?> openKimchiFxDeltaClientTuningDialog(BuildContext context) async {
  await KimchiFxDeltaStore.instance.ensureLoaded(ApiService.shared);
  if (!context.mounted) return null;
  final loc = AppLocalizations.of(context)!;
  final store = KimchiFxDeltaStore.instance;
  final base = store.payload;
  if (base == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          store.loadError == 'parse_failed'
              ? loc.kimchiFxDeltaPayloadInvalid
              : loc.kimchiFxDeltaTuningNoPayload,
        ),
      ),
    );
    return null;
  }

  final saved = SimulationCondition.instance.kimchiFxDeltaClientTuning;
  final initialTuning = saved ?? base.toClientTuningSnapshot();
  if (initialTuning == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.kimchiFxDeltaPayloadInvalid)),
    );
    return null;
  }

  if (!context.mounted) return null;
  return showDialog<bool>(
    context: context,
    builder:
        (ctx) => _KimchiFxDeltaTuningDialog(
          basePayload: base,
          initialTuning: initialTuning,
        ),
  );
}

class _KimchiFxDeltaTuningDialog extends StatefulWidget {
  const _KimchiFxDeltaTuningDialog({
    required this.basePayload,
    required this.initialTuning,
  });

  final KimchiFxDeltaPayload basePayload;
  final KimchiFxDeltaClientTuning initialTuning;

  @override
  State<_KimchiFxDeltaTuningDialog> createState() =>
      _KimchiFxDeltaTuningDialogState();
}

class _KimchiFxDeltaTuningDialogState
    extends State<_KimchiFxDeltaTuningDialog> {
  late String _method;
  late final TextEditingController _fxRef;
  late final TextEditingController _kPp;
  late final TextEditingController _bias;
  late final TextEditingController _clampMin;
  late final TextEditingController _clampMax;
  late final TextEditingController _highFxOnset;
  late final TextEditingController _kHi;
  late final List<TextEditingController> _bucketCtrls;
  final List<VoidCallback> _affineFieldListeners = [];

  @override
  void initState() {
    super.initState();
    _applyTuningToForm(widget.initialTuning);
    _attachAffineFieldListeners();
  }

  void _attachAffineFieldListeners() {
    for (final c in [
      _fxRef,
      _kPp,
      _bias,
      _clampMin,
      _clampMax,
      _highFxOnset,
      _kHi,
    ]) {
      void listener() {
        if (_method == KimchiFxDeltaClientTuning.methodAffine && mounted) {
          setState(() {});
        }
      }
      _affineFieldListeners.add(listener);
      c.addListener(listener);
    }
  }

  void _applyTuningToForm(KimchiFxDeltaClientTuning t) {
    _method = t.method;
    if (_method != KimchiFxDeltaClientTuning.methodQuintiles &&
        _method != KimchiFxDeltaClientTuning.methodAffine) {
      _method = widget.basePayload.method;
    }
    if (_method != KimchiFxDeltaClientTuning.methodQuintiles &&
        _method != KimchiFxDeltaClientTuning.methodAffine) {
      _method = KimchiFxDeltaClientTuning.methodQuintiles;
    }
    _fxRef = TextEditingController(text: t.affineFxReference.toString());
    _kPp = TextEditingController(text: t.affineKPpPerFxPercent.toString());
    _bias = TextEditingController(text: t.affineBiasPp.toString());
    _clampMin = TextEditingController(text: t.affineClampMin?.toString() ?? '');
    _clampMax = TextEditingController(text: t.affineClampMax?.toString() ?? '');
    _highFxOnset = TextEditingController(
      text: t.affineHighFxOnsetInclusive?.toString() ?? '',
    );
    _kHi = TextEditingController(
      text: t.affineKHiPpPerFxPercentSquared.toString(),
    );
    final n = widget.basePayload.buckets.length;
    _bucketCtrls = List.generate(n, (i) {
      final v =
          i < t.bucketDeltas.length
              ? t.bucketDeltas[i]
              : widget.basePayload.buckets[i].deltaAddPp;
      return TextEditingController(text: v.toString());
    });
  }

  @override
  void dispose() {
    var i = 0;
    for (final c in [
      _fxRef,
      _kPp,
      _bias,
      _clampMin,
      _clampMax,
      _highFxOnset,
      _kHi,
    ]) {
      c.removeListener(_affineFieldListeners[i]);
      i++;
    }
    _fxRef.dispose();
    _kPp.dispose();
    _bias.dispose();
    _clampMin.dispose();
    _clampMax.dispose();
    _highFxOnset.dispose();
    _kHi.dispose();
    for (final c in _bucketCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  double? _parseRequiredD(String s) {
    final t = s.trim().replaceAll(',', '');
    return double.tryParse(t);
  }

  double? _parseOpt(String s) {
    final t = s.trim().replaceAll(',', '');
    if (t.isEmpty) return null;
    return double.tryParse(t);
  }

  KimchiFxDeltaAffineRatio? _affineModelFromForm() {
    final tuning = _affineTuningFromFormFields();
    return tuning?.toAffineRatio();
  }

  KimchiFxDeltaClientTuning? _affineTuningFromFormFields() {
    final fxRef = _parseRequiredD(_fxRef.text);
    final k = _parseRequiredD(_kPp.text);
    final bias = _parseRequiredD(_bias.text);
    if (fxRef == null || fxRef <= 0 || k == null || bias == null) {
      return null;
    }
    final kHi = _parseRequiredD(_kHi.text) ?? 0;
    final onset = _parseOpt(_highFxOnset.text);
    return KimchiFxDeltaClientTuning(
      method: KimchiFxDeltaClientTuning.methodAffine,
      affineFxReference: fxRef.clamp(1.0, 1e7),
      affineBiasPp: bias,
      affineKPpPerFxPercent: k,
      affineHighFxOnsetInclusive: onset != null && onset > 0 ? onset : null,
      affineKHiPpPerFxPercentSquared: kHi,
      affineClampMin: _parseOpt(_clampMin.text),
      affineClampMax: _parseOpt(_clampMax.text),
      bucketDeltas: widget.basePayload.buckets.map((e) => e.deltaAddPp).toList(),
    );
  }

  KimchiFxDeltaClientTuning? _buildTuningFromForm() {
    final bd = <double>[];
    for (var i = 0; i < _bucketCtrls.length; i++) {
      final parsed = _parseRequiredD(_bucketCtrls[i].text);
      if (parsed == null) return null;
      bd.add(parsed);
    }
    if (_method == KimchiFxDeltaClientTuning.methodAffine) {
      final affine = _affineTuningFromFormFields();
      if (affine == null) return null;
      return KimchiFxDeltaClientTuning(
        method: _method,
        affineFxReference: affine.affineFxReference,
        affineBiasPp: affine.affineBiasPp,
        affineKPpPerFxPercent: affine.affineKPpPerFxPercent,
        affineHighFxOnsetInclusive: affine.affineHighFxOnsetInclusive,
        affineKHiPpPerFxPercentSquared: affine.affineKHiPpPerFxPercentSquared,
        affineClampMin: affine.affineClampMin,
        affineClampMax: affine.affineClampMax,
        bucketDeltas: bd,
      );
    }
    final serverSnap =
        widget.basePayload.serverDefaultsForMethod(
          KimchiFxDeltaClientTuning.methodQuintiles,
        );
    if (serverSnap == null) return null;
    return KimchiFxDeltaClientTuning(
      method: _method,
      affineFxReference: serverSnap.affineFxReference,
      affineBiasPp: serverSnap.affineBiasPp,
      affineKPpPerFxPercent: serverSnap.affineKPpPerFxPercent,
      affineHighFxOnsetInclusive: serverSnap.affineHighFxOnsetInclusive,
      affineKHiPpPerFxPercentSquared: serverSnap.affineKHiPpPerFxPercentSquared,
      affineClampMin: serverSnap.affineClampMin,
      affineClampMax: serverSnap.affineClampMax,
      bucketDeltas: bd,
    );
  }

  void _fillFormFromTuning(KimchiFxDeltaClientTuning t) {
    _method = t.method;
    _fxRef.text = t.affineFxReference.toString();
    _kPp.text = t.affineKPpPerFxPercent.toString();
    _bias.text = t.affineBiasPp.toString();
    _clampMin.text = t.affineClampMin?.toString() ?? '';
    _clampMax.text = t.affineClampMax?.toString() ?? '';
    _highFxOnset.text = t.affineHighFxOnsetInclusive?.toString() ?? '';
    _kHi.text = t.affineKHiPpPerFxPercentSquared.toString();
    for (var i = 0; i < _bucketCtrls.length; i++) {
      final v =
          i < t.bucketDeltas.length
              ? t.bucketDeltas[i]
              : widget.basePayload.buckets[i].deltaAddPp;
      _bucketCtrls[i].text = v.toString();
    }
  }

  void _resetCurrentMethodToServerDefaults() {
    final loc = AppLocalizations.of(context)!;
    final snap = widget.basePayload.serverDefaultsForMethod(_method);
    if (snap == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.kimchiFxDeltaPayloadInvalid)),
      );
      return;
    }
    setState(() => _fillFormFromTuning(snap));
  }

  Future<void> _saveAndClose() async {
    final tuning = _buildTuningFromForm();
    final loc = AppLocalizations.of(context)!;
    if (tuning == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.kimchiFxDeltaTuningInvalidFields)),
      );
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    final ok = await SimulationCondition.instance.saveKimchiFxDeltaClientTuning(
      tuning,
    );
    if (!mounted) return;
    Navigator.of(context).pop(true);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          ok ? loc.kimchiFxDeltaTuningSaved : loc.kimchiFxDeltaTuningSaveFailed,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final nf = NumberFormat('#,##0.##', localeTag);
    final base = widget.basePayload;

    return LiquidGlassDialog(
      title: Text(loc.kimchiFxDeltaTuningTitle),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(loc.kimchiFxDeltaTuningMethod),
              const SizedBox(height: 4),
              DropdownButton<String>(
                isExpanded: true,
                value: _method,
                items: [
                  DropdownMenuItem(
                    value: KimchiFxDeltaClientTuning.methodQuintiles,
                    child: Text(
                      loc.kimchiFxDeltaTuningMethodQuintiles,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DropdownMenuItem(
                    value: KimchiFxDeltaClientTuning.methodAffine,
                    child: Text(
                      loc.kimchiFxDeltaTuningMethodAffine,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                onChanged: (v) {
                  if (v == null) return;
                  if (v == KimchiFxDeltaClientTuning.methodAffine &&
                      widget.basePayload.formulaModel == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(loc.kimchiFxDeltaPayloadInvalid)),
                    );
                    return;
                  }
                  setState(() => _method = v);
                },
              ),
              const SizedBox(height: 16),
              if (_method == KimchiFxDeltaClientTuning.methodAffine) ...[
                Text(loc.kimchiFxDeltaTuningFxReference),
                TextField(
                  controller: _fxRef,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                Text(loc.kimchiFxDeltaTuningKPerFxPercent),
                TextField(
                  controller: _kPp,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                Text(loc.kimchiFxDeltaTuningBiasPp),
                TextField(
                  controller: _bias,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                Text(loc.kimchiFxDeltaTuningHighFxOnset),
                TextField(
                  controller: _highFxOnset,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    isDense: true,
                    hintText: loc.kimchiFxDeltaTuningHighFxOnsetHint,
                  ),
                ),
                const SizedBox(height: 12),
                Text(loc.kimchiFxDeltaTuningKHiFx2),
                TextField(
                  controller: _kHi,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    isDense: true,
                    hintText: loc.kimchiFxDeltaTuningKHiFx2Hint,
                  ),
                ),
                const SizedBox(height: 12),
                Text(loc.kimchiFxDeltaTuningClampMin),
                TextField(
                  controller: _clampMin,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                Text(loc.kimchiFxDeltaTuningClampMax),
                TextField(
                  controller: _clampMax,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                if (_affineModelFromForm() case final model?)
                  KimchiFxDeltaAffinePreviewChart(model: model),
              ] else ...[
                if (base.buckets.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      loc.kimchiFxDeltaTuningNoPayload,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  )
                else
                  for (var i = 0; i < base.buckets.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              '${base.buckets[i].order}: ${_fmtFxRange(base.buckets[i], nf)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: _bucketCtrls[i],
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                    signed: true,
                                  ),
                              decoration: InputDecoration(
                                labelText: loc.kimchiFxDeltaTuningDeltaPp,
                                border: const OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(loc.cancel),
        ),
        TextButton(
          onPressed: _resetCurrentMethodToServerDefaults,
          child: Text(loc.kimchiFxDeltaTuningReset),
        ),
        FilledButton(
          onPressed: _saveAndClose,
          child: Text(loc.kimchiFxDeltaTuningApply),
        ),
      ],
    );
  }
}
