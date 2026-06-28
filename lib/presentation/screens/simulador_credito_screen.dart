import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';

/// M5 — Simulador de crédito independiente (HU-19)
/// Formula amortización francesa (RF-47)
class SimuladorCreditoScreen extends StatefulWidget {
  const SimuladorCreditoScreen({super.key});
  @override
  State<SimuladorCreditoScreen> createState() => _SimuladorCreditoScreenState();
}

class _SimuladorCreditoScreenState extends State<SimuladorCreditoScreen> {
  double _monto = 5000;
  int _plazo = 12;
  final double _tea = 42.0; // TEA referencial Efectiva
  final _fmt = NumberFormat('#,##0.00', 'es');

  final List<int> _plazos = [3, 6, 12, 18, 24, 36, 48, 60];

  double get _tasaMensual => pow(1 + _tea / 100, 1 / 12) - 1;

  double get _cuotaMensual {
    final r = _tasaMensual;
    return _monto * r / (1 - pow(1 + r, -_plazo));
  }

  double get _totalPagar => _cuotaMensual * _plazo;
  double get _costoFinanciero => _totalPagar - _monto;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Simulador de Crédito', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
        backgroundColor: EfectivaColors.azulPrincipal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Tarjeta de resultado en tiempo real
          _buildResultCard(),
          const SizedBox(height: 20),
          // Controles
          _buildControles(),
          const SizedBox(height: 20),
          // Tabla de amortización simplificada
          _buildResumenAmortizacion(),
          const SizedBox(height: 20),
          // Botón de acción
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: const Icon(Icons.description_outlined),
              label: Text('Crear solicitud con estos datos', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
              onPressed: () => Navigator.pushNamed(context, '/nueva-solicitud',
                arguments: {'monto': _monto, 'plazo': _plazo}),
              style: FilledButton.styleFrom(
                backgroundColor: EfectivaColors.naranjaAcento,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Sin conexión a red — Cálculo local con TEA ${_tea.toStringAsFixed(1)}%',
            style: GoogleFonts.inter(fontSize: 11, color: EfectivaColors.grisSubtitulo),
            textAlign: TextAlign.center),
          const SizedBox(height: 80),
        ]),
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: EfectivaColors.gradienteTarjeta,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: EfectivaColors.azulOscuro.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(children: [
        Text('Crédito simulado', style: GoogleFonts.inter(fontSize: 14, color: Colors.white60, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text('S/ ${NumberFormat('#,##0').format(_monto.round())}',
          style: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white)),
        Text('por $_plazo meses', style: GoogleFonts.inter(fontSize: 14, color: Colors.white70)),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: _metricaCard('Cuota mensual', 'S/ ${_fmt.format(_cuotaMensual)}', EfectivaColors.naranjaAcento)),
          const SizedBox(width: 10),
          Expanded(child: _metricaCard('Total a pagar', 'S/ ${_fmt.format(_totalPagar)}', Colors.white70)),
          const SizedBox(width: 10),
          Expanded(child: _metricaCard('Costo financiero', 'S/ ${_fmt.format(_costoFinanciero)}', const Color(0xFFFF6B6B))),
        ]),
      ]),
    );
  }

  Widget _metricaCard(String label, String value, Color color) => Column(children: [
    Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
    Text(label, style: GoogleFonts.inter(fontSize: 9, color: Colors.white54), textAlign: TextAlign.center),
  ]);

  Widget _buildControles() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Monto: S/ ${NumberFormat('#,##0').format(_monto.round())}',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: EfectivaColors.negroTexto)),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(activeTrackColor: EfectivaColors.azulPrincipal, thumbColor: EfectivaColors.azulPrincipal),
          child: Slider(value: _monto, min: 500, max: 150000, divisions: 299,
            onChanged: (v) => setState(() => _monto = v)),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('S/ 500', style: GoogleFonts.inter(fontSize: 11, color: EfectivaColors.grisSubtitulo)),
          Text('S/ 150,000', style: GoogleFonts.inter(fontSize: 11, color: EfectivaColors.grisSubtitulo)),
        ]),
        const SizedBox(height: 16),
        Text('Plazo (meses)', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: EfectivaColors.negroTexto)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: _plazos.map((p) => ChoiceChip(
          label: Text('$p m'),
          selected: _plazo == p,
          onSelected: (_) => setState(() => _plazo = p),
          selectedColor: EfectivaColors.azulPrincipal,
          backgroundColor: EfectivaColors.grisClaro,
          labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600,
              color: _plazo == p ? Colors.white : EfectivaColors.grisTexto),
          side: BorderSide.none,
        )).toList()),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: EfectivaColors.azulSuave, borderRadius: BorderRadius.circular(8)),
          child: Row(children: [
            const Icon(Icons.info_outline, size: 14, color: EfectivaColors.azulPrincipal),
            const SizedBox(width: 8),
            Text('TEA referencial: ${_tea.toStringAsFixed(1)}% · Fórmula francesa',
              style: GoogleFonts.inter(fontSize: 11, color: EfectivaColors.azulPrincipal)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildResumenAmortizacion() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Resumen del crédito', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: EfectivaColors.negroTexto)),
        const SizedBox(height: 12),
        _fila('Monto a financiar', 'S/ ${_fmt.format(_monto)}'),
        _fila('Plazo', '$_plazo cuotas mensuales'),
        _fila('TEA', '${_tea.toStringAsFixed(1)}%'),
        _fila('Tasa mensual', '${(_tasaMensual * 100).toStringAsFixed(3)}%'),
        const Divider(height: 20),
        _fila('Cuota mensual', 'S/ ${_fmt.format(_cuotaMensual)}', bold: true, color: EfectivaColors.azulPrincipal),
        _fila('Total a pagar', 'S/ ${_fmt.format(_totalPagar)}', bold: true),
        _fila('Costo financiero total', 'S/ ${_fmt.format(_costoFinanciero)}', color: EfectivaColors.rojoError),
      ]),
    );
  }

  Widget _fila(String label, String val, {bool bold = false, Color? color}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 13, color: EfectivaColors.grisTexto))),
      Text(val, style: GoogleFonts.inter(fontSize: 13, fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          color: color ?? EfectivaColors.negroTexto)),
    ]),
  );
}
