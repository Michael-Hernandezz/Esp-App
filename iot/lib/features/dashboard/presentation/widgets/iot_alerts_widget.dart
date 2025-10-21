import 'package:flutter/material.dart';
import 'dart:async';

/// Widget de alertas IoT en tiempo real
class IoTAlertsWidget extends StatefulWidget {
  const IoTAlertsWidget({super.key});

  @override
  State<IoTAlertsWidget> createState() => _IoTAlertsWidgetState();
}

class _IoTAlertsWidgetState extends State<IoTAlertsWidget>
    with TickerProviderStateMixin {
  late Timer _alertTimer;
  late AnimationController _blinkController;
  List<IoTAlert> _activeAlerts = [];

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _blinkController.repeat(reverse: true);

    _generateSampleAlerts();
    _alertTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _updateAlerts();
    });
  }

  @override
  void dispose() {
    _alertTimer.cancel();
    _blinkController.dispose();
    super.dispose();
  }

  void _generateSampleAlerts() {
    _activeAlerts = [
      IoTAlert(
        id: 'TEMP_HIGH_001',
        title: 'Temperatura Crítica',
        message: 'Sensor TEMP-001: 35.2°C (Límite: 30°C)',
        severity: IoTAlertSeverity.critical,
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        deviceId: 'TEMP-001',
        sensorType: 'Temperatura',
      ),
      IoTAlert(
        id: 'VOLT_LOW_001',
        title: 'Voltaje Bajo',
        message: 'Sistema eléctrico: 10.8V (Mínimo: 11V)',
        severity: IoTAlertSeverity.warning,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        deviceId: 'VOLT-001',
        sensorType: 'Voltaje',
      ),
    ];
  }

  void _updateAlerts() {
    // Simular nuevas alertas ocasionalmente
    if (DateTime.now().second % 15 == 0) {
      setState(() {
        _activeAlerts.add(
          IoTAlert(
            id: 'SIM_${DateTime.now().millisecondsSinceEpoch}',
            title: 'Conexión Inestable',
            message: 'Sensor WIFI-001: Señal débil detectada',
            severity: IoTAlertSeverity.info,
            timestamp: DateTime.now(),
            deviceId: 'WIFI-001',
            sensorType: 'Conectividad',
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_activeAlerts.isEmpty) {
      return _buildNoAlertsWidget();
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedBuilder(
                  animation: _blinkController,
                  builder: (context, child) {
                    return Icon(
                      Icons.warning,
                      color: Colors.red.withOpacity(
                        0.5 + _blinkController.value * 0.5,
                      ),
                      size: 24,
                    );
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  'Alertas del Sistema',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_activeAlerts.length}',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...(_activeAlerts
                .take(3)
                .map((alert) => _buildAlertItem(alert))
                .toList()),
            if (_activeAlerts.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  '+${_activeAlerts.length - 3} alertas más',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoAlertsWidget() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[600], size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sistema Operativo',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  Text(
                    'Todos los sensores funcionando correctamente',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertItem(IoTAlert alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getAlertColor(alert.severity).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getAlertColor(alert.severity).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _getAlertIcon(alert.severity),
            color: _getAlertColor(alert.severity),
            size: 20,
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
                        alert.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _getAlertColor(alert.severity),
                        ),
                      ),
                    ),
                    Text(
                      _formatTimestamp(alert.timestamp),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  alert.message,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        alert.deviceId,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      alert.sensorType,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: () {
              setState(() {
                _activeAlerts.remove(alert);
              });
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
        ],
      ),
    );
  }

  Color _getAlertColor(IoTAlertSeverity severity) {
    switch (severity) {
      case IoTAlertSeverity.critical:
        return Colors.red;
      case IoTAlertSeverity.warning:
        return Colors.orange;
      case IoTAlertSeverity.info:
        return Colors.blue;
    }
  }

  IconData _getAlertIcon(IoTAlertSeverity severity) {
    switch (severity) {
      case IoTAlertSeverity.critical:
        return Icons.dangerous;
      case IoTAlertSeverity.warning:
        return Icons.warning;
      case IoTAlertSeverity.info:
        return Icons.info;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else {
      return '${difference.inHours}h';
    }
  }
}

/// Modelo de alerta IoT
class IoTAlert {
  final String id;
  final String title;
  final String message;
  final IoTAlertSeverity severity;
  final DateTime timestamp;
  final String deviceId;
  final String sensorType;

  IoTAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    required this.timestamp,
    required this.deviceId,
    required this.sensorType,
  });
}

enum IoTAlertSeverity { critical, warning, info }
