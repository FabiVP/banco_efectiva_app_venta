import 'package:flutter/material.dart';
import '../../../data/models/cliente_model.dart';
import '../../../data/models/solicitud_model.dart';
import '../../../data/models/visita_model.dart';
import '../../../data/datasources/demo_data.dart';

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
  int get clientesConRenovacion =>
      _clientes.where((c) => c.tieneRenovacion).length;

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
      // Filtro por categoría
      bool pasaFiltro = true;
      if (_filtroActivo == 'Renovación') {
        pasaFiltro = c.tieneRenovacion;
      } else if (_filtroActivo == 'Nuevos') {
        pasaFiltro = c.creditosAnteriores == 0;
      } else if (_filtroActivo == 'Activos') {
        pasaFiltro = c.productosActivos.isNotEmpty;
      }

      // Filtro por búsqueda
      bool pasaBusqueda = true;
      if (_busqueda.isNotEmpty) {
        final q = _busqueda.toLowerCase();
        pasaBusqueda = c.nombreCompleto.toLowerCase().contains(q) ||
            c.dni.contains(q);
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
  List<SolicitudCredito> _solicitudes = [];
  bool _cargando = false;
  String _filtroEstado = 'Todos';
  int _pendientesTransmision = 0;

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

    await Future.delayed(const Duration(milliseconds: 500));
    _solicitudes = DemoData.solicitudesDemo;
    _pendientesTransmision = _solicitudes.where((s) => !s.transmitido).length;
    _cargando = false;
    notifyListeners();
  }

  void filtrarPorEstado(String estado) {
    _filtroEstado = estado;
    notifyListeners();
  }

  Future<bool> transmitirSolicitud(String solicitudId) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    final index = _solicitudes.indexWhere((s) => s.id == solicitudId);
    if (index != -1) {
      _solicitudes[index] = _solicitudes[index].copyWith(
        transmitido: true,
        estado: EstadoSolicitud.enviado,
        fechaEnvio: DateTime.now(),
      );
      _pendientesTransmision = _solicitudes.where((s) => !s.transmitido).length;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> agregarSolicitud(SolicitudCredito solicitud) async {
    _solicitudes.insert(0, solicitud);
    _pendientesTransmision = _solicitudes.where((s) => !s.transmitido).length;
    notifyListeners();
  }

  Future<ResultadoBuro> consultarBuro(String dni) async {
    await Future.delayed(const Duration(seconds: 2));
    // Simulación de consulta de buró
    return ResultadoBuro(
      scoreRiesgo: 'Bajo',
      puntaje: 680 + (dni.hashCode % 120).abs(),
      aprobado: true,
      detalle:
          'Sin deudas vencidas. Historial de pagos regular. Capacidad de endeudamiento disponible.',
      fechaConsulta: DateTime.now(),
    );
  }
}
