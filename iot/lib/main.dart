import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:iot/core/core.dart';
import 'package:iot/core/app/app_router.dart';
import 'features/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno
  try {
    await dotenv.load(fileName: '.env');
    print('Variables de entorno cargadas');
  } catch (e) {
    print('Error cargando .env: $e');
  }

  runApp(const IoTMicrogridApp());
}

class IoTMicrogridApp extends StatelessWidget {
  const IoTMicrogridApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IoT Microgrid App',
      theme: SHThemeData.lightTheme,
      darkTheme: SHThemeData.darkTheme,
      themeMode: ThemeMode.system,
      // Ruta inicial
      initialRoute: AppRouter.splash,
      // Rutas definidas centralizadas
      routes: AppRouter.getRoutes(),
      // Generador de rutas para casos especiales
      onGenerateRoute: AppRouter.onGenerateRoute,
      // Fallback a splash screen
      home: const SplashScreen(),
    );
  }
}
