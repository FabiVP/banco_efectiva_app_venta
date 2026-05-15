import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../viewmodels/ventas_viewmodel.dart';
import 'dashboard_screen.dart';
import 'cartera_screen.dart';
import 'ruta_screen.dart';
import 'estado_solicitudes_screen.dart';
import 'perfil_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    CarteraScreen(),
    RutaScreen(),
    EstadoSolicitudesScreen(),
    PerfilScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Cargar datos iniciales
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CarteraViewModel>().cargarCartera();
      context.read<RutaViewModel>().cargarRuta();
      context.read<SolicitudViewModel>().cargarSolicitudes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                    0, Icons.dashboard_outlined, Icons.dashboard, 'INICIO'),
                _buildNavItem(1, Icons.people_outline, Icons.people, 'CARTERA'),
                _buildCenterNavItem(),
                _buildNavItem(
                    3, Icons.fact_check_outlined, Icons.fact_check, 'ESTADO'),
                _buildNavItem(
                    4, Icons.person_outline, Icons.person, 'PERFIL'),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              heroTag: 'fab_nueva_solicitud',
              onPressed: () =>
                  Navigator.pushNamed(context, '/nueva-solicitud'),
              backgroundColor: EfectivaColors.naranjaAcento,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: Text(
                'Nueva Solicitud',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildNavItem(
      int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? EfectivaColors.azulPrincipal.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 22,
              color: isSelected
                  ? EfectivaColors.azulPrincipal
                  : EfectivaColors.grisSubtitulo,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? EfectivaColors.azulPrincipal
                    : EfectivaColors.grisSubtitulo,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterNavItem() {
    final isSelected = _currentIndex == 2;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = 2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? EfectivaColors.naranjaAcento.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.map : Icons.map_outlined,
              size: 22,
              color: isSelected
                  ? EfectivaColors.naranjaAcento
                  : EfectivaColors.grisSubtitulo,
            ),
            const SizedBox(height: 3),
            Text(
              'RUTA',
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? EfectivaColors.naranjaAcento
                    : EfectivaColors.grisSubtitulo,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
