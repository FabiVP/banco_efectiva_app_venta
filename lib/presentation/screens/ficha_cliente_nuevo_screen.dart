import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/app_colors.dart';
import '../../data/models/cliente_model.dart';
import '../../data/models/cartera_model.dart';
import '../../data/datasources/cartera_demo_data.dart';

class FichaClienteNuevoScreen extends StatelessWidget {
  const FichaClienteNuevoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cliente = ModalRoute.of(context)!.settings.arguments as Cliente;
    final preaprobado = CarteraDemoData.preaprobadoPorCliente(cliente.id);
    final historial = CarteraDemoData.historialPagos(cliente.id);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(slivers: [
        _buildAppBar(context, cliente),
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildTarjetaIdentidad(context, cliente),
            const SizedBox(height: 16),
            _buildPosicionCliente(cliente),
            if (cliente.lat != null && cliente.lng != null) ...[
              const SizedBox(height: 16),
              _buildMiniMap(cliente),
            ],
            const SizedBox(height: 16),
            _buildHistorialGrafico(historial),
            const SizedBox(height: 16),
            _buildHistorialCreditos(cliente),
            const SizedBox(height: 16),
            if (preaprobado != null) _buildOfertaPreaprobada(context, cliente, preaprobado),
            const SizedBox(height: 100),
          ]),
        )),
      ]),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, Cliente cliente) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: EfectivaColors.azulPrincipal,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.phone_outlined, color: Colors.white),
          tooltip: 'Llamar',
          onPressed: () {
            final tel = cliente.telefono ?? '';
            if (tel.isNotEmpty) launchUrl(Uri(scheme: 'tel', path: tel));
          },
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline, color: Colors.white),
          tooltip: 'Nueva solicitud',
          onPressed: () => Navigator.pushNamed(context, '/nueva-solicitud', arguments: cliente),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: EfectivaColors.gradientePrincipal),
          child: SafeArea(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white54, width: 2),
                ),
                child: Center(child: Text(cliente.iniciales,
                  style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white))),
              ),
              const SizedBox(width: 16),
              Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(cliente.nombreCompleto,
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 4),
                Text('DNI: ${cliente.numeroDocumento} · ${cliente.tipoNegocio ?? ''}',
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
                const SizedBox(height: 6),
                _semaforoCriterioSBS(cliente.calificacionSbs ?? 'N'),
              ])),
            ]),
          )),
        ),
      ),
    );
  }

  Widget _buildTarjetaIdentidad(BuildContext context, Cliente cliente) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Datos de contacto', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: EfectivaColors.negroTexto)),
        const SizedBox(height: 12),
        _infoRow(Icons.location_on_outlined, cliente.direccion ?? ''),
        _infoRow(Icons.phone_outlined, cliente.telefono ?? ''),
        if (cliente.email?.isNotEmpty == true) _infoRow(Icons.email_outlined, cliente.email!),
        if (cliente.fechaNacimiento != null)
          _infoRow(Icons.cake_outlined, DateFormat('dd/MM/yyyy').format(cliente.fechaNacimiento!)),
        _infoRow(Icons.favorite_border, cliente.estadoCivil ?? ''),
        _infoRow(Icons.store_outlined, cliente.tipoNegocio ?? ''),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: OutlinedButton.icon(
            icon: const Icon(Icons.phone, size: 16),
            label: const Text('Llamar'),
            onPressed: () {
              final tel = cliente.telefono ?? '';
              if (tel.isNotEmpty) launchUrl(Uri(scheme: 'tel', path: tel));
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: EfectivaColors.azulPrincipal,
              side: const BorderSide(color: EfectivaColors.azulPrincipal),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          )),
          const SizedBox(width: 10),
          Expanded(child: FilledButton.icon(
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Solicitud'),
            onPressed: () => Navigator.pushNamed(context, '/nueva-solicitud', arguments: cliente),
            style: FilledButton.styleFrom(
              backgroundColor: EfectivaColors.naranjaAcento,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          )),
        ]),
      ]),
    );
  }

  Widget _buildPosicionCliente(Cliente cliente) {
    final cuotasPagadas = 0;
    final cuotasMora = 0;
    final deudaTotal = 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Posición del cliente', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: EfectivaColors.negroTexto)),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: _kpiPosicion('Deuda total', 'S/ ${NumberFormat('#,##0', 'es').format(deudaTotal)}', EfectivaColors.azulPrincipal)),
          const SizedBox(width: 10),
          Expanded(child: _kpiPosicion('Cuotas al día', '$cuotasPagadas', EfectivaColors.verdeExito)),
          const SizedBox(width: 10),
          Expanded(child: _kpiPosicion('En mora', '$cuotasMora', EfectivaColors.rojoError)),
        ]),
        if (cliente.ingresosEstimados != null) ...[
          const SizedBox(height: 12),
          Row(children: [
            const Icon(Icons.attach_money, size: 14, color: EfectivaColors.grisSubtitulo),
            const SizedBox(width: 6),
            Text('Ingreso estimado: S/ ${NumberFormat('#,##0', 'es').format(cliente.ingresosEstimados)}',
              style: GoogleFonts.inter(fontSize: 12, color: EfectivaColors.grisTexto)),
          ]),
        ],
      ]),
    );
  }

  Widget _kpiPosicion(String label, String value, Color color) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12)),
    child: Column(children: [
      Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
      const SizedBox(height: 2),
      Text(label, style: GoogleFonts.inter(fontSize: 10, color: EfectivaColors.grisTexto, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
    ]),
  );

  Widget _buildHistorialGrafico(List<PagoMensual> historial) {
    // Calcular indicadores
    final total = historial.where((p) => p.estado != 'sin_cuota').length;
    final puntuales = historial.where((p) => p.estado == 'puntual').length;
    final mora = historial.where((p) => p.estado == 'mora').length;
    final pct = total > 0 ? (puntuales / total * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Comportamiento de pagos (12 meses)', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: EfectivaColors.negroTexto)),
        const SizedBox(height: 14),
        SizedBox(
          height: 120,
          child: BarChart(BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 600,
            barTouchData: BarTouchData(enabled: false),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(sideTitles: SideTitles(
                showTitles: true, reservedSize: 22,
                getTitlesWidget: (val, meta) {
                  final idx = val.toInt();
                  if (idx < 0 || idx >= historial.length) return const SizedBox.shrink();
                  return Text(historial[idx].mes,
                    style: GoogleFonts.inter(fontSize: 8, color: EfectivaColors.grisTexto));
                },
              )),
            ),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: historial.asMap().entries.map((e) {
              final color = switch (e.value.estado) {
                'puntual' => EfectivaColors.verdeExito,
                'mora' => EfectivaColors.rojoError,
                _ => EfectivaColors.grisClaro,
              };
              return BarChartGroupData(x: e.key, barRods: [
                BarChartRodData(toY: e.value.monto, color: color, width: 14, borderRadius: BorderRadius.circular(4)),
              ]);
            }).toList(),
          )),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _indicador('Puntuales', '$pct%', EfectivaColors.verdeExito)),
          Expanded(child: _indicador('Con mora', '$mora mes(es)', EfectivaColors.rojoError)),
          Expanded(child: _indicador('Monto pagado', 'S/ ${NumberFormat('#,##0').format(historial.fold(0.0, (s, p) => s + p.monto))}', EfectivaColors.azulPrincipal)),
        ]),
      ]),
    );
  }

  Widget _indicador(String label, String val, Color color) => Column(children: [
    Text(val, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: color)),
    Text(label, style: GoogleFonts.inter(fontSize: 10, color: EfectivaColors.grisTexto), textAlign: TextAlign.center),
  ]);

  Widget _buildHistorialCreditos(Cliente cliente) {
    return const SizedBox.shrink();
  }

  Widget _buildOfertaPreaprobada(BuildContext context, Cliente cliente, CreditoPreaprobado pre) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EfectivaColors.verdeSuave,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: EfectivaColors.verdeExito.withValues(alpha: 0.4)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(
            color: EfectivaColors.verdeExito.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: const Icon(Icons.verified, color: EfectivaColors.verdeExito, size: 18)),
          const SizedBox(width: 10),
          Text('Oferta preaprobada', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: EfectivaColors.verdeExito)),
          const Spacer(),
          Text('Vence: ${DateFormat('dd/MM').format(pre.fechaVencimiento)}',
            style: GoogleFonts.inter(fontSize: 11, color: EfectivaColors.verdeExito)),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: _miniOferta('Monto máximo', 'S/ ${NumberFormat('#,##0').format(pre.montoMaximo)}', EfectivaColors.verdeExito)),
          Expanded(child: _miniOferta('Plazo sugerido', '${pre.plazoSugeridoMeses} meses', EfectivaColors.azulPrincipal)),
          Expanded(child: _miniOferta('TEA ref.', '${pre.teaReferencial}%', EfectivaColors.naranjaAcento)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Text('Confianza:', style: GoogleFonts.inter(fontSize: 11, color: EfectivaColors.grisTexto)),
          const SizedBox(width: 8),
          Expanded(child: LinearProgressIndicator(
            value: pre.scoreConfianza / 100,
            backgroundColor: EfectivaColors.grisClaro,
            valueColor: const AlwaysStoppedAnimation<Color>(EfectivaColors.verdeExito),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          )),
          const SizedBox(width: 8),
          Text('${pre.scoreConfianza}%', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: EfectivaColors.verdeExito)),
        ]),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.pushNamed(context, '/nueva-solicitud', arguments: cliente),
            style: FilledButton.styleFrom(
              backgroundColor: EfectivaColors.verdeExito,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Usar esta oferta', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    );
  }

  Widget _miniOferta(String label, String val, Color color) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: GoogleFonts.inter(fontSize: 10, color: EfectivaColors.grisTexto)),
    Text(val, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
  ]);

  Widget _semaforoCriterioSBS(String calificacion) {
    final (label, color) = switch (calificacion) {
      'A' => ('Normal · SBS Verde', EfectivaColors.verdeExito),
      'B' => ('CPP · SBS Amarillo', EfectivaColors.amarilloAcento),
      'C' => ('Deficiente · SBS Naranja', EfectivaColors.naranjaAcento),
      'D' => ('Dudoso · SBS Rojo', EfectivaColors.rojoError),
      _ => ('Sin historial', EfectivaColors.grisTexto),
    };
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w500)),
    ]);
  }

  Widget _buildMiniMap(Cliente cliente) {
    final pos = LatLng(cliente.lat!, cliente.lng!);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: EfectivaColors.grisCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.location_on_outlined, size: 16, color: EfectivaColors.rojoError),
          const SizedBox(width: 6),
          Text('Ubicación', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
          const Spacer(),
          SizedBox(
            height: 28,
            child: FilledButton.icon(
              icon: const Icon(Icons.navigation, size: 14),
              label: Text('Navegar', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600)),
              onPressed: () {
                final url = 'https://www.google.com/maps/dir/?api=1&destination=${cliente.lat},${cliente.lng}';
                launchUrl(Uri.parse(url));
              },
              style: FilledButton.styleFrom(
                backgroundColor: EfectivaColors.azulCorporativo,
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 140,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: pos,
                initialZoom: 15,
              ),
              children: [
                TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
                MarkerLayer(markers: [
                  Marker(
                    point: pos,
                    width: 36,
                    height: 36,
                    child: const Icon(Icons.location_on, color: EfectivaColors.rojoError, size: 36),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget _infoRow(IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      Icon(icon, size: 16, color: EfectivaColors.grisSubtitulo),
      const SizedBox(width: 10),
      Expanded(child: Text(text, style: GoogleFonts.inter(fontSize: 13, color: EfectivaColors.grisTexto))),
    ]),
  );
}
