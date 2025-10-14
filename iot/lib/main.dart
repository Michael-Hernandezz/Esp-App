import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:iot/core/app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno
  try {
    await dotenv.load(fileName: '.env');
    print('Variables de entorno cargadas');
  } catch (e) {
    print('Error cargando .env: $e');
  }

  runApp(const SmartHomeApp());
}
