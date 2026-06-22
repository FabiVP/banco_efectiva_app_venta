import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../data/models/cartera_model.dart';
import '../../data/datasources/cartera_demo_data.dart';

/// M10 — Recuperación de cartera vencida (HU-30, HU-31)
class CobranzaScreen extends StatefulWidget {
  const CobranzaScreen({super.key});
  @override
  State<CobranzaScreen> createState() => _CobranzaScreenState();
}

class _CobranzaScreenState extends State<CobranzaScreen> {
  final _items = CarteraDemoData.carteraVencida;
  double get _montoTotalVencido => _items.fold(0, (s, i) => s + i.montoVencido);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EfectivaColors.grisFondo,
      body: Column(children: [
        _buildHeader(),
        Expanded(child: _items.isEmpty
            ? _emptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _items.length,
                itemBuilder: (context, i) => _buildMoraCard(context, _items[i]),
              )),
      ]),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [EfectivaColors.rojoError.withValues(alpha: 0.9), EfectivaColors.rojoError],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 20, right: 20, bottom: 16,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 22),
          const SizedBox(width: 10),
          Text('Cartera Vencida', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
        ]),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Monto total vencido', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
              Text('S/ ${NumberFormat('#,##0.00', 'es').format(_montoTotalVencido)}',
                style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
              child: Text('${_items.length} clientes', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildMoraCard(BuildContext context, CarteraVencida item) {
    final (semaforoColor, urgencia) = switch (item.semaforoDias) {
      'amarillo' => (EfectivaColors.amarilloAcento, 'Seguimiento preventivo'),
      'naranja' => (EfectivaColors.naranjaAcento, 'Gestión prioritaria'),
      _ => (EfectivaColors.rojoError, 'Recuperación urgente'),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: semaforoColor, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _mostrarAccionCobranza(context, item),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(item.clienteNombre,
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: EfectivaColors.negroTexto))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: semaforoColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(width: 7, height: 7, decoration: BoxDecoration(color: semaforoColor, shape: BoxShape.circle)),
                    const SizedBox(width: 5),
                    Text('${item.diasMora} días', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: semaforoColor)),
                  ]),
                ),
              ]),
              const SizedBox(height: 6),
              Text(urgencia, style: GoogleFonts.inter(fontSize: 11, color: semaforoColor, fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _miniInfo('Monto vencido', 'S/ ${NumberFormat('#,##0').format(item.montoVencido)}', semaforoColor)),
                Expanded(child: _miniInfo('Último contacto', item.ultimoContacto != null
                    ? 'Hace ${DateTime.now().difference(item.ultimoContacto!).inDays} días' : 'Sin contacto', EfectivaColors.grisTexto)),
              ]),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.handshake_outlined, size: 16),
                  label: Text('Registrar gestión', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
                  onPressed: () => _mostrarAccionCobranza(context, item),
                  style: FilledButton.styleFrom(
                    backgroundColor: semaforoColor,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _miniInfo(String label, String val, Color color) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: GoogleFonts.inter(fontSize: 10, color: EfectivaColors.grisSubtitulo)),
    Text(val, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
  ]);

  void _mostrarAccionCobranza(BuildContext context, CarteraVencida item) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AccionCobranzaSheet(item: item),
    );
  }

  Widget _emptyState() => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Icon(Icons.check_circle_outline, size: 64, color: EfectivaColors.verdeExito),
    const SizedBox(height: 12),
    Text('¡Sin mora en cartera! 🎉', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: EfectivaColors.verdeExito)),
  ]));
}

// ─── Bottom sheet: Registrar acción de cobranza (HU-31) ────────────────────
class _AccionCobranzaSheet extends StatefulWidget {
  final CarteraVencida item;
  const _AccionCobranzaSheet({required this.item});
  @override
  State<_AccionCobranzaSheet> createState() => _AccionCobranzaSheetState();
}

class _AccionCobranzaSheetState extends State<_AccionCobranzaSheet> {
  String _tipoGestion = 'Visita';
  String _resultado = 'Compromiso de pago';
  final _montoCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();
  DateTime? _fechaCompromiso;
  bool _guardando = false;

  final List<String> _tipos = ['Visita', 'Llamada', 'Mensaje'];
  final List<String> _resultados = ['Compromiso de pago', 'Pago parcial', 'Sin contacto', 'Se niega a pagar'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: EfectivaColors.grisClaro, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Text('Acción de cobranza', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: EfectivaColors.negroTexto)),
          Text(widget.item.clienteNombre, style: GoogleFonts.inter(fontSize: 13, color: EfectivaColors.grisTexto)),
          const SizedBox(height: 16),
          _label('Tipo de gestión'),
          Wrap(spacing: 8, children: _tipos.map((t) => ChoiceChip(
            label: Text(t, style: GoogleFonts.inter(fontSize: 12)),
            selected: _tipoGestion == t,
            onSelected: (_) => setState(() => _tipoGestion = t),
            selectedColor: EfectivaColors.azulPrincipal,
            labelStyle: TextStyle(color: _tipoGestion == t ? Colors.white : EfectivaColors.grisTexto),
          )).toList()),
          const SizedBox(height: 14),
          _label('Resultado'),
          DropdownButtonFormField<String>(
            initialValue: _resultado,
            decoration: InputDecoration(
              filled: true, fillColor: EfectivaColors.grisFondo,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            items: _resultados.map((r) => DropdownMenuItem(value: r, child: Text(r, style: GoogleFonts.inter(fontSize: 14)))).toList(),
            onChanged: (v) => setState(() => _resultado = v!),
          ),
          if (_resultado == 'Compromiso de pago' || _resultado == 'Pago parcial') ...[
            const SizedBox(height: 12),
            _label(_resultado == 'Pago parcial' ? 'Monto pagado' : 'Monto comprometido'),
            TextField(
              controller: _montoCtrl, keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: 'S/ ', hintText: '0.00',
                filled: true, fillColor: EfectivaColors.grisFondo,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            if (_resultado == 'Compromiso de pago') ...[
              const SizedBox(height: 12),
              _label('Fecha de compromiso'),
              GestureDetector(
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 3)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );
                  if (d != null) setState(() => _fechaCompromiso = d);
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: EfectivaColors.grisFondo, borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    const Icon(Icons.calendar_today_outlined, size: 16, color: EfectivaColors.grisSubtitulo),
                    const SizedBox(width: 10),
                    Text(
                      _fechaCompromiso != null
                          ? DateFormat('dd/MM/yyyy').format(_fechaCompromiso!)
                          : 'Seleccionar fecha...',
                      style: GoogleFonts.inter(fontSize: 14, color: _fechaCompromiso != null ? EfectivaColors.negroTexto : EfectivaColors.grisSubtitulo),
                    ),
                  ]),
                ),
              ),
            ],
          ],
          const SizedBox(height: 12),
          _label('Observaciones'),
          TextField(
            controller: _obsCtrl, maxLines: 2, maxLength: 200,
            decoration: InputDecoration(
              hintText: 'Notas adicionales...',
              filled: true, fillColor: EfectivaColors.grisFondo,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.all(14), counterText: '',
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: EfectivaColors.azulSuave, borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              const Icon(Icons.gps_fixed, size: 14, color: EfectivaColors.azulPrincipal),
              const SizedBox(width: 8),
              Text('GPS: -12.0000, -77.0000 · Registrado automáticamente',
                style: GoogleFonts.inter(fontSize: 11, color: EfectivaColors.azulPrincipal)),
            ]),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _guardando ? null : _guardar,
              style: FilledButton.styleFrom(
                backgroundColor: EfectivaColors.rojoError,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _guardando
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('Registrar gestión', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: EfectivaColors.negroTexto)),
  );

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Gestión registrada con GPS y marca de tiempo', style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: EfectivaColors.verdeExito,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }
}
