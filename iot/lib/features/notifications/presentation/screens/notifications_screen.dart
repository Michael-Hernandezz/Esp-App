import 'package:flutter/material.dart';
import 'package:iot/core/core.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<SecurityDevice> _securityDevices = [
    SecurityDevice(
      id: '1',
      name: 'BMS Principal (dev-001)',
      type: SecurityDeviceType.motionSensor,
      status: SecurityStatus.active,
      location: 'Sistema Central',
      lastUpdate: DateTime.now().subtract(const Duration(seconds: 30)),
    ),
    SecurityDevice(
      id: '2',
      name: 'Monitor Voltaje Batería',
      type: SecurityDeviceType.window,
      status: SecurityStatus.open,
      location: 'Convertidor DC-DC',
      lastUpdate: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
    SecurityDevice(
      id: '3',
      name: 'Sensor Corriente',
      type: SecurityDeviceType.motionSensor,
      status: SecurityStatus.active,
      location: 'Circuito Principal',
      lastUpdate: DateTime.now().subtract(const Duration(minutes: 1)),
    ),
    SecurityDevice(
      id: '4',
      name: 'Protección de Carga',
      type: SecurityDeviceType.door,
      status: SecurityStatus.closed,
      location: 'Sistema BMS',
      lastUpdate: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    SecurityDevice(
      id: '5',
      name: 'Monitor Estado Salud (SOH)',
      type: SecurityDeviceType.motionSensor,
      status: SecurityStatus.active,
      location: 'Análisis Batería',
      lastUpdate: DateTime.now().subtract(const Duration(minutes: 3)),
    ),
  ];

  final List<SmartNotification> _notifications = [
    SmartNotification(
      id: '1',
      title: 'Voltaje de Batería Alto',
<<<<<<< Updated upstream
<<<<<<< Updated upstream
      message: 'El voltaje de batería (dev-001) ha superado el umbral de 26V. Valor actual: 26.3V',
=======
      message:
          'El voltaje de batería (dev-001) ha superado el umbral de 26V. Valor actual: 26.3V',
>>>>>>> Stashed changes
=======
      message:
          'El voltaje de batería (dev-001) ha superado el umbral de 26V. Valor actual: 26.3V',
>>>>>>> Stashed changes
      type: NotificationType.warning,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      isRead: false,
      icon: Icons.battery_alert,
    ),
    SmartNotification(
      id: '2',
      title: 'BMS: Carga Habilitada',
<<<<<<< Updated upstream
<<<<<<< Updated upstream
      message: 'El sistema BMS ha habilitado la carga automáticamente. Estado: CHG_ENABLE = ON',
=======
      message:
          'El sistema BMS ha habilitado la carga automáticamente. Estado: CHG_ENABLE = ON',
>>>>>>> Stashed changes
=======
      message:
          'El sistema BMS ha habilitado la carga automáticamente. Estado: CHG_ENABLE = ON',
>>>>>>> Stashed changes
      type: NotificationType.info,
      timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
      isRead: false,
      icon: Icons.battery_charging_full,
    ),
    SmartNotification(
      id: '3',
      title: 'Corriente del Circuito Normal',
      message: 'La corriente del circuito se encuentra en rango normal: 2.1A',
      type: NotificationType.info,
      timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
      isRead: true,
      icon: Icons.electrical_services,
    ),
    SmartNotification(
      id: '4',
      title: 'Estado de Carga (SOC) Bajo',
<<<<<<< Updated upstream
<<<<<<< Updated upstream
      message: 'El estado de carga de la batería está por debajo del 20%: 18.7%',
=======
      message:
          'El estado de carga de la batería está por debajo del 20%: 18.7%',
>>>>>>> Stashed changes
=======
      message:
          'El estado de carga de la batería está por debajo del 20%: 18.7%',
>>>>>>> Stashed changes
      type: NotificationType.warning,
      timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
      isRead: false,
      icon: Icons.battery_2_bar,
    ),
    SmartNotification(
      id: '5',
      title: 'Sistema BMS Conectado',
<<<<<<< Updated upstream
<<<<<<< Updated upstream
      message: 'El dispositivo dev-001 se ha conectado exitosamente al sistema de monitoreo',
=======
      message:
          'El dispositivo dev-001 se ha conectado exitosamente al sistema de monitoreo',
>>>>>>> Stashed changes
=======
      message:
          'El dispositivo dev-001 se ha conectado exitosamente al sistema de monitoreo',
>>>>>>> Stashed changes
      type: NotificationType.security,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: true,
      icon: Icons.power,
    ),
    SmartNotification(
      id: '6',
      title: 'Voltaje de Salida Estable',
<<<<<<< Updated upstream
<<<<<<< Updated upstream
      message: 'El voltaje de salida del convertidor se mantiene estable en 12.1V',
=======
      message:
          'El voltaje de salida del convertidor se mantiene estable en 12.1V',
>>>>>>> Stashed changes
=======
      message:
          'El voltaje de salida del convertidor se mantiene estable en 12.1V',
>>>>>>> Stashed changes
      type: NotificationType.info,
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      isRead: true,
      icon: Icons.power_outlined,
    ),
    SmartNotification(
      id: '7',
      title: 'Alerta: Descarga Deshabilitada',
<<<<<<< Updated upstream
<<<<<<< Updated upstream
      message: 'El sistema BMS ha deshabilitado la descarga por protección. DSG_ENABLE = OFF',
=======
      message:
          'El sistema BMS ha deshabilitado la descarga por protección. DSG_ENABLE = OFF',
>>>>>>> Stashed changes
=======
      message:
          'El sistema BMS ha deshabilitado la descarga por protección. DSG_ENABLE = OFF',
>>>>>>> Stashed changes
      type: NotificationType.warning,
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
      isRead: false,
      icon: Icons.block,
    ),
    SmartNotification(
      id: '8',
      title: 'Salud de Batería (SOH) Óptima',
      message: 'La salud de la batería se mantiene en excelente estado: 95.2%',
      type: NotificationType.info,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: true,
      icon: Icons.health_and_safety,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SHColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: SHColors.cardColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            onPressed: _markAllAsRead,
          ),
        ],
      ),
      drawer: const SmartHomeDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSecuritySection(),
            const SizedBox(height: 32),
            _buildNotificationsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Estado del Sistema IoT'),
        const SizedBox(height: 16),
        _buildSecurityOverview(),
        const SizedBox(height: 16),
        ..._securityDevices.map((device) => _buildSecurityDeviceCard(device)),
      ],
    );
  }

  Widget _buildSecurityOverview() {
    final closedDoors = _securityDevices
        .where(
          (d) =>
              d.type == SecurityDeviceType.door &&
              d.status == SecurityStatus.closed,
        )
        .length;
    final totalDoors = _securityDevices
        .where((d) => d.type == SecurityDeviceType.door)
        .length;
    final activeMotionSensors = _securityDevices
        .where(
          (d) =>
              d.type == SecurityDeviceType.motionSensor &&
              d.status == SecurityStatus.active,
        )
        .length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SHColors.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSecurityStat(
              'Puertas Cerradas',
              '$closedDoors/$totalDoors',
              Icons.door_back_door,
              closedDoors == totalDoors ? Colors.green : Colors.orange,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildSecurityStat(
              'Sensores Activos',
              '$activeMotionSensors',
              Icons.sensors,
              Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityStat(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSecurityDeviceCard(SecurityDevice device) {
    final color = _getStatusColor(device.status);
    final statusText = _getStatusText(device.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SHColors.cardColor,
        borderRadius: BorderRadius.circular(8),
        border:
            device.status == SecurityStatus.open ||
                device.status == SecurityStatus.active
            ? Border.all(color: color.withOpacity(0.3))
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(_getDeviceIcon(device.type), color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  device.location,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatTime(device.lastUpdate),
                style: const TextStyle(color: Colors.white54, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection() {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildSectionTitle('Notificaciones y Recordatorios'),
            const Spacer(),
            if (unreadCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unreadCount nuevas',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        ..._notifications.map(
          (notification) => _buildNotificationCard(notification),
        ),
      ],
    );
  }

  Widget _buildNotificationCard(SmartNotification notification) {
    final color = _getNotificationColor(notification.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SHColors.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: !notification.isRead
            ? Border.all(color: color.withOpacity(0.3))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(notification.icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: notification.isRead
                              ? FontWeight.normal
                              : FontWeight.w600,
                        ),
                      ),
                    ),
                    if (!notification.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: TextStyle(
                    color: notification.isRead
                        ? Colors.white54
                        : Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      _formatTime(notification.timestamp),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    if (!notification.isRead)
                      InkWell(
                        onTap: () => _markAsRead(notification.id),
                        child: const Text(
                          'Marcar como leída',
                          style: TextStyle(
                            color: SHColors.selectedColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Color _getStatusColor(SecurityStatus status) {
    switch (status) {
      case SecurityStatus.closed:
      case SecurityStatus.inactive:
        return Colors.green;
      case SecurityStatus.open:
      case SecurityStatus.active:
        return Colors.orange;
      case SecurityStatus.alarm:
        return Colors.red;
    }
  }

  String _getStatusText(SecurityStatus status) {
    switch (status) {
      case SecurityStatus.closed:
        return 'Cerrado';
      case SecurityStatus.open:
        return 'Abierto';
      case SecurityStatus.active:
        return 'Activo';
      case SecurityStatus.inactive:
        return 'Inactivo';
      case SecurityStatus.alarm:
        return 'Alarma';
    }
  }

  IconData _getDeviceIcon(SecurityDeviceType type) {
    switch (type) {
      case SecurityDeviceType.door:
        return Icons.door_back_door;
      case SecurityDeviceType.window:
        return Icons.window;
      case SecurityDeviceType.motionSensor:
        return Icons.sensors;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.info:
        return Colors.blue;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.error:
        return Colors.red;
      case NotificationType.security:
        return Colors.purple;
      case NotificationType.reminder:
        return Colors.green;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  void _markAsRead(String id) {
    setState(() {
      final notification = _notifications.firstWhere((n) => n.id == id);
      notification.isRead = true;
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (final notification in _notifications) {
        notification.isRead = true;
      }
    });

    MessageService.showDeviceMessage(
      context,
      'Todas las notificaciones marcadas como leídas',
      true,
    );
  }
}

enum SecurityDeviceType { door, window, motionSensor }

enum SecurityStatus { closed, open, active, inactive, alarm }

enum NotificationType { info, warning, error, security, reminder }

class SecurityDevice {
  final String id;
  final String name;
  final SecurityDeviceType type;
  final SecurityStatus status;
  final String location;
  final DateTime lastUpdate;

  SecurityDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.location,
    required this.lastUpdate,
  });
}

class SmartNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  bool isRead;
  final IconData icon;

  SmartNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    required this.isRead,
    required this.icon,
  });
}
