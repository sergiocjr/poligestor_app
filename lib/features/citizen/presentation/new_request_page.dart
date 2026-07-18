import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../shared/widgets/ui_kit.dart';
import '../../protocols/data/protocol_models.dart';
import '../../protocols/data/protocols_repository.dart';

class NewRequestPage extends StatefulWidget {
  const NewRequestPage({super.key, this.initialCategory});

  final String? initialCategory;

  @override
  State<NewRequestPage> createState() => _NewRequestPageState();
}

class _NewRequestPageState extends State<NewRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _subjectCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String? _category;
  bool _busy = false;
  bool _locBusy = false;
  String? _error;
  double? _lat;
  double? _lng;
  String? _locLabel;

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory;
    if (_category == 'ajuda') _subjectCtrl.text = 'Solicitação de ajuda';
    if (_category == 'denuncia') _subjectCtrl.text = 'Denúncia';
    if (_category == 'sugestao') _subjectCtrl.text = 'Sugestão';
    if (_category == 'atendimento') _subjectCtrl.text = 'Agendamento de atendimento';
    if (_category == 'documento') _subjectCtrl.text = 'Envio de documento';
  }

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _captureLocation() async {
    setState(() {
      _locBusy = true;
      _error = null;
    });
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        throw ApiException(message: 'Ative a localização do dispositivo.');
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw ApiException(message: 'Permissão de localização negada.');
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      setState(() {
        _lat = pos.latitude;
        _lng = pos.longitude;
        _locLabel =
            'Lat ${pos.latitude.toStringAsFixed(5)}, Lng ${pos.longitude.toStringAsFixed(5)}';
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Não foi possível obter a localização: $e');
    } finally {
      setState(() => _locBusy = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final auth = context.read<AuthController>();
    final repo = context.read<ProtocolsRepository>();
    try {
      final created = await repo.create(
        mode: auth.mode,
        input: CreateProtocolInput(
          subject: _subjectCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          category: _category,
          latitude: _lat,
          longitude: _lng,
          locationLabel: _locLabel,
        ),
      );
      if (!mounted) return;
      context.pushReplacement('/citizen/requests/${created.id}');
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Nova solicitação')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (auth.apiDegraded) ...[
            const ApiDegradedBanner(),
            const SizedBox(height: 12),
          ],
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  // ignore: deprecated_member_use
                  value: _category,
                  decoration: const InputDecoration(labelText: 'Tipo'),
                  items: RequestCategory.all
                      .where((c) => c.id != 'acompanhar')
                      .map(
                        (c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.label),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _category = v),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _subjectCtrl,
                  decoration: const InputDecoration(labelText: 'Assunto'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Informe o assunto' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descCtrl,
                  minLines: 4,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    alignLabelWithHint: true,
                  ),
                  validator: (v) => (v == null || v.trim().length < 10)
                      ? 'Descreva com mais detalhes'
                      : null,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _locBusy ? null : _captureLocation,
                  icon: _locBusy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location),
                  label: Text(_locLabel == null
                      ? 'Enviar localização'
                      : 'Localização: $_locLabel'),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error)),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _busy ? null : _submit,
                  child: _busy
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Enviar solicitação'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
