import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _codigoController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _recordarUsuario = false;
  bool _obscurePassword = true;
  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthViewModel>().cargarEstadoBloqueo();
    });
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: EfectivaColors.gradientePrincipal,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(24, 0, 24, 20 + bottomInset),
            child: Column(
              children: [
                const SizedBox(height: 40),
                FadeTransition(
                  opacity: _fadeIn,
                  child: _buildLogo(),
                ),
                const SizedBox(height: 24),
                SlideTransition(
                  position: _slideUp,
                  child: FadeTransition(
                    opacity: _fadeIn,
                    child: _buildFormCard(),
                  ),
                ),
                const SizedBox(height: 24),
                // Botón modo demo
                FadeTransition(
                  opacity: _fadeIn,
                  child: Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white38),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: _handleDemoLogin,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.play_circle_outline_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Ingresar en modo demo',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Credenciales demo hint
                FadeTransition(
                  opacity: _fadeIn,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white38),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: Colors.white70, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Prueba: EF2024-0145 / demo123456',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset('assets/images/icono_efectiva.png',
                  width: 100, height: 100, fit: BoxFit.cover),
              ),
            ),
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: EfectivaColors.naranjaAcento,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8),
                ],
              ),
              child: Center(
                child: Text('V', style: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Financiera Efectiva',
          style: GoogleFonts.pacifico(
            fontSize: 32,
            color: Colors.white,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                EfectivaColors.naranjaAcento.withValues(alpha: 0.8),
                EfectivaColors.amarilloAcento.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            AppStrings.slogan.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: EfectivaColors.azulSuave,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.badge_outlined,
                      color: EfectivaColors.azulPrincipal, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.bienvenido,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: EfectivaColors.negroTexto,
                      ),
                    ),
                    Text(
                      AppStrings.subtituloBienvenido,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: EfectivaColors.grisTexto,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 28),
            TextFormField(
              controller: _codigoController,
              decoration: InputDecoration(
                labelText: AppStrings.codigoEmpleado,
                prefixIcon: const Icon(
                  Icons.person_pin_outlined,
                  color: EfectivaColors.azulPrincipal,
                ),
                floatingLabelStyle: GoogleFonts.inter(
                  color: EfectivaColors.azulPrincipal,
                ),
              ),
              validator: Validators.codigoEmpleado,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: AppStrings.contrasena,
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: EfectivaColors.azulPrincipal,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: EfectivaColors.grisSubtitulo,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                floatingLabelStyle: GoogleFonts.inter(
                  color: EfectivaColors.azulPrincipal,
                ),
              ),
              obscureText: _obscurePassword,
              validator: Validators.password,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _recordarUsuario = !_recordarUsuario),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _recordarUsuario ? EfectivaColors.azulPrincipal : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: _recordarUsuario ? EfectivaColors.azulPrincipal : EfectivaColors.grisMedio,
                        width: 1.5,
                      ),
                    ),
                    child: _recordarUsuario
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => _recordarUsuario = !_recordarUsuario),
                  child: Text(
                    AppStrings.recordarme,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: EfectivaColors.grisTexto,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Consumer<AuthViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.state == AuthState.loading) {
                  return Container(
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: EfectivaColors.gradientePrincipal,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                }
                if (viewModel.state == AuthState.locked) {
                  return Column(children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: EfectivaColors.rojoSuave,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: EfectivaColors.rojoError.withValues(alpha: 0.3)),
                      ),
                      child: Column(children: [
                        const Icon(Icons.lock_outline, color: EfectivaColors.rojoError, size: 36),
                        const SizedBox(height: 8),
                        Text('Cuenta bloqueada',
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: EfectivaColors.rojoError)),
                        const SizedBox(height: 4),
                        Text('Demasiados intentos fallidos',
                          style: GoogleFonts.inter(fontSize: 12, color: EfectivaColors.grisTexto)),
                        const SizedBox(height: 8),
                        Text('${viewModel.segundosRestantes}s',
                          style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w800, color: EfectivaColors.rojoError)),
                        const SizedBox(height: 4),
                        Text('Espera para reintentar',
                          style: GoogleFonts.inter(fontSize: 11, color: EfectivaColors.grisTexto)),
                      ]),
                    ),
                  ]);
                }
                return Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: EfectivaColors.gradientePrincipal,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: EfectivaColors.azulPrincipal
                                .withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: _handleLogin,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.login_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  AppStrings.continuar,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (viewModel.state == AuthState.error)
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: EfectivaColors.rojoSuave,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: EfectivaColors.rojoError,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                viewModel.errorMessage,
                                style: GoogleFonts.inter(
                                  color: EfectivaColors.rojoError,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      // Normalizamos: quitamos espacios y convertimos el código a mayúsculas
      final codigo = _codigoController.text.trim().toUpperCase();
      final password = _passwordController.text.trim();

      final success = await context.read<AuthViewModel>().login(
            codigo,
            password,
          );

      if (!mounted) return;

      if (success) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  Future<void> _handleDemoLogin() async {
    final success = await context.read<AuthViewModel>().loginDemo();

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _codigoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
