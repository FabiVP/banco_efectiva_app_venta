import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';
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
  int _paso = 0;
  final _dniCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _consultando = false;
  bool _aceptoTerminos = false;
  ResultadoBuro? _resultado;
  List<ResultadoListaNegra> _listasNegras = [];

  final _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: EfectivaColors.negroTexto,
    exportBackgroundColor: Colors.white,
  );

  @override
  void dispose() {
    _dniCtrl.dispose();
    _nombreCtrl.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EfectivaColors.grisFondo,
      appBar: AppBar(title: const Text('Consulta de Buró')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          _buildStepper(),
          const SizedBox(height: 20),
          if (_paso == 0) _buildConsentimiento(),
          if (_paso == 1) _buildConsultaForm(),
          if (_paso == 2) _buildResultados(),
        ]),
      ),
    );
  }

  Widget _buildStepper() {
    final pasos = ['Consentimiento', 'Consultar', 'Resultados'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(children: List.generate(pasos.length, (i) {
        final activo = i <= _paso;
        return Expanded(child: Row(children: [
          if (i > 0) Expanded(child: Container(height: 2, color: activo ? const Color(0xFF7C3AED) : EfectivaColors.grisClaro)),
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: activo ? const Color(0xFF7C3AED) : EfectivaColors.grisClaro),
            child: Center(child: i < _paso
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text('${i + 1}', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700,
                    color: activo ? Colors.white : EfectivaColors.grisTexto))),
          ),
        ]));
      })),
    );
  }

  // ──────────────────────────────────────────────
  // STEP 0: Consentimiento con firma (RF-57)
  // ──────────────────────────────────────────────
  Widget _buildConsentimiento() {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.verified_user, color: const Color(0xFF7C3AED).withValues(alpha: 0.15), size: 48),
          const SizedBox(height: 12),
          Text('Consentimiento Informado', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(
            'Autorizo a Financiera Efectiva S.A. a consultar mi historial crediticio en centrales de riesgo (SBS, Infocorp, Sentinel) conforme a la Ley N° 29571 - Código de Protección y Defensa del Consumidor.',
            style: GoogleFonts.inter(fontSize: 13, color: EfectivaColors.grisTexto, height: 1.5),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nombreCtrl,
            decoration: const InputDecoration(
              labelText: 'Nombres completos del cliente',
              prefixIcon: Icon(Icons.person_outline, color: EfectivaColors.azulPrincipal),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingrese el nombre' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _dniCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'N° DNI del cliente',
              prefixIcon: Icon(Icons.badge_outlined, color: EfectivaColors.azulPrincipal),
            ),
            validator: Validators.dni,
          ),
          const SizedBox(height: 20),
          Text('Firma digital del cliente:', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: EfectivaColors.grisClaro),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Signature(
              controller: _signatureController,
              height: 150,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Row(children: [
            TextButton.icon(
              icon: const Icon(Icons.refresh, size: 16),
              label: Text('Limpiar', style: GoogleFonts.inter(fontSize: 12)),
              onPressed: () => _signatureController.clear(),
            ),
            const Spacer(),
            Text(
              _signatureController.isNotEmpty ? '✓ Firmado' : 'Toque para firmar',
              style: GoogleFonts.inter(fontSize: 11, color: _signatureController.isNotEmpty ? EfectivaColors.verdeExito : EfectivaColors.grisTexto),
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Checkbox(
              value: _aceptoTerminos,
              activeColor: const Color(0xFF7C3AED),
              onChanged: (v) => setState(() => _aceptoTerminos = v ?? false),
            ),
            Expanded(child: Text(
              'He leído y acepto los términos del consentimiento informado',
              style: GoogleFonts.inter(fontSize: 12, color: EfectivaColors.negroTexto),
            )),
          ]),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: Text('Continuar a consulta', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                minimumSize: const Size(0, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _aceptoTerminos && _signatureController.isNotEmpty ? _avanzarConsulta : null,
            ),
          ),
        ]),
      ),
    );
  }

  Future<void> _avanzarConsulta() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_signatureController.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Debe firmar el consentimiento')));
      return;
    }
    final firmaData = await _signatureController.toPngBytes();
    if (firmaData == null) return;
    debugPrint('Consentimiento guardado para ${_nombreCtrl.text}');
    setState(() => _paso = 1);
  }

  // ──────────────────────────────────────────────
  // STEP 1: Consulta (RF-57 + RF-60/61)
  // ──────────────────────────────────────────────
  Widget _buildConsultaForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20)),
          child: const Icon(Icons.search, color: Color(0xFF7C3AED), size: 36),
        ),
        const SizedBox(height: 16),
        Text('Verificación Crediticia', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Consultando para ${_nombreCtrl.text} (${_dniCtrl.text})',
          style: GoogleFonts.inter(fontSize: 13, color: EfectivaColors.grisTexto)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            Icon(Icons.info_outline, size: 16, color: const Color(0xFF7C3AED)),
            const SizedBox(width: 8),
            Expanded(child: Text('También se consultarán listas negras (OFAC, SUNAT, SBS)',
              style: GoogleFonts.inter(fontSize: 11, color: EfectivaColors.grisTexto))),
          ]),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _consultando ? null : _consultarBuro,
            icon: _consultando
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.cloud_download, size: 18),
            label: Text(_consultando ? 'Consultando...' : 'Consultar buró + listas'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => setState(() => _paso = 0),
          child: Text('Volver a consentimiento', style: GoogleFonts.inter(fontSize: 12, color: EfectivaColors.grisTexto)),
        ),
      ]),
    );
  }

  Future<void> _consultarBuro() async {
    setState(() => _consultando = true);

    // RF-57: Consulta buró
    _resultado = await context.read<SolicitudViewModel>().consultarBuro(_dniCtrl.text);

    // RF-60/61: Consulta listas negras simulada
    await Future.delayed(const Duration(milliseconds: 800));
    _listasNegras = [
      ResultadoListaNegra(lista: 'OFAC (EE.UU.)', coincide: false),
      ResultadoListaNegra(lista: 'SUNAT', coincide: false),
      ResultadoListaNegra(lista: 'SBS', coincide: false, detalle: 'Sin registros'),
      ResultadoListaNegra(lista: 'Lista Negra Interna', coincide: _dniCtrl.text.hashCode % 10 == 0),
    ];

    if (mounted) setState(() => _paso = 2);
  }

  // ──────────────────────────────────────────────
  // STEP 2: Resultados (RF-57 + RF-60/61)
  // ──────────────────────────────────────────────
  Widget _buildResultados() {
    if (_resultado == null) return const SizedBox();
    final bloqueado = _listasNegras.any((l) => l.coincide);

    return Column(children: [
      // Resultado buró
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _resultado!.aprobado == true
              ? EfectivaColors.verdeExito.withValues(alpha: 0.3)
              : EfectivaColors.rojoError.withValues(alpha: 0.3))),
        child: Column(children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: bloqueado
                    ? EfectivaColors.rojoError
                    : _resultado!.aprobado == true
                        ? EfectivaColors.verdeExito
                        : EfectivaColors.rojoError,
                width: 4)),
            child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('${_resultado!.puntaje}',
                style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w800,
                  color: bloqueado
                      ? EfectivaColors.rojoError
                      : _resultado!.aprobado == true
                          ? EfectivaColors.verdeExito
                          : EfectivaColors.rojoError)),
              Text('pts', style: GoogleFonts.inter(fontSize: 12, color: EfectivaColors.grisTexto)),
            ])),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: bloqueado
                  ? EfectivaColors.rojoSuave
                  : _resultado!.aprobado == true
                      ? EfectivaColors.verdeSuave
                      : EfectivaColors.rojoSuave,
              borderRadius: BorderRadius.circular(20)),
            child: Text(
              bloqueado
                  ? '❌ BLOQUEADO - LISTAS NEGRAS'
                  : _resultado!.aprobado == true
                      ? '✅ APTO PARA CRÉDITO'
                      : '❌ NO APTO',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700,
                color: bloqueado
                    ? EfectivaColors.rojoError
                    : _resultado!.aprobado == true
                        ? EfectivaColors.verdeExito
                        : EfectivaColors.rojoError),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity, padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: EfectivaColors.grisFondo, borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _infoRow('Nivel de riesgo', _resultado!.scoreRiesgo ?? ''),
              _infoRow('Puntaje', '${_resultado!.puntaje} pts'),
              _infoRow('Cliente', _nombreCtrl.text),
              _infoRow('DNI', _dniCtrl.text),
              const SizedBox(height: 8),
              Text('Detalle:', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
              Text(_resultado!.detalle ?? '', style: GoogleFonts.inter(fontSize: 13, color: EfectivaColors.grisTexto, height: 1.4)),
            ]),
          ),
        ]),
      ),
      const SizedBox(height: 16),
      // Listas negras (RF-60, RF-61)
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20),
          border: Border.all(color: bloqueado ? EfectivaColors.rojoError.withValues(alpha: 0.3) : EfectivaColors.verdeExito.withValues(alpha: 0.3))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.gavel, color: EfectivaColors.negroTexto, size: 20),
            const SizedBox(width: 8),
            Text('Listas Restringidas (RF-61)', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 12),
          ..._listasNegras.map((l) => _buildListaItem(l)),
          if (bloqueado) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: EfectivaColors.rojoSuave, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                const Icon(Icons.warning_amber_rounded, color: EfectivaColors.rojoError, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(
                  'El cliente coincide con listas restringidas. No es posible continuar con la solicitud.',
                  style: GoogleFonts.inter(fontSize: 12, color: EfectivaColors.rojoError, height: 1.4))),
              ]),
            ),
          ],
        ]),
      ),
      const SizedBox(height: 20),
      // Acciones
      Row(children: [
        Expanded(child: OutlinedButton.icon(
          icon: const Icon(Icons.refresh, size: 18),
          label: Text('Nueva consulta', style: GoogleFonts.inter(fontSize: 14)),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            side: const BorderSide(color: Color(0xFF7C3AED)),
          ),
          onPressed: () {
            setState(() {
              _paso = 0;
              _resultado = null;
              _listasNegras = [];
              _dniCtrl.clear();
              _nombreCtrl.clear();
              _aceptoTerminos = false;
              _signatureController.clear();
            });
          },
        )),
        const SizedBox(width: 16),
        if (bloqueado)
          Expanded(child: ElevatedButton.icon(
            icon: const Icon(Icons.block, size: 18),
            label: Text('Rechazar', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: EfectivaColors.rojoError,
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context),
          ))
        else
          Expanded(child: ElevatedButton.icon(
            icon: const Icon(Icons.check_circle, size: 18),
            label: Text('Continuar solicitud', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: EfectivaColors.verdeExito,
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context),
          )),
      ]),
    ]);
  }

  Widget _buildListaItem(ResultadoListaNegra item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: item.coincide ? EfectivaColors.rojoSuave : EfectivaColors.verdeSuave,
        borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Icon(item.coincide ? Icons.cancel : Icons.check_circle,
          color: item.coincide ? EfectivaColors.rojoError : EfectivaColors.verdeExito, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.lista ?? '',
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: EfectivaColors.negroTexto)),
          if (item.detalle != null)
            Text(item.detalle!, style: GoogleFonts.inter(fontSize: 11, color: EfectivaColors.grisTexto)),
        ])),
        Text(item.coincide ? 'COINCIDE' : 'LIMPIO',
          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700,
            color: item.coincide ? EfectivaColors.rojoError : EfectivaColors.verdeExito)),
      ]),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 13, color: EfectivaColors.grisTexto)),
        Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: EfectivaColors.negroTexto)),
      ],
    ));
  }
}
