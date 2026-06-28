import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../data/models/cartera_model.dart';
import '../../data/datasources/cartera_demo_data.dart';

/// M4 — Pre-evaluación y prospección (HU-15, HU-16)
class PreEvaluacionScreen extends StatefulWidget {
  const PreEvaluacionScreen({super.key});
  @override
  State<PreEvaluacionScreen> createState() => _PreEvaluacionScreenState();
}

class _PreEvaluacionScreenState extends State<PreEvaluacionScreen>
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
        title: Text('Pre-evaluación', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
        backgroundColor: EfectivaColors.azulPrincipal,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: EfectivaColors.naranjaAcento,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
          tabs: const [Tab(text: 'Nuevo Prospecto'), Tab(text: 'Campañas Activas')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _FormularioProspecto(),
          _CampanasActivasTab(),
        ],
      ),
    );
  }
}

// ─── Formulario de pre-evaluación de prospecto (HU-15) ──────────────────────
class _FormularioProspecto extends StatefulWidget {
  const _FormularioProspecto();
  @override
  State<_FormularioProspecto> createState() => _FormularioProspectoState();
}

class _FormularioProspectoState extends State<_FormularioProspecto> {
  final _formKey = GlobalKey<FormState>();
  final _dniCtrl = TextEditingController();
  final _nombresCtrl = TextEditingController();
  final _apellidosCtrl = TextEditingController();
  final _ingresosCtrl = TextEditingController();
  final _destinoCtrl = TextEditingController();
  String _tipoNegocio = 'Comercio';
  double _montoSolicitado = 5000;
  bool _evaluando = false;
  ResultadoPreEvaluacion? _resultado;

  final List<String> _tiposNegocio = ['Comercio', 'Servicios', 'Producción', 'Agropecuario'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _seccion('Datos del prospecto'),
          const SizedBox(height: 12),
          _campo('Número de documento (DNI)', _dniCtrl,
            keyboardType: TextInputType.number, maxLength: 8,
            validator: (v) => v != null && v.length == 8 ? null : 'Ingrese 8 dígitos'),
          _campo('Nombres', _nombresCtrl,
            validator: (v) => v != null && v.isNotEmpty ? null : 'Requerido'),
          _campo('Apellidos', _apellidosCtrl,
            validator: (v) => v != null && v.isNotEmpty ? null : 'Requerido'),
          const SizedBox(height: 8),
          Text('Tipo de negocio', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: EfectivaColors.negroTexto)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _tipoNegocio,
            decoration: InputDecoration(
              filled: true, fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            items: _tiposNegocio.map((t) => DropdownMenuItem(value: t, child: Text(t, style: GoogleFonts.inter(fontSize: 14)))).toList(),
            onChanged: (v) => setState(() => _tipoNegocio = v!),
          ),
          const SizedBox(height: 12),
          _campo('Ingresos estimados mensuales (S/)', _ingresosCtrl,
            keyboardType: TextInputType.number,
            validator: (v) => v != null && v.isNotEmpty ? null : 'Requerido'),
          _campo('Destino del crédito', _destinoCtrl,
            validator: (v) => v != null && v.isNotEmpty ? null : 'Requerido'),
          const SizedBox(height: 12),
          Text('Monto solicitado: S/ ${NumberFormat('#,##0').format(_montoSolicitado.round())}',
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: EfectivaColors.negroTexto)),
          Slider(
            value: _montoSolicitado, min: 500, max: 50000, divisions: 99,
            activeColor: EfectivaColors.azulPrincipal,
            onChanged: (v) => setState(() => _montoSolicitado = v),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _evaluando ? null : _evaluar,
              style: FilledButton.styleFrom(
                backgroundColor: EfectivaColors.azulPrincipal,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _evaluando
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('Pre-evaluar', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
          if (_resultado != null) ...[
            const SizedBox(height: 20),
            _buildResultado(_resultado!),
          ],
        ]),
      ),
    );
  }

  Future<void> _evaluar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _evaluando = true; _resultado = null; });
    await Future.delayed(const Duration(seconds: 2));
    // Lógica demo: califica por ingreso
    final ingresos = double.tryParse(_ingresosCtrl.text) ?? 0;
    final calificacion = ingresos >= 2000 ? 'APTO'
        : ingresos >= 1000 ? 'REVISAR'
        : 'NO_PROCEDE';
    setState(() {
      _evaluando = false;
      _resultado = ResultadoPreEvaluacion(
        calificacion: calificacion,
        motivo: calificacion == 'NO_PROCEDE' ? 'Ingresos insuficientes para el monto solicitado' : null,
        puntajeEstimado: (ingresos / 100).round().clamp(0, 100),
      );
    });
  }

  Widget _buildResultado(ResultadoPreEvaluacion res) {
    final (color, bgColor, icono, desc) = switch (res.calificacion) {
      'APTO' => (EfectivaColors.verdeExito, EfectivaColors.verdeSuave, Icons.check_circle, 'Puede continuar la evaluación'),
      'REVISAR' => (EfectivaColors.amarilloAcento, EfectivaColors.amarilloClaro, Icons.warning_amber_rounded, 'Requiere análisis adicional'),
      _ => (EfectivaColors.rojoError, EfectivaColors.rojoSuave, Icons.cancel, 'No cumple condiciones'),
    };
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icono, color: color, size: 28),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(res.calificacion, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
            Text(desc, style: GoogleFonts.inter(fontSize: 12, color: color)),
          ]),
          const Spacer(),
          Text('Score: ${res.puntajeEstimado}',
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
        ]),
        if (res.motivo != null) ...[
          const SizedBox(height: 10),
          Text(res.motivo!, style: GoogleFonts.inter(fontSize: 12, color: color)),
        ],
        if (res.calificacion == 'APTO') ...[
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pushNamed(context, '/nueva-solicitud'),
              style: FilledButton.styleFrom(backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: Text('Iniciar solicitud formal', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ]),
    );
  }

  Widget _campo(String label, TextEditingController ctrl,
      {TextInputType? keyboardType, int? maxLength, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: EfectivaColors.negroTexto)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl, keyboardType: keyboardType, maxLength: maxLength,
          validator: validator,
          decoration: InputDecoration(
            filled: true, fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            counterText: '',
          ),
        ),
      ]),
    );
  }

  Widget _seccion(String titulo) => Text(titulo,
    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: EfectivaColors.negroTexto));
}

// ─── Campañas Activas (HU-16) ────────────────────────────────────────────────
class _CampanasActivasTab extends StatelessWidget {
  const _CampanasActivasTab();

  @override
  Widget build(BuildContext context) {
    final campanas = CarteraDemoData.campanasActivas;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: campanas.length,
      itemBuilder: (context, i) => _buildCampanaCard(context, campanas[i]),
    );
  }

  Widget _buildCampanaCard(BuildContext context, CampanaActiva c) {
    final (label, color) = switch (c.tipoCampana) {
      'renovacion' => ('RENOVACIÓN', EfectivaColors.azulPrincipal),
      'ampliacion' => ('AMPLIACIÓN', EfectivaColors.verdeExito),
      _ => ('PRODUCTO PARALELO', EfectivaColors.naranjaAcento),
    };
    final urgente = c.diasRestantes <= 3;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: urgente ? Border.all(color: EfectivaColors.rojoError.withValues(alpha: 0.4)) : null,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
            child: Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: urgente ? EfectivaColors.rojoSuave : EfectivaColors.amarilloClaro,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              urgente ? '¡Vence en ${c.diasRestantes} día(s)!' : '${c.diasRestantes} días restantes',
              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700,
                  color: urgente ? EfectivaColors.rojoError : EfectivaColors.amarilloAcento),
            ),
          ),
        ]),
        const SizedBox(height: 10),
        Text(c.clienteNombre, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: EfectivaColors.negroTexto)),
        const SizedBox(height: 4),
        Text('Oferta: S/ ${NumberFormat('#,##0').format(c.montoOfertado)}',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pushNamed(context, '/nueva-solicitud'),
            style: OutlinedButton.styleFrom(
              foregroundColor: color,
              side: BorderSide(color: color),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Gestionar ahora', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    );
  }
}
