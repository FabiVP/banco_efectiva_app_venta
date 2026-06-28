import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/constants/app_colors.dart';
import '../../data/models/cartera_model.dart';
import '../viewmodels/cartera_viewmodel.dart';
import '../viewmodels/ventas_viewmodel.dart';

class CarteraNuevoScreen extends StatefulWidget {
  const CarteraNuevoScreen({super.key});
  @override
  State<CarteraNuevoScreen> createState() => _CarteraNuevoScreenState();
}

class _CarteraNuevoScreenState extends State<CarteraNuevoScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CarteraNuevoViewModel>().cargarCartera();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CarteraNuevoViewModel>();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(children: [
        _buildHeader(vm),
        if (vm.modoOffline) _buildOfflineBanner(vm),
        _buildAlertaSeguimiento(vm),
        _buildBusquedaFiltros(vm),
        Expanded(child: vm.cargando
            ? const Center(child: CircularProgressIndicator(color: EfectivaColors.azulPrincipal))
            : vm.items.isEmpty
                ? _emptyState()
                : _buildLista(vm)),
      ]),
    );
  }

  Widget _buildHeader(CarteraNuevoViewModel vm) {
    return Container(
      decoration: const BoxDecoration(gradient: EfectivaColors.gradientePrincipal),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 20, right: 20, bottom: 16,
      ),
      child: Column(children: [
        Row(children: [
          const Icon(Icons.folder_copy_outlined, color: Colors.white, size: 22),
          const SizedBox(width: 10),
          Expanded(child: Text('Cartera del Día',
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white))),
          if (vm.alertasNoLeidas > 0)
            Stack(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
              ),
              Positioned(right: 0, top: 0, child: Container(
                width: 18, height: 18,
                decoration: const BoxDecoration(color: EfectivaColors.naranjaAcento, shape: BoxShape.circle),
                child: Center(child: Text('${vm.alertasNoLeidas}',
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white))),
              )),
            ]),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => vm.cargarCartera(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.refresh, color: Colors.white, size: 20),
            ),
          ),
        ]),
        const SizedBox(height: 14),
        // Indicador de progreso
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${vm.visitados} visitados · ${vm.pendientes} pendientes',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: vm.porcentajeAvance,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(EfectivaColors.naranjaAcento),
                minHeight: 6,
              ),
            ),
          ])),
          const SizedBox(width: 16),
          Text('${vm.totalClientes} clientes',
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
        ]),
        if (vm.ultimaActualizacion != null) ...[
          const SizedBox(height: 6),
          Text('Última actualización: ${DateFormat('HH:mm', 'es').format(vm.ultimaActualizacion!)}',
              style: GoogleFonts.inter(fontSize: 11, color: Colors.white54)),
        ],
      ]),
    );
  }

  Widget _buildAlertaSeguimiento(CarteraNuevoViewModel vm) {
    final sinContacto = vm.clientesSinContacto;
    if (sinContacto.isEmpty) return const SizedBox();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: EfectivaColors.naranjaAcento.withValues(alpha: 0.15),
      child: Row(children: [
        Icon(Icons.notifications_outlined, color: EfectivaColors.naranjaAcento, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(
          '${sinContacto.length} cliente(s) sin contacto en más de 7 días',
          style: GoogleFonts.inter(fontSize: 12, color: EfectivaColors.naranjaAcento, fontWeight: FontWeight.w600),
        )),
        GestureDetector(
          onTap: () => vm.filtrar('Seguimiento'),
          child: Text('Ver', style: GoogleFonts.inter(fontSize: 12, color: EfectivaColors.naranjaAcento, fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline, decorationColor: EfectivaColors.naranjaAcento)),
        ),
      ]),
    );
  }

  Widget _buildOfflineBanner(CarteraNuevoViewModel vm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(0xFFFF6F00),
      child: Row(children: [
        const Icon(Icons.wifi_off, color: Colors.white, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(
          vm.pendientesSync > 0
              ? 'Modo offline — ${vm.pendientesSync} pendiente(s) de sincronizar'
              : 'Modo offline — Los cambios se sincronizarán al reconectar',
          style: GoogleFonts.inter(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
        )),
        if (vm.pendientesSync > 0)
          GestureDetector(
            onTap: () => vm.sincronizarPendientes(),
            child: Text('Sync', style: GoogleFonts.inter(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline, decorationColor: Colors.white)),
          ),
      ]),
    );
  }

  Widget _buildBusquedaFiltros(CarteraNuevoViewModel vm) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(children: [
        TextField(
          onChanged: vm.buscar,
          decoration: InputDecoration(
            hintText: 'Buscar por nombre o DNI...',
            hintStyle: GoogleFonts.inter(fontSize: 14, color: EfectivaColors.grisSubtitulo),
            prefixIcon: const Icon(Icons.search, color: EfectivaColors.grisSubtitulo, size: 20),
            filled: true, fillColor: EfectivaColors.grisFondo,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            isDense: true,
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: ['Todos', 'Renovación', 'Nuevas', 'En mora', 'Visitados'].map((f) =>
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(f),
                selected: vm.filtroActivo == f,
                onSelected: (_) => vm.filtrar(f),
                selectedColor: EfectivaColors.azulPrincipal,
                backgroundColor: EfectivaColors.grisClaro,
                labelStyle: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w600,
                  color: vm.filtroActivo == f ? Colors.white : EfectivaColors.grisTexto,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                side: BorderSide.none, padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ).toList()),
        ),
      ]),
    );
  }

  Widget _buildLista(CarteraNuevoViewModel vm) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vm.items.length,
      onReorder: vm.reordenar,
      itemBuilder: (context, index) {
        final item = vm.items[index];
        return _buildCarteraCard(context, item, vm, key: ValueKey(item.id));
      },
    );
  }

  Widget _buildCarteraCard(BuildContext context, CarteraItem item, CarteraNuevoViewModel vm, {required Key key}) {
    final color = _colorTipoGestion(item.tipoGestion);
    final visitado = item.visitado;
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: visitado ? EfectivaColors.grisClaro : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: visitado ? null : Border.all(color: color.withValues(alpha: 0.15)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _mostrarDetalle(context, item, vm),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              // Indicador de prioridad lateral
              Container(
                width: 4, height: 56,
                decoration: BoxDecoration(
                  color: visitado ? EfectivaColors.grisClaro : _colorPrioridad(item.prioridad),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              // Avatar / iniciales
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: visitado ? EfectivaColors.grisClaro : color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: visitado
                    ? const Icon(Icons.check_circle, color: EfectivaColors.verdeExito, size: 24)
                    : Center(child: Text(
                        item.clienteNombre.split(' ').take(2).map((e) => e[0]).join('').toUpperCase(),
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: color),
                      )),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.clienteNombre,
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600,
                    color: visitado ? EfectivaColors.grisTexto : EfectivaColors.negroTexto)),
                const SizedBox(height: 2),
                Text('DNI: ${item.clienteDniCensurado}',
                  style: GoogleFonts.inter(fontSize: 12, color: EfectivaColors.grisSubtitulo)),
                const SizedBox(height: 6),
                Row(children: [
                  _tag(item.tipoGestionLabel, color),
                  const SizedBox(width: 6),
                  _tagPrioridad(item.prioridad),
                ]),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                if (item.montoCredito != null)
                  Text('S/ ${NumberFormat('#,##0', 'es').format(item.montoCredito)}',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700,
                      color: visitado ? EfectivaColors.grisTexto : EfectivaColors.negroTexto)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                  child: const Icon(Icons.drag_handle, color: EfectivaColors.grisSubtitulo, size: 18),
                ),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  void _mostrarDetalle(BuildContext context, CarteraItem item, CarteraNuevoViewModel vm) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ResultadoVisitaSheet(item: item, vm: vm, parentContext: context),
    );
  }

  Widget _emptyState() => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Icon(Icons.search_off_rounded, size: 64, color: EfectivaColors.grisClaro),
    const SizedBox(height: 12),
    Text('No se encontraron clientes', style: GoogleFonts.inter(color: EfectivaColors.grisTexto, fontSize: 15)),
  ]));

  Widget _tag(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
    child: Text(text, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: color)),
  );

  Widget _tagPrioridad(PrioridadVisita p) {
    final (label, color) = switch (p) {
      PrioridadVisita.alta => ('ALTA', EfectivaColors.rojoError),
      PrioridadVisita.media => ('MEDIA', EfectivaColors.naranjaAcento),
      PrioridadVisita.normal => ('NORMAL', EfectivaColors.grisTexto),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: color)),
    );
  }

  Color _colorTipoGestion(TipoGestion tipo) {
    switch (tipo) {
      case TipoGestion.renovacion: return EfectivaColors.azulPrincipal;
      case TipoGestion.ampliacion: return EfectivaColors.verdeExito;
      case TipoGestion.nuevaSolicitud: return EfectivaColors.naranjaAcento;
      case TipoGestion.seguimiento: return EfectivaColors.grisTexto;
      case TipoGestion.recuperacionMora: return EfectivaColors.rojoError;
      case TipoGestion.desertor: return const Color(0xFF7C3AED);
    }
  }

  Color _colorPrioridad(PrioridadVisita p) {
    switch (p) {
      case PrioridadVisita.alta: return EfectivaColors.rojoError;
      case PrioridadVisita.media: return EfectivaColors.naranjaAcento;
      case PrioridadVisita.normal: return EfectivaColors.verdeExito;
    }
  }
}

// ─── Bottom sheet: Registrar resultado de visita ────────────────────────────
class _ResultadoVisitaSheet extends StatefulWidget {
  final CarteraItem item;
  final CarteraNuevoViewModel vm;
  final BuildContext parentContext;
  const _ResultadoVisitaSheet({required this.item, required this.vm, required this.parentContext});
  @override
  State<_ResultadoVisitaSheet> createState() => _ResultadoVisitaSheetState();
}

class _ResultadoVisitaSheetState extends State<_ResultadoVisitaSheet> {
  String? _resultadoSeleccionado;
  final _obsCtrl = TextEditingController();
  bool _enviando = false;

  final List<Map<String, dynamic>> _opciones = [
    {'label': 'Visitado', 'icon': Icons.check_circle_outline, 'color': EfectivaColors.verdeExito},
    {'label': 'No encontrado', 'icon': Icons.person_off_outlined, 'color': EfectivaColors.naranjaAcento},
    {'label': 'Reagendar', 'icon': Icons.event_repeat_outlined, 'color': EfectivaColors.azulPrincipal},
    {'label': 'Negocio cerrado', 'icon': Icons.store_outlined, 'color': EfectivaColors.rojoError},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: EfectivaColors.grisClaro, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: Text(widget.item.clienteNombre, style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: EfectivaColors.negroTexto))),
            TextButton.icon(
              onPressed: () {
                final carteraVm = widget.parentContext.read<CarteraViewModel>();
                final cliente = carteraVm.clientes.where((c) => c.id == widget.item.clienteId).firstOrNull;
                if (cliente != null) {
                  Navigator.pop(widget.parentContext);
                  Navigator.pushNamed(widget.parentContext, '/ficha-cliente', arguments: cliente);
                }
              },
              icon: const Icon(Icons.open_in_new, size: 16),
              label: Text('Perfil', style: GoogleFonts.inter(fontSize: 12)),
              style: TextButton.styleFrom(foregroundColor: EfectivaColors.azulPrincipal, padding: const EdgeInsets.symmetric(horizontal: 8)),
            ),
          ]),
          Text(widget.item.clienteNombre, style: GoogleFonts.inter(fontSize: 13, color: EfectivaColors.grisTexto)),
          const SizedBox(height: 16),
          Text('Resultado de la visita', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: EfectivaColors.negroTexto)),
          const SizedBox(height: 10),
          Row(children: _opciones.map((op) => Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: GestureDetector(
                onTap: () => setState(() => _resultadoSeleccionado = op['label']),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: _resultadoSeleccionado == op['label']
                        ? (op['color'] as Color).withValues(alpha: 0.12) : EfectivaColors.grisFondo,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _resultadoSeleccionado == op['label'] ? op['color'] : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(children: [
                    Icon(op['icon'] as IconData, color: op['color'] as Color, size: 22),
                    const SizedBox(height: 4),
                    Text(op['label'] as String,
                      style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600,
                          color: _resultadoSeleccionado == op['label'] ? op['color'] : EfectivaColors.grisTexto),
                      textAlign: TextAlign.center),
                  ]),
                ),
              ),
            ),
          )).toList()),
          const SizedBox(height: 14),
          TextField(
            controller: _obsCtrl,
            maxLength: 200,
            decoration: InputDecoration(
              hintText: 'Observaciones (opcional)...',
              filled: true, fillColor: EfectivaColors.grisFondo,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.all(14),
              counterText: '',
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _resultadoSeleccionado == null || _enviando ? null : _confirmar,
              style: FilledButton.styleFrom(
                backgroundColor: EfectivaColors.azulPrincipal,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _enviando
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('Confirmar resultado', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      ),
    );
  }

  Future<void> _confirmar() async {
    setState(() => _enviando = true);

    double? lat;
    double? lng;
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      lat = pos.latitude;
      lng = pos.longitude;
    } catch (_) {
      // Si falla el GPS, se envía null y el backend/repositorio usa valor por defecto
    }

    await widget.vm.registrarResultadoVisita(
      itemId: widget.item.id,
      estadoVisita: _resultadoSeleccionado!,
      observacion: _obsCtrl.text.isNotEmpty ? _obsCtrl.text : null,
      lat: lat,
      lng: lng,
    );
    if (mounted) Navigator.pop(context);
  }
}
