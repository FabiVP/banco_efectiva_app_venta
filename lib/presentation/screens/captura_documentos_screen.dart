import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class CapturaDocumentosScreen extends StatefulWidget {
  const CapturaDocumentosScreen({super.key});

  @override
  State<CapturaDocumentosScreen> createState() => _CapturaDocumentosScreenState();
}

class _CapturaDocumentosScreenState extends State<CapturaDocumentosScreen> {
  final List<_DocItem> _documentos = [
    _DocItem('DNI - Frontal', Icons.credit_card, false),
    _DocItem('DNI - Reverso', Icons.credit_card, false),
    _DocItem('Recibo de servicios', Icons.receipt_long, false),
    _DocItem('Croquis de domicilio', Icons.map_outlined, false),
    _DocItem('Comprobante de ingresos', Icons.attach_money, false),
    _DocItem('Contrato firmado', Icons.description, false),
  ];

  @override
  Widget build(BuildContext context) {
    final capturados = _documentos.where((d) => d.capturado).length;
    return Scaffold(
      backgroundColor: EfectivaColors.grisFondo,
      appBar: AppBar(title: const Text('Captura de Documentos')),
      body: Column(children: [
        // Progreso
        Container(
          padding: const EdgeInsets.all(20), color: Colors.white,
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Documentos capturados', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: EfectivaColors.negroTexto)),
              Text('$capturados/${_documentos.length}', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: EfectivaColors.azulPrincipal)),
            ]),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _documentos.isEmpty ? 0 : capturados / _documentos.length,
                backgroundColor: EfectivaColors.grisClaro,
                valueColor: const AlwaysStoppedAnimation(EfectivaColors.verdeExito),
                minHeight: 8,
              ),
            ),
          ]),
        ),
        // Lista de documentos
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _documentos.length,
          itemBuilder: (context, index) {
            final doc = _documentos[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(16),
                border: doc.capturado ? Border.all(color: EfectivaColors.verdeExito.withValues(alpha: 0.4)) : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _capturarDocumento(index),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          color: doc.capturado ? EfectivaColors.verdeSuave : EfectivaColors.grisFondo,
                          borderRadius: BorderRadius.circular(12)),
                        child: Icon(doc.icon, color: doc.capturado ? EfectivaColors.verdeExito : EfectivaColors.grisSubtitulo, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(doc.nombre, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: EfectivaColors.negroTexto)),
                        Text(doc.capturado ? 'Capturado ✓' : 'Pendiente',
                          style: GoogleFonts.inter(fontSize: 12, color: doc.capturado ? EfectivaColors.verdeExito : EfectivaColors.grisSubtitulo)),
                      ])),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: doc.capturado ? EfectivaColors.verdeSuave : EfectivaColors.azulSuave,
                          borderRadius: BorderRadius.circular(10)),
                        child: Icon(doc.capturado ? Icons.refresh : Icons.camera_alt_outlined,
                          color: doc.capturado ? EfectivaColors.verdeExito : EfectivaColors.azulPrincipal, size: 20),
                      ),
                    ]),
                  ),
                ),
              ),
            );
          },
        )),
        // Botón guardar
        Container(
          padding: const EdgeInsets.all(16), color: Colors.white,
          child: ElevatedButton.icon(
            onPressed: capturados > 0 ? () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('$capturados documentos guardados localmente'),
                backgroundColor: EfectivaColors.verdeExito,
              ));
              Navigator.pop(context);
            } : null,
            icon: const Icon(Icons.save, size: 18),
            label: const Text('Guardar documentos'),
            style: ElevatedButton.styleFrom(backgroundColor: EfectivaColors.verdeExito),
          ),
        ),
      ]),
    );
  }

  void _capturarDocumento(int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: EfectivaColors.grisClaro, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Text('Capturar: ${_documentos[index].nombre}', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: EfectivaColors.negroTexto)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: _captureOption(Icons.camera_alt, 'Cámara', () {
              setState(() => _documentos[index].capturado = true);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('${_documentos[index].nombre} capturado'), backgroundColor: EfectivaColors.verdeExito));
            })),
            const SizedBox(width: 16),
            Expanded(child: _captureOption(Icons.photo_library, 'Galería', () {
              setState(() => _documentos[index].capturado = true);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('${_documentos[index].nombre} capturado'), backgroundColor: EfectivaColors.verdeExito));
            })),
          ]),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  Widget _captureOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: EfectivaColors.grisFondo, borderRadius: BorderRadius.circular(16)),
        child: Column(children: [
          Icon(icon, size: 40, color: EfectivaColors.azulPrincipal),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: EfectivaColors.negroTexto)),
        ]),
      ),
    );
  }
}

class _DocItem {
  final String nombre;
  final IconData icon;
  bool capturado;
  _DocItem(this.nombre, this.icon, this.capturado);
}
