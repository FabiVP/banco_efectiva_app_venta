import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/ventas_viewmodel.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final oficial = context.watch<AuthViewModel>().oficialActual;
    final cartera = context.watch<CarteraViewModel>();
    final ruta = context.watch<RutaViewModel>();
    final solicitudes = context.watch<SolicitudViewModel>();
    final hoy = DateFormat('EEEE d MMMM', 'es').format(DateTime.now());

    return Scaffold(
      backgroundColor: EfectivaColors.grisFondo,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: EfectivaColors.azulPrincipal,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: EfectivaColors.gradientePrincipal),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white38, width: 2),
                            ),
                            child: Center(child: Text(
                              oficial?.nombreCompleto.split(' ').take(2).map((e) => e[0]).join('') ?? 'OF',
                              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                            )),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Hola, ${oficial?.nombreCompleto.split(' ').first ?? 'Oficial'}',
                                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                              Text(hoy.substring(0, 1).toUpperCase() + hoy.substring(1),
                                style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
                            ],
                          )),
                          Stack(children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
                            ),
                            if (solicitudes.pendientesTransmision > 0)
                              Positioned(right: 0, top: 0, child: Container(
                                width: 18, height: 18,
                                decoration: const BoxDecoration(color: EfectivaColors.naranjaAcento, shape: BoxShape.circle),
                                child: Center(child: Text('${solicitudes.pendientesTransmision}',
                                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white))),
                              )),
                          ]),
                        ]),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.location_on_outlined, color: Colors.white70, size: 16),
                            const SizedBox(width: 6),
                            Text(oficial?.perfil ?? 'Perfil no asignado', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500)),
                            Container(margin: const EdgeInsets.symmetric(horizontal: 8), width: 1, height: 14, color: Colors.white30),
                            const Icon(Icons.business_outlined, color: Colors.white70, size: 16),
                            const SizedBox(width: 6),
                            Text(oficial?.agenciaNombre ?? oficial?.agenciaId ?? '', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500)),
                          ]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _buildKPISection(ruta, solicitudes, cartera),
                const SizedBox(height: 20),
                _buildProgresoRuta(ruta),
                const SizedBox(height: 20),
                Text('Acciones rápidas', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: EfectivaColors.negroTexto)),
                const SizedBox(height: 12),
                _buildAccionesRapidas(context),
                const SizedBox(height: 20),
                _buildProximaVisita(ruta),
                const SizedBox(height: 20),
                _buildClientesRenovacion(cartera),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPISection(RutaViewModel ruta, SolicitudViewModel sol, CarteraViewModel cart) {
    return Row(children: [
      Expanded(child: _kpi('Visitas', '${ruta.visitasCompletadas}/${ruta.totalVisitas}', Icons.route_outlined, EfectivaColors.azulPrincipal)),
      const SizedBox(width: 10),
      Expanded(child: _kpi('Solicitudes', '${sol.totalSolicitudes}', Icons.description_outlined, EfectivaColors.naranjaAcento)),
      const SizedBox(width: 10),
      Expanded(child: _kpi('Renovaciones', '${cart.clientes.length}', Icons.autorenew, EfectivaColors.verdeExito)),
    ]);
  }

  Widget _kpi(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20)),
        const SizedBox(height: 8),
        Text(value, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: EfectivaColors.negroTexto)),
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: EfectivaColors.grisTexto, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Widget _buildProgresoRuta(RutaViewModel ruta) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: EfectivaColors.gradienteTarjeta, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: EfectivaColors.azulOscuro.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))]),
      child: Row(children: [
        CircularPercentIndicator(radius: 42, lineWidth: 6, percent: ruta.porcentajeAvance,
          center: Text('${(ruta.porcentajeAvance * 100).toInt()}%', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
          progressColor: EfectivaColors.naranjaAcento, backgroundColor: Colors.white.withValues(alpha: 0.2), circularStrokeCap: CircularStrokeCap.round),
        const SizedBox(width: 20),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Progreso del día', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 4),
          Text('${ruta.visitasCompletadas} de ${ruta.totalVisitas} visitas completadas', style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
        ])),
      ]),
    );
  }

  Widget _buildAccionesRapidas(BuildContext context) {
    return GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.85,
      children: [
        _accion(context, Icons.add_circle_outline, 'Nueva\nSolicitud', EfectivaColors.naranjaAcento, () => Navigator.pushNamed(context, '/nueva-solicitud')),
        _accion(context, Icons.camera_alt_outlined, 'Captura\nDocumentos', EfectivaColors.azulPrincipal, () => Navigator.pushNamed(context, '/captura-documentos')),
        _accion(context, Icons.verified_user_outlined, 'Consulta\nBuró', const Color(0xFF7C3AED), () => Navigator.pushNamed(context, '/consulta-buro')),
        _accion(context, Icons.send_outlined, 'Transmitir\nDatos', EfectivaColors.verdeExito, () => Navigator.pushNamed(context, '/transmision')),
      ]);
  }

  Widget _accion(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(onTap: onTap, child: Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 22)),
        const SizedBox(height: 8),
        Text(label, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: EfectivaColors.negroTexto, height: 1.2)),
      ]),
    ));
  }

  Widget _buildProximaVisita(RutaViewModel ruta) {
    final proxima = ruta.visitas.where((v) => !v.completada).toList();
    if (proxima.isEmpty) {
      return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: EfectivaColors.verdeSuave, borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          const Icon(Icons.check_circle, color: EfectivaColors.verdeExito, size: 32),
          const SizedBox(width: 12),
          Expanded(child: Text('¡Todas las visitas del día completadas! 🎉', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: EfectivaColors.verdeExito))),
        ]));
    }
    final v = proxima.first;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Próxima visita', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: EfectivaColors.negroTexto)),
      const SizedBox(height: 10),
      Container(padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: EfectivaColors.naranjaAcento.withValues(alpha: 0.3))),
        child: Row(children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(gradient: EfectivaColors.gradienteNaranja, borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text('${v.orden}', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(v.clienteNombre, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: EfectivaColors.negroTexto)),
            const SizedBox(height: 2),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: EfectivaColors.verdeExito.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
              child: Text(v.motivo, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: EfectivaColors.verdeExito))),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.location_on_outlined, size: 14, color: EfectivaColors.grisSubtitulo),
              const SizedBox(width: 4),
              Expanded(child: Text(v.direccion, style: GoogleFonts.inter(fontSize: 12, color: EfectivaColors.grisTexto), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ]),
          ])),
          const Icon(Icons.navigation_outlined, color: EfectivaColors.azulPrincipal, size: 22),
        ]),
      ),
    ]);
  }

  Widget _buildClientesRenovacion(CarteraViewModel cartera) {
    final ren = cartera.clientes.take(3).toList();
    if (ren.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Clientes con renovación', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: EfectivaColors.negroTexto)),
      const SizedBox(height: 10),
      ...ren.map((c) => Container(
        margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Container(width: 42, height: 42, decoration: BoxDecoration(color: EfectivaColors.azulSuave, borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(c.iniciales, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: EfectivaColors.azulPrincipal)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(c.nombreCompleto, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: EfectivaColors.negroTexto)),
            Text('DNI: ${c.numeroDocumento} · Calf: ${c.calificacionSbs ?? 'N'}', style: GoogleFonts.inter(fontSize: 11, color: EfectivaColors.grisTexto)),
          ])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: EfectivaColors.verdeSuave, borderRadius: BorderRadius.circular(8)),
            child: Text('S/ ${NumberFormat('#,##0', 'es').format(c.ingresosEstimados ?? 0)}', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: EfectivaColors.verdeExito))),
        ]),
      )),
    ]);
  }
}
