import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:usdt_signal/api_service.dart';
import 'package:usdt_signal/dialogs/liquid_glass_dialog.dart';
import 'package:usdt_signal/kimchi_fx_delta.dart';
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

Future<void> openKimchiFxDeltaClientTuningDialog(BuildContext context) async {
  await KimchiFxDeltaStore.instance.ensureLoaded(ApiService.shared);
  if (!context.mounted) return;
  final base = KimchiFxDeltaStore.instance.payload;
  final loc = AppLocalizations.of(context)!;
  if (base == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.kimchiFxDeltaTuningNoPayload)),
    );
    return;
  }

  final useOverride =
      SimulationCondition.instance.kimchiFxDeltaClientOverrideEnabled;
  final saved = SimulationCondition.instance.kimchiFxDeltaClientTuning;
  final initialTuning =
      useOverride && saved != null ? saved : base.toClientTuningSnapshot();

  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder:
        (ctx) => _KimchiFxDeltaTuningDialog(
          basePayload: base,
          initialTuning: initialTuning,
          initialOverride: useOverride,
        ),
  );
}

class _KimchiFxDeltaTuningDialog extends StatefulWidget {
  const _KimchiFxDeltaTuningDialog({
    required this.basePayload,
    required this.initialTuning,
    required this.initialOverride,
  });

  final KimchiFxDeltaPayload basePayload;
  final KimchiFxDeltaClientTuning initialTuning;
  final bool initialOverride;

  @override
  State<_KimchiFxDeltaTuningDialog> createState() =>
      _KimchiFxDeltaTuningDialogState();
}

class _KimchiFxDeltaTuningDialogState extends State<_KimchiFxDeltaTuningDialog> {
  late bool _useOverride;
  late String _method;
  late final TextEditingController _fxRef;
  late final TextEditingController _kPp;
  late final TextEditingController _bias;
  late final TextEditingController _clampMin;
  late final TextEditingController _clampMax;
  late final List<TextEditingController> _bucketCtrls;

  @override
  void initState() {
    super.initState();
    final t = widget.initialTuning;
    _useOverride = widget.initialOverride;
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
    _clampMin = TextEditingController(
      text: t.affineClampMin?.toString() ?? '',
    );
    _clampMax = TextEditingController(
      text: t.affineClampMax?.toString() ?? '',
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
    _fxRef.dispose();
    _kPp.dispose();
    _bias.dispose();
    _clampMin.dispose();
    _clampMax.dispose();
    for (final c in _bucketCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  double _parseD(String s, double fallback) {
    final t = s.trim().replaceAll(',', '');
    return double.tryParse(t) ?? fallback;
  }

  double? _parseOpt(String s) {
    final t = s.trim().replaceAll(',', '');
    if (t.isEmpty) return null;
    return double.tryParse(t);
  }

  KimchiFxDeltaClientTuning _buildTuningFromForm() {
    final bd = <double>[];
    for (var i = 0; i < _bucketCtrls.length; i++) {
      bd.add(
        _parseD(
          _bucketCtrls[i].text,
          widget.basePayload.buckets[i].deltaAddPp,
        ),
      );
    }
    return KimchiFxDeltaClientTuning(
      method: _method,
      affineFxReference: _parseD(_fxRef.text, 1450).clamp(1.0, 1e7),
      affineBiasPp: _parseD(_bias.text, 0),
      affineKPpPerFxPercent: _parseD(_kPp.text, 0),
      affineClampMin: _parseOpt(_clampMin.text),
      affineClampMax: _parseOpt(_clampMax.text),
      bucketDeltas: bd,
    );
  }

  Future<void> _saveAndClose() async {
    final tuning = _buildTuningFromForm();
    final loc = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final ok = await SimulationCondition.instance.saveKimchiFxDeltaClientTuning(
      overrideEnabled: _useOverride,
      tuning: tuning,
    );
    if (!mounted) return;
    Navigator.of(context).pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          ok ? loc.kimchiFxDeltaTuningSaved : loc.kimchiFxDeltaTuningSaveFailed,
        ),
      ),
    );
  }

  Future<void> _resetToServer() async {
    final snap = widget.basePayload.toClientTuningSnapshot();
    final loc = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final ok = await SimulationCondition.instance.saveKimchiFxDeltaClientTuning(
      overrideEnabled: false,
      tuning: snap,
    );
    if (!mounted) return;
    Navigator.of(context).pop();
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
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(loc.kimchiFxDeltaTuningUseOverride),
                value: _useOverride,
                onChanged: (v) => setState(() => _useOverride = v),
              ),
              const SizedBox(height: 8),
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
                  if (v != null) setState(() => _method = v);
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
                ),
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
                              keyboardType: const TextInputType.numberWithOptions(
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
          onPressed: _resetToServer,
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
