import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/models/cartera_model.dart';
import '../../data/datasources/cartera_demo_data.dart';
import '../../data/repositories/cartera_repository.dart';
import '../../core/services/network_monitor.dart';

class CarteraNuevoViewModel extends ChangeNotifier {
  final CarteraRepository _repository;
  StreamSubscription<bool>? _networkSub;

  List<CarteraItem> _items = [];
  List<CarteraItem> _itemsFiltrados = [];
  String _filtroActivo = 'Todos';
  String _busqueda = '';
  bool _cargando = false;
  DateTime? _ultimaActualizacion;
  bool _modoOffline = false;

  CarteraNuevoViewModel({CarteraRepository? repository})
      : _repository = repository ??
            CarteraRepository(
              networkMonitor: NetworkMonitor(),
            ) {
    _networkSub = NetworkMonitor().onStatusChanged.listen((online) {
      if (online && _modoOffline) {
        _modoOffline = false;
        cargarCartera();
      }
    });
  }

  List<CarteraItem> get items => _itemsFiltrados;
  String get filtroActivo => _filtroActivo;
  bool get cargando => _cargando;
  bool get modoOffline => _modoOffline;
  DateTime? get ultimaActualizacion => _ultimaActualizacion;
  bool get isOnline => NetworkMonitor().isOnline;

  int get totalClientes => _items.length;
  int get visitados => _items.where((i) => i.visitado).length;
  int get pendientes => _items.where((i) => !i.visitado).length;
  double get porcentajeAvance =>
      totalClientes > 0 ? visitados / totalClientes : 0;
  int get alertasNoLeidas => CarteraDemoData.alertasNoLeidas;

  Future<void> cargarCartera({String? asesorId}) async {
    _cargando = true;
    notifyListeners();

    try {
      if (isOnline) {
        final data = await _repository.getCarteraDiaria(asesorId: asesorId);
        final nuevos = data.map((json) => _fromJson(json)).toList();
        _items = [
          ...nuevos,
          ..._items.where((i) => i.pendienteSync),
        ];
        _modoOffline = false;
        _retryCount = 0;
      } else {
        _items = [
          ...CarteraDemoData.carteraDiaria,
          ..._items.where((i) => i.pendienteSync),
        ];
        _modoOffline = true;
        _reintentarCarga(asesorId: asesorId);
      }
    } catch (_) {
      _items = [
        ...CarteraDemoData.carteraDiaria,
        ..._items.where((i) => i.pendienteSync),
      ];
      _modoOffline = true;
      _reintentarCarga(asesorId: asesorId);
    }

    _ultimaActualizacion = DateTime.now();
    _aplicarFiltros();
    _cargando = false;
    notifyListeners();
  }

  int _retryCount = 0;
  static const int _maxRetries = 3;

  void _reintentarCarga({String? asesorId}) {
    if (_retryCount >= _maxRetries) return;
    _retryCount++;
    Future.delayed(const Duration(seconds: 5), () {
      if (_modoOffline && isOnline) {
        cargarCartera(asesorId: asesorId);
      }
    });
  }

  CarteraItem _fromJson(Map<String, dynamic> json) {
    final nombre = json['cliente_nombre'] as String?;
    final doc = json['documento'] as String?;
    return CarteraItem(
      id: json['id'] as String,
      asesorId: json['asesor_id'] as String? ?? json['cliente_id'] as String,
      clienteId: json['cliente_id'] as String,
      clienteNombre: nombre ?? '',
      clienteDniCensurado: doc != null && doc.length > 4
          ? '***${doc.substring(doc.length - 4)}'
          : '',
      agenciaId: json['agencia_id'] as String? ?? '',
      fechaAsignacion: DateTime.tryParse(json['fecha_asignacion'] as String? ?? '') ?? DateTime.now(),
      tipoGestion: _parseTipoGestion(json['tipo_gestion'] as String? ?? ''),
      prioridad: _parsePrioridad(json['prioridad'] as String? ?? 'normal'),
      scorePrioridad: (json['score_prioridad'] as num?)?.toInt() ?? 0,
      montoCredito: (json['monto_credito'] as num?)?.toDouble(),
      estadoVisita: _parseEstado(json['estado_visita'] as String? ?? 'pendiente'),
      resultadoVisita: json['resultado_visita'] as String?,
      observacionVisita: json['observacion_visita'] as String?,
      timestampVisita: DateTime.tryParse(json['timestamp_visita'] as String? ?? ''),
      latVisita: (json['lat_visita'] as num?)?.toDouble(),
      lngVisita: (json['lng_visita'] as num?)?.toDouble(),
      ordenManual: json['orden_manual'] as int?,
      pendienteSync: json['pendiente_sync'] as bool? ?? false,
    );
  }

  TipoGestion _parseTipoGestion(String s) {
    switch (s.toLowerCase()) {
      case 'renovacion': return TipoGestion.renovacion;
      case 'ampliacion': return TipoGestion.ampliacion;
      case 'nueva_solicitud': return TipoGestion.nuevaSolicitud;
      case 'seguimiento': return TipoGestion.seguimiento;
      case 'recuperacion_mora': return TipoGestion.recuperacionMora;
      case 'desertor': return TipoGestion.desertor;
      default: return TipoGestion.nuevaSolicitud;
    }
  }

  PrioridadVisita _parsePrioridad(String s) {
    switch (s) {
      case 'alta': return PrioridadVisita.alta;
      case 'media': return PrioridadVisita.media;
      default: return PrioridadVisita.normal;
    }
  }

  EstadoVisita _parseEstado(String s) {
    switch (s.toLowerCase()) {
      case 'visitado': return EstadoVisita.visitado;
      case 'no_encontrado': return EstadoVisita.noEncontrado;
      case 'reagendado': return EstadoVisita.reagendado;
      case 'negocio_cerrado': return EstadoVisita.negocioCerrado;
      default: return EstadoVisita.pendiente;
    }
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
    _itemsFiltrados = _items.where((item) {
      bool pasaFiltro = true;
      switch (_filtroActivo) {
        case 'Renovación':
          pasaFiltro = item.tipoGestion == TipoGestion.renovacion;
        case 'Nuevas':
          pasaFiltro = item.tipoGestion == TipoGestion.nuevaSolicitud;
        case 'En mora':
          pasaFiltro = item.tipoGestion == TipoGestion.recuperacionMora;
        case 'Visitados':
          pasaFiltro = item.visitado;
      }
      bool pasaBusqueda = true;
      if (_busqueda.isNotEmpty) {
        final q = _busqueda.toLowerCase();
        pasaBusqueda = item.clienteNombre.toLowerCase().contains(q) ||
            item.clienteDniCensurado.contains(q);
      }
      return pasaFiltro && pasaBusqueda;
    }).toList();

    _itemsFiltrados.sort((a, b) {
      if (a.visitado && !b.visitado) return 1;
      if (!a.visitado && b.visitado) return -1;
      return b.scorePrioridad.compareTo(a.scorePrioridad);
    });
  }

  static int calcularScorePrioridad({
    required TipoGestion tipoGestion,
    int diasSinContacto = 0,
    int scoreConfianza = 50,
    int creditosAnteriores = 0,
    double tasaMora = 0,
  }) {
    int score = 50;
    switch (tipoGestion) {
      case TipoGestion.recuperacionMora:
        score += 25;
      case TipoGestion.renovacion:
        score += 15;
      case TipoGestion.ampliacion:
        score += 10;
      case TipoGestion.desertor:
        score += 5;
      case TipoGestion.seguimiento:
        score += 0;
      case TipoGestion.nuevaSolicitud:
        score -= 5;
    }
    if (diasSinContacto > 60) {
      score += 15;
    } else if (diasSinContacto > 30) {
      score += 10;
    } else if (diasSinContacto > 15) {
      score += 5;
    }
    score += (scoreConfianza * 0.2).round();
    if (creditosAnteriores > 0) score += 5;
    if (tasaMora > 0) score = (score * (1 - tasaMora)).round();
    return score.clamp(0, 100);
  }

  Future<void> registrarResultadoVisita({
    required String itemId,
    required String estadoVisita,
    String? observacion,
    double? lat,
    double? lng,
  }) async {
    final idx = _items.indexWhere((i) => i.id == itemId);
    if (idx == -1) return;

    final estado = _parseEstado(estadoVisita);
    final actualizado = _items[idx].copyWith(
      estadoVisita: estado,
      resultadoVisita: estadoVisita,
      observacionVisita: observacion,
      timestampVisita: DateTime.now(),
      latVisita: lat ?? -12.0,
      lngVisita: lng ?? -77.0,
      pendienteSync: _modoOffline,
    );

    _items[idx] = actualizado;
    _aplicarFiltros();
    notifyListeners();

    await _repository.actualizarResultadoVisita(
      itemId,
      estadoVisita: estadoVisita,
      resultado: estadoVisita,
      observacion: observacion,
      lat: lat,
      lng: lng,
    );
  }

  void reordenar(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    final item = _itemsFiltrados.removeAt(oldIndex);
    _itemsFiltrados.insert(newIndex, item);
    notifyListeners();
  }

  void toggleOffline() {
    _modoOffline = !_modoOffline;
    notifyListeners();
  }

  void agregarItem(CarteraItem item) {
    _items.insert(0, item);
    _aplicarFiltros();
    notifyListeners();
  }

  int get pendientesSync => _items.where((i) => i.pendienteSync).length;

  List<CarteraItem> get clientesSinContacto {
    final limite = DateTime.now().subtract(const Duration(days: 7));
    return _items
        .where((i) =>
            !i.visitado &&
            (i.timestampVisita == null ||
                i.timestampVisita!.isBefore(limite)))
        .toList();
  }

  int get alertasSeguimiento => clientesSinContacto.length;

  Future<void> sincronizarPendientes() async {
    try {
      await _repository.sincronizarVisitasPendientes();
    } catch (_) {}

    _items = _items
        .map((i) => i.pendienteSync ? i.copyWith(pendienteSync: false) : i)
        .toList();
    _modoOffline = false;
    _aplicarFiltros();
    notifyListeners();
  }

  @override
  void dispose() {
    _networkSub?.cancel();
    super.dispose();
  }
}
