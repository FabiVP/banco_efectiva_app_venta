import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/ventas_viewmodel.dart';
import '../viewmodels/cartera_viewmodel.dart';
import 'dashboard_screen.dart';
import 'cartera_diaria_screen.dart';
import 'ruta_screen.dart';
import 'estado_solicitudes_screen.dart';
import 'perfil_screen.dart';
import 'cobranza_screen.dart';
import 'reportes_screen.dart';
import 'pre_evaluacion_screen.dart';
import 'simulador_credito_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Tabs del bottom navigation (todos los perfiles)
  static const List<_NavTab> _tabs = [
    _NavTab(0, Icons.dashboard_outlined, Icons.dashboard, 'INICIO'),
    _NavTab(1, Icons.folder_copy_outlined, Icons.folder_copy, 'CARTERA'),
    _NavTab(2, Icons.map_outlined, Icons.map, 'RUTA'),
    _NavTab(3, Icons.fact_check_outlined, Icons.fact_check, 'ESTADO'),
    _NavTab(4, Icons.person_outline, Icons.person, 'PERFIL'),
  ];

  final List<Widget> _screens = const [
    DashboardScreen(),
    CarteraNuevoScreen(),
    RutaScreen(),
    EstadoSolicitudesScreen(),
    PerfilScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CarteraViewModel>().cargarCartera();
      context.read<CarteraNuevoViewModel>().cargarCartera();
      context.read<RutaViewModel>().cargarRuta();
      context.read<SolicitudViewModel>().cargarSolicitudes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final perfil = auth.oficialActual?.perfil ?? 'operador';

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      drawer: _buildDrawer(context, perfil),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton(
              heroTag: 'fab_simulador',
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SimuladorCreditoScreen())),
              backgroundColor: EfectivaColors.naranjaAcento,
              child: const Icon(Icons.calculate_outlined, color: Colors.white),
            )
          : _currentIndex == 0
              ? FloatingActionButton.extended(
                  heroTag: 'fab_solicitud',
                  onPressed: () => Navigator.pushNamed(context, '/nueva-solicitud'),
                  backgroundColor: EfectivaColors.naranjaAcento,
                  icon: const Icon(Icons.add_rounded, color: Colors.white),
                  label: Text('Nueva Solicitud',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)),
                )
              : null,
    );
  }

  Widget _buildBottomNav() {
    final vm = context.watch<CarteraNuevoViewModel>();
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _tabs.map((tab) {
              final isSelected = _currentIndex == tab.index;
              return GestureDetector(
                onTap: () => setState(() => _currentIndex = tab.index),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (tab.index == 2 ? EfectivaColors.naranjaAcento : EfectivaColors.azulPrincipal).withValues(alpha: 0.10)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Stack(children: [
                      Icon(
                        isSelected ? tab.activeIcon : tab.icon,
                        size: 22,
                        color: isSelected
                            ? (tab.index == 2 ? EfectivaColors.naranjaAcento : EfectivaColors.azulPrincipal)
                            : EfectivaColors.textoSecundario_(context),
                      ),
                      if (tab.index == 1 && vm.alertasNoLeidas > 0)
                        Positioned(right: -2, top: -2, child: Container(
                          width: 14, height: 14,
                          decoration: const BoxDecoration(color: EfectivaColors.rojoError, shape: BoxShape.circle),
                          child: Center(child: Text('${vm.alertasNoLeidas}',
                              style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w700, color: Colors.white))),
                        )),
                    ]),
                    const SizedBox(height: 3),
                    Text(tab.label, style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? (tab.index == 2 ? EfectivaColors.naranjaAcento : EfectivaColors.azulPrincipal)
                          : EfectivaColors.textoSecundario_(context),
                    )),
                  ]),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // ─── Menú lateral adaptativo por perfil (HU-02 · RF-05) ──────────────────
  Widget _buildDrawer(BuildContext context, String perfil) {
    final auth = context.watch<AuthViewModel>();
    final oficial = auth.oficialActual;
    final vm = context.watch<CarteraNuevoViewModel>();

    // Opciones disponibles por perfil
    final esOperador = ['operador', 'super_operador', 'supervisor', 'administrador'].contains(perfil);
    final esSupervisor = ['supervisor', 'administrador'].contains(perfil);
    final esAdmin = perfil == 'administrador';

    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(children: [
        // Cabecera
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(gradient: EfectivaColors.gradientePrincipal),
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16, left: 20, right: 20, bottom: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 58, height: 58,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle,
                border: Border.all(color: Colors.white38, width: 2)),
              child: Center(child: Text(
                oficial?.nombreCompleto.split(' ').take(2).map((e) => e[0]).join('') ?? 'OF',
                style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white))),
            ),
            const SizedBox(height: 12),
            Text(oficial?.nombreCompleto ?? 'Oficial de Crédito',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            Text(oficial?.agenciaNombre ?? oficial?.agenciaId ?? '-', style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
              child: Text(_perfilLabel(perfil), style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ]),
        ),
        Expanded(child: ListView(padding: const EdgeInsets.symmetric(vertical: 8), children: [
          // ─ Operador (siempre visible) ─────────────────────────────────────
          if (esOperador) ...[
            _drawerTitulo(context, 'CAMPO'),
            _drawerItem(context, Icons.dashboard_outlined, 'Dashboard', () { setState(() => _currentIndex = 0); Navigator.pop(context); }),
            _drawerItem(context, Icons.folder_copy_outlined, 'Cartera del día', () { setState(() => _currentIndex = 1); Navigator.pop(context); },
              badge: vm.alertasNoLeidas > 0 ? vm.alertasNoLeidas : null),
            _drawerItem(context, Icons.map_outlined, 'Planificación de ruta', () { setState(() => _currentIndex = 2); Navigator.pop(context); }),
            _drawerItem(context, Icons.person_search_outlined, 'Pre-evaluación / Campañas',
              () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const PreEvaluacionScreen())); }),
            _drawerItem(context, Icons.description_outlined, 'Nueva solicitud',
              () { Navigator.pop(context); Navigator.pushNamed(context, '/nueva-solicitud'); }),
            _drawerItem(context, Icons.camera_alt_outlined, 'Captura de documentos',
              () { Navigator.pop(context); Navigator.pushNamed(context, '/captura-documentos'); }),
            _drawerItem(context, Icons.verified_user_outlined, 'Consulta de buró',
              () { Navigator.pop(context); Navigator.pushNamed(context, '/consulta-buro'); }),
            _drawerItem(context, Icons.send_outlined, 'Transmisión electrónica',
              () { Navigator.pop(context); Navigator.pushNamed(context, '/transmision'); }),
            _drawerItem(context, Icons.fact_check_outlined, 'Estado de solicitudes',
              () { setState(() => _currentIndex = 3); Navigator.pop(context); }),
            _drawerItem(context, Icons.calculate_outlined, 'Simulador de crédito',
              () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const SimuladorCreditoScreen())); }),
            _drawerItem(context, Icons.warning_amber_outlined, 'Cobranza / Mora',
              () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const CobranzaScreen())); }),
          ],
          // ─ Supervisor + ────────────────────────────────────────────────────
          if (esSupervisor) ...[
            const Divider(height: 20, indent: 20, endIndent: 20),
            _drawerTitulo(context, 'SUPERVISIÓN'),
            _drawerItem(context, Icons.analytics_outlined, 'Reportes y productividad',
              () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportesScreen())); }),
            _drawerItem(context, Icons.radar_outlined, 'Monitor en tiempo real',
              () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportesScreen())); }),
          ],
          // ─ Admin ───────────────────────────────────────────────────────────
          if (esAdmin) ...[
            const Divider(height: 20, indent: 20, endIndent: 20),
            _drawerTitulo(context, 'ADMINISTRACIÓN'),
            _drawerItem(context, Icons.manage_accounts_outlined, 'Gestión de usuarios', () { Navigator.pop(context); }),
            _drawerItem(context, Icons.settings_outlined, 'Configuración', () { Navigator.pop(context); }),
          ],
          const Divider(height: 20, indent: 20, endIndent: 20),
          // ─ Modo offline toggle ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(children: [
              const Icon(Icons.wifi_off_outlined, size: 18, color: EfectivaColors.grisTexto),
              const SizedBox(width: 12),
              Expanded(child: Text('Simular offline', style: GoogleFonts.inter(fontSize: 14, color: EfectivaColors.grisTexto))),
              Switch(
                value: vm.modoOffline,
                onChanged: (_) => vm.toggleOffline(),
                activeTrackColor: EfectivaColors.naranjaAcento,
              ),
            ]),
          ),
          if (vm.pendientesSync > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: EfectivaColors.amarilloClaro, borderRadius: BorderRadius.circular(8)),
                child: Text('${vm.pendientesSync} pendiente(s) de sync',
                  style: GoogleFonts.inter(fontSize: 12, color: EfectivaColors.naranjaAcento, fontWeight: FontWeight.w600)),
              ),
            ),
        ])),
        // ─ Cerrar sesión (HU-03) ─────────────────────────────────────────────
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.logout, color: EfectivaColors.rojoError),
          title: Text('Cerrar sesión', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: EfectivaColors.rojoError)),
          onTap: () => _confirmarLogout(context, vm),
        ),
        const SizedBox(height: 8),
      ]),
    );
  }

  void _confirmarLogout(BuildContext context, CarteraNuevoViewModel vm) {
    // RF-08: Advertencia si hay pendientes de sync
    if (vm.pendientesSync > 0) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Solicitudes pendientes', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          content: Text(
            'Tienes ${vm.pendientesSync} solicitud(es) sin sincronizar. ¿Cerrar de todas formas?',
            style: GoogleFonts.inter(),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () { Navigator.pop(context); _logout(context); },
              style: FilledButton.styleFrom(backgroundColor: EfectivaColors.rojoError),
              child: const Text('Cerrar de todas formas'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('¿Cerrar sesión?', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          content: Text('Se eliminarán la sesión y los datos en caché.', style: GoogleFonts.inter()),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () { Navigator.pop(context); _logout(context); },
              style: FilledButton.styleFrom(backgroundColor: EfectivaColors.rojoError),
              child: const Text('Cerrar sesión'),
            ),
          ],
        ),
      );
    }
  }

  void _logout(BuildContext context) {
    // RF-07: Invalidar token + borrar caché + navegar a login
    context.read<AuthViewModel>().logout();
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  Widget _drawerTitulo(BuildContext ctx, String titulo) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
    child: Text(titulo, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: EfectivaColors.textoSecundario_(ctx), letterSpacing: 1.2)),
  );

  Widget _drawerItem(BuildContext ctx, IconData icon, String label, VoidCallback onTap, {int? badge}) => ListTile(
    dense: true,
    leading: Stack(clipBehavior: Clip.none, children: [
      Icon(icon, color: EfectivaColors.azulPrincipal, size: 22),
      if (badge != null)
        Positioned(right: -6, top: -4, child: Container(
          width: 16, height: 16,
          decoration: const BoxDecoration(color: EfectivaColors.rojoError, shape: BoxShape.circle),
          child: Center(child: Text('$badge', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white))),
        )),
    ]),
    title: Text(label, style: GoogleFonts.inter(fontSize: 14, color: Theme.of(ctx).colorScheme.onSurface)),
    onTap: onTap,
  );

  String _perfilLabel(String perfil) => switch (perfil) {
    'operador' => 'OPERADOR',
    'super_operador' => 'SUPER OPERADOR',
    'supervisor' => 'SUPERVISOR',
    'administrador' => 'ADMINISTRADOR',
    _ => 'OPERADOR',
  };
}

class _NavTab {
  final int index;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavTab(this.index, this.icon, this.activeIcon, this.label);
}
