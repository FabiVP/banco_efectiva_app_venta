enum EstadoSolicitud {
  borrador,
  enviado,
  comite,
  enEvaluacion,
  aprobado,
  condicionado,
  rechazado,
  desembolsado,
}

class SolicitudCredito {
  final String id;
  final String asesorId;
  final String clienteId;
  final String? agenciaId;
  final String? numeroExpediente;
  final String? codSolicitudCore;

  // Display fields (populated from JOIN queries)
  final String? clienteNombre;
  final String? clienteDni;
  final String? nombres;
  final String? apellidos;
  final String? tipoCredito;
  final String? centroTrabajo;
  final String? cargoOcupacion;
  final double? tasaInteres;
  final List<Referencia> referencias;
  final ResultadoBuro? resultadoBuro;
  final bool transmitido;
  final DateTime? fechaEnvio;
  final DateTime? fechaEvaluacion;
  final DateTime? fechaAprobacion;
  final DateTime? fechaDesembolso;

  final String? tipoNegocio;
  final String? nombreNegocio;
  final String? actividadEconomica;
  final int? antiguedadNegocioMeses;
  final double? ingresosEstimados;
  final double? gastosMensuales;
  final double? patrimonioEstimado;

  final bool tieneConyuge;
  final bool tieneGarante;

  final double montoSolicitado;
  final int? plazoMeses;
  final String moneda;
  final String? garantia;
  final String? destinoCredito;
  final double? cuotaEstimada;
  final double? teaReferencial;

  final EstadoSolicitud estado;
  final double? montoAprobado;
  final String? motivoRechazo;
  final String? condicionAdicional;
  final String? analistaAsignado;
  final String? firmaClienteBase64;
  final double? latCaptura;
  final double? lngCaptura;
  final bool pendienteSync;

  final DateTime fechaCreacion;
  final DateTime? updatedAt;

  SolicitudCredito({
    required this.id,
    required this.asesorId,
    required this.clienteId,
    this.agenciaId,
    this.numeroExpediente,
    this.codSolicitudCore,
    this.clienteNombre,
    this.clienteDni,
    this.nombres,
    this.apellidos,
    this.tipoCredito,
    this.centroTrabajo,
    this.cargoOcupacion,
    this.tasaInteres,
    this.referencias = const [],
    this.resultadoBuro,
    this.transmitido = false,
    this.fechaEnvio,
    this.fechaEvaluacion,
    this.fechaAprobacion,
    this.fechaDesembolso,
    this.tipoNegocio,
    this.nombreNegocio,
    this.actividadEconomica,
    this.antiguedadNegocioMeses,
    this.ingresosEstimados,
    this.gastosMensuales,
    this.patrimonioEstimado,
    this.tieneConyuge = false,
    this.tieneGarante = false,
    required this.montoSolicitado,
    this.plazoMeses,
    this.moneda = 'PEN',
    this.garantia,
    this.destinoCredito,
    this.cuotaEstimada,
    this.teaReferencial,
    this.estado = EstadoSolicitud.borrador,
    this.montoAprobado,
    this.motivoRechazo,
    this.condicionAdicional,
    this.analistaAsignado,
    this.firmaClienteBase64,
    this.latCaptura,
    this.lngCaptura,
    this.pendienteSync = false,
    required this.fechaCreacion,
    this.updatedAt,
  });

  String get estadoTexto {
    switch (estado) {
      case EstadoSolicitud.borrador:
        return 'Borrador';
      case EstadoSolicitud.enviado:
        return 'Enviado';
      case EstadoSolicitud.comite:
        return 'Recibido Comité';
      case EstadoSolicitud.enEvaluacion:
        return 'En evaluación';
      case EstadoSolicitud.aprobado:
        return 'Aprobado';
      case EstadoSolicitud.condicionado:
        return 'Condicionado';
      case EstadoSolicitud.rechazado:
        return 'Rechazado';
      case EstadoSolicitud.desembolsado:
        return 'Desembolsado';
    }
  }

  String get estadoDb => estado.name;

  double get cuotaEstimadaCalculada {
    final tasa = teaReferencial ?? 0;
    final plazo = plazoMeses ?? 12;
    if (montoSolicitado <= 0 || plazo <= 0) return 0;
    final tasaMensual = tasa / 100 / 12;
    if (tasaMensual == 0) return montoSolicitado / plazo;
    return montoSolicitado *
        (tasaMensual * _pow(1 + tasaMensual, plazo)) /
        (_pow(1 + tasaMensual, plazo) - 1);
  }

  double _pow(double base, int exp) {
    double result = 1;
    for (int i = 0; i < exp; i++) {
      result *= base;
    }
    return result;
  }

  Map<String, dynamic> toMap() => {
    'numero_documento': clienteDni ?? '',
    'nombres': nombres ?? clienteNombre?.split(' ').first ?? '',
    'apellidos': apellidos ?? clienteNombre?.split(' ').skip(1).join(' ') ?? '',
    'telefono': null,
    if (agenciaId != null) 'agencia_id': agenciaId,
    if (tipoNegocio != null) 'tipo_negocio': tipoNegocio,
    if (nombreNegocio != null) 'nombre_negocio': nombreNegocio,
    if (actividadEconomica != null) 'actividad_economica': actividadEconomica,
    if (antiguedadNegocioMeses != null) 'antiguedad_negocio_meses': antiguedadNegocioMeses,
    if (ingresosEstimados != null) 'ingresos_estimados': ingresosEstimados,
    if (gastosMensuales != null) 'gastos_mensuales': gastosMensuales,
    if (patrimonioEstimado != null) 'patrimonio_estimado': patrimonioEstimado,
    'tiene_conyuge': tieneConyuge,
    'tiene_garante': tieneGarante,
    'monto_solicitado': montoSolicitado,
    if (plazoMeses != null) 'plazo_meses': plazoMeses,
    'moneda': moneda,
    if (garantia != null) 'garantia': garantia,
    if (destinoCredito != null) 'destino_credito': destinoCredito,
    if (cuotaEstimada != null) 'cuota_estimada': cuotaEstimada,
    if (teaReferencial != null) 'tea_referencial': teaReferencial,
    'estado': estadoDb,
    if (montoAprobado != null) 'monto_aprobado': montoAprobado,
    if (motivoRechazo != null) 'motivo_rechazo': motivoRechazo,
    if (condicionAdicional != null) 'condicion_adicional': condicionAdicional,
    if (analistaAsignado != null) 'analista_asignado': analistaAsignado,
    if (firmaClienteBase64 != null) 'firma_cliente_base64': firmaClienteBase64,
    if (latCaptura != null) 'lat_captura': latCaptura,
    if (lngCaptura != null) 'lng_captura': lngCaptura,
    'pendiente_sync': pendienteSync,
    if (transmitido) 'transmitido': transmitido,
  };

  factory SolicitudCredito.fromJson(Map<String, dynamic> json) => SolicitudCredito(
    id: json['id'] ?? '',
    asesorId: json['asesor_id'] ?? '',
    clienteId: json['cliente_id'] ?? '',
    agenciaId: json['agencia_id']?.toString(),
    numeroExpediente: json['numero_expediente']?.toString(),
    codSolicitudCore: json['cod_solicitud_core']?.toString(),
    clienteNombre: json['cliente_nombre']?.toString(),
    clienteDni: json['cliente_dni']?.toString(),
    nombres: json['nombres']?.toString(),
    apellidos: json['apellidos']?.toString(),
    tipoCredito: json['tipo_credito']?.toString(),
    centroTrabajo: json['centro_trabajo']?.toString(),
    cargoOcupacion: json['cargo_ocupacion']?.toString(),
    tasaInteres: (json['tasa_interes'] as num?)?.toDouble(),
    transmitido: json['transmitido'] as bool? ?? false,
    fechaEnvio: json['fecha_envio'] != null ? DateTime.tryParse(json['fecha_envio']) : null,
    fechaEvaluacion: json['fecha_evaluacion'] != null ? DateTime.tryParse(json['fecha_evaluacion']) : null,
    fechaAprobacion: json['fecha_aprobacion'] != null ? DateTime.tryParse(json['fecha_aprobacion']) : null,
    fechaDesembolso: json['fecha_desembolso'] != null ? DateTime.tryParse(json['fecha_desembolso']) : null,
    tipoNegocio: json['tipo_negocio']?.toString(),
    nombreNegocio: json['nombre_negocio']?.toString(),
    actividadEconomica: json['actividad_economica']?.toString(),
    antiguedadNegocioMeses: json['antiguedad_negocio_meses'] as int?,
    ingresosEstimados: (json['ingresos_estimados'] as num?)?.toDouble(),
    gastosMensuales: (json['gastos_mensuales'] as num?)?.toDouble(),
    patrimonioEstimado: (json['patrimonio_estimado'] as num?)?.toDouble(),
    tieneConyuge: json['tiene_conyuge'] as bool? ?? false,
    tieneGarante: json['tiene_garante'] as bool? ?? false,
    montoSolicitado: (json['monto_solicitado'] as num?)?.toDouble() ?? 0,
    plazoMeses: json['plazo_meses'] as int?,
    moneda: json['moneda']?.toString() ?? 'PEN',
    garantia: json['garantia']?.toString(),
    destinoCredito: json['destino_credito']?.toString(),
    cuotaEstimada: (json['cuota_estimada'] as num?)?.toDouble(),
    teaReferencial: (json['tea_referencial'] as num?)?.toDouble(),
    estado: _parseEstado(json['estado']?.toString() ?? 'borrador'),
    montoAprobado: (json['monto_aprobado'] as num?)?.toDouble(),
    motivoRechazo: json['motivo_rechazo']?.toString(),
    condicionAdicional: json['condicion_adicional']?.toString(),
    analistaAsignado: json['analista_asignado']?.toString(),
    firmaClienteBase64: json['firma_cliente_base64']?.toString(),
    latCaptura: (json['lat_captura'] as num?)?.toDouble(),
    lngCaptura: (json['lng_captura'] as num?)?.toDouble(),
    pendienteSync: json['pendiente_sync'] as bool? ?? false,
    fechaCreacion: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
  );

  static EstadoSolicitud _parseEstado(String s) {
    switch (s) {
      case 'borrador': return EstadoSolicitud.borrador;
      case 'enviado': return EstadoSolicitud.enviado;
      case 'recibido_comite': return EstadoSolicitud.comite;
      case 'en_evaluacion': return EstadoSolicitud.enEvaluacion;
      case 'aprobado': return EstadoSolicitud.aprobado;
      case 'condicionado': return EstadoSolicitud.condicionado;
      case 'rechazado': return EstadoSolicitud.rechazado;
      case 'desembolsado': return EstadoSolicitud.desembolsado;
      default: return EstadoSolicitud.borrador;
    }
  }

  SolicitudCredito copyWith({
    String? id,
    String? asesorId,
    String? clienteId,
    String? agenciaId,
    String? numeroExpediente,
    String? codSolicitudCore,
    String? clienteNombre,
    String? clienteDni,
    String? nombres,
    String? apellidos,
    String? tipoCredito,
    String? centroTrabajo,
    String? cargoOcupacion,
    double? tasaInteres,
    List<Referencia>? referencias,
    ResultadoBuro? resultadoBuro,
    bool? transmitido,
    DateTime? fechaEnvio,
    DateTime? fechaEvaluacion,
    DateTime? fechaAprobacion,
    DateTime? fechaDesembolso,
    String? tipoNegocio,
    String? nombreNegocio,
    String? actividadEconomica,
    int? antiguedadNegocioMeses,
    double? ingresosEstimados,
    double? gastosMensuales,
    double? patrimonioEstimado,
    bool? tieneConyuge,
    bool? tieneGarante,
    double? montoSolicitado,
    int? plazoMeses,
    String? moneda,
    String? garantia,
    String? destinoCredito,
    double? cuotaEstimada,
    double? teaReferencial,
    EstadoSolicitud? estado,
    double? montoAprobado,
    String? motivoRechazo,
    String? condicionAdicional,
    String? analistaAsignado,
    String? firmaClienteBase64,
    double? latCaptura,
    double? lngCaptura,
    bool? pendienteSync,
    DateTime? fechaCreacion,
    DateTime? updatedAt,
  }) {
    return SolicitudCredito(
      id: id ?? this.id,
      asesorId: asesorId ?? this.asesorId,
      clienteId: clienteId ?? this.clienteId,
      agenciaId: agenciaId ?? this.agenciaId,
      numeroExpediente: numeroExpediente ?? this.numeroExpediente,
      codSolicitudCore: codSolicitudCore ?? this.codSolicitudCore,
      clienteNombre: clienteNombre ?? this.clienteNombre,
      clienteDni: clienteDni ?? this.clienteDni,
      nombres: nombres ?? this.nombres,
      apellidos: apellidos ?? this.apellidos,
      tipoCredito: tipoCredito ?? this.tipoCredito,
      centroTrabajo: centroTrabajo ?? this.centroTrabajo,
      cargoOcupacion: cargoOcupacion ?? this.cargoOcupacion,
      tasaInteres: tasaInteres ?? this.tasaInteres,
      referencias: referencias ?? this.referencias,
      resultadoBuro: resultadoBuro ?? this.resultadoBuro,
      transmitido: transmitido ?? this.transmitido,
      fechaEnvio: fechaEnvio ?? this.fechaEnvio,
      fechaEvaluacion: fechaEvaluacion ?? this.fechaEvaluacion,
      fechaAprobacion: fechaAprobacion ?? this.fechaAprobacion,
      fechaDesembolso: fechaDesembolso ?? this.fechaDesembolso,
      tipoNegocio: tipoNegocio ?? this.tipoNegocio,
      nombreNegocio: nombreNegocio ?? this.nombreNegocio,
      actividadEconomica: actividadEconomica ?? this.actividadEconomica,
      antiguedadNegocioMeses: antiguedadNegocioMeses ?? this.antiguedadNegocioMeses,
      ingresosEstimados: ingresosEstimados ?? this.ingresosEstimados,
      gastosMensuales: gastosMensuales ?? this.gastosMensuales,
      patrimonioEstimado: patrimonioEstimado ?? this.patrimonioEstimado,
      tieneConyuge: tieneConyuge ?? this.tieneConyuge,
      tieneGarante: tieneGarante ?? this.tieneGarante,
      montoSolicitado: montoSolicitado ?? this.montoSolicitado,
      plazoMeses: plazoMeses ?? this.plazoMeses,
      moneda: moneda ?? this.moneda,
      garantia: garantia ?? this.garantia,
      destinoCredito: destinoCredito ?? this.destinoCredito,
      cuotaEstimada: cuotaEstimada ?? this.cuotaEstimada,
      teaReferencial: teaReferencial ?? this.teaReferencial,
      estado: estado ?? this.estado,
      montoAprobado: montoAprobado ?? this.montoAprobado,
      motivoRechazo: motivoRechazo ?? this.motivoRechazo,
      condicionAdicional: condicionAdicional ?? this.condicionAdicional,
      analistaAsignado: analistaAsignado ?? this.analistaAsignado,
      firmaClienteBase64: firmaClienteBase64 ?? this.firmaClienteBase64,
      latCaptura: latCaptura ?? this.latCaptura,
      lngCaptura: lngCaptura ?? this.lngCaptura,
      pendienteSync: pendienteSync ?? this.pendienteSync,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      updatedAt: updatedAt ?? this.updatedAt,
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
  final String tipo;
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
  final String calificacionSbs;
  final int? entidadesConDeuda;
  final double? deudaTotalPen;
  final bool enListaNegra;
  final String? motivoBloqueo;
  final DateTime fechaConsulta;
  final bool? aprobado;
  final int? puntaje;
  final String? scoreRiesgo;
  final String? detalle;

  ResultadoBuro({
    required this.calificacionSbs,
    this.entidadesConDeuda,
    this.deudaTotalPen,
    this.enListaNegra = false,
    this.motivoBloqueo,
    required this.fechaConsulta,
    this.aprobado,
    this.puntaje,
    this.scoreRiesgo,
    this.detalle,
  });
}

class ResultadoListaNegra {
  final bool coincide;
  final String? lista;
  final String? detalle;
  final String? tipoDocumento;
  final String? numeroDocumento;

  ResultadoListaNegra({
    this.coincide = false,
    this.lista,
    this.detalle,
    this.tipoDocumento,
    this.numeroDocumento,
  });
}

class ConsentimientoBuro {
  final bool aceptado;
  final DateTime fecha;
  final String? clienteId;

  ConsentimientoBuro({
    this.aceptado = false,
    required this.fecha,
    this.clienteId,
  });
}
