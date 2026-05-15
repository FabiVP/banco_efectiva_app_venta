import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/solicitud_model.dart';
import '../viewmodels/ventas_viewmodel.dart';

class ConsultaBuroScreen extends StatefulWidget {
  const ConsultaBuroScreen({super.key});

  @override
  State<ConsultaBuroScreen> createState() => _ConsultaBuroScreenState();
}

class _ConsultaBuroScreenState extends State<ConsultaBuroScreen> {
  final _dniCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _consultando = false;
  ResultadoBuro? _resultado;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EfectivaColors.grisFondo,
      appBar: AppBar(title: const Text('Consulta de Buró de Crédito')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Formulario
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Form(
              key: _formKey,
              child: Column(children: [
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20)),
                  child: const Icon(Icons.verified_user, color: Color(0xFF7C3AED), size: 36),
                ),
                const SizedBox(height: 16),
                Text('Verificación en Campo', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: EfectivaColors.negroTexto)),
                const SizedBox(height: 4),
                Text('Ingresa el DNI del cliente para consultar su historial crediticio',
                  style: GoogleFonts.inter(fontSize: 13, color: EfectivaColors.grisTexto), textAlign: TextAlign.center),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _dniCtrl, keyboardType: TextInputType.number,
                  validator: Validators.dni,
                  decoration: InputDecoration(
                    labelText: 'N° DNI del cliente',
                    prefixIcon: const Icon(Icons.badge_outlined, color: EfectivaColors.azulPrincipal),
                    suffixIcon: IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () {
                      _dniCtrl.clear();
                      setState(() => _resultado = null);
                    }),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _consultando ? null : _consultarBuro,
                    icon: _consultando
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.search, size: 18),
                    label: Text(_consultando ? 'Consultando...' : 'Consultar buró'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED)),
                  ),
                ),
              ]),
            ),
          ),
          // Resultado
          if (_resultado != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _resultado!.aprobado ? EfectivaColors.verdeExito.withValues(alpha: 0.3) : EfectivaColors.rojoError.withValues(alpha: 0.3)),
              ),
              child: Column(children: [
                // Score visual
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _resultado!.aprobado ? EfectivaColors.verdeExito : EfectivaColors.rojoError, width: 4),
                  ),
                  child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text('${_resultado!.puntaje}', style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w800,
                      color: _resultado!.aprobado ? EfectivaColors.verdeExito : EfectivaColors.rojoError)),
                    Text('pts', style: GoogleFonts.inter(fontSize: 12, color: EfectivaColors.grisTexto)),
                  ])),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _resultado!.aprobado ? EfectivaColors.verdeSuave : EfectivaColors.rojoSuave,
                    borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    _resultado!.aprobado ? '✅ APTO PARA CRÉDITO' : '❌ NO APTO',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700,
                      color: _resultado!.aprobado ? EfectivaColors.verdeExito : EfectivaColors.rojoError),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity, padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: EfectivaColors.grisFondo, borderRadius: BorderRadius.circular(12)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _infoRow('Nivel de riesgo', _resultado!.scoreRiesgo),
                    _infoRow('Puntaje', '${_resultado!.puntaje}'),
                    const SizedBox(height: 8),
                    Text('Detalle:', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: EfectivaColors.negroTexto)),
                    const SizedBox(height: 4),
                    Text(_resultado!.detalle, style: GoogleFonts.inter(fontSize: 13, color: EfectivaColors.grisTexto, height: 1.4)),
                  ]),
                ),
              ]),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 13, color: EfectivaColors.grisTexto)),
        Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: EfectivaColors.negroTexto)),
      ],
    ));
  }

  Future<void> _consultarBuro() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _consultando = true; _resultado = null; });
    _resultado = await context.read<SolicitudViewModel>().consultarBuro(_dniCtrl.text);
    if (mounted) setState(() => _consultando = false);
  }

  @override
  void dispose() { _dniCtrl.dispose(); super.dispose(); }
}
