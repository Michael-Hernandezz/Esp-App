import 'package:flutter/material.dart';
import 'package:iot/core/core.dart';

class SmartHomeDrawer extends StatelessWidget {
  const SmartHomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: SHColors.backgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(context),
          _buildDrawerItem(
            context,
            icon: Icons.dashboard,
            title: 'Dashboard',
            subtitle: 'Resumen del hogar',
            onTap: () => _navigateToScreen(context, '/dashboard'),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.home,
            title: 'Inicio',
            subtitle: 'Control de habitaciones',
            onTap: () => _navigateToScreen(context, '/home'),
          ),
          const Divider(color: SHColors.cardColor),
          _buildDrawerItem(
            context,
            icon: Icons.notifications,
            title: 'Notificaciones',
            subtitle: 'Alertas y seguridad',
            onTap: () => _navigateToScreen(context, '/notifications'),
            badge: _getNotificationBadge(),
          ),
          const Divider(color: SHColors.cardColor),
          _buildDrawerItem(
            context,
            icon: Icons.settings,
            title: 'Configuración',
            subtitle: 'Ajustes generales',
            onTap: () => _navigateToScreen(context, '/settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return DrawerHeader(
      decoration: const BoxDecoration(
        color: SHColors.cardColor,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [SHColors.selectedColor, SHColors.cardColor],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white24,
            child: Icon(Icons.home_rounded, size: 35, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            'Smart Home',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Control inteligente',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? badge,
  }) {
    return ListTile(
      leading: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: SHColors.cardColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: SHColors.selectedColor, size: 24),
          ),
          if (badge != null) Positioned(right: 0, top: 0, child: badge),
        ],
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: Colors.white70),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _getNotificationBadge() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      child: const Text(
        '3',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _navigateToScreen(BuildContext context, String route) {
    Navigator.pop(context); // Cerrar drawer

    switch (route) {
      case '/dashboard':
        Navigator.pushNamed(context, '/dashboard');
        break;
      case '/home':
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        break;
      case '/notifications':
        Navigator.pushNamed(context, '/notifications');
        break;
      case '/settings':
        Navigator.pushNamed(context, '/settings');
        break;
    }
  }
}
