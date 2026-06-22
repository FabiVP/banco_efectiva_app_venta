import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import '../../../data/models/cliente_model.dart';
import '../../../data/models/solicitud_model.dart';
import '../../../data/models/visita_model.dart';
import '../../../data/datasources/demo_data.dart';
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

  List<VisitaPlanificada> get visitas => _visitas;
  bool get cargando => _cargando;

  int get visitasCompletadas => _visitas.where((v) => v.completada).length;
  int get totalVisitas => _visitas.length;
  double get porcentajeAvance =>
      totalVisitas > 0 ? visitasCompletadas / totalVisitas : 0;

  Future<void> cargarRuta() async {
    _cargando = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));
    _visitas = DemoData.visitasDemo;
    _cargando = false;
    notifyListeners();
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
