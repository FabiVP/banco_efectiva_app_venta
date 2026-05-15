import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/cliente_model.dart';

class FichaClienteScreen extends StatelessWidget {
  const FichaClienteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cliente = ModalRoute.of(context)!.settings.arguments as Cliente;
    final moneyFmt = NumberFormat('#,##0.00', 'es');
    return Scaffold(
      backgroundColor: EfectivaColors.grisFondo,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 220, pinned: true,
          backgroundColor: EfectivaColors.azulPrincipal,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(gradient: EfectivaColors.gradientePrincipal),
              child: SafeArea(child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                child: Column(children: [
                  Container(
                    width: 70, height: 70,
                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 8))]),
                    child: Center(child: Text(cliente.iniciales, style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: EfectivaColors.azulPrincipal))),
                  ),
                  const SizedBox(height: 12),
                  Text(cliente.nombreCompleto, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white), textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  Text('DNI: ${cliente.dni}', style: GoogleFonts.inter(fontSize: 14, color: Colors.white70)),
                ]),
              )),
            ),
          ),
        ),
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Badges
            Row(children: [
              _badge(cliente.calificacion, _califColor(cliente.calificacion)),
              const SizedBox(width: 8),
              if (cliente.tieneRenovacion) _badge('Renovación', EfectivaColors.verdeExito),
              const SizedBox(width: 8),
              _badge('${cliente.creditosAnteriores} créditos', EfectivaColors.azulPrincipal),
            ]),
            const SizedBox(height: 20),
            // Datos personales
            _section('Datos Personales', [
              _row('Teléfono', cliente.telefono, Icons.phone),
              _row('Email', cliente.email.isEmpty ? 'No registrado' : cliente.email, Icons.email),
              _row('Dirección', cliente.direccion, Icons.location_on),
              _row('Fecha Nac.', DateFormat('dd/MM/yyyy').format(cliente.fechaNacimiento), Icons.cake),
              _row('Estado Civil', cliente.estadoCivil, Icons.favorite),
              _row('Ocupación', cliente.ocupacion, Icons.work),
              _row('Ingreso', 'S/ ${moneyFmt.format(cliente.ingresoMensual)}', Icons.attach_money),
            ]),
            const SizedBox(height: 16),
            // Historial crediticio
            _section('Historial Crediticio', [
              _row('Créditos anteriores', '${cliente.creditosAnteriores}', Icons.history),
              _row('Monto máx. aprobado', 'S/ ${moneyFmt.format(cliente.montoMaximoAprobado)}', Icons.trending_up),
              _row('Calificación', cliente.calificacion, Icons.star),
              if (cliente.fechaUltimoCredito != null)
                _row('Último crédito', DateFormat('dd/MM/yyyy').format(cliente.fechaUltimoCredito!), Icons.calendar_today),
            ]),
            const SizedBox(height: 16),
            // Productos activos
            if (cliente.productosActivos.isNotEmpty) ...[
              Text('Productos Activos', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: EfectivaColors.negroTexto)),
              const SizedBox(height: 10),
              ...cliente.productosActivos.map((p) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: p.estado == 'Vigente' ? EfectivaColors.verdeExito.withValues(alpha: 0.3) : EfectivaColors.grisClaro)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(p.tipo, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: EfectivaColors.negroTexto)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: p.estado == 'Vigente' ? EfectivaColors.verdeSuave : EfectivaColors.grisClaro,
                        borderRadius: BorderRadius.circular(6)),
                      child: Text(p.estado, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600,
                        color: p.estado == 'Vigente' ? EfectivaColors.verdeExito : EfectivaColors.grisTexto)),
                    ),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Monto original', style: GoogleFonts.inter(fontSize: 10, color: EfectivaColors.grisSubtitulo)),
                      Text('S/ ${moneyFmt.format(p.montoOriginal)}', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: EfectivaColors.negroTexto)),
                    ])),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Saldo pendiente', style: GoogleFonts.inter(fontSize: 10, color: EfectivaColors.grisSubtitulo)),
                      Text('S/ ${moneyFmt.format(p.saldoPendiente)}', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: EfectivaColors.naranjaAcento)),
                    ])),
                  ]),
                  const SizedBox(height: 10),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('${p.cuotasPagadas}/${p.cuotasTotales} cuotas', style: GoogleFonts.inter(fontSize: 12, color: EfectivaColors.grisTexto)),
                    Text('${(p.porcentajeAvance * 100).toInt()}%', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: EfectivaColors.verdeExito)),
                  ]),
                  const SizedBox(height: 6),
                  LinearPercentIndicator(
                    padding: EdgeInsets.zero, lineHeight: 6,
                    percent: p.porcentajeAvance,
                    backgroundColor: EfectivaColors.grisClaro,
                    progressColor: EfectivaColors.verdeExito,
                    barRadius: const Radius.circular(3),
                  ),
                ]),
              )),
            ],
            const SizedBox(height: 20),
            // Acciones
            Row(children: [
              Expanded(child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/nueva-solicitud'),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Nueva solicitud'),
                style: ElevatedButton.styleFrom(backgroundColor: EfectivaColors.azulPrincipal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              )),
              const SizedBox(width: 10),
              Expanded(child: OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/consulta-buro'),
                icon: const Icon(Icons.verified_user_outlined, size: 18),
                label: const Text('Consultar buró'),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              )),
            ]),
            const SizedBox(height: 40),
          ]),
        )),
      ]),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Widget _section(String title, List<Widget> rows) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: EfectivaColors.negroTexto)),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(children: rows),
      ),
    ]);
  }

  Widget _row(String label, String value, IconData icon) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(children: [
      Icon(icon, size: 18, color: EfectivaColors.azulPrincipal.withValues(alpha: 0.6)),
      const SizedBox(width: 10),
      Text(label, style: GoogleFonts.inter(fontSize: 13, color: EfectivaColors.grisTexto)),
      const Spacer(),
      Flexible(child: Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: EfectivaColors.negroTexto), textAlign: TextAlign.end)),
    ]));
  }

  Color _califColor(String c) {
    switch (c) { case 'A': return EfectivaColors.verdeExito; case 'B': return EfectivaColors.naranjaAcento; case 'C': return EfectivaColors.amarilloAcento; default: return EfectivaColors.grisTexto; }
  }
}
