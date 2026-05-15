import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/solicitud_model.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/ventas_viewmodel.dart';

class NuevaSolicitudScreen extends StatefulWidget {
  const NuevaSolicitudScreen({super.key});

  @override
  State<NuevaSolicitudScreen> createState() => _NuevaSolicitudScreenState();
}

class _NuevaSolicitudScreenState extends State<NuevaSolicitudScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _guardando = false;

  // Datos personales
  final _dniCtrl = TextEditingController();
  final _nombresCtrl = TextEditingController();
  final _apellidoPCtrl = TextEditingController();
  final _apellidoMCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();

  // Datos laborales
  final _centroTrabajoCtrl = TextEditingController();
  final _cargoCtrl = TextEditingController();
  final _ingresoCtrl = TextEditingController();
  final _gastosCtrl = TextEditingController();

  // Datos del préstamo
  final _montoCtrl = TextEditingController();
  final _plazoCtrl = TextEditingController(text: '12');
  String _tipoCredito = 'Personal';
  String _destinoCredito = 'Capital de trabajo';

  // Referencias
  final _refNombre1Ctrl = TextEditingController();
  final _refTel1Ctrl = TextEditingController();
  final _refRel1Ctrl = TextEditingController();
  final _refNombre2Ctrl = TextEditingController();
  final _refTel2Ctrl = TextEditingController();
  final _refRel2Ctrl = TextEditingController();

  final _stepTitles = ['Datos Personales', 'Datos Laborales', 'Préstamo', 'Referencias', 'Resumen'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EfectivaColors.grisFondo,
      appBar: AppBar(
        title: const Text('Nueva Solicitud de Crédito'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(children: List.generate(5, (i) => Expanded(child: Row(children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: i <= _currentStep ? EfectivaColors.naranjaAcento : Colors.white.withValues(alpha: 0.3),
                  shape: BoxShape.circle),
                child: Center(child: i < _currentStep
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : Text('${i + 1}', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700,
                        color: i == _currentStep ? Colors.white : Colors.white70))),
              ),
              if (i < 4) Expanded(child: Container(height: 2,
                color: i < _currentStep ? EfectivaColors.naranjaAcento : Colors.white.withValues(alpha: 0.2))),
            ])))),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(children: [
          // Step title
          Container(
            width: double.infinity, padding: const EdgeInsets.all(16), color: Colors.white,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Paso ${_currentStep + 1} de 5', style: GoogleFonts.inter(fontSize: 12, color: EfectivaColors.grisTexto)),
              Text(_stepTitles[_currentStep], style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: EfectivaColors.negroTexto)),
            ]),
          ),
          // Contenido del paso
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _buildStepContent(),
          )),
          // Botones de navegación
          Container(
            padding: const EdgeInsets.all(16), color: Colors.white,
            child: Row(children: [
              if (_currentStep > 0)
                Expanded(child: OutlinedButton(
                  onPressed: () => setState(() => _currentStep--),
                  child: const Text('Anterior'),
                )),
              if (_currentStep > 0) const SizedBox(width: 12),
              Expanded(child: ElevatedButton(
                onPressed: _guardando ? null : () {
                  if (_currentStep < 4) {
                    setState(() => _currentStep++);
                  } else {
                    _guardarSolicitud();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _currentStep == 4 ? EfectivaColors.verdeExito : EfectivaColors.azulPrincipal),
                child: _guardando
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(_currentStep == 4 ? 'Guardar Solicitud' : 'Siguiente'),
              )),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0: return _datosPersonales();
      case 1: return _datosLaborales();
      case 2: return _datosPrestamo();
      case 3: return _referencias();
      case 4: return _resumen();
      default: return const SizedBox.shrink();
    }
  }

  Widget _datosPersonales() {
    return Column(children: [
      _field(_dniCtrl, 'N° DNI', Icons.badge_outlined, keyboard: TextInputType.number, validator: Validators.dni),
      _field(_nombresCtrl, 'Nombres', Icons.person_outline, validator: Validators.requerido),
      _field(_apellidoPCtrl, 'Apellido paterno', Icons.person_outline, validator: Validators.requerido),
      _field(_apellidoMCtrl, 'Apellido materno', Icons.person_outline),
      _field(_telefonoCtrl, 'Teléfono', Icons.phone_outlined, keyboard: TextInputType.phone, validator: Validators.telefono),
      _field(_direccionCtrl, 'Dirección', Icons.location_on_outlined, validator: Validators.requerido),
    ]);
  }

  Widget _datosLaborales() {
    return Column(children: [
      _field(_centroTrabajoCtrl, 'Centro de trabajo', Icons.business_outlined, validator: Validators.requerido),
      _field(_cargoCtrl, 'Cargo / Ocupación', Icons.work_outline, validator: Validators.requerido),
      _field(_ingresoCtrl, 'Ingreso mensual (S/)', Icons.attach_money, keyboard: TextInputType.number, validator: Validators.monto),
      _field(_gastosCtrl, 'Gastos mensuales (S/)', Icons.money_off, keyboard: TextInputType.number, validator: Validators.monto),
      // Indicador de capacidad
      if (_ingresoCtrl.text.isNotEmpty && _gastosCtrl.text.isNotEmpty) ...[
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: EfectivaColors.azulSuave, borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            const Icon(Icons.info_outline, color: EfectivaColors.azulPrincipal, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(
              'Disponible para cuota: S/ ${NumberFormat('#,##0.00', 'es').format(((double.tryParse(_ingresoCtrl.text) ?? 0) - (double.tryParse(_gastosCtrl.text) ?? 0)) * 0.4)}',
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: EfectivaColors.azulPrincipal),
            )),
          ]),
        ),
      ],
    ]);
  }

  Widget _datosPrestamo() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Tipo de crédito
      Text('Tipo de crédito', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: EfectivaColors.negroTexto)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, children: ['Personal', 'PYME', 'Grupal', 'Agrícola'].map((t) =>
        ChoiceChip(
          label: Text(t), selected: _tipoCredito == t,
          onSelected: (s) => setState(() => _tipoCredito = t),
          selectedColor: EfectivaColors.azulPrincipal,
          labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: _tipoCredito == t ? Colors.white : EfectivaColors.grisTexto),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), side: BorderSide.none,
        ),
      ).toList()),
      const SizedBox(height: 16),
      _field(_montoCtrl, 'Monto solicitado (S/)', Icons.payments_outlined, keyboard: TextInputType.number, validator: Validators.monto),
      _field(_plazoCtrl, 'Plazo (meses)', Icons.calendar_month_outlined, keyboard: TextInputType.number, validator: Validators.requerido),
      // Destino del crédito
      const SizedBox(height: 8),
      Text('Destino del crédito', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: EfectivaColors.negroTexto)),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: EfectivaColors.grisClaro)),
        child: DropdownButtonHideUnderline(child: DropdownButton<String>(
          value: _destinoCredito, isExpanded: true,
          items: ['Capital de trabajo', 'Compra de activo fijo', 'Ampliación de negocio', 'Mejoramiento de vivienda', 'Consumo personal', 'Educación', 'Salud', 'Otro']
              .map((d) => DropdownMenuItem(value: d, child: Text(d, style: GoogleFonts.inter(fontSize: 14)))).toList(),
          onChanged: (v) => setState(() => _destinoCredito = v!),
        )),
      ),
      const SizedBox(height: 16),
      // Cuota estimada
      if (_montoCtrl.text.isNotEmpty && _plazoCtrl.text.isNotEmpty)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(gradient: EfectivaColors.gradienteNaranja, borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            const Icon(Icons.calculate, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Cuota estimada mensual', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
              Text('S/ ${NumberFormat('#,##0.00', 'es').format(_calcCuota())}',
                style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
            ]),
          ]),
        ),
    ]);
  }

  double _calcCuota() {
    final m = double.tryParse(_montoCtrl.text) ?? 0;
    final p = int.tryParse(_plazoCtrl.text) ?? 12;
    if (m <= 0 || p <= 0) return 0;
    const tasa = 0.24 / 12;
    return m * (tasa * _pow(1 + tasa, p)) / (_pow(1 + tasa, p) - 1);
  }

  double _pow(double base, int exp) { double r = 1; for (int i = 0; i < exp; i++) r *= base; return r; }

  Widget _referencias() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Referencia 1', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: EfectivaColors.negroTexto)),
      const SizedBox(height: 8),
      _field(_refNombre1Ctrl, 'Nombre completo', Icons.person_outline),
      _field(_refTel1Ctrl, 'Teléfono', Icons.phone_outlined, keyboard: TextInputType.phone),
      _field(_refRel1Ctrl, 'Relación', Icons.people_outline),
      const SizedBox(height: 16),
      Text('Referencia 2', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: EfectivaColors.negroTexto)),
      const SizedBox(height: 8),
      _field(_refNombre2Ctrl, 'Nombre completo', Icons.person_outline),
      _field(_refTel2Ctrl, 'Teléfono', Icons.phone_outlined, keyboard: TextInputType.phone),
      _field(_refRel2Ctrl, 'Relación', Icons.people_outline),
    ]);
  }

  Widget _resumen() {
    final moneyFmt = NumberFormat('#,##0.00', 'es');
    return Column(children: [
      _resumenCard('Datos del Solicitante', [
        _resRow('DNI', _dniCtrl.text),
        _resRow('Nombre', '${_nombresCtrl.text} ${_apellidoPCtrl.text} ${_apellidoMCtrl.text}'),
        _resRow('Teléfono', _telefonoCtrl.text),
        _resRow('Dirección', _direccionCtrl.text),
      ]),
      const SizedBox(height: 12),
      _resumenCard('Datos Laborales', [
        _resRow('Centro de trabajo', _centroTrabajoCtrl.text),
        _resRow('Cargo', _cargoCtrl.text),
        _resRow('Ingreso', 'S/ ${moneyFmt.format(double.tryParse(_ingresoCtrl.text) ?? 0)}'),
        _resRow('Gastos', 'S/ ${moneyFmt.format(double.tryParse(_gastosCtrl.text) ?? 0)}'),
      ]),
      const SizedBox(height: 12),
      _resumenCard('Datos del Préstamo', [
        _resRow('Tipo', _tipoCredito),
        _resRow('Monto', 'S/ ${moneyFmt.format(double.tryParse(_montoCtrl.text) ?? 0)}'),
        _resRow('Plazo', '${_plazoCtrl.text} meses'),
        _resRow('Destino', _destinoCredito),
        _resRow('Cuota est.', 'S/ ${moneyFmt.format(_calcCuota())}'),
      ]),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: EfectivaColors.amarilloClaro, borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          const Icon(Icons.warning_amber, color: EfectivaColors.naranjaAcento, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text('Esta solicitud se guardará localmente. Use "Transmitir" para enviarla al sistema central.',
            style: GoogleFonts.inter(fontSize: 12, color: EfectivaColors.negroTexto))),
        ]),
      ),
    ]);
  }

  Widget _resumenCard(String title, List<Widget> rows) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: EfectivaColors.azulPrincipal)),
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

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {TextInputType keyboard = TextInputType.text, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl, keyboardType: keyboard, validator: validator,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, color: EfectivaColors.azulPrincipal, size: 20)),
      ),
    );
  }

  Future<void> _guardarSolicitud() async {
    setState(() => _guardando = true);
    await Future.delayed(const Duration(milliseconds: 1000));

    final oficial = context.read<AuthViewModel>().oficialActual;
    final solicitud = SolicitudCredito(
      id: 'SOL-${const Uuid().v4().substring(0, 6).toUpperCase()}',
      clienteId: 'NEW-${_dniCtrl.text}',
      clienteNombre: '${_nombresCtrl.text} ${_apellidoPCtrl.text} ${_apellidoMCtrl.text}',
      clienteDni: _dniCtrl.text,
      oficialId: oficial?.id ?? '',
      montoSolicitado: double.tryParse(_montoCtrl.text) ?? 0,
      plazoMeses: int.tryParse(_plazoCtrl.text) ?? 12,
      destinoCredito: _destinoCredito,
      tipoCredito: _tipoCredito,
      tasaInteres: 24,
      centroTrabajo: _centroTrabajoCtrl.text,
      cargoOcupacion: _cargoCtrl.text,
      ingresoMensual: double.tryParse(_ingresoCtrl.text) ?? 0,
      gastosMensuales: double.tryParse(_gastosCtrl.text) ?? 0,
      referencias: [
        if (_refNombre1Ctrl.text.isNotEmpty) Referencia(nombre: _refNombre1Ctrl.text, telefono: _refTel1Ctrl.text, relacion: _refRel1Ctrl.text),
        if (_refNombre2Ctrl.text.isNotEmpty) Referencia(nombre: _refNombre2Ctrl.text, telefono: _refTel2Ctrl.text, relacion: _refRel2Ctrl.text),
      ],
      estado: EstadoSolicitud.borrador,
      fechaCreacion: DateTime.now(),
    );

    await context.read<SolicitudViewModel>().agregarSolicitud(solicitud);

    if (!mounted) return;
    setState(() => _guardando = false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Solicitud ${solicitud.id} guardada correctamente'),
      backgroundColor: EfectivaColors.verdeExito,
    ));
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _dniCtrl.dispose(); _nombresCtrl.dispose(); _apellidoPCtrl.dispose(); _apellidoMCtrl.dispose();
    _telefonoCtrl.dispose(); _direccionCtrl.dispose(); _centroTrabajoCtrl.dispose(); _cargoCtrl.dispose();
    _ingresoCtrl.dispose(); _gastosCtrl.dispose(); _montoCtrl.dispose(); _plazoCtrl.dispose();
    _refNombre1Ctrl.dispose(); _refTel1Ctrl.dispose(); _refRel1Ctrl.dispose();
    _refNombre2Ctrl.dispose(); _refTel2Ctrl.dispose(); _refRel2Ctrl.dispose();
    super.dispose();
  }
}
