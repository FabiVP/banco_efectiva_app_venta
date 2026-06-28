import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import '../../../core/services/geo_service.dart';
import '../../../data/models/cliente_model.dart';
import '../../../data/models/solicitud_model.dart';
import '../../../data/models/visita_model.dart';
import '../../../data/datasources/demo_data.dart';
import '../../../data/datasources/remote/cartera_remote_datasource.dart';
import '../../../data/repositories/solicitud_repository.dart';
import 'auth_viewmodel.dart';

class CarteraViewModel extends ChangeNotifier {
  List<Cliente> _clientes = [];
  List<Cliente> _clientesFiltrados = [];
  String _filtroActivo = 'Todos';
  String _busqueda = '';
  bool _cargando = false;

  List<Cliente> get clientes => _clientesFiltrados;
  String get filtroActivo => _filtroActivo;
  bool get cargando => _cargando;

  int get totalClientes => _clientes.length;

  Future<void> cargarCartera() async {
    _cargando = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));
    _clientes = DemoData.clientesDemo;
    _aplicarFiltros();
    _cargando = false;
    notifyListeners();
  }

  void filtrar(String filtro) {
    _filtroActivo = filtro;
    _aplicarFiltros();
    notifyListeners();
  }

  void buscar(String query) {
    _busqueda = query;
    _aplicarFiltros();
    notifyListeners();
  }

  void _aplicarFiltros() {
    _clientesFiltrados = _clientes.where((c) {
      bool pasaFiltro = true;
      if (_filtroActivo == 'Nuevos') {
        pasaFiltro = c.esProspecto;
      }
      bool pasaBusqueda = true;
      if (_busqueda.isNotEmpty) {
        final q = _busqueda.toLowerCase();
        pasaBusqueda = c.nombreCompleto.toLowerCase().contains(q) ||
            c.numeroDocumento.contains(q);
      }
      return pasaFiltro && pasaBusqueda;
    }).toList();
  }

  Cliente? getCliente(String clienteId) {
    try {
      return _clientes.firstWhere((c) => c.id == clienteId);
    } catch (_) {
      return null;
    }
  }
}

class RutaViewModel extends ChangeNotifier {
  List<VisitaPlanificada> _visitas = [];
  bool _cargando = false;
  String? _errorMsg;

  List<VisitaPlanificada> get visitas => _visitas;
  bool get cargando => _cargando;
  String? get errorMsg => _errorMsg;

  int get visitasCompletadas => _visitas.where((v) => v.completada).length;
  int get totalVisitas => _visitas.length;
  double get porcentajeAvance =>
      totalVisitas > 0 ? visitasCompletadas / totalVisitas : 0;

  // Coordenadas por defecto — Lima centro
  static const double _latDefault = -12.0464;
  static const double _lngDefault = -77.0428;

  Future<void> cargarRuta({DateTime? fecha}) async {
    _cargando = true;
    _errorMsg = null;
    notifyListeners();

    try {
      final remote = CarteraRemoteDataSource();
      final items = await remote.getCarteraDiaria(fecha: fecha);

      if (items.isEmpty) {
        _visitas = DemoData.visitasDemo;
        _errorMsg = 'Sin visitas asignadas hoy (modo demo)';
      } else {
        // Geocodificar clientes sin coords antes de construir visitas
        _visitas = await _mapearCarteraConGeo(items);
      }
    } catch (e) {
      debugPrint('[RutaViewModel] error al cargar cartera: $e');
      _visitas = DemoData.visitasDemo;
      _errorMsg = 'Sin conexión — mostrando datos demo';
    }

    _cargando = false;
    notifyListeners();
  }

  /// Mapea CarteraItemOut → VisitaPlanificada.
  /// Si un cliente no tiene lat/lng en BD, geocodifica su dirección texto.
  Future<List<VisitaPlanificada>> _mapearCarteraConGeo(
    List<Map<String, dynamic>> items,
  ) async {
    final visitas = <VisitaPlanificada>[];

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final motivo = _tipoGestionAMotivo(item['tipo_gestion'] as String? ?? '');
      final direccion = item['direccion'] as String? ?? '';

      // Intentar coords del backend primero
      double lat = (item['lat'] as num?)?.toDouble() ?? 0;
      double lng = (item['lng'] as num?)?.toDouble() ?? 0;

      // Si no hay coords válidas → geocodificar la dirección
      if (lat == 0 && lng == 0 && direccion.isNotEmpty) {
        debugPrint('[RutaViewModel] Geocodificando: $direccion');
        final coords = await GeoService.addressToCoordinates(
          '$direccion, Lima, Peru',
        );
        if (coords != null) {
          lat = coords.$1;
          lng = coords.$2;
          debugPrint('[RutaViewModel] Geocodificado → ($lat, $lng)');
        } else {
          // Fallback: Lima centro
          lat = _latDefault;
          lng = _lngDefault;
          debugPrint('[RutaViewModel] Sin coords para: $direccion → usando Lima centro');
        }
      } else if (lat == 0 && lng == 0) {
        lat = _latDefault;
        lng = _lngDefault;
      }

      visitas.add(VisitaPlanificada(
        id: item['id'] as String,
        clienteId: item['cliente_id'] as String,
        clienteNombre: item['cliente_nombre'] as String? ?? 'Cliente',
        clienteDni: item['documento'] as String? ?? '',
        direccion: direccion.isEmpty ? 'Sin dirección registrada' : direccion,
        latitud: lat,
        longitud: lng,
        motivo: motivo,
        orden: (item['orden_manual'] as int? ?? i) + 1,
        completada: (item['estado_visita'] as String?) == 'visitado',
        fechaPlanificada: DateTime.now(),
      ));
    }

    visitas.sort((a, b) => a.orden.compareTo(b.orden));
    return visitas;
  }

  String _tipoGestionAMotivo(String tipo) {
    switch (tipo.toUpperCase()) {
      case 'RENOVACION':         return 'Renovación';
      case 'AMPLIACION':         return 'Ampliación';
      case 'NUEVA_SOLICITUD':    return 'Nueva Solicitud';
      case 'RECUPERACION_MORA':  return 'Cobranza';
      case 'SEGUIMIENTO':        return 'Seguimiento';
      case 'PROSPECCION':        return 'Prospección';
      default:                   return tipo;
    }
  }

  void iniciarVisita(String visitaId) {
    final index = _visitas.indexWhere((v) => v.id == visitaId);
    if (index != -1) {
      _visitas[index] = _visitas[index].copyWith(
        horaInicio: DateTime.now(),
      );
      notifyListeners();
    }
  }

  void finalizarVisita(String visitaId, String? observaciones) {
    final index = _visitas.indexWhere((v) => v.id == visitaId);
    if (index != -1) {
      _visitas[index] = _visitas[index].copyWith(
        completada: true,
        horaFin: DateTime.now(),
        observaciones: observaciones,
      );
      notifyListeners();
    }
  }
}

class SolicitudViewModel extends ChangeNotifier {
  final SolicitudRepository repository;
  final AuthViewModel? _authViewModel;

  List<SolicitudCredito> _solicitudes = [];
  bool _cargando = false;
  String _filtroEstado = 'Todos';
  int _pendientesTransmision = 0;

  SolicitudViewModel({
    SolicitudRepository? repository,
    AuthViewModel? authViewModel,
  })  : repository = repository ?? SolicitudRepository(),
        _authViewModel = authViewModel;

  String? get _asesorId => _authViewModel?.oficialActual?.id;

  List<SolicitudCredito> get solicitudes {
    if (_filtroEstado == 'Todos') return _solicitudes;
    return _solicitudes.where((s) => s.estadoTexto == _filtroEstado).toList();
  }

  bool get cargando => _cargando;
  String get filtroEstado => _filtroEstado;
  int get pendientesTransmision => _pendientesTransmision;
  int get totalSolicitudes => _solicitudes.length;

  Future<void> cargarSolicitudes() async {
    _cargando = true;
    notifyListeners();

    try {
      // El backend usa el JWT para identificar al asesor, no necesita asesorId explícito
      final data = await repository.getSolicitudes();
      _solicitudes = data.map((row) => SolicitudCredito.fromJson(row)).toList();
    } catch (_) {
      _solicitudes = DemoData.solicitudesDemo;
    }

    _pendientesTransmision = _solicitudes.where((s) => s.estado == EstadoSolicitud.borrador).length;
    _cargando = false;
    notifyListeners();
  }

  void filtrarPorEstado(String estado) {
    _filtroEstado = estado;
    notifyListeners();
  }

  Future<bool> transmitirSolicitud(String solicitudId) async {
    try {
      await repository.actualizarEstado(solicitudId, 'enviado');
      final index = _solicitudes.indexWhere((s) => s.id == solicitudId);
      if (index != -1) {
        _solicitudes[index] = _solicitudes[index].copyWith(
          estado: EstadoSolicitud.enviado,
          transmitido: true,
          fechaEnvio: DateTime.now(),
        );
        _pendientesTransmision =
            _solicitudes.where((s) => s.estado == EstadoSolicitud.borrador).length;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      final idx = _solicitudes.indexWhere((s) => s.id == solicitudId);
      if (idx == -1) return false;
      final sol = _solicitudes[idx];
      if (e is ApiException && e.statusCode == 404) {
        try {
          final result = await repository.crearSolicitud(sol.toMap());
          final dbId = result['id']?.toString() ?? sol.id;
          _solicitudes[idx] = sol.copyWith(
            id: dbId,
            estado: EstadoSolicitud.enviado,
            transmitido: true,
            fechaEnvio: DateTime.now(),
          );
          _pendientesTransmision =
              _solicitudes.where((s) => s.estado == EstadoSolicitud.borrador).length;
          notifyListeners();
          return true;
        } catch (_) {
          return false;
        }
      }
      return false;
    }
  }

  Future<bool> agregarSolicitud(SolicitudCredito solicitud) async {
    final asesorId = _asesorId;
    if (asesorId != null) {
      try {
        final result = await repository.crearSolicitud(solicitud.toMap());
        final dbId = result['id']?.toString() ?? solicitud.id;
        final transmitido = result['estado'] == 'enviado';
        _solicitudes.insert(
          0,
          solicitud.copyWith(
            id: dbId,
            transmitido: transmitido,
            estado: transmitido ? EstadoSolicitud.enviado : solicitud.estado,
            fechaEnvio: transmitido ? DateTime.now() : null,
          ),
        );
        _pendientesTransmision = _solicitudes.where((s) => s.estado == EstadoSolicitud.borrador).length;
        notifyListeners();
        return true;
      } catch (_) {
        _solicitudes.insert(0, solicitud);
        _pendientesTransmision = _solicitudes.where((s) => s.estado == EstadoSolicitud.borrador).length;
        notifyListeners();
        return false;
      }
    }
    _solicitudes.insert(0, solicitud);
    _pendientesTransmision = _solicitudes.where((s) => s.estado == EstadoSolicitud.borrador).length;
    notifyListeners();
    return false;
  }

  Future<List<Map<String, dynamic>>> getCronograma(String solicitudId) async {
    try {
      return await repository.getCronograma(solicitudId);
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getBitacora(String solicitudId) async {
    try {
      return await repository.getBitacora(solicitudId);
    } catch (_) {
      return [];
    }
  }

  Future<ResultadoBuro> consultarBuro(String dni) async {
    await Future.delayed(const Duration(seconds: 2));
    return ResultadoBuro(
      calificacionSbs: 'Normal',
      deudaTotalPen: 1500 + (dni.hashCode % 5000).abs().toDouble(),
      entidadesConDeuda: 2,
      enListaNegra: false,
      fechaConsulta: DateTime.now(),
    );
  }
}
