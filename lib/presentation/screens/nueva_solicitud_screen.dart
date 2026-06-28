import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:signature/signature.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/location_service.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/solicitud_model.dart';
import '../../../data/models/cartera_model.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../data/models/cliente_model.dart';
import '../viewmodels/ventas_viewmodel.dart';
import '../viewmodels/cartera_viewmodel.dart';

class NuevaSolicitudScreen extends StatefulWidget {
  const NuevaSolicitudScreen({super.key});

  @override
  State<NuevaSolicitudScreen> createState() => _NuevaSolicitudScreenState();
}

class _NuevaSolicitudScreenState extends State<NuevaSolicitudScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _guardando = false;
  final _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  bool _aceptaTerminos = false;

  // Geocoding
  bool _geocodificando = false;
  bool _geoExitoso = false;
  bool _geoFallido = false;
  double? _latCaptura;
  double? _lngCaptura;

  // Paso 1: Datos del solicitante
  final _nombresCtrl = TextEditingController();
  final _apellidosCtrl = TextEditingController();
  final _dniCtrl = TextEditingController();
  final _fechaNacCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  String _estadoCivil = 'Soltero(a)';
  String _gradoInstruccion = 'Secundaria';

  // Paso 2: Datos del negocio y destino
  String _tipoNegocio = 'Comercio';
  final _nombreNegocioCtrl = TextEditingController();
  final _direccionNegocioCtrl = TextEditingController();
  final _antiguedadAniosCtrl = TextEditingController();
  final _antiguedadMesesCtrl = TextEditingController();
  final _ingresosCtrl = TextEditingController();
  final _gastosCtrl = TextEditingController();
  final _patrimonioCtrl = TextEditingController();
  final _destinoCtrl = TextEditingController();
  String _actividadEconomica = 'Comercio';

  // Paso 3: Condiciones del crédito
  double _montoSolicitado = 5000;
  int _plazoMeses = 12;
  String _moneda = 'PEN';
  String _tipoCuota = 'Mensual';
  String _garantia = 'Sin garantía';
  final double _teaReferencial = 42.0;

  final List<int> _plazos = [3, 6, 12, 18, 24, 36, 48, 60];
  final List<String> _estadosCiviles = ['Soltero(a)', 'Casado(a)', 'Conviviente', 'Divorciado(a)', 'Viudo(a)'];
  final List<String> _gradosInstruccion = ['Primaria', 'Secundaria', 'Técnico', 'Universitario'];
  final List<String> _tiposNegocio = ['Comercio', 'Servicios', 'Producción', 'Agropecuario'];
  final List<String> _actividadesEconomicas = ['Comercio', 'Servicios', 'Manufactura', 'Agricultura', 'Ganadería', 'Transporte', 'Construcción'];
  final List<String> _monedas = ['PEN', 'USD'];
  final List<String> _tiposCuota = ['Mensual', 'Quincenal', 'Semanal'];
  final List<String> _garantias = ['Sin garantía', 'Aval', 'Hipotecaria', 'Prendaria'];

  @override
  void initState() {
    super.initState();
    _fechaNacCtrl.text = '01/01/1990';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Cliente) {
      _nombresCtrl.text = args.nombres;
      _apellidosCtrl.text = args.apellidos;
      _dniCtrl.text = args.numeroDocumento;
      _telefonoCtrl.text = args.telefono ?? '';
      _emailCtrl.text = args.email ?? '';
      _estadoCivil = args.estadoCivil ?? '';
      if (args.fechaNacimiento != null) {
        _fechaNacCtrl.text = DateFormat('dd/MM/yyyy').format(args.fechaNacimiento!);
      }
    } else if (args is Map<String, dynamic>) {
      if (args.containsKey('monto')) _montoSolicitado = (args['monto'] as num).toDouble();
      if (args.containsKey('plazo')) _plazoMeses = args['plazo'] as int;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Nueva Solicitud de Crédito'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(children: List.generate(4, (i) => Expanded(child: Row(children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 30, height: 30,
                decoration: BoxDecoration(
                  color: i < _currentStep
                      ? EfectivaColors.verdeExito
                      : i == _currentStep
                          ? EfectivaColors.naranjaAcento
                          : Colors.white.withValues(alpha: 0.3),
                  shape: BoxShape.circle),
                child: Center(child: i < _currentStep
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : Text('${i + 1}', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700,
                        color: i == _currentStep ? Colors.white : Colors.white70))),
              ),
              if (i < 3) Expanded(child: Container(height: 2,
                color: i < _currentStep ? EfectivaColors.verdeExito : Colors.white.withValues(alpha: 0.2))),
            ])))),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(children: [
          Container(
            width: double.infinity, padding: const EdgeInsets.all(16), color: Colors.white,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Paso ${_currentStep + 1} de 4', style: GoogleFonts.inter(fontSize: 12, color: EfectivaColors.grisTexto)),
              Text(_stepTitles[_currentStep], style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: EfectivaColors.negroTexto)),
            ]),
          ),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _buildStepContent(),
          )),
          _buildBottomNav(),
        ]),
      ),
    );
  }

  List<String> get _stepTitles => const [
    'Datos del Solicitante',
    'Datos del Negocio',
    'Condiciones del Crédito',
    'Confirmación y Firma',
  ];

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.all(16), color: Colors.white,
      child: Row(children: [
        if (_currentStep > 0)
          Expanded(child: OutlinedButton(
            onPressed: () => setState(() => _currentStep--),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text('Anterior', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          )),
        if (_currentStep > 0) const SizedBox(width: 12),
        Expanded(child: ElevatedButton(
          onPressed: _guardando ? null : () {
            if (_currentStep == 3) {
              _guardarSolicitud();
            } else {
              if (_formKey.currentState!.validate()) {
                setState(() => _currentStep++);
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _currentStep == 3 ? EfectivaColors.verdeExito : EfectivaColors.azulPrincipal,
            minimumSize: const Size(0, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: _guardando
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
              : Text(_currentStep == 3 ? 'Enviar Solicitud' : 'Siguiente',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
        )),
      ]),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0: return _pasoDatosSolicitante();
      case 1: return _pasoDatosNegocio();
      case 2: return _pasoCondicionesCredito();
      case 3: return _pasoConfirmacionFirma();
      default: return const SizedBox.shrink();
    }
  }

  // ─── Paso 1: Datos del solicitante (RF-44) ─────────────────────────────────
  Widget _pasoDatosSolicitante() {
    return Column(children: [
      _card(children: [
        _field(_nombresCtrl, 'Nombres', Icons.person_outline, validator: Validators.requerido),
        _field(_apellidosCtrl, 'Apellidos', Icons.person_outline, validator: Validators.requerido),
        _field(_dniCtrl, 'N° Documento (DNI)', Icons.badge_outlined,
            keyboard: TextInputType.number, maxLength: 8, validator: Validators.dni),
        _buildFechaNacimiento(),
        const SizedBox(height: 12),
        _buildDropdown('Estado civil', _estadoCivil, _estadosCiviles, (v) => setState(() => _estadoCivil = v!)),
        const SizedBox(height: 12),
        _buildDropdown('Grado de instrucción', _gradoInstruccion, _gradosInstruccion, (v) => setState(() => _gradoInstruccion = v!)),
        _field(_telefonoCtrl, 'Teléfono', Icons.phone_outlined, keyboard: TextInputType.phone, validator: Validators.telefono),
        _field(_emailCtrl, 'Correo electrónico (opcional)', Icons.email_outlined),
      ]),
    ]);
  }

  Widget _buildFechaNacimiento() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: _fechaNacCtrl,
        readOnly: true,
        onTap: _seleccionarFecha,
        decoration: InputDecoration(
          labelText: 'Fecha de nacimiento',
          prefixIcon: const Icon(Icons.cake_outlined, color: EfectivaColors.azulPrincipal, size: 20),
          suffixIcon: const Icon(Icons.date_range, color: EfectivaColors.grisSubtitulo, size: 18),
        ),
        validator: (v) => v == null || v.isEmpty ? 'Selecciona la fecha' : null,
      ),
    );
  }

  Future<void> _seleccionarFecha() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime(1990, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime(2007),
    );
    if (d != null) _fechaNacCtrl.text = DateFormat('dd/MM/yyyy').format(d);
  }

  // ─── Paso 2: Datos del negocio y destino (RF-45) ────────────────────────────
  Widget _pasoDatosNegocio() {
    return Column(children: [
      _card(children: [
        _buildDropdown('Tipo de negocio', _tipoNegocio, _tiposNegocio, (v) => setState(() => _tipoNegocio = v!)),
        _field(_nombreNegocioCtrl, 'Nombre del negocio', Icons.store_outlined, validator: Validators.requerido),
        _direccionField(),
        Row(children: [
          Expanded(child: _field(_antiguedadAniosCtrl, 'Años', Icons.calendar_today, keyboard: TextInputType.number, validator: Validators.requerido)),
          const SizedBox(width: 10),
          Expanded(child: _field(_antiguedadMesesCtrl, 'Meses', Icons.calendar_today, keyboard: TextInputType.number, validator: Validators.requerido)),
        ]),
      ]),
      const SizedBox(height: 12),
      _card(children: [
        Text('Capacidad de pago', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: EfectivaColors.negroTexto)),
        const SizedBox(height: 8),
        _field(_ingresosCtrl, 'Ingresos estimados mensuales (S/)', Icons.attach_money, keyboard: TextInputType.number, validator: Validators.monto),
        _field(_gastosCtrl, 'Gastos mensuales (S/)', Icons.money_off, keyboard: TextInputType.number, validator: Validators.monto),
        _field(_patrimonioCtrl, 'Patrimonio estimado (S/) — opcional', Icons.account_balance_outlined, keyboard: TextInputType.number),
        if (_ingresosCtrl.text.isNotEmpty && _gastosCtrl.text.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: EfectivaColors.azulSuave, borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              const Icon(Icons.info_outline, color: EfectivaColors.azulPrincipal, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(
                'Capacidad de cuota estimada: S/ ${((double.tryParse(_ingresosCtrl.text) ?? 0) - (double.tryParse(_gastosCtrl.text) ?? 0)) * 0.4} /mes',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: EfectivaColors.azulPrincipal))),
            ]),
          ),
        ],
      ]),
      const SizedBox(height: 12),
      _card(children: [
        _buildDropdown('Actividad económica (CIIU)', _actividadEconomica, _actividadesEconomicas, (v) => setState(() => _actividadEconomica = v!)),
        _field(_destinoCtrl, 'Destino del crédito', Icons.trending_up_outlined, validator: Validators.requerido),
      ]),
    ]);
  }

  // ─── Paso 3: Condiciones del crédito (RF-46) ───────────────────────────────
  Widget _pasoCondicionesCredito() {
    return Column(children: [
      _card(children: [
        Text('Monto solicitado: S/ ${NumberFormat('#,##0').format(_montoSolicitado.round())}',
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: EfectivaColors.negroTexto)),
        const SizedBox(height: 4),
        Text('Arrastra para ajustar (S/500 — S/150,000)',
          style: GoogleFonts.inter(fontSize: 11, color: EfectivaColors.grisSubtitulo)),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: EfectivaColors.naranjaAcento,
            thumbColor: EfectivaColors.naranjaAcento,
            inactiveTrackColor: EfectivaColors.grisClaro,
          ),
          child: Slider(value: _montoSolicitado, min: 500, max: 150000, divisions: 299,
            onChanged: (v) => setState(() => _montoSolicitado = v)),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('S/ 500', style: GoogleFonts.inter(fontSize: 10, color: EfectivaColors.grisSubtitulo)),
          Text('S/ 150,000', style: GoogleFonts.inter(fontSize: 10, color: EfectivaColors.grisSubtitulo)),
        ]),
        const SizedBox(height: 16),
        Text('Plazo en meses', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: EfectivaColors.negroTexto)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: _plazos.map((p) => ChoiceChip(
          label: Text('$p', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
          selected: _plazoMeses == p,
          onSelected: (_) => setState(() => _plazoMeses = p),
          selectedColor: EfectivaColors.azulPrincipal,
          backgroundColor: EfectivaColors.grisClaro,
          labelStyle: GoogleFonts.inter(color: _plazoMeses == p ? Colors.white : EfectivaColors.grisTexto),
          side: BorderSide.none,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        )).toList()),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _buildDropdown('Moneda', _moneda, _monedas, (v) => setState(() => _moneda = v!))),
          const SizedBox(width: 10),
          Expanded(child: _buildDropdown('Tipo cuota', _tipoCuota, _tiposCuota, (v) => setState(() => _tipoCuota = v!))),
        ]),
        const SizedBox(height: 10),
        _buildDropdown('Garantía', _garantia, _garantias, (v) => setState(() => _garantia = v!)),
      ]),
      const SizedBox(height: 12),
      _buildSimuladorEnVivo(),
    ]);
  }

  Widget _buildSimuladorEnVivo() {
    final cuota = _calcularCuota();
    final total = cuota * _plazoMeses;
    final costo = total - _montoSolicitado;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: EfectivaColors.gradienteTarjeta,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: EfectivaColors.azulOscuro.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(children: [
        Text('SIMULACIÓN EN TIEMPO REAL', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white54, letterSpacing: 1.2)),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: _metricaSim('Cuota $_tipoCuota', 'S/ ${NumberFormat('#,##0.00', 'es').format(cuota)}', EfectivaColors.naranjaAcento)),
          Expanded(child: _metricaSim('Total a pagar', 'S/ ${NumberFormat('#,##0.00', 'es').format(total)}', Colors.white70)),
          Expanded(child: _metricaSim('Costo financiero', 'S/ ${NumberFormat('#,##0.00', 'es').format(costo)}', const Color(0xFFFF6B6B))),
        ]),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Text('TEA $_teaReferencial% · Amortización francesa', style: GoogleFonts.inter(fontSize: 10, color: Colors.white54)),
        ),
      ]),
    );
  }

  Widget _metricaSim(String label, String value, Color color) => Column(children: [
    Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
    Text(label, style: GoogleFonts.inter(fontSize: 9, color: Colors.white54), textAlign: TextAlign.center),
  ]);

  double _calcularCuota() {
    if (_montoSolicitado <= 0 || _plazoMeses <= 0) return 0;
    final tasaMensual = _calcularTasaMensual(_teaReferencial);
    if (tasaMensual <= 0) return _montoSolicitado / _plazoMeses;
    final denom = 1 - pow(1 + tasaMensual, -_plazoMeses);
    if (denom == 0) return _montoSolicitado / _plazoMeses;
    return _montoSolicitado * tasaMensual / denom;
  }

  double _calcularTasaMensual(double tea) {
    return pow(1 + tea / 100, 1 / 12) - 1;
  }

  // ─── Paso 4: Confirmación y firma digital (RF-48) ──────────────────────────
  Widget _pasoConfirmacionFirma() {
    final moneyFmt = NumberFormat('#,##0.00', 'es');
    final cuota = _calcularCuota();
    return Column(children: [
      _resumenCard('Datos del Solicitante', [
        _resRow('Nombres', _nombresCtrl.text),
        _resRow('Apellidos', _apellidosCtrl.text),
        _resRow('Documento', _dniCtrl.text),
        _resRow('Estado civil', _estadoCivil),
        _resRow('Teléfono', _telefonoCtrl.text),
      ]),
      const SizedBox(height: 10),
      _resumenCard('Datos del Negocio', [
        _resRow('Tipo', _tipoNegocio),
        _resRow('Negocio', _nombreNegocioCtrl.text),
        _resRow('Dirección', _direccionNegocioCtrl.text),
        _resRow('Ingresos', 'S/ ${moneyFmt.format(double.tryParse(_ingresosCtrl.text) ?? 0)}'),
        _resRow('Destino', _destinoCtrl.text),
      ]),
      if (_geoExitoso && _latCaptura != null && _lngCaptura != null) ...[
        const SizedBox(height: 10),
        Container(
          width: double.infinity, height: 150,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.antiAlias,
          child: FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(_latCaptura!, _lngCaptura!),
              initialZoom: 16,
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.efectiva.appventa',
              ),
              MarkerLayer(markers: [
                Marker(
                  point: LatLng(_latCaptura!, _lngCaptura!),
                  width: 36, height: 36,
                  child: const Icon(Icons.location_on, color: EfectivaColors.rojoError, size: 36),
                ),
              ]),
            ],
          ),
        ),
      ],
      const SizedBox(height: 10),
      _resumenCard('Condiciones del Crédito', [
        _resRow('Monto', 'S/ ${moneyFmt.format(_montoSolicitado)}'),
        _resRow('Plazo', '$_plazoMeses meses'),
        _resRow('Cuota', 'S/ ${moneyFmt.format(cuota)} mes'),
        _resRow('Moneda', _moneda),
        _resRow('Garantía', _garantia),
      ]),
      const SizedBox(height: 16),
      // Firma digital
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Firma digital del cliente', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: EfectivaColors.negroTexto)),
          const SizedBox(height: 4),
          Text('El cliente debe firmar en el recuadro inferior', style: GoogleFonts.inter(fontSize: 11, color: EfectivaColors.grisSubtitulo)),
          const SizedBox(height: 10),
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: EfectivaColors.grisFondo,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: EfectivaColors.grisClaro),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Signature(
                controller: _signatureController,
                height: 120,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(children: [
            TextButton.icon(
              icon: const Icon(Icons.refresh, size: 16),
              label: Text('Limpiar', style: GoogleFonts.inter(fontSize: 12)),
              onPressed: () => _signatureController.clear(),
            ),
            const Spacer(),
            if (_signatureController.isNotEmpty)
              Text('✏️ Firmado', style: GoogleFonts.inter(fontSize: 12, color: EfectivaColors.verdeExito, fontWeight: FontWeight.w600)),
          ]),
        ]),
      ),
      const SizedBox(height: 12),
      // Aceptación de términos
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            width: 24, height: 24,
            child: Checkbox(
              value: _aceptaTerminos,
              onChanged: (v) => setState(() => _aceptaTerminos = v ?? false),
              activeColor: EfectivaColors.azulPrincipal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(
            'El cliente declara que los datos son veraces y autoriza el tratamiento de sus datos personales conforme a la Ley N° 29733.',
            style: GoogleFonts.inter(fontSize: 12, color: EfectivaColors.grisTexto, height: 1.4),
          )),
        ]),
      ),
      if (_guardando) ...[
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: EfectivaColors.azulSuave, borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            const SizedBox(width: 12),
            Text('Guardando solicitud...', style: GoogleFonts.inter(fontSize: 13, color: EfectivaColors.azulPrincipal)),
          ]),
        ),
      ],
    ]);
  }

  Widget _resumenCard(String title, List<Widget> rows) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 4, height: 18, decoration: BoxDecoration(color: EfectivaColors.azulPrincipal, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: EfectivaColors.azulPrincipal)),
        ]),
        const Divider(height: 16),
        ...rows,
      ]),
    );
  }

  Widget _resRow(String label, String value) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 13, color: EfectivaColors.grisTexto)),
        Flexible(child: Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: EfectivaColors.negroTexto), textAlign: TextAlign.end)),
      ],
    ));
  }

  // ─── Widgets reutilizables ──────────────────────────────────────────────────
  Widget _card({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(children: children),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {TextInputType keyboard = TextInputType.text, int? maxLength, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl, keyboardType: keyboard, maxLength: maxLength, validator: validator,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: EfectivaColors.azulPrincipal, size: 20),
          counterText: '',
        ),
      ),
    );
  }

  Widget _direccionField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: _direccionNegocioCtrl,
        keyboardType: TextInputType.text,
        validator: Validators.requerido,
        onChanged: (_) {
          setState(() {
            _geoExitoso = false;
            _geoFallido = false;
            _latCaptura = null;
            _lngCaptura = null;
          });
        },
        decoration: InputDecoration(
          labelText: 'Dirección del negocio',
          prefixIcon: const Icon(Icons.location_on_outlined, color: EfectivaColors.azulPrincipal, size: 20),
          suffixIcon: _geocodificando
              ? Padding(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: EfectivaColors.azulCorporativo),
                  ),
                )
              : _geoExitoso
                  ? const Icon(Icons.check_circle, color: EfectivaColors.verdeExito, size: 22)
                  : _geoFallido
                      ? const Icon(Icons.gps_off, color: EfectivaColors.naranjaAcento, size: 22)
                      : IconButton(
                          icon: const Icon(Icons.search, color: EfectivaColors.azulCorporativo, size: 22),
                          onPressed: _geocodificarDireccion,
                          tooltip: 'Buscar en mapa',
                        ),
          counterText: '',
        ),
      ),
    );
  }

  Future<void> _geocodificarDireccion() async {
    final dir = _direccionNegocioCtrl.text.trim();
    if (dir.isEmpty) return;
    setState(() {
      _geocodificando = true;
      _geoExitoso = false;
      _geoFallido = false;
    });
    final result = await LocationService.addressToCoordinates(dir);
    if (!mounted) return;
    setState(() {
      _geocodificando = false;
      if (result.hasCoords) {
        _latCaptura = result.lat;
        _lngCaptura = result.lng;
        _geoExitoso = true;
        _geoFallido = false;
      } else {
        _geoExitoso = false;
        _geoFallido = true;
      }
    });
    if (!result.hasCoords && mounted) {
      final fallback = await showDialog<_FallbackLocation>(
        context: context,
        builder: (_) => _MapaSeleccionDialog(dir: dir),
      );
      if (fallback != null && mounted) {
        setState(() {
          _latCaptura = fallback.lat;
          _lngCaptura = fallback.lng;
          _geoExitoso = true;
          _geoFallido = false;
        });
      }
    }
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          filled: true, fillColor: EfectivaColors.grisFondo.withValues(alpha: 0.3),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        items: items.map((t) => DropdownMenuItem(value: t, child: Text(t, style: GoogleFonts.inter(fontSize: 14)))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Future<void> _guardarSolicitud() async {
    if (!_aceptaTerminos) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Debe aceptar los términos y condiciones', style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: EfectivaColors.rojoError,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    if (_signatureController.isNotEmpty != true) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('El cliente debe firmar digitalmente', style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: EfectivaColors.rojoError,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    setState(() => _guardando = true);

    await Future.delayed(const Duration(milliseconds: 1000));

    final dir = _direccionNegocioCtrl.text.trim();

    final oficial = context.read<AuthViewModel>().oficialActual;
    final solicitud = SolicitudCredito(
      id: 'SOL-${const Uuid().v4().substring(0, 6).toUpperCase()}',
      asesorId: oficial?.id ?? '',
      clienteId: 'NEW-${_dniCtrl.text}',
      clienteNombre: '${_nombresCtrl.text} ${_apellidosCtrl.text}',
      clienteDni: _dniCtrl.text,
      nombres: _nombresCtrl.text,
      apellidos: _apellidosCtrl.text,
      montoSolicitado: _montoSolicitado,
      plazoMeses: _plazoMeses,
      destinoCredito: _destinoCtrl.text,
      tipoCredito: _tipoNegocio == 'Comercio' ? 'Microcrédito' : _tipoNegocio,
      tasaInteres: _teaReferencial,
      centroTrabajo: _nombreNegocioCtrl.text,
      cargoOcupacion: _tipoNegocio,
      direccionNegocio: dir.isNotEmpty ? dir : null,
      ingresosEstimados: double.tryParse(_ingresosCtrl.text) ?? 0,
      gastosMensuales: double.tryParse(_gastosCtrl.text) ?? 0,
      latCaptura: _latCaptura,
      lngCaptura: _lngCaptura,
      estado: EstadoSolicitud.borrador,
      fechaCreacion: DateTime.now(),
    );

    final persistido = await context.read<SolicitudViewModel>().agregarSolicitud(solicitud);

    if (!persistido) {
      try {
        context.read<CarteraNuevoViewModel>().agregarItem(
          CarteraItem(
            id: solicitud.id,
            asesorId: solicitud.asesorId,
            clienteId: solicitud.clienteId,
            clienteNombre: solicitud.clienteNombre ?? '',
            clienteDniCensurado: solicitud.clienteDni != null
                ? '***${solicitud.clienteDni!.substring(solicitud.clienteDni!.length - 4)}'
                : '',
            agenciaId: '',
            fechaAsignacion: DateTime.now(),
            tipoGestion: TipoGestion.nuevaSolicitud,
            prioridad: PrioridadVisita.normal,
            scorePrioridad: 50,
            montoCredito: solicitud.montoSolicitado,
            pendienteSync: true,
          ),
        );
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() => _guardando = false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(color: EfectivaColors.verdeSuave, shape: BoxShape.circle),
            child: const Icon(Icons.check_circle, color: EfectivaColors.verdeExito, size: 36),
          ),
          const SizedBox(height: 16),
          Text('Solicitud Creada', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(solicitud.id, style: GoogleFonts.inter(fontSize: 14, color: EfectivaColors.azulPrincipal, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Use "Transmisión" para enviarla al sistema central.',
            style: GoogleFonts.inter(fontSize: 12, color: EfectivaColors.grisTexto), textAlign: TextAlign.center),
        ]),
        actions: [FilledButton(
          onPressed: () { Navigator.pop(ctx); Navigator.pop(context); },
          child: const Text('Ir al inicio'),
        )],
      ),
    );
  }

  @override
  void dispose() {
    _nombresCtrl.dispose(); _apellidosCtrl.dispose(); _dniCtrl.dispose();
    _fechaNacCtrl.dispose(); _telefonoCtrl.dispose(); _emailCtrl.dispose();
    _nombreNegocioCtrl.dispose(); _direccionNegocioCtrl.dispose();
    _antiguedadAniosCtrl.dispose(); _antiguedadMesesCtrl.dispose();
    _ingresosCtrl.dispose(); _gastosCtrl.dispose(); _patrimonioCtrl.dispose();
    _destinoCtrl.dispose();
    _signatureController.dispose();
    super.dispose();
  }
}

class _FallbackLocation {
  final double lat;
  final double lng;
  const _FallbackLocation(this.lat, this.lng);
}

class _MapaSeleccionDialog extends StatefulWidget {
  final String dir;
  const _MapaSeleccionDialog({required this.dir});
  @override
  State<_MapaSeleccionDialog> createState() => _MapaSeleccionDialogState();
}

class _MapaSeleccionDialogState extends State<_MapaSeleccionDialog> {
  static const double _latDefault = -12.046374;
  static const double _lngDefault = -77.042793;

  late double _lat;
  late double _lng;

  @override
  void initState() {
    super.initState();
    _lat = _latDefault;
    _lng = _lngDefault;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(children: [
              Expanded(child: Text(
                'Selecciona la ubicación',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: EfectivaColors.negroTexto),
              )),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'No se pudo geocodificar "${widget.dir}". Toca el mapa para colocar el pin.',
              style: GoogleFonts.inter(fontSize: 12, color: EfectivaColors.grisSubtitulo),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 300,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(_lat, _lng),
                  initialZoom: 14,
                  onTap: (_, latlng) => setState(() {
                    _lat = latlng.latitude;
                    _lng = latlng.longitude;
                  }),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.efectiva.appventa',
                  ),
                  MarkerLayer(markers: [
                    Marker(
                      point: LatLng(_lat, _lng),
                      width: 36, height: 36,
                      child: const Icon(Icons.location_on, color: EfectivaColors.rojoError, size: 36),
                    ),
                  ]),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.check, size: 18),
                label: Text('Usar esta ubicación', style: GoogleFonts.inter()),
                onPressed: () => Navigator.pop(context, _FallbackLocation(_lat, _lng)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
