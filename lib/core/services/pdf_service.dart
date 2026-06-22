import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../data/models/solicitud_model.dart';

class PdfService {
  static String safeVal(String? v) => v ?? '-';

  static Future<void> exportarSolicitudPdf(SolicitudCredito solicitud) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(solicitud),
          pw.SizedBox(height: 20),
          _buildSeccion('DATOS DEL SOLICITANTE', [
            _campo('Nombre', safeVal(solicitud.clienteNombre)),
            _campo('DNI', safeVal(solicitud.clienteDni)),
            _campo('Centro de Trabajo', safeVal(solicitud.centroTrabajo)),
            _campo('Cargo / Ocupación', safeVal(solicitud.cargoOcupacion)),
          ]),
          pw.SizedBox(height: 16),
          _buildSeccion('DATOS DEL CRÉDITO', [
            _campo('Monto Solicitado', 'S/ ${solicitud.montoSolicitado.toStringAsFixed(2)}'),
            _campo('Plazo', '${solicitud.plazoMeses ?? 0} meses'),
            _campo('Tasa de Interés', '${solicitud.tasaInteres?.toStringAsFixed(2) ?? '0.00'}%'),
            _campo('Cuota Estimada', 'S/ ${solicitud.cuotaEstimada?.toStringAsFixed(2) ?? '0.00'}'),
            _campo('Destino', safeVal(solicitud.destinoCredito)),
            _campo('Tipo de Crédito', safeVal(solicitud.tipoCredito)),
          ]),
          pw.SizedBox(height: 16),
          if (solicitud.referencias.isNotEmpty)
            _buildSeccion('REFERENCIAS', solicitud.referencias.map((r) =>
              _campo(r.nombre, '${r.relacion} - ${r.telefono}')).toList()),
          pw.SizedBox(height: 16),
          if (solicitud.resultadoBuro != null)
            _buildSeccion('BURÓ DE CRÉDITO', [
              _campo('Puntaje', '${solicitud.resultadoBuro!.puntaje ?? '-'} pts'),
              _campo('Score Riesgo', safeVal(solicitud.resultadoBuro!.scoreRiesgo)),
              _campo('Detalle', safeVal(solicitud.resultadoBuro!.detalle)),
            ]),
          pw.SizedBox(height: 16),
          _buildSeccion('ESTADO', [
            _campo('Estado', solicitud.estadoTexto),
            _campo('Fecha de Creación', _fmt(solicitud.fechaCreacion)),
            _campo('Transmitido', solicitud.transmitido ? 'Sí' : 'No'),
          ]),
          pw.SizedBox(height: 32),
          pw.Center(
            child: pw.Text(
              'Financiera Efectiva S.A. - Documento generado electrónicamente',
              style: pw.TextStyle(fontSize: 9, color: PdfColors.grey),
            ),
          ),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'solicitud_${solicitud.id}.pdf',
    );
  }

  static pw.Widget _buildHeader(SolicitudCredito s) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Text('FINANCIERA EFECTIVA S.A.',
        style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
      pw.SizedBox(height: 4),
      pw.Text('SOLICITUD DE CRÉDITO - ${s.id}',
        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
      pw.Divider(color: PdfColors.blue800, thickness: 1.5),
    ]);
  }

  static pw.Widget _buildSeccion(String titulo, List<pw.Widget> campos) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text(titulo, style: pw.TextStyle(
          fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
        pw.SizedBox(height: 8),
        ...campos,
      ]),
    );
  }

  static pw.Widget _campo(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
        pw.Text(value, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
      ]),
    );
  }

  static String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
