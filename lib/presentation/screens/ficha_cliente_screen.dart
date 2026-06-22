import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/cliente_model.dart';

class FichaClienteScreen extends StatefulWidget {
  const FichaClienteScreen({super.key});

  @override
  State<FichaClienteScreen> createState() => _FichaClienteScreenState();
}

class _FichaClienteScreenState extends State<FichaClienteScreen> {
  final Map<String, List<String>> _notasInternas = {};

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
                  Text('DNI: ${cliente.numeroDocumento}', style: GoogleFonts.inter(fontSize: 14, color: Colors.white70)),
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
              if (cliente.calificacionSbs != null)
                _badge(cliente.calificacionSbs!, _califColor(cliente.calificacionSbs!)),
              if (cliente.esProspecto) ...[
                const SizedBox(width: 8),
                _badge('Prospecto', EfectivaColors.naranjaAcento),
              ],
            ]),
            const SizedBox(height: 20),
            // Datos personales
            _section('Datos Personales', [
              _row('Teléfono', cliente.telefono ?? 'No registrado', Icons.phone),
              _row('Email', cliente.email?.isEmpty == true ? 'No registrado' : cliente.email ?? '', Icons.email),
              _row('Dirección', cliente.direccion ?? 'No registrada', Icons.location_on),
              if (cliente.fechaNacimiento != null)
                _row('Fecha Nac.', DateFormat('dd/MM/yyyy').format(cliente.fechaNacimiento!), Icons.cake),
              _row('Estado Civil', cliente.estadoCivil ?? 'No registrado', Icons.favorite),
              _row('Tipo Negocio', cliente.tipoNegocio ?? 'No registrado', Icons.work),
              if (cliente.ingresosEstimados != null)
                _row('Ingreso Estimado', 'S/ ${moneyFmt.format(cliente.ingresosEstimados)}', Icons.attach_money),
            ]),
            const SizedBox(height: 16),
            // Información del negocio
            if (cliente.nombreNegocio != null || cliente.antiguedadNegocioMeses != null)
              _section('Negocio', [
                if (cliente.nombreNegocio != null)
                  _row('Nombre', cliente.nombreNegocio!, Icons.store),
                if (cliente.antiguedadNegocioMeses != null)
                  _row('Antigüedad', '${cliente.antiguedadNegocioMeses} meses', Icons.timer),
              ]),
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
            const SizedBox(height: 16),
            // Notas internas
            _section('Notas Internas', [
              if (_notasInternas[cliente.id] != null && _notasInternas[cliente.id]!.isNotEmpty)
                ..._notasInternas[cliente.id]!.map((n) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: EfectivaColors.grisFondo, borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [
                    const Icon(Icons.note, size: 14, color: EfectivaColors.grisSubtitulo),
                    const SizedBox(width: 6),
                    Expanded(child: Text(n, style: GoogleFonts.inter(fontSize: 12, color: EfectivaColors.grisTexto, fontStyle: FontStyle.italic))),
                  ]),
                ))
              else
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text('Sin notas internas', style: GoogleFonts.inter(fontSize: 12, color: EfectivaColors.grisTexto, fontStyle: FontStyle.italic)),
                ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.add_comment, size: 16),
                  label: const Text('Agregar nota'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _agregarNota(cliente.id),
                ),
              ),
            ]),
            const SizedBox(height: 40),
          ]),
        )),
      ]),
    );
  }

  Future<void> _agregarNota(String clienteId) async {
    final ctrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Nueva nota', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Escribe tu nota interna...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (result != null && result.trim().isNotEmpty) {
      setState(() {
        _notasInternas.putIfAbsent(clienteId, () => []);
        _notasInternas[clienteId]!.insert(0, '${DateFormat('dd/MM HH:mm').format(DateTime.now())} - $result');
      });
    }
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
    switch (c) { case 'Normal': return EfectivaColors.verdeExito; case 'CPP': return EfectivaColors.naranjaAcento; case 'Deficiente': return EfectivaColors.rojoError; case 'Dudoso': return EfectivaColors.rojoError; case 'Perdida': return EfectivaColors.rojoError; default: return EfectivaColors.grisTexto; }
  }
}
