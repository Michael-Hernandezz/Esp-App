import 'package:flutter/material.dart';
import 'package:iot/core/core.dart';
import '../auth/auth.dart';
import '../auth/auth_di.dart';
import '../home/presentation/screens/home_screen.dart';
import '../dashboard/presentation/screens/enhanced_dashboard_screen.dart';
import '../notifications/presentation/screens/notifications_screen.dart';
import '../settings/presentation/screens/settings_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late AuthNotifier _authNotifier;

  @override
  void initState() {
    super.initState();
    _authNotifier = AuthDependencyInjection.getAuthNotifier();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Mostrar splash por un momento
    await Future.delayed(const Duration(seconds: 2));

    // Verificar estado de autenticación
    await _authNotifier.checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    return AuthProvider(
      notifier: _authNotifier,
      child: ValueListenableBuilder<AuthState>(
        valueListenable: _authNotifier,
        builder: (context, authState, _) {
          // Mostrar splash mientras está cargando o inicial
          if (authState.status == AuthStatus.initial ||
              authState.status == AuthStatus.loading) {
            return _buildSplashContent();
          }

          // Si hay error, mostrar login con el error
          if (authState.status == AuthStatus.error) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(authState.errorMessage ?? 'Error desconocido'),
                  backgroundColor: Colors.red,
                ),
              );
            });
            return const LoginScreen();
          }

          // Si está autenticado, ir a la app principal
          if (authState.status == AuthStatus.authenticated) {
            return _buildMainApp();
          }

          // Si no está autenticado, mostrar login
          return const LoginScreen();
        },
      ),
    );
  }

  Widget _buildSplashContent() {
    return Scaffold(
      backgroundColor: SHColors.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: SHColors.selectedColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.sensors,
                size: 60,
                color: SHColors.selectedColor,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'IoT Microgrid',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Cargando...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              color: SHColors.selectedColor,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainApp() {
    return RoomStateProvider(
      notifier: RoomStateNotifier(),
      child: Navigator(
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/evidence':
              return MaterialPageRoute(
                builder: (_) => AuthProvider(
                  notifier: _authNotifier,
                  child: const EvidenceScreen(),
                ),
              );
            default:
              return MaterialPageRoute(
                builder: (_) => const MainAppNavigation(),
              );
          }
        },
      ),
    );
  }
}

// Widget para la navegación principal de la app
class MainAppNavigation extends StatefulWidget {
  const MainAppNavigation({super.key});

  @override
  State<MainAppNavigation> createState() => _MainAppNavigationState();
}

class _MainAppNavigationState extends State<MainAppNavigation> {
  int _currentIndex = 0;

  void _handleRefresh() {
    // Funcionalidad de refresh para el dashboard
    if (_currentIndex == 1) {
      // Aquí puedes agregar la lógica de refresh específica del dashboard
<<<<<<< Updated upstream
<<<<<<< Updated upstream
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Actualizando datos...')),
      );
=======
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Actualizando datos...')));
>>>>>>> Stashed changes
=======
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Actualizando datos...')));
>>>>>>> Stashed changes
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const HomeScreen(),
      Builder(
        builder: (context) => const EnhancedDashboardScreen(),
      ), // Dashboard sin AppBar duplicado
      const NotificationsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: SHColors.backgroundColor,
<<<<<<< Updated upstream
<<<<<<< Updated upstream
      drawer: _currentIndex == 1 ? null : null, // Sin drawer para Dashboard (índice 1)
=======
      drawer: _currentIndex == 1
          ? null
          : null, // Sin drawer para Dashboard (índice 1)
>>>>>>> Stashed changes
=======
      drawer: _currentIndex == 1
          ? null
          : null, // Sin drawer para Dashboard (índice 1)
>>>>>>> Stashed changes
      endDrawer: null, // Sin drawer derecho
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: SHColors.cardColor,
        selectedItemColor: SHColors.selectedColor,
        unselectedItemColor: Colors.white.withOpacity(0.6),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notificaciones',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configuración',
          ),
        ],
      ),
    );
  }
}
