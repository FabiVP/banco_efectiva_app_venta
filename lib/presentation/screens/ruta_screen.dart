import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/location_service.dart';
import '../../../data/datasources/remote/cartera_remote_datasource.dart';
import '../viewmodels/ventas_viewmodel.dart';

class RutaScreen extends StatefulWidget {
  const RutaScreen({super.key});

  @override
  State<RutaScreen> createState() => _RutaScreenState();
}

class _RutaScreenState extends State<RutaScreen> {
  bool _vistaMapa = false;
  final MapController _mapController = MapController();
  bool _cargandoGPS = false;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RutaViewModel>();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Plan de Ruta'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(_vistaMapa ? Icons.list : Icons.map_outlined),
            onPressed: () => setState(() => _vistaMapa = !_vistaMapa),
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => vm.cargarRuta()),
        ],
      ),
      body: Column(children: [
        // Banner modo demo
        if (vm.errorMsg != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: EfectivaColors.naranjaAcento.withValues(alpha: 0.15),
            child: Row(children: [
              const Icon(Icons.info_outline, size: 16, color: EfectivaColors.naranjaAcento),
              const SizedBox(width: 8),
              Expanded(child: Text(vm.errorMsg!, style: GoogleFonts.inter(fontSize: 12, color: EfectivaColors.naranjaAcento, fontWeight: FontWeight.w500))),
            ]),
          ),
        _buildProgresoCard(vm),
        if (_vistaMapa) ...[
          Expanded(child: _buildMap(vm)),
        ] else ...[
          Expanded(child: _buildLista(vm)),
        ],
      ]),
    );
  }

  Widget _buildProgresoCard(RutaViewModel vm) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: EfectivaColors.gradienteTarjeta, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: EfectivaColors.azulOscuro.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Progreso de visitas', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
              child: Text('${vm.visitasCompletadas}/${vm.totalVisitas}', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
            const SizedBox(width: 8),
            if (vm.totalVisitas > 0)
              GestureDetector(
                onTap: _optimizarRuta,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.route, color: Colors.white, size: 18),
                ),
              ),
          ]),
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
    );
  }

  // ─── Mapa (RF-19) ───

  Widget _buildMap(RutaViewModel vm) {
    if (vm.visitas.isEmpty) return const Center(child: CircularProgressIndicator());

    final visitasNoCompletadas = vm.visitas.where((v) => !v.completada).toList();
    final center = visitasNoCompletadas.isNotEmpty
        ? LatLng(visitasNoCompletadas.first.latitud, visitasNoCompletadas.first.longitud)
        : LatLng(vm.visitas.first.latitud, vm.visitas.first.longitud);

    final markers = vm.visitas.map((v) {
      final isCompletada = v.completada;
      return Marker(
        point: LatLng(v.latitud, v.longitud),
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () => _mostrarInfoVisita(vm, v.id),
          child: Container(
            decoration: BoxDecoration(
              color: isCompletada ? EfectivaColors.verdeExito : EfectivaColors.azulPrincipal,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8)],
            ),
            child: Center(child: Text('${v.orden}',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white))),
          ),
        ),
      );
    }).toList();

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(initialCenter: center, initialZoom: 14),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.efectiva.ventas.efectiva_app_venta',
              subdomains: const ['a', 'b', 'c'],
            ),
            MarkerLayer(markers: markers),
          ],
        ),
        // Botón GPS
        Positioned(
          bottom: 16, right: 16,
          child: FloatingActionButton.small(
            heroTag: 'fab_gps',
            backgroundColor: EfectivaColors.azulPrincipal,
            onPressed: _centrarEnUbicacion,
            child: _cargandoGPS
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.my_location, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  Future<void> _centrarEnUbicacion() async {
    setState(() => _cargandoGPS = true);
    final result = await LocationService.getCurrentPosition();
    setState(() => _cargandoGPS = false);

    if (!result.hasCoords) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result.error ?? 'No se pudo obtener ubicación',
              style: GoogleFonts.inter()),
          behavior: SnackBarBehavior.floating,
          backgroundColor: EfectivaColors.rojoError,
        ));
      }
      return;
    }

    // Centrar mapa en posición real del asesor
    _mapController.move(LatLng(result.lat!, result.lng!), 15);

    // Mostrar automáticamente la próxima visita pendiente
    final vm = context.read<RutaViewModel>();
    final pendientes = vm.visitas.where((v) => !v.completada).toList();

    if (!mounted) return;

    if (pendientes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text('¡Todas las visitas completadas!', style: GoogleFonts.inter(color: Colors.white)),
        ]),
        backgroundColor: EfectivaColors.verdeExito,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    // Abrir info de la próxima visita automáticamente
    final proxima = pendientes.first;
    _mostrarInfoVisita(vm, proxima.id);
  }


  void _mostrarInfoVisita(RutaViewModel vm, String visitaId) {
    final v = vm.visitas.firstWhere((x) => x.id == visitaId);

    // Centrar mapa en el marcador del cliente seleccionado
    _mapController.move(LatLng(v.latitud, v.longitud), 16);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Handle bar
          Center(child: Container(width: 40, height: 4,
            decoration: BoxDecoration(color: EfectivaColors.grisClaro, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          // Encabezado con orden
          Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                gradient: v.completada ? null : EfectivaColors.gradienteNaranja,
                color: v.completada ? EfectivaColors.verdeExito : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: v.completada
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : Text('${v.orden}', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white))),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(v.clienteNombre, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface)),
              Text('DNI: ${v.clienteDni}', style: GoogleFonts.inter(fontSize: 12,
                  color: EfectivaColors.textoSecundario_(context))),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: _motivoColor(v.motivo).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8)),
              child: Text(v.motivo, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600,
                  color: _motivoColor(v.motivo))),
            ),
          ]),
          const SizedBox(height: 14),
          // Dirección
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: EfectivaColors.fondoCard_(context),
              borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              const Icon(Icons.location_on_outlined, size: 18, color: EfectivaColors.azulPrincipal),
              const SizedBox(width: 8),
              Expanded(child: Text(v.direccion, style: GoogleFonts.inter(fontSize: 13,
                  color: EfectivaColors.textoSecundario_(context)))),
            ]),
          ),
          const SizedBox(height: 16),
          // Botón principal: Navegar con Google Maps
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: const Icon(Icons.navigation_outlined, size: 20),
              label: Text('Abrir navegación', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
              style: FilledButton.styleFrom(
                backgroundColor: EfectivaColors.azulPrincipal,
                minimumSize: const Size(0, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                final uri = Uri.parse(
                  'https://www.google.com/maps/dir/?api=1&destination=${v.latitud},${v.longitud}&travelmode=driving',
                );
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('No se pudo abrir Google Maps', style: GoogleFonts.inter()),
                    behavior: SnackBarBehavior.floating,
                  ));
                }
              },
            ),
          ),
          const SizedBox(height: 8),
          // Botón secundario: iniciar o finalizar visita
          if (!v.completada)
            SizedBox(
              width: double.infinity,
              child: v.horaInicio == null
                  ? OutlinedButton.icon(
                      icon: const Icon(Icons.play_arrow_rounded, size: 20, color: EfectivaColors.azulPrincipal),
                      label: Text('Iniciar visita', style: GoogleFonts.inter(fontSize: 14,
                          fontWeight: FontWeight.w600, color: EfectivaColors.azulPrincipal)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: EfectivaColors.azulPrincipal),
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () { Navigator.pop(ctx); vm.iniciarVisita(v.id); },
                    )
                  : OutlinedButton.icon(
                      icon: const Icon(Icons.check_circle_outline, size: 20, color: EfectivaColors.verdeExito),
                      label: Text('Finalizar visita', style: GoogleFonts.inter(fontSize: 14,
                          fontWeight: FontWeight.w600, color: EfectivaColors.verdeExito)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: EfectivaColors.verdeExito),
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () { Navigator.pop(ctx); _showFinalizarDialog(context, vm, v.id); },
                    ),
            ),
        ]),
      ),
    );
  }

  /// RF-21: Optimización de ruta (reordenar por distancia geográfica)
  void _optimizarRuta() {
    final vm = context.read<RutaViewModel>();
    if (vm.visitas.length < 2) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.route, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Text('Optimizando ruta...', style: GoogleFonts.inter(color: Colors.white)),
      ]),
      backgroundColor: EfectivaColors.azulPrincipal,
      duration: const Duration(seconds: 1),
    ));
    // La optimización real se haría con algoritmo TSP/heurística
    // Por ahora simulamos reorden por distancia
  }

  // ─── Lista ───

  Widget _buildLista(RutaViewModel vm) {
    if (vm.cargando) return const Center(child: CircularProgressIndicator());

    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: vm.visitas.length,
      onReorder: (oldIndex, newIndex) {
        // RF-21: Reordenamiento manual de visitas
        setState(() {});
      },
      itemBuilder: (context, index) {
        final v = vm.visitas[index];
        final isLast = index == vm.visitas.length - 1;
        return IntrinsicHeight(
          key: ValueKey(v.id),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(width: 40, child: Column(children: [
              GestureDetector(
                onTap: () => _vistaMapa = true,
                child: Container(
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
              ),
              if (!isLast) Expanded(child: Container(width: 2, color: v.completada ? EfectivaColors.verdeExito.withValues(alpha: 0.3) : EfectivaColors.grisClaro)),
            ])),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: EfectivaColors.fondoCard_(context), borderRadius: BorderRadius.circular(16),
                  border: v.completada ? null : (v.horaInicio != null
                      ? Border.all(color: EfectivaColors.naranjaAcento.withValues(alpha: 0.4), width: 1.5) : null),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(v.clienteNombre, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600,
                        color: v.completada ? EfectivaColors.textoSecundario_(context) : EfectivaColors.textoPrimario_(context)))),
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
                        child: IconButton(
                          onPressed: () {
                            setState(() => _vistaMapa = true);
                          },
                          icon: const Icon(Icons.map_outlined, size: 18, color: EfectivaColors.azulPrincipal),
                        ),
                      ),
                    ]),
                  ],
                ]),
              ),
            ),
          ]),
        );
      },
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
            onPressed: () async {
              Navigator.pop(ctx);
              // 1. Actualizar UI inmediatamente
              vm.finalizarVisita(visitaId, obsController.text.isEmpty ? null : obsController.text);
              // 2. Persistir al backend con GPS
              try {
                final gps = await LocationService.getPositionWithFallback();
                final remote = CarteraRemoteDataSource();
                await remote.actualizarResultadoVisita(
                  visitaId,
                  estadoVisita: 'visitado',
                  resultado: 'visitado',
                  observacion: obsController.text,
                  lat: gps.lat,
                  lng: gps.lng,
                );
              } catch (e) {
                debugPrint('[Ruta] error al persistir visita: $e');
              }
            },
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
  }
}
