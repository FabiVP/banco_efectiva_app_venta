import '../models/cartera_model.dart';

class CarteraDemoData {
  // ─── Historial de pagos 12 meses ───────────────────────────────────────────
  static List<PagoMensual> historialPagos(String clienteId) {
    final meses = ['Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic', 'Ene', 'Feb', 'Mar', 'Abr', 'May'];
    final Map<String, List<String>> estados = {
      'CL-001': ['puntual','puntual','puntual','puntual','mora','puntual','puntual','puntual','puntual','puntual','puntual','puntual'],
      'CL-002': ['puntual','mora','puntual','puntual','puntual','mora','puntual','puntual','puntual','sin_cuota','sin_cuota','sin_cuota'],
      'CL-003': ['puntual','puntual','puntual','puntual','puntual','puntual','puntual','puntual','puntual','puntual','puntual','puntual'],
    };
    final lista = estados[clienteId] ?? List.filled(12, 'puntual');
    return List.generate(12, (i) => PagoMensual(
      mes: meses[i],
      estado: lista[i],
      monto: lista[i] == 'sin_cuota' ? 0 : 450 + (i * 10).toDouble(),
    ));
  }

  // ─── Créditos preaprobados ─────────────────────────────────────────────────
  static List<CreditoPreaprobado> creditosPreaprobados = [
    CreditoPreaprobado(
      id: 'PRE-001', clienteId: 'CL-001',
      montoMaximo: 9000, plazoSugeridoMeses: 18,
      teaReferencial: 42.0, scoreConfianza: 88,
      vigente: true, fechaVencimiento: DateTime.now().add(const Duration(days: 15)),
    ),
    CreditoPreaprobado(
      id: 'PRE-002', clienteId: 'CL-003',
      montoMaximo: 14000, plazoSugeridoMeses: 24,
      teaReferencial: 38.0, scoreConfianza: 92,
      vigente: true, fechaVencimiento: DateTime.now().add(const Duration(days: 7)),
    ),
    CreditoPreaprobado(
      id: 'PRE-003', clienteId: 'CL-005',
      montoMaximo: 18000, plazoSugeridoMeses: 36,
      teaReferencial: 35.5, scoreConfianza: 95,
      vigente: true, fechaVencimiento: DateTime.now().add(const Duration(days: 30)),
    ),
  ];

  // ─── Alertas de cartera ────────────────────────────────────────────────────
  static List<AlertaCartera> alertasCartera = [
    AlertaCartera(
      id: 'ALT-001', clienteId: 'CL-004',
      clienteNombre: 'Pedro Sánchez Rojas',
      tipoAlerta: 'primer_dia_mora',
      mensaje: 'Pedro Sánchez entró en mora hoy — Cuota S/ 320.00 vencida',
      leida: false, createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    AlertaCartera(
      id: 'ALT-002', clienteId: 'CL-007',
      clienteNombre: 'Carmen Vega Paredes',
      tipoAlerta: 'mora_30d',
      mensaje: 'Carmen Vega lleva 32 días de mora — Monto vencido S/ 640.00',
      leida: false, createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    AlertaCartera(
      id: 'ALT-003', clienteId: 'CL-002',
      clienteNombre: 'José Luis Rodríguez',
      tipoAlerta: 'pago_parcial',
      mensaje: 'José Rodríguez realizó pago parcial de S/ 150.00',
      leida: true, createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  // ─── Campañas activas ──────────────────────────────────────────────────────
  static List<CampanaActiva> campanasActivas = [
    CampanaActiva(
      id: 'CMP-001', clienteId: 'CL-001',
      clienteNombre: 'María Elena García',
      tipoCampana: 'renovacion',
      montoOfertado: 9000,
      fechaVencimiento: DateTime.now().add(const Duration(days: 3)),
    ),
    CampanaActiva(
      id: 'CMP-002', clienteId: 'CL-003',
      clienteNombre: 'Ana Rosa Huamán',
      tipoCampana: 'ampliacion',
      montoOfertado: 14000,
      fechaVencimiento: DateTime.now().add(const Duration(days: 7)),
    ),
    CampanaActiva(
      id: 'CMP-003', clienteId: 'CL-005',
      clienteNombre: 'Lucía Torres Mamani',
      tipoCampana: 'producto_paralelo',
      montoOfertado: 5000,
      fechaVencimiento: DateTime.now().add(const Duration(days: 12)),
    ),
  ];

  // ─── Cartera diaria ────────────────────────────────────────────────────────
  static List<CarteraItem> carteraDiaria = [
    CarteraItem(
      id: 'CD-001', asesorId: 'OF-001', clienteId: 'CL-004',
      clienteNombre: 'Pedro Sánchez Rojas', clienteDniCensurado: '***2536',
      agenciaId: 'AG-001', fechaAsignacion: DateTime.now(),
      tipoGestion: TipoGestion.recuperacionMora, prioridad: PrioridadVisita.alta,
      scorePrioridad: 87,
      montoCredito: 6000,
    ),
    CarteraItem(
      id: 'CD-002', asesorId: 'OF-001', clienteId: 'CL-001',
      clienteNombre: 'María Elena García', clienteDniCensurado: '***8901',
      agenciaId: 'AG-001', fechaAsignacion: DateTime.now(),
      tipoGestion: TipoGestion.renovacion, prioridad: PrioridadVisita.alta,
      scorePrioridad: 75,
      montoCredito: 8000,
    ),
    CarteraItem(
      id: 'CD-003', asesorId: 'OF-001', clienteId: 'CL-002',
      clienteNombre: 'José Luis Rodríguez', clienteDniCensurado: '***2178',
      agenciaId: 'AG-001', fechaAsignacion: DateTime.now(),
      tipoGestion: TipoGestion.ampliacion, prioridad: PrioridadVisita.media,
      scorePrioridad: 55,
      montoCredito: 5000,
    ),
    CarteraItem(
      id: 'CD-004', asesorId: 'OF-001', clienteId: 'CL-003',
      clienteNombre: 'Ana Rosa Huamán Vilca', clienteDniCensurado: '***6974',
      agenciaId: 'AG-001', fechaAsignacion: DateTime.now(),
      tipoGestion: TipoGestion.renovacion, prioridad: PrioridadVisita.alta,
      scorePrioridad: 70,
      montoCredito: 12000,
      estadoVisita: EstadoVisita.visitado,
      resultadoVisita: 'Visitado',
      timestampVisita: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    CarteraItem(
      id: 'CD-005', asesorId: 'OF-001', clienteId: 'CL-005',
      clienteNombre: 'Lucía Torres Mamani', clienteDniCensurado: '***1478',
      agenciaId: 'AG-001', fechaAsignacion: DateTime.now(),
      tipoGestion: TipoGestion.seguimiento, prioridad: PrioridadVisita.normal,
      scorePrioridad: 25,
      montoCredito: 15000,
    ),
    CarteraItem(
      id: 'CD-006', asesorId: 'OF-001', clienteId: 'CL-006',
      clienteNombre: 'Roberto Chávez Luna', clienteDniCensurado: '***2389',
      agenciaId: 'AG-001', fechaAsignacion: DateTime.now(),
      tipoGestion: TipoGestion.nuevaSolicitud, prioridad: PrioridadVisita.normal,
      scorePrioridad: 15,
      montoCredito: null,
    ),
    CarteraItem(
      id: 'CD-007', asesorId: 'OF-001', clienteId: 'CL-007',
      clienteNombre: 'Carmen Vega Paredes', clienteDniCensurado: '***5412',
      agenciaId: 'AG-001', fechaAsignacion: DateTime.now(),
      tipoGestion: TipoGestion.desertor, prioridad: PrioridadVisita.media,
      scorePrioridad: 40,
      montoCredito: null,
    ),
  ];

  // ─── Cartera vencida ───────────────────────────────────────────────────────
  static List<CarteraVencida> carteraVencida = [
    CarteraVencida(
      id: 'CV-001', clienteId: 'CL-004',
      clienteNombre: 'Pedro Sánchez Rojas', creditoId: 'CR-004',
      diasMora: 72, montoVencido: 960,
      ultimoContacto: DateTime.now().subtract(const Duration(days: 5)),
    ),
    CarteraVencida(
      id: 'CV-002', clienteId: 'CL-007',
      clienteNombre: 'Carmen Vega Paredes', creditoId: 'CR-007',
      diasMora: 32, montoVencido: 640,
      ultimoContacto: DateTime.now().subtract(const Duration(days: 2)),
    ),
    CarteraVencida(
      id: 'CV-003', clienteId: 'CL-002',
      clienteNombre: 'José Luis Rodríguez', creditoId: 'CR-002',
      diasMora: 8, montoVencido: 320,
      ultimoContacto: null,
    ),
  ];

  // ─── Datos asesores para reporte (M11) ────────────────────────────────────
  static List<Map<String, dynamic>> reporteProductividad = [
    {'nombre': 'Carlos Mendoza', 'enviadas': 18, 'aprobadas': 14, 'desembolsadas': 11, 'monto': 142000},
    {'nombre': 'Rosa Quispe',   'enviadas': 15, 'aprobadas': 10, 'desembolsadas': 8,  'monto': 98000},
    {'nombre': 'Luis Flores',   'enviadas': 22, 'aprobadas': 17, 'desembolsadas': 14, 'monto': 185000},
    {'nombre': 'Ana Paredes',   'enviadas': 12, 'aprobadas': 9,  'desembolsadas': 7,  'monto': 76000},
  ];

  // Helper: preaprobado por cliente
  static CreditoPreaprobado? preaprobadoPorCliente(String clienteId) {
    try {
      return creditosPreaprobados.firstWhere((p) => p.clienteId == clienteId && p.vigente);
    } catch (_) {
      return null;
    }
  }

  // Helper: alertas no leídas
  static int get alertasNoLeidas => alertasCartera.where((a) => !a.leida).length;
}
