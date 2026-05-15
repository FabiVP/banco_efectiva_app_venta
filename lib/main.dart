import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/nueva_solicitud_screen.dart';
import 'presentation/screens/captura_documentos_screen.dart';
import 'presentation/screens/consulta_buro_screen.dart';
import 'presentation/screens/transmision_screen.dart';
import 'presentation/screens/ficha_cliente_screen.dart';
import 'presentation/viewmodels/auth_viewmodel.dart';
import 'presentation/viewmodels/ventas_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Status bar transparente para diseño inmersivo
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Inicializar formato de fechas en español
  await initializeDateFormatting('es', null);

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
        ChangeNotifierProvider(create: (_) => RutaViewModel()),
        ChangeNotifierProvider(create: (_) => SolicitudViewModel()),
      ],
      child: MaterialApp(
        title: 'Efectiva - Fuerza de Ventas',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/nueva-solicitud': (context) => const NuevaSolicitudScreen(),
          '/captura-documentos': (context) => const CapturaDocumentosScreen(),
          '/consulta-buro': (context) => const ConsultaBuroScreen(),
          '/transmision': (context) => const TransmisionScreen(),
          '/ficha-cliente': (context) => const FichaClienteScreen(),
        },
      ),
    );
  }
}
