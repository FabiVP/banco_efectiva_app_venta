import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../viewmodels/ventas_viewmodel.dart';

class CarteraScreen extends StatelessWidget {
  const CarteraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CarteraViewModel>();
    return Scaffold(
      backgroundColor: EfectivaColors.grisFondo,
      appBar: AppBar(
        title: const Text('Cartera del Día'),
        automaticallyImplyLeading: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.people, size: 16, color: Colors.white),
              const SizedBox(width: 4),
              Text('${vm.totalClientes}', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
            ]),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(children: [
              TextField(
                onChanged: vm.buscar,
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre o DNI...',
                  prefixIcon: const Icon(Icons.search, color: EfectivaColors.grisSubtitulo),
                  filled: true, fillColor: EfectivaColors.grisFondo,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              // Filtros
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: ['Todos', 'Renovación', 'Activos', 'Nuevos'].map((f) =>
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
                      side: BorderSide.none,
                    ),
                  ),
                ).toList()),
              ),
            ]),
          ),
          // Lista de clientes
          Expanded(
            child: vm.cargando
                ? const Center(child: CircularProgressIndicator())
                : vm.clientes.isEmpty
                    ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.search_off, size: 64, color: EfectivaColors.grisClaro),
                        const SizedBox(height: 12),
                        Text('No se encontraron clientes', style: GoogleFonts.inter(color: EfectivaColors.grisTexto)),
                      ]))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: vm.clientes.length,
                        itemBuilder: (context, index) {
                          final c = vm.clientes[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.white, borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => Navigator.pushNamed(context, '/ficha-cliente', arguments: c),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(children: [
                                    // Avatar con calificación
                                    Stack(children: [
                                      Container(
                                        width: 50, height: 50,
                                        decoration: BoxDecoration(
                                          gradient: EfectivaColors.gradientePrincipal,
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: Center(child: Text(c.iniciales,
                                          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white))),
                                      ),
                                      if (c.tieneRenovacion)
                                        Positioned(right: -2, top: -2, child: Container(
                                          width: 18, height: 18,
                                          decoration: BoxDecoration(color: EfectivaColors.verdeExito, shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 2)),
                                          child: const Icon(Icons.autorenew, size: 10, color: Colors.white),
                                        )),
                                    ]),
                                    const SizedBox(width: 14),
                                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Text(c.nombreCompleto, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: EfectivaColors.negroTexto)),
                                      const SizedBox(height: 2),
                                      Text('DNI: ${c.dni}', style: GoogleFonts.inter(fontSize: 12, color: EfectivaColors.grisTexto)),
                                      const SizedBox(height: 4),
                                      Row(children: [
                                        _tag(c.calificacion, _califColor(c.calificacion)),
                                        const SizedBox(width: 6),
                                        _tag(c.ocupacion, EfectivaColors.azulPrincipal),
                                      ]),
                                    ])),
                                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                      if (c.productosActivos.isNotEmpty)
                                        Text('${c.productosActivos.length} prod.', style: GoogleFonts.inter(fontSize: 11, color: EfectivaColors.grisSubtitulo)),
                                      const SizedBox(height: 4),
                                      const Icon(Icons.chevron_right, color: EfectivaColors.grisSubtitulo, size: 20),
                                    ]),
                                  ]),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Color _califColor(String cal) {
    switch (cal) {
      case 'A': return EfectivaColors.verdeExito;
      case 'B': return EfectivaColors.naranjaAcento;
      case 'C': return EfectivaColors.amarilloAcento;
      case 'D': return EfectivaColors.rojoError;
      default: return EfectivaColors.grisTexto;
    }
  }
}
