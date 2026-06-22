import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/ventas_viewmodel.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final oficial = auth.oficialActual;
    final solicitudes = context.watch<SolicitudViewModel>();

    return Scaffold(
      backgroundColor: EfectivaColors.grisFondo,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 200, pinned: true, automaticallyImplyLeading: false,
          backgroundColor: EfectivaColors.azulPrincipal,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(gradient: EfectivaColors.gradientePrincipal),
              child: SafeArea(child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 20)]),
                    child: Center(child: Text(
                      oficial?.nombreCompleto.split(' ').take(2).map((e) => e[0]).join('') ?? 'OF',
                      style: GoogleFonts.inter(fontSize: 30, fontWeight: FontWeight.w800, color: EfectivaColors.azulPrincipal),
                    )),
                  ),
                  const SizedBox(height: 12),
                  Text(oficial?.nombreCompleto ?? '', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                  Text(oficial?.codigoEmpleado ?? '', style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
                ]),
              )),
            ),
          ),
        ),
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            // Info del oficial
            _card([
              _row(Icons.email_outlined, 'Email', '${oficial?.codigoEmpleado ?? ''}@efectiva.pe'),
              _row(Icons.location_on_outlined, 'Zona', '-'),
              _row(Icons.business_outlined, 'Agencia', oficial?.agenciaNombre ?? oficial?.agenciaId ?? '-'),
            ]),
            const SizedBox(height: 16),
            // Estadísticas
            Text('Resumen del día', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: EfectivaColors.negroTexto)),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _statCard('Solicitudes', '${solicitudes.totalSolicitudes}', Icons.description, EfectivaColors.azulPrincipal)),
              const SizedBox(width: 10),
              Expanded(child: _statCard('Pendientes', '${solicitudes.pendientesTransmision}', Icons.cloud_off, EfectivaColors.naranjaAcento)),
            ]),
            const SizedBox(height: 16),
            // Opciones
            _card([
              _menuItem(Icons.sync, 'Sincronizar datos', () {}, EfectivaColors.verdeExito),
              const Divider(height: 1),
              _menuItem(Icons.settings_outlined, 'Configuración', () {}, EfectivaColors.grisTexto),
              const Divider(height: 1),
              _menuItem(Icons.help_outline, 'Soporte', () {}, EfectivaColors.azulPrincipal),
              const Divider(height: 1),
              _menuItem(Icons.info_outline, 'Acerca de', () => _showAcercaDe(context), EfectivaColors.grisTexto),
            ]),
            const SizedBox(height: 16),
            // Cerrar sesión
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await auth.logout();
                  if (context.mounted) Navigator.pushReplacementNamed(context, '/');
                },
                icon: const Icon(Icons.logout, size: 18, color: EfectivaColors.rojoError),
                label: Text('Cerrar sesión', style: GoogleFonts.inter(color: EfectivaColors.rojoError, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: EfectivaColors.rojoError),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (auth.isDemoMode)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: EfectivaColors.amarilloClaro, borderRadius: BorderRadius.circular(8)),
                child: Text('Modo demo activo', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: EfectivaColors.naranjaAcento)),
              ),
            const SizedBox(height: 8),
            Text('v${AppStrings.version}', style: GoogleFonts.inter(fontSize: 12, color: EfectivaColors.grisSubtitulo)),
            const SizedBox(height: 40),
          ]),
        )),
      ]),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(children: children),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Icon(icon, size: 20, color: EfectivaColors.azulPrincipal),
        const SizedBox(width: 12),
        Text(label, style: GoogleFonts.inter(fontSize: 13, color: EfectivaColors.grisTexto)),
        const Spacer(),
        Flexible(child: Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: EfectivaColors.negroTexto), textAlign: TextAlign.end)),
      ]),
    );
  }

  Widget _menuItem(IconData icon, String label, VoidCallback onTap, Color color) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: EfectivaColors.negroTexto))),
            const Icon(Icons.chevron_right, size: 18, color: EfectivaColors.grisSubtitulo),
          ]),
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(value, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: color)),
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: EfectivaColors.grisTexto)),
      ]),
    );
  }

  void _showAcercaDe(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: EfectivaColors.azulPrincipal, shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: EfectivaColors.azulPrincipal.withValues(alpha: 0.3), blurRadius: 20)]),
            child: Center(child: Text('E', style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white))),
          ),
          const SizedBox(height: 16),
          Text('Efectiva', style: GoogleFonts.pacifico(fontSize: 24, color: EfectivaColors.azulPrincipal)),
          Text('Fuerza de Ventas', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: EfectivaColors.naranjaAcento)),
          const SizedBox(height: 8),
          Text('v${AppStrings.version}', style: GoogleFonts.inter(fontSize: 12, color: EfectivaColors.grisSubtitulo)),
          const SizedBox(height: 12),
          Text(AppStrings.copyright, style: GoogleFonts.inter(fontSize: 11, color: EfectivaColors.grisTexto), textAlign: TextAlign.center),
        ]),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar'))],
      ),
    );
  }
}
