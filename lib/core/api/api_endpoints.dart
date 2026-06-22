/// Definición de todos los endpoints del backend
/// (FastAPI puerto 8003)
///
/// Mantiene centralizado el contrato de API para Financiera Efectiva.
class ApiEndpoints {
  // ── Raíz ──────────────────────────────────────────────────────────
  static const String health = '/';

  // ── Autenticación (Asesores) ──────────────────────────────────────
  /// POST: { codigo_empleado, password } → { access_token, asesor }
  static const String authLogin = '/auth/login';

  // ── Cartera Diaria ────────────────────────────────────────────────
  /// GET  → lista créditos asignados al asesor del día
  static const String cartera = '/cartera';

  /// POST → { estado_visita, resultado, lat, lng }
  static String carteraVisita(String carteraId) =>
      '/cartera/$carteraId/visita';

  // ── Ficha Cliente (360°) ──────────────────────────────────────────
  /// GET → historial, oferta, datos completos del cliente
  static String fichaCliente(String clienteId) => '/clientes/$clienteId';

  /// GET → lista clientes del asesor
  static const String clientes = '/clientes';

  // ── Cobranza / Mora ───────────────────────────────────────────────
  /// GET → clientes con cuotas vencidas del asesor
  static const String cobranzaMora = '/cobranza/mora';

  // ── Pre-evaluación ────────────────────────────────────────────────
  /// POST: { dni, ingresos, deudas_actuales } → { aprobado, limite }
  static const String preEvaluar = '/pre-evaluar';

  // ── Buró de Crédito ───────────────────────────────────────────────
  /// POST → score crediticio del cliente por DNI
  static const String buroConsulta = '/buro/consulta';

  // ── Solicitudes de Crédito ────────────────────────────────────────
  /// GET  → lista de solicitudes del asesor
  /// POST → nueva solicitud con stepper + firma
  static const String solicitudes = '/solicitudes';

  /// GET → detalle de una solicitud específica
  static String solicitudDetalle(String solicitudId) =>
      '/solicitudes/$solicitudId';

  /// GET → cronograma de pagos de una solicitud desembolsada
  static String solicitudCronograma(String solicitudId) =>
      '/solicitudes/$solicitudId/cronograma';

  /// GET → bitácora de cambios de estado de una solicitud
  static String solicitudBitacora(String solicitudId) =>
      '/solicitudes/$solicitudId/bitacora';

  // ── Reportes ──────────────────────────────────────────────────────
  /// GET → productividad, visitas, conversión del asesor
  static const String reportesProductividad = '/reportes/productividad';

  // ── Alertas y Campañas ────────────────────────────────────────────
  /// GET → alertas de cartera no leídas
  static const String alertas = '/alertas';

  /// POST → marca alerta como leída
  static String alertaLeida(String alertaId) => '/alertas/$alertaId/leer';

  /// GET → campañas activas para el asesor
  static const String campanas = '/campanas';

  // ── Sincronización ────────────────────────────────────────────────
  /// POST → sube pendientes offline al core
  static const String sync = '/sync';

  // ── App Clientes (Banca Móvil) ────────────────────────────────────
  /// POST: { dni, password } → { access_token, cliente }
  static const String clienteLogin = '/cliente/login';

  /// GET → cuentas del cliente autenticado
  static const String clienteCuentas = '/cliente/cuentas';

  /// GET → tarjetas del cliente
  static const String clienteTarjetas = '/cliente/tarjetas';

  /// GET → créditos del cliente
  static const String clienteCreditos = '/cliente/creditos';
}
