import 'package:flutter/material.dart';
import 'package:iot/features/home/presentation/screens/home_screen.dart';
import 'package:iot/features/dashboard/presentation/screens/enhanced_dashboard_screen.dart';
import 'package:iot/features/automations/presentation/screens/automations_screen.dart';
import 'package:iot/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:iot/features/history/presentation/screens/history_screen.dart';
import 'package:iot/features/settings/presentation/screens/settings_screen.dart';
import 'package:iot/features/auth/presentation/screens/login_screen.dart';
import 'package:iot/features/auth/presentation/screens/evidence_screen.dart';
import 'package:iot/features/splash/splash_screen.dart';

/// Router de la aplicación IoT Microgrid
/// Centraliza todas las rutas de navegación para un mantenimiento fácil
class AppRouter {
  // Rutas constantes para evitar errores de typos
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String automations = '/automations';
  static const String notifications = '/notifications';
  static const String history = '/history';
  static const String settings = '/settings';
  static const String login = '/login';
  static const String evidence = '/evidence';
  static const String splash = '/splash';

  /// Mapa de rutas de la aplicación
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      home: (context) => const HomeScreen(),
      dashboard: (context) => const EnhancedDashboardScreen(),
      automations: (context) => const AutomationsScreen(),
      notifications: (context) => const NotificationsScreen(),
      history: (context) => const HistoryScreen(),
      settings: (context) => const SettingsScreen(),
      login: (context) => const LoginScreen(),
      evidence: (context) => const EvidenceScreen(),
    };
  }

  /// Genera una ruta cuando no se encuentra en el mapa
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final String routeName = settings.name ?? home;
    final routes = getRoutes();

    if (routes.containsKey(routeName)) {
      return MaterialPageRoute(builder: routes[routeName]!, settings: settings);
    }

    // Ruta por defecto si no se encuentra
    return MaterialPageRoute(
      builder: (context) => const HomeScreen(),
      settings: settings,
    );
  }

  /// Métodos de navegación helper para uso en toda la app
  static Future<T?> navigateTo<T>(BuildContext context, String routeName) {
    return Navigator.pushNamed<T>(context, routeName);
  }

  static Future<T?> navigateAndReplace<T>(
    BuildContext context,
    String routeName,
  ) {
    return Navigator.pushReplacementNamed<T, Object?>(context, routeName);
  }

  static Future<T?> navigateAndClearStack<T>(
    BuildContext context,
    String routeName,
  ) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      routeName,
      (route) => false,
    );
  }

  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }

  /// Validación de rutas existentes
  static bool isValidRoute(String routeName) {
    return getRoutes().containsKey(routeName);
  }

  /// Lista de todas las rutas disponibles (útil para debugging)
  static List<String> getAllRoutes() {
    return getRoutes().keys.toList();
  }
}
