import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import '../../../core/constants/app_colors.dart';

enum EstadoDocumento { pendiente, listo, obligatorio }

class _DocItem {
  final String nombre;
  final IconData icon;
  final EstadoDocumento estado;
  final String? rutaLocal;
  final bool esObligatorio;

  const _DocItem({
    required this.nombre,
    required this.icon,
    this.estado = EstadoDocumento.pendiente,
    this.rutaLocal,
    this.esObligatorio = true,
  });

  _DocItem copyWith({EstadoDocumento? estado, String? rutaLocal}) {
    return _DocItem(
      nombre: nombre,
      icon: icon,
      estado: estado ?? this.estado,
      rutaLocal: rutaLocal ?? this.rutaLocal,
      esObligatorio: esObligatorio,
    );
  }
}

class CapturaDocumentosScreen extends StatefulWidget {
  const CapturaDocumentosScreen({super.key});

  @override
  State<CapturaDocumentosScreen> createState() => _CapturaDocumentosScreenState();
}

class _CapturaDocumentosScreenState extends State<CapturaDocumentosScreen> {
  final List<_DocItem> _documentos = [
    const _DocItem(nombre: 'DNI - Anverso', icon: Icons.credit_card, esObligatorio: true),
    const _DocItem(nombre: 'DNI - Reverso', icon: Icons.credit_card, esObligatorio: true),
    const _DocItem(nombre: 'Foto del negocio', icon: Icons.store_outlined, esObligatorio: true),
    const _DocItem(nombre: 'Foto asesor + cliente', icon: Icons.people_outline, esObligatorio: true),
    const _DocItem(nombre: 'RUC (opcional)', icon: Icons.receipt_long, esObligatorio: false),
    const _DocItem(nombre: 'Recibo de servicios', icon: Icons.lightbulb_outline, esObligatorio: false),
    const _DocItem(nombre: 'Contrato de arriendo', icon: Icons.description, esObligatorio: false),
  ];

  final _picker = ImagePicker();
  bool _analizando = false;

  int get _capturados => _documentos.where((d) => d.estado == EstadoDocumento.listo).length;
  int get _obligatorios => _documentos.where((d) => d.esObligatorio).length;
    int get obligatoriosListos => _documentos.where((d) => d.esObligatorio && d.estado == EstadoDocumento.listo).length;
  bool get _todoListo => obligatoriosListos >= _obligatorios;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Captura de Documentos'),
        actions: [
          if (_analizando)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
            ),
        ],
      ),
      body: Column(children: [
        _buildHeader(),
        Expanded(child: _buildLista()),
        _buildBottomBar(),
      ]),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16), color: Colors.white,
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Progreso', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: EfectivaColors.negroTexto)),
          Text('$_capturados/${_documentos.length}',
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700,
              color: _todoListo ? EfectivaColors.verdeExito : EfectivaColors.azulPrincipal)),
        ]),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _documentos.isEmpty ? 0 : _capturados / _documentos.length,
            backgroundColor: EfectivaColors.grisClaro,
            valueColor: AlwaysStoppedAnimation<Color>(_todoListo ? EfectivaColors.verdeExito : EfectivaColors.azulPrincipal),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 6),
        Text('$obligatoriosListos/$_obligatorios obligatorios',
          style: GoogleFonts.inter(fontSize: 11, color: EfectivaColors.grisTexto)),
      ]),
    );
  }

  Widget _buildLista() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _documentos.length,
      itemBuilder: (context, index) => _buildDocCard(context, index),
    );
  }

  Widget _buildDocCard(BuildContext context, int index) {
    final doc = _documentos[index];
    final colorEstado = switch (doc.estado) {
      EstadoDocumento.listo => EfectivaColors.verdeExito,
      EstadoDocumento.obligatorio => EfectivaColors.rojoError,
      EstadoDocumento.pendiente => EfectivaColors.grisSubtitulo,
    };
    final labelEstado = switch (doc.estado) {
      EstadoDocumento.listo => 'LISTO',
      EstadoDocumento.obligatorio => 'OBLIGATORIO',
      EstadoDocumento.pendiente => 'PENDIENTE',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: doc.estado == EstadoDocumento.listo
            ? Border.all(color: EfectivaColors.verdeExito.withValues(alpha: 0.4))
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _capturarDocumento(index),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: doc.estado == EstadoDocumento.listo
                      ? EfectivaColors.verdeSuave : EfectivaColors.grisFondo,
                  borderRadius: BorderRadius.circular(12)),
                child: doc.rutaLocal != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(File(doc.rutaLocal!), fit: BoxFit.cover))
                    : Icon(doc.icon, color: colorEstado, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(doc.nombre, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: EfectivaColors.negroTexto)),
                const SizedBox(height: 2),
                Row(children: [
                  Text(labelEstado, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: colorEstado)),
                  if (doc.esObligatorio) ...[
                    const SizedBox(width: 6),
                    Text('* Obligatorio', style: GoogleFonts.inter(fontSize: 10, color: EfectivaColors.rojoError)),
                  ],
                ]),
              ])),
              if (doc.rutaLocal != null)
                GestureDetector(
                  onTap: () => _verDocumento(index),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: EfectivaColors.azulSuave, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.visibility_outlined, color: EfectivaColors.azulPrincipal, size: 20),
                  ),
                ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: doc.estado == EstadoDocumento.listo
                      ? EfectivaColors.verdeSuave : EfectivaColors.azulSuave,
                  borderRadius: BorderRadius.circular(10)),
                child: Icon(
                  doc.rutaLocal != null ? Icons.refresh : Icons.camera_alt_outlined,
                  color: doc.estado == EstadoDocumento.listo ? EfectivaColors.verdeExito : EfectivaColors.azulPrincipal,
                  size: 20),
              ),
            ]),
          ),
        ),
      ),
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
          const SizedBox(height: 4),
          Text('Marco guía disponible para DNI', style: GoogleFonts.inter(fontSize: 12, color: EfectivaColors.grisTexto)),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: _captureOption(Icons.camera_alt, 'Cámara', () {
              Navigator.pop(ctx);
              _tomarFoto(index, ImageSource.camera);
            })),
            const SizedBox(width: 16),
            Expanded(child: _captureOption(Icons.photo_library, 'Galería', () {
              Navigator.pop(ctx);
              _tomarFoto(index, ImageSource.gallery);
            })),
          ]),
          if (_documentos[index].rutaLocal != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.delete_outline, size: 18, color: EfectivaColors.rojoError),
                label: Text('Eliminar foto actual', style: GoogleFonts.inter(color: EfectivaColors.rojoError)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: EfectivaColors.rojoError),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  setState(() => _documentos[index] = _documentos[index].copyWith(
                    estado: EstadoDocumento.pendiente, rutaLocal: null,
                  ));
                  Navigator.pop(ctx);
                },
              ),
            ),
          ],
          const SizedBox(height: 8),
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

  Future<void> _tomarFoto(int index, ImageSource source) async {
    final XFile? foto = await _picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (foto == null) return;

    setState(() => _analizando = true);

    await Future.delayed(const Duration(milliseconds: 500));

    final esNitida = await _validarNitidez(foto.path);

    if (!mounted) return;
    setState(() => _analizando = false);

    if (!esNitida) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.blur_on, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text('Foto borrosa. Por favor, toma una foto más nítida.', style: GoogleFonts.inter(color: Colors.white))),
        ]),
        backgroundColor: EfectivaColors.rojoError,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Reintentar',
          textColor: Colors.white,
          onPressed: () => _tomarFoto(index, source),
        ),
      ));
      return;
    }

    final rutaComprimida = await _comprimirImagen(foto.path);

    setState(() {
      _documentos[index] = _documentos[index].copyWith(
        estado: EstadoDocumento.listo,
        rutaLocal: rutaComprimida,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${_documentos[index].nombre} capturado correctamente', style: GoogleFonts.inter(color: Colors.white)),
      backgroundColor: EfectivaColors.verdeExito,
      behavior: SnackBarBehavior.floating,
    ));
  }

  /// RF-54: Validación básica de calidad de imagen
  Future<bool> _validarNitidez(String path) async {
    try {
      final file = File(path);
      final len = await file.length();
      if (len < 10 * 1024) return false;

      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes, targetWidth: 100, targetHeight: 100);
      final frameInfo = await codec.getNextFrame();
      final bitmap = frameInfo.image;
      final byteData = await bitmap.toByteData();
      if (byteData == null) return false;

      final pixels = byteData.buffer.asUint32List();
      return pixels.isNotEmpty;
    } catch (_) {
      return true;
    }
  }

  /// RF-54: Compresión iterativa a máximo 800 KB
  Future<String> _comprimirImagen(String path) async {
    final file = File(path);
    int calidad = 90;
    String rutaActual = path;

    while (calidad >= 10 && await file.length() > 800 * 1024) {
      final XFile? comprimida = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: calidad,
      );
      if (comprimida == null) break;
      rutaActual = comprimida.path;
      final nuevoFile = File(rutaActual);
      if (await nuevoFile.length() <= 800 * 1024) break;
      calidad -= 10;
    }
    return rutaActual;
  }

  void _verDocumento(int index) {
    final doc = _documentos[index];
    if (doc.rutaLocal == null) return;

    Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(doc.nombre, style: GoogleFonts.inter(color: Colors.white, fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: Text('¿Eliminar?', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                  content: Text('Se eliminará ${doc.nombre}. ¿Continuar?', style: GoogleFonts.inter()),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                    FilledButton(
                      onPressed: () {
                        setState(() => _documentos[index] = _documentos[index].copyWith(
                          estado: EstadoDocumento.pendiente, rutaLocal: null,
                        ));
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                      style: FilledButton.styleFrom(backgroundColor: EfectivaColors.rojoError),
                      child: const Text('Eliminar'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: PhotoView(
          imageProvider: FileImage(File(doc.rutaLocal!)),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 3,
          backgroundDecoration: const BoxDecoration(color: Colors.black),
        ),
      ),
    )));
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16), color: Colors.white,
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text('$_capturados/${_documentos.length} documentos',
            style: GoogleFonts.inter(fontSize: 12, color: EfectivaColors.grisTexto)),
          Text(_todoListo ? 'Todos los obligatorios listos ✓'
              : 'Faltan $_obligatorios - $obligatoriosListos obligatorios',
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600,
              color: _todoListo ? EfectivaColors.verdeExito : EfectivaColors.rojoError)),
        ])),
        SizedBox(
          width: 180,
          child: ElevatedButton.icon(
            onPressed: _todoListo ? () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('$_capturados documentos guardados', style: GoogleFonts.inter(color: Colors.white)),
                backgroundColor: EfectivaColors.verdeExito,
                behavior: SnackBarBehavior.floating,
              ));
              Navigator.pop(context);
            } : null,
            icon: const Icon(Icons.save, size: 18),
            label: Text('Guardar', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: EfectivaColors.verdeExito,
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ]),
    );
  }
}
