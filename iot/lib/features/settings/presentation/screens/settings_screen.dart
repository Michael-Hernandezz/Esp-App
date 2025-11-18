import 'package:flutter/material.dart';
import 'package:iot/core/core.dart';
import '../../../auth/auth.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SHColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: SHColors.cardColor,
        foregroundColor: Colors.white,
      ),
      drawer: const SmartHomeDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Notificaciones'),
            _buildSettingsCard(context, [
              _buildSettingItem(
                context,
                icon: Icons.notifications,
                title: 'Notificaciones push',
                subtitle: 'Recibir alertas del sistema',
                trailing: Switch(
                  value: true,
                  onChanged: (value) {},
                  activeThumbColor: SHColors.selectedColor,
                ),
              ),
              _buildSettingItem(
                context,
                icon: Icons.email,
                title: 'Notificaciones por email',
                subtitle: 'Resumen diario',
                trailing: Switch(
                  value: false,
                  onChanged: (value) {},
                  activeThumbColor: SHColors.selectedColor,
                ),
              ),
              _buildSettingItem(
                context,
                icon: Icons.schedule,
                title: 'Horario de notificaciones',
                subtitle: '8:00 AM - 10:00 PM',
                onTap: () => _showTimeRangeDialog(context),
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Seguridad'),
            _buildSettingsCard(context, [
              _buildSettingItem(
                context,
                icon: Icons.lock,
                title: 'Cambiar PIN',
                subtitle: 'Actualizar código de seguridad',
                onTap: () => _showPinDialog(context),
              ),
              _buildSettingItem(
                context,
                icon: Icons.fingerprint,
                title: 'Autenticación biométrica',
                subtitle: 'Huella dactilar / Face ID',
                trailing: Switch(
                  value: true,
                  onChanged: (value) {},
                  activeThumbColor: SHColors.selectedColor,
                ),
              ),
              _buildSettingItem(
                context,
                icon: Icons.shield,
                title: 'Modo seguro',
                subtitle: 'Bloquear dispositivos automáticamente',
                trailing: Switch(
                  value: false,
                  onChanged: (value) {},
                  activeThumbColor: SHColors.selectedColor,
                ),
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Sesión'),
            _buildSettingsCard(context, [
              _buildSettingItem(
                context,
                icon: Icons.account_circle,
                title: 'Datos de sesión',
                subtitle: 'Ver información almacenada',
                onTap: () => _navigateToEvidence(context),
              ),
              _buildSettingItem(
                context,
                icon: Icons.logout,
                title: 'Cerrar sesión',
                subtitle: 'Salir de la aplicación',
                onTap: () => _showLogoutDialog(context),
              ),
            ]),
            const SizedBox(height: 32),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: SHColors.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final index = entry.key;
          final child = entry.value;
          return Column(
            children: [
              child,
              if (index < children.length - 1)
                const Divider(
                  color: SHColors.backgroundColor,
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: SHColors.selectedColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: SHColors.selectedColor, size: 24),
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
      trailing:
          trailing ?? const Icon(Icons.chevron_right, color: Colors.white54),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutDialog(context),
        icon: const Icon(Icons.logout, color: Colors.white),
        label: const Text(
          'Cerrar sesión',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showTimeRangeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SHColors.cardColor,
        title: const Text(
          'Horario de notificaciones',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Selecciona el horario en el que quieres recibir notificaciones.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey.shade400),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Configurar',
              style: TextStyle(color: SHColors.selectedColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showPinDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SHColors.cardColor,
        title: const Text('Cambiar PIN', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Para cambiar tu PIN de seguridad, primero debes introducir el PIN actual.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey.shade400),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Continuar',
              style: TextStyle(color: SHColors.selectedColor),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToEvidence(BuildContext context) {
    Navigator.pushNamed(context, '/evidence');
  }

  void _showLogoutDialog(BuildContext context) {
    final authNotifier = AuthProvider.of(context);
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: SHColors.cardColor,
        title: const Text(
          'Cerrar sesión',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '¿Estás seguro de que quieres cerrar sesión?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey.shade400),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // Usar el authNotifier capturado fuera del diálogo
              authNotifier?.logout();
            },
            child: const Text(
              'Cerrar sesión',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
