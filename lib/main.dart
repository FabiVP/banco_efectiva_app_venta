import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'core/api/api_client.dart';
import 'core/services/network_monitor.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/nueva_solicitud_screen.dart';
import 'presentation/screens/captura_documentos_screen.dart';
import 'presentation/screens/consulta_buro_screen.dart';
import 'presentation/screens/transmision_screen.dart';
import 'presentation/screens/ficha_cliente_nuevo_screen.dart';
import 'presentation/viewmodels/auth_viewmodel.dart';
import 'presentation/viewmodels/ventas_viewmodel.dart';
import 'presentation/viewmodels/cartera_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF0F172A),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

  // Carga variables de entorno (.env)
  await dotenv.load(fileName: '.env');

  // Formatos de fecha en español
  await initializeDateFormatting('es', null);

  // Inicializar el monitor de conectividad
  await NetworkMonitor().initialize();

  // El ApiClient se inicializa como singleton al primer uso.
  // La URL base se lee desde .env (API_BASE_URL) o usa 10.0.2.2:8003.
  ApiClient();

  runApp(const EfectivaVentasApp());
}

class EfectivaVentasApp extends StatelessWidget {
  const EfectivaVentasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => CarteraViewModel()),
        ChangeNotifierProvider(create: (_) => CarteraNuevoViewModel()),
        ChangeNotifierProvider(create: (_) => RutaViewModel()),
        ChangeNotifierProxyProvider<AuthViewModel, SolicitudViewModel>(
          create: (_) => SolicitudViewModel(),
          update: (_, auth, prev) => SolicitudViewModel(
            repository: prev?.repository,
            authViewModel: auth,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Efectiva — Fuerza de Ventas',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/nueva-solicitud': (context) => const NuevaSolicitudScreen(),
          '/captura-documentos': (context) => const CapturaDocumentosScreen(),
          '/consulta-buro': (context) => const ConsultaBuroScreen(),
          '/transmision': (context) => const TransmisionScreen(),
          '/ficha-cliente': (context) => const FichaClienteNuevoScreen(),
        },
      ),
    );
  }
}
