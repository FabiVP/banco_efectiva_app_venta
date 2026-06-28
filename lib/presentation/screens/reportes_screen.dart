import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/pdf_service.dart';
import '../../data/datasources/cartera_demo_data.dart';
import '../viewmodels/ventas_viewmodel.dart';

/// M11 — Reportes y supervisión (HU-32, HU-33)
class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});
  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Reportes', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
        backgroundColor: EfectivaColors.azulPrincipal,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined, color: Colors.white),
            tooltip: 'Exportar PDF',
            onPressed: _exportarPdf,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: EfectivaColors.naranjaAcento,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
          tabs: const [Tab(text: 'Monitor Tiempo Real'), Tab(text: 'Productividad')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _MonitorTiempoReal(),
          _ProductividadTab(),
        ],
      ),
    );
  }

  void _exportarPdf() {
    final vm = context.read<SolicitudViewModel>();
    final solicitudes = vm.solicitudes;
    if (solicitudes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('No hay solicitudes para exportar', style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: EfectivaColors.rojoError, behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    PdfService.exportarSolicitudPdf(solicitudes.first).then((_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('PDF generado exitosamente', style: GoogleFonts.inter(color: Colors.white)),
          backgroundColor: EfectivaColors.verdeExito, behavior: SnackBarBehavior.floating,
        ));
      }
    }).catchError((e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error al generar PDF: $e', style: GoogleFonts.inter(color: Colors.white)),
          backgroundColor: EfectivaColors.rojoError, behavior: SnackBarBehavior.floating,
        ));
      }
    });
  }
}

// ─── Monitor en tiempo real (HU-32) ─────────────────────────────────────────
class _MonitorTiempoReal extends StatelessWidget {
  const _MonitorTiempoReal();

  @override
  Widget build(BuildContext context) {
    final asesores = [
      {'nombre': 'Carlos Mendoza', 'visitados': 11, 'total': 15, 'zona': 'Los Olivos', 'ultimo': 'hace 5 min'},
      {'nombre': 'Rosa Quispe',   'visitados': 8,  'total': 12, 'zona': 'Independencia', 'ultimo': 'hace 12 min'},
      {'nombre': 'Luis Flores',   'visitados': 14, 'total': 18, 'zona': 'SMP', 'ultimo': 'hace 2 min'},
      {'nombre': 'Ana Paredes',   'visitados': 5,  'total': 10, 'zona': 'Comas', 'ultimo': 'hace 20 min'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Banner de supervisión
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: EfectivaColors.gradienteTarjeta,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: const Icon(Icons.radar, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Monitor en Tiempo Real', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
              Text('Agencia Pro — ${DateFormat('HH:mm', 'es').format(DateTime.now())}',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.white60)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: EfectivaColors.verdeExito.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 6, height: 6, decoration: const BoxDecoration(color: EfectivaColors.verdeExito, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Text('LIVE', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: EfectivaColors.verdeExito)),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        // KPIs globales
        Row(children: [
          Expanded(child: _kpi('Total asesores', '${asesores.length}', EfectivaColors.azulPrincipal, Icons.people_outline)),
          const SizedBox(width: 10),
          Expanded(child: _kpi('Visitas hoy', '${asesores.fold<int>(0, (s, a) => s + (a['visitados'] as int))}', EfectivaColors.verdeExito, Icons.check_circle_outline)),
          const SizedBox(width: 10),
          Expanded(child: _kpi('Pendientes', '${asesores.fold<int>(0, (s, a) => s + ((a['total'] as int) - (a['visitados'] as int)))}', EfectivaColors.naranjaAcento, Icons.pending_actions_outlined)),
        ]),
        const SizedBox(height: 16),
        Text('Avance por asesor', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: EfectivaColors.negroTexto)),
        const SizedBox(height: 10),
        ...asesores.map((a) => _buildAsesorCard(a)),
      ]),
    );
  }

  Widget _kpi(String label, String val, Color color, IconData icon) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 8)]),
    child: Column(children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(height: 4),
      Text(val, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: EfectivaColors.negroTexto)),
      Text(label, style: GoogleFonts.inter(fontSize: 9, color: EfectivaColors.grisTexto), textAlign: TextAlign.center),
    ]),
  );

  Widget _buildAsesorCard(Map<String, dynamic> asesor) {
    final pct = (asesor['visitados'] as int) / (asesor['total'] as int);
    final color = pct >= 0.8 ? EfectivaColors.verdeExito
        : pct >= 0.5 ? EfectivaColors.naranjaAcento
        : EfectivaColors.rojoError;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(asesor['nombre'].split(' ').map((e) => e[0]).take(2).join(''),
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: color)))),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(asesor['nombre'], style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: EfectivaColors.negroTexto)),
            Text('${asesor['zona']} · ${asesor['ultimo']}', style: GoogleFonts.inter(fontSize: 11, color: EfectivaColors.grisSubtitulo)),
          ])),
          Text('${asesor['visitados']}/${asesor['total']}',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
        ]),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: pct, backgroundColor: EfectivaColors.grisClaro,
          valueColor: AlwaysStoppedAnimation<Color>(color), minHeight: 6, borderRadius: BorderRadius.circular(3)),
        const SizedBox(height: 4),
        Text('${(pct * 100).round()}% completado', style: GoogleFonts.inter(fontSize: 10, color: EfectivaColors.grisSubtitulo)),
      ]),
    );
  }
}

// ─── Productividad mensual (HU-33) ───────────────────────────────────────────
class _ProductividadTab extends StatelessWidget {
  const _ProductividadTab();

  @override
  Widget build(BuildContext context) {
    final data = CarteraDemoData.reporteProductividad;
    final totalSol = data.fold<int>(0, (s, d) => s + (d['enviadas'] as int));
    final totalMonto = data.fold<int>(0, (s, d) => s + (d['monto'] as int));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // KPIs del mes
        Row(children: [
          Expanded(child: _miniKpi('Enviadas', '$totalSol', EfectivaColors.azulPrincipal)),
          const SizedBox(width: 8),
          Expanded(child: _miniKpi('Monto total', 'S/ ${NumberFormat('#,##0').format(totalMonto)}', EfectivaColors.verdeExito)),
        ]),
        const SizedBox(height: 16),
        Text('Comparativo por asesor', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: EfectivaColors.negroTexto)),
        const SizedBox(height: 12),
        Container(
          height: 220,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]),
          child: BarChart(BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 25,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, gi, rod, ri) {
                  final labels = ['Enviadas', 'Aprobadas', 'Desembolsadas'];
                  return BarTooltipItem('${labels[ri]}\n${rod.toY.round()}',
                    GoogleFonts.inter(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700));
                },
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(sideTitles: SideTitles(
                showTitles: true, reservedSize: 30,
                getTitlesWidget: (val, meta) {
                  final idx = val.toInt();
                  if (idx < 0 || idx >= data.length) return const SizedBox.shrink();
                  return Padding(padding: const EdgeInsets.only(top: 6), child:
                    Text(data[idx]['nombre'].split(' ')[0],
                      style: GoogleFonts.inter(fontSize: 10, color: EfectivaColors.grisTexto)));
                },
              )),
            ),
            gridData: FlGridData(show: true, drawVerticalLine: false,
              getDrawingHorizontalLine: (v) => const FlLine(color: EfectivaColors.grisClaro, strokeWidth: 1)),
            borderData: FlBorderData(show: false),
            barGroups: data.asMap().entries.map((e) => BarChartGroupData(
              x: e.key, barsSpace: 4,
              barRods: [
                BarChartRodData(toY: (e.value['enviadas'] as int).toDouble(), color: EfectivaColors.azulPrincipal, width: 10, borderRadius: BorderRadius.circular(4)),
                BarChartRodData(toY: (e.value['aprobadas'] as int).toDouble(), color: EfectivaColors.verdeExito, width: 10, borderRadius: BorderRadius.circular(4)),
                BarChartRodData(toY: (e.value['desembolsadas'] as int).toDouble(), color: EfectivaColors.naranjaAcento, width: 10, borderRadius: BorderRadius.circular(4)),
              ],
            )).toList(),
          )),
        ),
        const SizedBox(height: 8),
        // Leyenda
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _leyenda('Enviadas', EfectivaColors.azulPrincipal),
          const SizedBox(width: 16),
          _leyenda('Aprobadas', EfectivaColors.verdeExito),
          const SizedBox(width: 16),
          _leyenda('Desembolsadas', EfectivaColors.naranjaAcento),
        ]),
        const SizedBox(height: 16),
        // Tabla detallada
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]),
          child: Column(children: [
            Row(children: [
              Expanded(flex: 2, child: Text('Asesor', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: EfectivaColors.grisTexto))),
              Expanded(child: Text('Env.', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: EfectivaColors.grisTexto), textAlign: TextAlign.center)),
              Expanded(child: Text('Apr.', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: EfectivaColors.grisTexto), textAlign: TextAlign.center)),
              Expanded(child: Text('Tasa', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: EfectivaColors.grisTexto), textAlign: TextAlign.center)),
            ]),
            const Divider(height: 14),
            ...data.map((d) {
              final tasa = ((d['aprobadas'] as int) / (d['enviadas'] as int) * 100).round();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(children: [
                  Expanded(flex: 2, child: Text(d['nombre'], style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: EfectivaColors.negroTexto))),
                  Expanded(child: Text('${d['enviadas']}', style: GoogleFonts.inter(fontSize: 12, color: EfectivaColors.azulPrincipal, fontWeight: FontWeight.w700), textAlign: TextAlign.center)),
                  Expanded(child: Text('${d['aprobadas']}', style: GoogleFonts.inter(fontSize: 12, color: EfectivaColors.verdeExito, fontWeight: FontWeight.w700), textAlign: TextAlign.center)),
                  Expanded(child: Text('$tasa%', style: GoogleFonts.inter(fontSize: 12, color: tasa >= 80 ? EfectivaColors.verdeExito : EfectivaColors.naranjaAcento, fontWeight: FontWeight.w700), textAlign: TextAlign.center)),
                ]),
              );
            }),
          ]),
        ),
        const SizedBox(height: 80),
      ]),
    );
  }

  Widget _miniKpi(String label, String val, Color color) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 8)]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.inter(fontSize: 11, color: EfectivaColors.grisTexto)),
      const SizedBox(height: 4),
      Text(val, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
    ]),
  );

  Widget _leyenda(String label, Color color) => Row(children: [
    Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
    const SizedBox(width: 4),
    Text(label, style: GoogleFonts.inter(fontSize: 10, color: EfectivaColors.grisTexto)),
  ]);
}
