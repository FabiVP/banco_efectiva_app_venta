enum TipoGestion {
  renovacion,
  ampliacion,
  nuevaSolicitud,
  seguimiento,
  recuperacionMora,
  desertor,
}

enum PrioridadVisita { alta, media, normal }

enum EstadoVisita {
  pendiente,
  visitado,
  noEncontrado,
  reagendado,
  negocioCerrado,
}

class CarteraItem {
  final String id;
  final String asesorId;
  final String clienteId;
  final String clienteNombre;
  final String clienteDniCensurado;
  final String agenciaId;
  final DateTime fechaAsignacion;
  final TipoGestion tipoGestion;
  final PrioridadVisita prioridad;
  final int scorePrioridad;
  final EstadoVisita estadoVisita;
  final String? resultadoVisita;
  final String? observacionVisita;
  final DateTime? timestampVisita;
  final double? latVisita;
  final double? lngVisita;
  final double? montoCredito;
  final int? ordenManual;
  final bool pendienteSync;

  const CarteraItem({
    required this.id,
    required this.asesorId,
    required this.clienteId,
    required this.clienteNombre,
    required this.clienteDniCensurado,
    required this.agenciaId,
    required this.fechaAsignacion,
    required this.tipoGestion,
    required this.prioridad,
    required this.scorePrioridad,
    this.estadoVisita = EstadoVisita.pendiente,
    this.resultadoVisita,
    this.observacionVisita,
    this.timestampVisita,
    this.latVisita,
    this.lngVisita,
    this.montoCredito,
    this.ordenManual,
    this.pendienteSync = false,
  });

  bool get visitado => estadoVisita == EstadoVisita.visitado;

  String get tipoGestionLabel {
    switch (tipoGestion) {
      case TipoGestion.renovacion:
        return 'RENOVACIÓN';
      case TipoGestion.ampliacion:
        return 'AMPLIACIÓN';
      case TipoGestion.nuevaSolicitud:
        return 'NUEVA SOLICITUD';
      case TipoGestion.seguimiento:
        return 'SEGUIMIENTO';
      case TipoGestion.recuperacionMora:
        return 'RECUPERACIÓN MORA';
      case TipoGestion.desertor:
        return 'DESERTOR';
    }
  }

  String get prioridadLabel {
    switch (prioridad) {
      case PrioridadVisita.alta:
        return 'ALTA';
      case PrioridadVisita.media:
        return 'MEDIA';
      case PrioridadVisita.normal:
        return 'NORMAL';
    }
  }

  CarteraItem copyWith({
    EstadoVisita? estadoVisita,
    String? resultadoVisita,
    String? observacionVisita,
    DateTime? timestampVisita,
    double? latVisita,
    double? lngVisita,
    int? ordenManual,
    bool? pendienteSync,
  }) {
    return CarteraItem(
      id: id,
      asesorId: asesorId,
      clienteId: clienteId,
      clienteNombre: clienteNombre,
      clienteDniCensurado: clienteDniCensurado,
      agenciaId: agenciaId,
      fechaAsignacion: fechaAsignacion,
      tipoGestion: tipoGestion,
      prioridad: prioridad,
      scorePrioridad: scorePrioridad,
      estadoVisita: estadoVisita ?? this.estadoVisita,
      resultadoVisita: resultadoVisita ?? this.resultadoVisita,
      observacionVisita: observacionVisita ?? this.observacionVisita,
      timestampVisita: timestampVisita ?? this.timestampVisita,
      latVisita: latVisita ?? this.latVisita,
      lngVisita: lngVisita ?? this.lngVisita,
      montoCredito: montoCredito,
      ordenManual: ordenManual ?? this.ordenManual,
      pendienteSync: pendienteSync ?? this.pendienteSync,
    );
  }
}

class AlertaCartera {
  final String id;
  final String clienteId;
  final String clienteNombre;
  final String tipoAlerta;
  final String mensaje;
  bool leida;
  final DateTime createdAt;

  AlertaCartera({
    required this.id,
    required this.clienteId,
    required this.clienteNombre,
    required this.tipoAlerta,
    required this.mensaje,
    this.leida = false,
    required this.createdAt,
  });
}

class CampanaActiva {
  final String id;
  final String clienteId;
  final String clienteNombre;
  final String tipoCampana;
  final double montoOfertado;
  final DateTime fechaVencimiento;
  final bool activa;

  const CampanaActiva({
    required this.id,
    required this.clienteId,
    required this.clienteNombre,
    required this.tipoCampana,
    required this.montoOfertado,
    required this.fechaVencimiento,
    this.activa = true,
  });

  int get diasRestantes =>
      fechaVencimiento.difference(DateTime.now()).inDays;
}

class CreditoPreaprobado {
  final String id;
  final String clienteId;
  final double montoMaximo;
  final int plazoSugeridoMeses;
  final double teaReferencial;
  final int scoreConfianza;
  final bool vigente;
  final DateTime fechaVencimiento;

  const CreditoPreaprobado({
    required this.id,
    required this.clienteId,
    required this.montoMaximo,
    required this.plazoSugeridoMeses,
    required this.teaReferencial,
    required this.scoreConfianza,
    required this.vigente,
    required this.fechaVencimiento,
  });
}

class CrCredito {
  final String id;
  final String codCuentaCredito;
  final String clienteId;
  final String? producto;
  final double? montoDesembolsado;
  final double? saldoCapital;
  final double? saldoTotal;
  final int diasMora;
  final String? calificacionInterna;
  final String? estado;
  final DateTime? fechaDesembolso;
  final double? tea;
  final int? cuotasTotal;
  final int? cuotasPagadas;

  const CrCredito({
    required this.id,
    required this.codCuentaCredito,
    required this.clienteId,
    this.producto,
    this.montoDesembolsado,
    this.saldoCapital,
    this.saldoTotal,
    this.diasMora = 0,
    this.calificacionInterna,
    this.estado,
    this.fechaDesembolso,
    this.tea,
    this.cuotasTotal,
    this.cuotasPagadas,
  });

  factory CrCredito.fromJson(Map<String, dynamic> json) => CrCredito(
    id: json['id'] ?? '',
    codCuentaCredito: json['cod_cuenta_credito'] ?? '',
    clienteId: json['cliente_id'] ?? '',
    producto: json['producto']?.toString(),
    montoDesembolsado: (json['monto_desembolsado'] as num?)?.toDouble(),
    saldoCapital: (json['saldo_capital'] as num?)?.toDouble(),
    saldoTotal: (json['saldo_total'] as num?)?.toDouble(),
    diasMora: (json['dias_mora'] as num?)?.toInt() ?? 0,
    calificacionInterna: json['calificacion_interna']?.toString(),
    estado: json['estado']?.toString(),
    fechaDesembolso: json['fecha_desembolso'] != null
        ? DateTime.tryParse(json['fecha_desembolso'])
        : null,
    tea: (json['tea'] as num?)?.toDouble(),
    cuotasTotal: json['cuotas_total'] as int?,
    cuotasPagadas: json['cuotas_pagadas'] as int?,
  );
}

class AccionCobranza {
  final String id;
  final String clienteId;
  final String? codCuentaCredito;
  final String tipoGestion;
  final String resultado;
  final double? montoPagado;
  final DateTime? fechaCompromiso;
  final double? montoCompromiso;
  final String? observaciones;
  final double? lat;
  final double? lng;
  final DateTime timestampGestion;

  const AccionCobranza({
    required this.id,
    required this.clienteId,
    this.codCuentaCredito,
    required this.tipoGestion,
    required this.resultado,
    this.montoPagado,
    this.fechaCompromiso,
    this.montoCompromiso,
    this.observaciones,
    this.lat,
    this.lng,
    required this.timestampGestion,
  });
}

class CarteraVencida {
  final String id;
  final String clienteId;
  final String clienteNombre;
  final String creditoId;
  final int diasMora;
  final double montoVencido;
  final DateTime? ultimoContacto;

  const CarteraVencida({
    required this.id,
    required this.clienteId,
    required this.clienteNombre,
    required this.creditoId,
    required this.diasMora,
    required this.montoVencido,
    this.ultimoContacto,
  });

  String get semaforoDias {
    if (diasMora <= 30) return 'amarillo';
    if (diasMora <= 60) return 'naranja';
    return 'rojo';
  }
}

class PagoMensual {
  final String mes;
  final String estado;
  final double monto;

  const PagoMensual({
    required this.mes,
    required this.estado,
    required this.monto,
  });
}

class ResultadoPreEvaluacion {
  final String calificacion;
  final String? motivo;
  final int puntajeEstimado;

  const ResultadoPreEvaluacion({
    required this.calificacion,
    this.motivo,
    required this.puntajeEstimado,
  });
}
