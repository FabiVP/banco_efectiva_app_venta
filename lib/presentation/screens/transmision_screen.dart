import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../viewmodels/ventas_viewmodel.dart';

class TransmisionScreen extends StatefulWidget {
  const TransmisionScreen({super.key});

  @override
  State<TransmisionScreen> createState() => _TransmisionScreenState();
}

class _TransmisionScreenState extends State<TransmisionScreen> {
  bool _transmitiendo = false;
  int _transmitidos = 0;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SolicitudViewModel>();
    final pendientes = vm.solicitudes.where((s) => !s.transmitido).toList();

    return Scaffold(
      backgroundColor: EfectivaColors.grisFondo,
      appBar: AppBar(title: const Text('Transmisión Electrónica')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Estado de conexión
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  color: EfectivaColors.verdeSuave,
                  borderRadius: BorderRadius.circular(20)),
                child: const Icon(Icons.cell_tower, color: EfectivaColors.verdeExito, size: 36),
              ),
              const SizedBox(height: 16),
              Text('Estado de Conexión', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: EfectivaColors.negroTexto)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(color: EfectivaColors.verdeSuave, borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: EfectivaColors.verdeExito, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text('Conectado', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: EfectivaColors.verdeExito)),
                ]),
              ),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _statItem('Pendientes', '${pendientes.length}', EfectivaColors.naranjaAcento),
                Container(width: 1, height: 30, color: EfectivaColors.grisClaro),
                _statItem('Transmitidos hoy', '$_transmitidos', EfectivaColors.verdeExito),
                Container(width: 1, height: 30, color: EfectivaColors.grisClaro),
                _statItem('Total', '${vm.totalSolicitudes}', EfectivaColors.azulPrincipal),
              ]),
            ]),
          ),
          const SizedBox(height: 20),
          // Botón transmitir todo
          if (pendientes.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: EfectivaColors.gradienteVerde,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: EfectivaColors.verdeExito.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
              ),
              child: Column(children: [
                Text('${pendientes.length} solicitudes pendientes', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 4),
                Text('Se enviarán al sistema central de Efectiva', style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _transmitiendo ? null : () => _transmitirTodo(vm, pendientes.length),
                    icon: _transmitiendo
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.cloud_upload, size: 20),
                    label: Text(_transmitiendo ? 'Transmitiendo...' : 'Transmitir todo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, foregroundColor: EfectivaColors.verdeExito,
                      minimumSize: const Size(0, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 20),
          ],
          // Lista de pendientes
          if (pendientes.isNotEmpty) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Detalle de pendientes', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: EfectivaColors.negroTexto)),
            ),
            const SizedBox(height: 10),
            ...pendientes.map((s) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: EfectivaColors.amarilloClaro, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.cloud_off, color: EfectivaColors.naranjaAcento, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s.clienteNombre, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: EfectivaColors.negroTexto)),
                  Text('${s.id} · S/ ${s.montoSolicitado.toStringAsFixed(0)}', style: GoogleFonts.inter(fontSize: 11, color: EfectivaColors.grisTexto)),
                ])),
                IconButton(
                  onPressed: () async {
                    final ok = await vm.transmitirSolicitud(s.id);
                    if (context.mounted && ok) {
                      setState(() => _transmitidos++);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${s.id} transmitido'), backgroundColor: EfectivaColors.verdeExito));
                    }
                  },
                  icon: const Icon(Icons.send, size: 18, color: EfectivaColors.verdeExito),
                ),
              ]),
            )),
          ] else ...[
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: EfectivaColors.verdeSuave, borderRadius: BorderRadius.circular(20)),
              child: Column(children: [
                const Icon(Icons.cloud_done, size: 56, color: EfectivaColors.verdeExito),
                const SizedBox(height: 12),
                Text('¡Todo sincronizado!', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: EfectivaColors.verdeExito)),
                const SizedBox(height: 4),
                Text('Todas las solicitudes han sido transmitidas al sistema central.',
                  style: GoogleFonts.inter(fontSize: 13, color: EfectivaColors.grisTexto), textAlign: TextAlign.center),
              ]),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(children: [
      Text(value, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
      Text(label, style: GoogleFonts.inter(fontSize: 11, color: EfectivaColors.grisTexto)),
    ]);
  }

  Future<void> _transmitirTodo(SolicitudViewModel vm, int count) async {
    setState(() => _transmitiendo = true);
    final pendIds = vm.solicitudes.where((s) => !s.transmitido).map((s) => s.id).toList();
    for (final id in pendIds) {
      await vm.transmitirSolicitud(id);
    }
    if (mounted) {
      setState(() {
        _transmitiendo = false;
        _transmitidos += count;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$count solicitudes transmitidas exitosamente'),
        backgroundColor: EfectivaColors.verdeExito,
      ));
    }
  }
}
