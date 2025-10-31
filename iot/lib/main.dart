import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ui_common/ui_common.dart';
import 'package:iot/core/core.dart';
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
    return ScreenUtilInit(
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'IoT Microgrid App',
          theme: SHTheme.dark,
          home: const SplashScreen(),
        );
      },
    );
  }
}
