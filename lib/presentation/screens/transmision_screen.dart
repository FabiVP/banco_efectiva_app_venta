import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../data/models/solicitud_model.dart';
import '../viewmodels/ventas_viewmodel.dart';

enum PasoTransmision { serializar, comprimir, enviar, confirmar }

class _EstadoTransmision {
  final String solicitudId;
  final String clienteNombre;
  final PasoTransmision pasoActual;
  final double progreso;
  final bool completado;
  final bool error;

  const _EstadoTransmision({
    required this.solicitudId,
    required this.clienteNombre,
    this.pasoActual = PasoTransmision.serializar,
    this.progreso = 0,
    this.completado = false,
    this.error = false,
  });

  _EstadoTransmision copyWith({
    PasoTransmision? pasoActual,
    double? progreso,
    bool? completado,
    bool? error,
  }) {
    return _EstadoTransmision(
      solicitudId: solicitudId,
      clienteNombre: clienteNombre,
      pasoActual: pasoActual ?? this.pasoActual,
      progreso: progreso ?? this.progreso,
      completado: completado ?? this.completado,
      error: error ?? this.error,
    );
  }
}

class TransmisionScreen extends StatefulWidget {
  const TransmisionScreen({super.key});

  @override
  State<TransmisionScreen> createState() => _TransmisionScreenState();
}

class _TransmisionScreenState extends State<TransmisionScreen> {
  List<_EstadoTransmision> _estados = [];
  bool _transmitiendo = false;
  int _completados = 0;

  static const _pasos = [
    ('Serializar', 'Preparando datos', Icons.data_object),
    ('Comprimir', 'Comprimiendo', Icons.compress),
    ('Enviar', 'Transmitiendo', Icons.cloud_upload),
    ('Confirmar', 'Confirmando', Icons.verified),
  ];

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SolicitudViewModel>();
    final pendientes = vm.solicitudes.where((s) => !s.transmitido).toList();

    // Inicializar estados si no hay uno activo
    if (_estados.isEmpty || _estados.length != pendientes.length) {
      _estados = pendientes.map((s) => _EstadoTransmision(
        solicitudId: s.id,
        clienteNombre: s.clienteNombre ?? '',
      )).toList();
    }

    final total = pendientes.length + _completados;
    final progresoGlobal = total > 0 ? _completados / total : 0.0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Transmisión Electrónica')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          _buildConexionCard(pendientes.length, progresoGlobal, vm.totalSolicitudes),
          const SizedBox(height: 20),
          if (pendientes.isNotEmpty) ...[
            _buildBotonTransmitir(pendientes.length, vm),
            const SizedBox(height: 20),
            _buildProgresoGlobal(progresoGlobal, total),
            const SizedBox(height: 20),
          ],
          _buildListaPendientes(pendientes, vm),
        ]),
      ),
    );
  }

  Widget _buildConexionCard(int pendientes, double progresoGlobal, int total) {
    final ok = pendientes == 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            color: ok ? EfectivaColors.verdeSuave : EfectivaColors.azulSuave,
            borderRadius: BorderRadius.circular(20)),
          child: Icon(ok ? Icons.cloud_done : Icons.cell_tower, color: ok ? EfectivaColors.verdeExito : EfectivaColors.azulPrincipal, size: 36),
        ),
        const SizedBox(height: 16),
        Text(ok ? 'Todo sincronizado' : 'Transmisión Electrónica',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: EfectivaColors.negroTexto)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: ok ? EfectivaColors.verdeSuave : EfectivaColors.azulSuave,
            borderRadius: BorderRadius.circular(20)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 8, height: 8,
              decoration: BoxDecoration(color: ok ? EfectivaColors.verdeExito : EfectivaColors.azulPrincipal, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(ok ? 'Conectado' : 'En línea', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600,
              color: ok ? EfectivaColors.verdeExito : EfectivaColors.azulPrincipal)),
          ]),
        ),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _statItem('Pendientes', '$pendientes', EfectivaColors.naranjaAcento),
          Container(width: 1, height: 30, color: EfectivaColors.grisClaro),
          _statItem('Transmitidos', '$_completados', EfectivaColors.verdeExito),
          Container(width: 1, height: 30, color: EfectivaColors.grisClaro),
          _statItem('Total', '$total', EfectivaColors.azulPrincipal),
        ]),
      ]),
    );
  }

  Widget _buildBotonTransmitir(int count, SolicitudViewModel vm) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: EfectivaColors.gradienteVerde,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: EfectivaColors.verdeExito.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(children: [
        Text('$count solicitudes pendientes',
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 4),
        Text('RF-65: Subida paralela automática', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _transmitiendo ? null : () => _transmitirTodo(vm),
            icon: _transmitiendo
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.cloud_upload, size: 20),
            label: Text(_transmitiendo ? 'Transmitiendo...' : 'Transmitir todo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white, foregroundColor: EfectivaColors.verdeExito,
              minimumSize: const Size(0, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        if (_transmitiendo) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            icon: const Icon(Icons.cancel_outlined, color: Colors.white70, size: 16),
            label: Text('Cancelar', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
            onPressed: () {
              setState(() => _transmitiendo = false);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Transmisión cancelada. $_completados completados.'),
                backgroundColor: EfectivaColors.naranjaAcento,
              ));
            },
          ),
        ],
      ]),
    );
  }

  Widget _buildProgresoGlobal(double progreso, int total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Progreso global', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: EfectivaColors.negroTexto)),
          Text('$_completados / $total', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: EfectivaColors.azulPrincipal)),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progreso,
            backgroundColor: EfectivaColors.grisClaro,
            valueColor: AlwaysStoppedAnimation<Color>(EfectivaColors.verdeExito),
            minHeight: 8,
          ),
        ),
      ]),
    );
  }

  Widget _buildListaPendientes(List<SolicitudCredito> pendientes, SolicitudViewModel vm) {
    if (pendientes.isEmpty && _completados > 0) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: EfectivaColors.verdeSuave, borderRadius: BorderRadius.circular(20)),
        child: Column(children: [
          const Icon(Icons.cloud_done, size: 56, color: EfectivaColors.verdeExito),
          const SizedBox(height: 12),
          Text('¡Todo sincronizado!', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: EfectivaColors.verdeExito)),
          const SizedBox(height: 4),
          Text('$_completados solicitudes transmitidas al sistema central.',
            style: GoogleFonts.inter(fontSize: 13, color: EfectivaColors.grisTexto), textAlign: TextAlign.center),
        ]),
      );
    }

    return Column(children: [
      Align(
        alignment: Alignment.centerLeft,
        child: Text('Detalle de transmisión', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: EfectivaColors.negroTexto)),
      ),
      const SizedBox(height: 10),
      ..._estados.asMap().entries.map((entry) => _buildTransmisionCard(entry.key, entry.value, vm)),
    ]);
  }

  Widget _buildTransmisionCard(int index, _EstadoTransmision estado, SolicitudViewModel vm) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: estado.completado
            ? Border.all(color: EfectivaColors.verdeExito.withValues(alpha: 0.4))
            : estado.error
                ? Border.all(color: EfectivaColors.rojoError.withValues(alpha: 0.4))
                : null,
      ),
      child: Column(children: [
        Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: estado.completado
                  ? EfectivaColors.verdeSuave
                  : estado.error
                      ? EfectivaColors.rojoSuave
                      : EfectivaColors.azulSuave,
              borderRadius: BorderRadius.circular(10)),
            child: estado.completado
                ? const Icon(Icons.check_circle, color: EfectivaColors.verdeExito, size: 22)
                : estado.error
                    ? const Icon(Icons.error, color: EfectivaColors.rojoError, size: 22)
                    : const Icon(Icons.cloud_upload, color: EfectivaColors.azulPrincipal, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(estado.clienteNombre, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
            Text('${estado.solicitudId} · S/${_buscarSolicitud(estado.solicitudId, vm)?.montoSolicitado.toStringAsFixed(0) ?? '?'}',
              style: GoogleFonts.inter(fontSize: 11, color: EfectivaColors.grisTexto)),
          ])),
          if (estado.completado || estado.error)
            GestureDetector(
              onTap: estado.error ? () => _reintentarUna(index, vm) : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: estado.error ? EfectivaColors.rojoSuave : EfectivaColors.verdeSuave,
                  borderRadius: BorderRadius.circular(20)),
                child: Text(
                  estado.completado ? 'Completado' : 'Reintentar',
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700,
                    color: estado.error ? EfectivaColors.rojoError : EfectivaColors.verdeExito),
                ),
              ),
            ),
        ]),
        if (!estado.completado && !estado.error) ...[
          const SizedBox(height: 12),
          _buildPasos(estado),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: estado.progreso,
              backgroundColor: EfectivaColors.grisClaro,
              valueColor: AlwaysStoppedAnimation<Color>(EfectivaColors.azulPrincipal),
              minHeight: 4,
            ),
          ),
        ],
      ]),
    );
  }

  Widget _buildPasos(_EstadoTransmision estado) {
    final pasoIndex = _pasos.indexWhere((p) => p.$2 == estado.pasoActual.name);
    return Row(children: List.generate(_pasos.length, (i) {
      final activo = i <= pasoIndex;
      final actual = i == pasoIndex;
      return Expanded(child: Row(children: [
        if (i > 0) Expanded(child: Container(height: 2, color: activo && !estado.error ? EfectivaColors.azulPrincipal : EfectivaColors.grisClaro)),
        Column(children: [
          Icon(
            i < pasoIndex ? Icons.check_circle : _pasos[i].$3,
            size: 18,
            color: estado.error
                ? EfectivaColors.rojoError
                : activo
                    ? EfectivaColors.azulPrincipal
                    : EfectivaColors.grisClaro,
          ),
          const SizedBox(height: 2),
          Text(_pasos[i].$1, style: GoogleFonts.inter(fontSize: 9,
            color: actual ? EfectivaColors.azulPrincipal : EfectivaColors.grisTexto)),
        ]),
      ]));
    }));
  }

  SolicitudCredito? _buscarSolicitud(String id, SolicitudViewModel vm) {
    try {
      return vm.solicitudes.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  // ─── Transmisión ───

  Future<void> _transmitirTodo(SolicitudViewModel vm) async {
    setState(() => _transmitiendo = true);

    final pendIds = _estados.where((e) => !e.completado).map((e) => e.solicitudId).toList();

    // RF-65: Subida paralela (hasta 3 concurrentes)
    final batches = <List<String>>[];
    for (int i = 0; i < pendIds.length; i += 3) {
      batches.add(pendIds.sublist(i, (i + 3 > pendIds.length) ? pendIds.length : i + 3));
    }

    for (final batch in batches) {
      if (!_transmitiendo) break;
      await Future.wait(batch.map((id) => _transmitirUna(id, vm)));
    }

    if (mounted) {
      setState(() => _transmitiendo = false);
      final ok = _estados.every((e) => e.completado);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok
            ? '$_completados solicitudes transmitidas exitosamente'
            : 'Transmisión completada con errores. $_completados exitosas.'),
        backgroundColor: ok ? EfectivaColors.verdeExito : EfectivaColors.naranjaAcento,
      ));
    }
  }

  Future<void> _transmitirUna(String id, SolicitudViewModel vm) async {
    final index = _estados.indexWhere((e) => e.solicitudId == id);
    if (index == -1) return;

    try {
      // RF-63: Pasos atómicos
      await _actualizarPaso(index, PasoTransmision.serializar, 0.1);
      // Simular serialización
      await Future.delayed(const Duration(milliseconds: 300));
      if (!_transmitiendo) return;

      await _actualizarPaso(index, PasoTransmision.comprimir, 0.35);
      await Future.delayed(const Duration(milliseconds: 400));
      if (!_transmitiendo) return;

      await _actualizarPaso(index, PasoTransmision.enviar, 0.6);
      final ok = await vm.transmitirSolicitud(id);
      if (!ok) throw Exception('Error de transmisión');
      if (!_transmitiendo) return;

      await _actualizarPaso(index, PasoTransmision.confirmar, 0.9);
      await Future.delayed(const Duration(milliseconds: 200));

      if (mounted) {
        setState(() {
          _estados[index] = _estados[index].copyWith(progreso: 1.0, completado: true);
          _completados++;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _estados[index] = _estados[index].copyWith(error: true));
      }
    }
  }

  Future<void> _actualizarPaso(int index, PasoTransmision paso, double progreso) async {
    await Future.delayed(const Duration(milliseconds: 50));
    if (mounted) {
      setState(() {
        _estados[index] = _estados[index].copyWith(pasoActual: paso, progreso: progreso);
      });
    }
  }

  Future<void> _reintentarUna(int index, SolicitudViewModel vm) async {
    setState(() {
      _estados[index] = _estados[index].copyWith(
        pasoActual: PasoTransmision.serializar,
        progreso: 0,
        error: false,
      );
    });
    await _transmitirUna(_estados[index].solicitudId, vm);
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(children: [
      Text(value, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
      Text(label, style: GoogleFonts.inter(fontSize: 11, color: EfectivaColors.grisTexto)),
    ]);
  }
}
