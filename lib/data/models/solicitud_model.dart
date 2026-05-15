enum EstadoSolicitud {
  borrador,
  enviado,
  enEvaluacion,
  aprobado,
  desembolsado,
  rechazado,
}

class SolicitudCredito {
  final String id;
  final String clienteId;
  final String clienteNombre;
  final String clienteDni;
  final String oficialId;

  // Datos del préstamo
  final double montoSolicitado;
  final int plazoMeses;
  final String destinoCredito;
  final String tipoCredito;
  final double tasaInteres;

  // Datos laborales del cliente
  final String centroTrabajo;
  final String cargoOcupacion;
  final double ingresoMensual;
  final double gastosMensuales;

  // Referencias
  final List<Referencia> referencias;

  // Documentos capturados
  final List<DocumentoCapturado> documentos;

  // Estado y tracking
  final EstadoSolicitud estado;
  final DateTime fechaCreacion;
  final DateTime? fechaEnvio;
  final DateTime? fechaEvaluacion;
  final DateTime? fechaAprobacion;
  final DateTime? fechaDesembolso;
  final String? motivoRechazo;
  final bool transmitido;

  // Buró de crédito
  final ResultadoBuro? resultadoBuro;

  // Geolocalización de captura
  final double latitudCaptura;
  final double longitudCaptura;

  SolicitudCredito({
    required this.id,
    required this.clienteId,
    required this.clienteNombre,
    required this.clienteDni,
    required this.oficialId,
    this.montoSolicitado = 0,
    this.plazoMeses = 12,
    this.destinoCredito = '',
    this.tipoCredito = 'Personal',
    this.tasaInteres = 0,
    this.centroTrabajo = '',
    this.cargoOcupacion = '',
    this.ingresoMensual = 0,
    this.gastosMensuales = 0,
    this.referencias = const [],
    this.documentos = const [],
    this.estado = EstadoSolicitud.borrador,
    required this.fechaCreacion,
    this.fechaEnvio,
    this.fechaEvaluacion,
    this.fechaAprobacion,
    this.fechaDesembolso,
    this.motivoRechazo,
    this.transmitido = false,
    this.resultadoBuro,
    this.latitudCaptura = 0,
    this.longitudCaptura = 0,
  });

  String get estadoTexto {
    switch (estado) {
      case EstadoSolicitud.borrador:
        return 'Borrador';
      case EstadoSolicitud.enviado:
        return 'Enviado';
      case EstadoSolicitud.enEvaluacion:
        return 'En evaluación';
      case EstadoSolicitud.aprobado:
        return 'Aprobado';
      case EstadoSolicitud.desembolsado:
        return 'Desembolsado';
      case EstadoSolicitud.rechazado:
        return 'Rechazado';
    }
  }

  double get cuotaEstimada {
    if (montoSolicitado <= 0 || plazoMeses <= 0) return 0;
    final tasaMensual = tasaInteres / 100 / 12;
    if (tasaMensual == 0) return montoSolicitado / plazoMeses;
    return montoSolicitado *
        (tasaMensual * _pow(1 + tasaMensual, plazoMeses)) /
        (_pow(1 + tasaMensual, plazoMeses) - 1);
  }

  double _pow(double base, int exp) {
    double result = 1;
    for (int i = 0; i < exp; i++) {
      result *= base;
    }
    return result;
  }

  SolicitudCredito copyWith({
    String? id,
    String? clienteId,
    String? clienteNombre,
    String? clienteDni,
    String? oficialId,
    double? montoSolicitado,
    int? plazoMeses,
    String? destinoCredito,
    String? tipoCredito,
    double? tasaInteres,
    String? centroTrabajo,
    String? cargoOcupacion,
    double? ingresoMensual,
    double? gastosMensuales,
    List<Referencia>? referencias,
    List<DocumentoCapturado>? documentos,
    EstadoSolicitud? estado,
    DateTime? fechaCreacion,
    DateTime? fechaEnvio,
    DateTime? fechaEvaluacion,
    DateTime? fechaAprobacion,
    DateTime? fechaDesembolso,
    String? motivoRechazo,
    bool? transmitido,
    ResultadoBuro? resultadoBuro,
    double? latitudCaptura,
    double? longitudCaptura,
  }) {
    return SolicitudCredito(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      clienteNombre: clienteNombre ?? this.clienteNombre,
      clienteDni: clienteDni ?? this.clienteDni,
      oficialId: oficialId ?? this.oficialId,
      montoSolicitado: montoSolicitado ?? this.montoSolicitado,
      plazoMeses: plazoMeses ?? this.plazoMeses,
      destinoCredito: destinoCredito ?? this.destinoCredito,
      tipoCredito: tipoCredito ?? this.tipoCredito,
      tasaInteres: tasaInteres ?? this.tasaInteres,
      centroTrabajo: centroTrabajo ?? this.centroTrabajo,
      cargoOcupacion: cargoOcupacion ?? this.cargoOcupacion,
      ingresoMensual: ingresoMensual ?? this.ingresoMensual,
      gastosMensuales: gastosMensuales ?? this.gastosMensuales,
      referencias: referencias ?? this.referencias,
      documentos: documentos ?? this.documentos,
      estado: estado ?? this.estado,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaEnvio: fechaEnvio ?? this.fechaEnvio,
      fechaEvaluacion: fechaEvaluacion ?? this.fechaEvaluacion,
      fechaAprobacion: fechaAprobacion ?? this.fechaAprobacion,
      fechaDesembolso: fechaDesembolso ?? this.fechaDesembolso,
      motivoRechazo: motivoRechazo ?? this.motivoRechazo,
      transmitido: transmitido ?? this.transmitido,
      resultadoBuro: resultadoBuro ?? this.resultadoBuro,
      latitudCaptura: latitudCaptura ?? this.latitudCaptura,
      longitudCaptura: longitudCaptura ?? this.longitudCaptura,
    );
  }
}

class Referencia {
  final String nombre;
  final String telefono;
  final String relacion;

  Referencia({
    required this.nombre,
    required this.telefono,
    required this.relacion,
  });
}

class DocumentoCapturado {
  final String id;
  final String tipo; // 'DNI Frontal', 'DNI Reverso', 'Recibo', 'Contrato'
  final String rutaLocal;
  final DateTime fechaCaptura;
  final bool sincronizado;

  DocumentoCapturado({
    required this.id,
    required this.tipo,
    required this.rutaLocal,
    required this.fechaCaptura,
    this.sincronizado = false,
  });
}

class ResultadoBuro {
  final String scoreRiesgo;
  final int puntaje;
  final bool aprobado;
  final String detalle;
  final DateTime fechaConsulta;

  ResultadoBuro({
    required this.scoreRiesgo,
    required this.puntaje,
    required this.aprobado,
    required this.detalle,
    required this.fechaConsulta,
  });
}
