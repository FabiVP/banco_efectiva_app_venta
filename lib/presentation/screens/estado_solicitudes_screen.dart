import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/solicitud_model.dart';
import '../viewmodels/ventas_viewmodel.dart';

class EstadoSolicitudesScreen extends StatelessWidget {
  const EstadoSolicitudesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SolicitudViewModel>();
    return Scaffold(
      backgroundColor: EfectivaColors.grisFondo,
      appBar: AppBar(title: const Text('Estado de Solicitudes'), automaticallyImplyLeading: false),
      body: Column(children: [
        // Filtros de estado
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.white,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: ['Todos', 'Borrador', 'Enviado', 'En evaluación', 'Aprobado', 'Desembolsado'].map((e) =>
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(e),
                  selected: vm.filtroEstado == e,
                  onSelected: (_) => vm.filtrarPorEstado(e),
                  selectedColor: _estadoColor(e),
                  backgroundColor: EfectivaColors.grisClaro,
                  labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600,
                    color: vm.filtroEstado == e ? Colors.white : EfectivaColors.grisTexto),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  side: BorderSide.none,
                ),
              ),
            ).toList()),
          ),
        ),
        // Pipeline visual
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _pipelineItem('Borrador', _countByStatus(vm, EstadoSolicitud.borrador), Icons.edit_note, EfectivaColors.grisTexto),
            _arrow(),
            _pipelineItem('Enviado', _countByStatus(vm, EstadoSolicitud.enviado), Icons.send, EfectivaColors.estadoEnviado),
            _arrow(),
            _pipelineItem('Evaluación', _countByStatus(vm, EstadoSolicitud.enEvaluacion), Icons.pending, EfectivaColors.estadoEvaluacion),
            _arrow(),
            _pipelineItem('Aprobado', _countByStatus(vm, EstadoSolicitud.aprobado), Icons.thumb_up, EfectivaColors.estadoAprobado),
            _arrow(),
            _pipelineItem('Desembolso', _countByStatus(vm, EstadoSolicitud.desembolsado), Icons.payments, EfectivaColors.estadoDesembolsado),
          ]),
        ),
        // Lista de solicitudes
        Expanded(
          child: vm.cargando
              ? const Center(child: CircularProgressIndicator())
              : vm.solicitudes.isEmpty
                  ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.inbox_outlined, size: 64, color: EfectivaColors.grisClaro),
                      const SizedBox(height: 12),
                      Text('Sin solicitudes', style: GoogleFonts.inter(color: EfectivaColors.grisTexto)),
                    ]))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: vm.solicitudes.length,
                      itemBuilder: (context, index) {
                        final s = vm.solicitudes[index];
                        return _buildSolicitudCard(context, s, vm);
                      },
                    ),
        ),
      ]),
    );
  }

  int _countByStatus(SolicitudViewModel vm, EstadoSolicitud estado) {
    return vm.solicitudes.where((s) => s.estado == estado).length;
  }

  Widget _pipelineItem(String label, int count, IconData icon, Color color) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
        child: Center(child: Icon(icon, color: color, size: 18)),
      ),
      const SizedBox(height: 4),
      Text('$count', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
      Text(label, style: GoogleFonts.inter(fontSize: 9, color: EfectivaColors.grisTexto, fontWeight: FontWeight.w500)),
    ]);
  }

  Widget _arrow() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Icon(Icons.arrow_forward_ios, size: 10, color: EfectivaColors.grisSubtitulo),
    );
  }

  Widget _buildSolicitudCard(BuildContext context, SolicitudCredito s, SolicitudViewModel vm) {
    final color = _estadoColorFromEnum(s.estado);
    final moneyFmt = NumberFormat('#,##0.00', 'es');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showSolicitudDetalle(context, s),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s.clienteNombre, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: EfectivaColors.negroTexto)),
                  Text('DNI: ${s.clienteDni} · ${s.tipoCredito}', style: GoogleFonts.inter(fontSize: 12, color: EfectivaColors.grisTexto)),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(s.estadoTexto, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
                ),
              ]),
              const Divider(height: 20),
              Row(children: [
                _infoItem('Monto', 'S/ ${moneyFmt.format(s.montoSolicitado)}'),
                _infoItem('Plazo', '${s.plazoMeses} meses'),
                _infoItem('Cuota est.', s.cuotaEstimada > 0 ? 'S/ ${moneyFmt.format(s.cuotaEstimada)}' : '-'),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Icon(s.transmitido ? Icons.cloud_done : Icons.cloud_off, size: 14,
                  color: s.transmitido ? EfectivaColors.verdeExito : EfectivaColors.rojoError),
                const SizedBox(width: 4),
                Text(s.transmitido ? 'Transmitido' : 'Sin transmitir',
                  style: GoogleFonts.inter(fontSize: 11, color: s.transmitido ? EfectivaColors.verdeExito : EfectivaColors.rojoError, fontWeight: FontWeight.w500)),
                const Spacer(),
                Text(DateFormat('dd/MM/yyyy HH:mm').format(s.fechaCreacion),
                  style: GoogleFonts.inter(fontSize: 11, color: EfectivaColors.grisSubtitulo)),
              ]),
              if (!s.transmitido) ...[
                const SizedBox(height: 10),
                SizedBox(width: double.infinity, child: ElevatedButton.icon(
                  onPressed: () async {
                    final ok = await vm.transmitirSolicitud(s.id);
                    if (context.mounted && ok) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Solicitud ${s.id} transmitida correctamente'),
                        backgroundColor: EfectivaColors.verdeExito,
                      ));
                    }
                  },
                  icon: const Icon(Icons.send, size: 16),
                  label: const Text('Transmitir ahora'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: EfectivaColors.verdeExito,
                    minimumSize: const Size(0, 40),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    textStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                )),
              ],
            ]),
          ),
        ),
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.inter(fontSize: 10, color: EfectivaColors.grisSubtitulo)),
      Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: EfectivaColors.negroTexto)),
    ]));
  }

  Color _estadoColor(String estado) {
    switch (estado) {
      case 'Enviado': return EfectivaColors.estadoEnviado;
      case 'En evaluación': return EfectivaColors.estadoEvaluacion;
      case 'Aprobado': return EfectivaColors.estadoAprobado;
      case 'Desembolsado': return EfectivaColors.estadoDesembolsado;
      case 'Borrador': return EfectivaColors.grisTexto;
      default: return EfectivaColors.azulPrincipal;
    }
  }

  Color _estadoColorFromEnum(EstadoSolicitud e) {
    switch (e) {
      case EstadoSolicitud.borrador: return EfectivaColors.grisTexto;
      case EstadoSolicitud.enviado: return EfectivaColors.estadoEnviado;
      case EstadoSolicitud.enEvaluacion: return EfectivaColors.estadoEvaluacion;
      case EstadoSolicitud.aprobado: return EfectivaColors.estadoAprobado;
      case EstadoSolicitud.desembolsado: return EfectivaColors.estadoDesembolsado;
      case EstadoSolicitud.rechazado: return EfectivaColors.estadoRechazado;
    }
  }

  void _showSolicitudDetalle(BuildContext context, SolicitudCredito s) {
    final moneyFmt = NumberFormat('#,##0.00', 'es');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40, height: 4,
            decoration: BoxDecoration(color: EfectivaColors.grisClaro, borderRadius: BorderRadius.circular(2)),
          ),
          Expanded(child: ListView(padding: const EdgeInsets.all(24), children: [
            Text('Solicitud ${s.id}', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: EfectivaColors.negroTexto)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: _estadoColorFromEnum(s.estado).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(s.estadoTexto, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: _estadoColorFromEnum(s.estado))),
            ),
            const SizedBox(height: 20),
            // Timeline de estados
            _buildTimeline(s),
            const SizedBox(height: 20),
            _detalleSection('Datos del Cliente', [
              _detalleRow('Nombre', s.clienteNombre),
              _detalleRow('DNI', s.clienteDni),
            ]),
            _detalleSection('Datos del Préstamo', [
              _detalleRow('Tipo', s.tipoCredito),
              _detalleRow('Monto', 'S/ ${moneyFmt.format(s.montoSolicitado)}'),
              _detalleRow('Plazo', '${s.plazoMeses} meses'),
              _detalleRow('Destino', s.destinoCredito),
              _detalleRow('Cuota estimada', 'S/ ${moneyFmt.format(s.cuotaEstimada)}'),
            ]),
            if (s.resultadoBuro != null)
              _detalleSection('Buró de Crédito', [
                _detalleRow('Score', '${s.resultadoBuro!.puntaje}'),
                _detalleRow('Riesgo', s.resultadoBuro!.scoreRiesgo),
                _detalleRow('Resultado', s.resultadoBuro!.aprobado ? '✅ Aprobado' : '❌ No aprobado'),
              ]),
          ])),
        ]),
      ),
    );
  }

  Widget _buildTimeline(SolicitudCredito s) {
    final steps = [
      _TimelineStep('Creado', s.fechaCreacion, true),
      _TimelineStep('Enviado', s.fechaEnvio, s.fechaEnvio != null),
      _TimelineStep('En evaluación', s.fechaEvaluacion, s.fechaEvaluacion != null),
      _TimelineStep('Aprobado', s.fechaAprobacion, s.fechaAprobacion != null),
      _TimelineStep('Desembolsado', s.fechaDesembolso, s.fechaDesembolso != null),
    ];
    return Column(children: steps.asMap().entries.map((e) {
      final i = e.key;
      final step = e.value;
      final isLast = i == steps.length - 1;
      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Column(children: [
          Container(width: 24, height: 24,
            decoration: BoxDecoration(
              color: step.completado ? EfectivaColors.verdeExito : EfectivaColors.grisClaro,
              shape: BoxShape.circle),
            child: step.completado ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
          ),
          if (!isLast) Container(width: 2, height: 30, color: step.completado ? EfectivaColors.verdeExito.withValues(alpha: 0.3) : EfectivaColors.grisClaro),
        ]),
        const SizedBox(width: 12),
        Expanded(child: Padding(padding: const EdgeInsets.only(bottom: 16), child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(step.label, style: GoogleFonts.inter(fontSize: 13, fontWeight: step.completado ? FontWeight.w600 : FontWeight.w400,
              color: step.completado ? EfectivaColors.negroTexto : EfectivaColors.grisSubtitulo)),
            if (step.fecha != null)
              Text(DateFormat('dd/MM HH:mm').format(step.fecha!), style: GoogleFonts.inter(fontSize: 11, color: EfectivaColors.grisTexto)),
          ],
        ))),
      ]);
    }).toList());
  }

  Widget _detalleSection(String title, List<Widget> rows) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: EfectivaColors.negroTexto)),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: EfectivaColors.grisFondo, borderRadius: BorderRadius.circular(12)),
        child: Column(children: rows),
      ),
      const SizedBox(height: 16),
    ]);
  }

  Widget _detalleRow(String label, String value) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 13, color: EfectivaColors.grisTexto)),
        Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: EfectivaColors.negroTexto)),
      ],
    ));
  }
}

class _TimelineStep {
  final String label;
  final DateTime? fecha;
  final bool completado;
  _TimelineStep(this.label, this.fecha, this.completado);
}
