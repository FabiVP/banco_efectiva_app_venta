import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../../core/constants/app_colors.dart';
import '../viewmodels/ventas_viewmodel.dart';

class RutaScreen extends StatelessWidget {
  const RutaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RutaViewModel>();
    return Scaffold(
      backgroundColor: EfectivaColors.grisFondo,
      appBar: AppBar(
        title: const Text('Plan de Ruta'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: const Icon(Icons.map_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => vm.cargarRuta()),
        ],
      ),
      body: Column(children: [
        // Resumen del progreso
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(gradient: EfectivaColors.gradienteTarjeta, borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: EfectivaColors.azulOscuro.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Progreso de visitas', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                child: Text('${vm.visitasCompletadas}/${vm.totalVisitas}', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ]),
            const SizedBox(height: 16),
            LinearPercentIndicator(
              padding: EdgeInsets.zero,
              lineHeight: 8,
              percent: vm.porcentajeAvance,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              linearGradient: EfectivaColors.gradienteNaranja,
              barRadius: const Radius.circular(4),
            ),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: EfectivaColors.naranjaAcento, borderRadius: BorderRadius.circular(3))),
                const SizedBox(width: 6),
                Text('${vm.visitasCompletadas} completadas', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
              ]),
              Row(children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(3))),
                const SizedBox(width: 6),
                Text('${vm.totalVisitas - vm.visitasCompletadas} pendientes', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
              ]),
            ]),
          ]),
        ),
        // Lista de visitas (timeline)
        Expanded(
          child: vm.cargando
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: vm.visitas.length,
                  itemBuilder: (context, index) {
                    final v = vm.visitas[index];
                    final isLast = index == vm.visitas.length - 1;
                    return IntrinsicHeight(
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        // Timeline
                        SizedBox(width: 40, child: Column(children: [
                          Container(
                            width: 32, height: 32,
                            decoration: BoxDecoration(
                              color: v.completada ? EfectivaColors.verdeExito : (v.horaInicio != null ? EfectivaColors.naranjaAcento : EfectivaColors.grisClaro),
                              shape: BoxShape.circle,
                            ),
                            child: Center(child: v.completada
                                ? const Icon(Icons.check, color: Colors.white, size: 16)
                                : Text('${v.orden}', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700,
                                    color: v.horaInicio != null ? Colors.white : EfectivaColors.grisTexto))),
                          ),
                          if (!isLast) Expanded(child: Container(width: 2, color: v.completada ? EfectivaColors.verdeExito.withValues(alpha: 0.3) : EfectivaColors.grisClaro)),
                        ])),
                        const SizedBox(width: 10),
                        // Tarjeta de visita
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white, borderRadius: BorderRadius.circular(16),
                              border: v.completada ? null : (v.horaInicio != null
                                  ? Border.all(color: EfectivaColors.naranjaAcento.withValues(alpha: 0.4), width: 1.5) : null),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                            ),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(children: [
                                Expanded(child: Text(v.clienteNombre, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600,
                                    color: v.completada ? EfectivaColors.grisTexto : EfectivaColors.negroTexto))),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(color: _motivoColor(v.motivo).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                                  child: Text(v.motivo, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: _motivoColor(v.motivo))),
                                ),
                              ]),
                              const SizedBox(height: 6),
                              Row(children: [
                                const Icon(Icons.location_on_outlined, size: 14, color: EfectivaColors.grisSubtitulo),
                                const SizedBox(width: 4),
                                Expanded(child: Text(v.direccion, style: GoogleFonts.inter(fontSize: 12, color: EfectivaColors.grisTexto), maxLines: 1, overflow: TextOverflow.ellipsis)),
                              ]),
                              if (v.completada && v.observaciones != null) ...[
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: EfectivaColors.grisFondo, borderRadius: BorderRadius.circular(8)),
                                  child: Row(children: [
                                    const Icon(Icons.notes, size: 14, color: EfectivaColors.grisSubtitulo),
                                    const SizedBox(width: 6),
                                    Expanded(child: Text(v.observaciones!, style: GoogleFonts.inter(fontSize: 11, color: EfectivaColors.grisTexto, fontStyle: FontStyle.italic))),
                                  ]),
                                ),
                              ],
                              if (!v.completada) ...[
                                const SizedBox(height: 10),
                                Row(children: [
                                  if (v.horaInicio == null)
                                    Expanded(child: ElevatedButton.icon(
                                      onPressed: () => vm.iniciarVisita(v.id),
                                      icon: const Icon(Icons.play_arrow_rounded, size: 18),
                                      label: const Text('Iniciar visita'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: EfectivaColors.azulPrincipal,
                                        minimumSize: const Size(0, 40),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        textStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                                      ),
                                    ))
                                  else
                                    Expanded(child: ElevatedButton.icon(
                                      onPressed: () => _showFinalizarDialog(context, vm, v.id),
                                      icon: const Icon(Icons.check_circle_outline, size: 18),
                                      label: const Text('Finalizar'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: EfectivaColors.verdeExito,
                                        minimumSize: const Size(0, 40),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        textStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                                      ),
                                    )),
                                  const SizedBox(width: 8),
                                  Container(
                                    height: 40,
                                    decoration: BoxDecoration(color: EfectivaColors.grisFondo, borderRadius: BorderRadius.circular(10)),
                                    child: IconButton(onPressed: () {}, icon: const Icon(Icons.navigation_outlined, size: 18, color: EfectivaColors.azulPrincipal)),
                                  ),
                                ]),
                              ],
                            ]),
                          ),
                        ),
                      ]),
                    );
                  },
                ),
        ),
      ]),
    );
  }

  Color _motivoColor(String motivo) {
    switch (motivo) {
      case 'Renovación': return EfectivaColors.verdeExito;
      case 'Prospección': return EfectivaColors.naranjaAcento;
      case 'Seguimiento': return EfectivaColors.azulPrincipal;
      case 'Cobranza': return EfectivaColors.rojoError;
      default: return EfectivaColors.grisTexto;
    }
  }

  void _showFinalizarDialog(BuildContext context, RutaViewModel vm, String visitaId) {
    final obsController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Finalizar visita', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Agrega observaciones de la visita:', style: GoogleFonts.inter(fontSize: 14, color: EfectivaColors.grisTexto)),
          const SizedBox(height: 12),
          TextField(
            controller: obsController, maxLines: 3,
            decoration: InputDecoration(hintText: 'Observaciones...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              vm.finalizarVisita(visitaId, obsController.text.isEmpty ? null : obsController.text);
              Navigator.pop(ctx);
            },
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
  }
}
