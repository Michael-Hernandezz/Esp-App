import 'package:flutter/material.dart';
import 'dart:async';
import 'package:iot/core/shared/data/services/influxdb_service.dart';

/// Widget de alertas IoT en tiempo real conectado a InfluxDB
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

    _loadRealAlerts();
    _alertTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _loadRealAlerts();
    });
  }

  @override
  void dispose() {
    _alertTimer.cancel();
    _blinkController.dispose();
    super.dispose();
  }

  Future<void> _loadRealAlerts() async {
    try {
      final latestData = await InfluxDBService.getLatestSensorData();
      final List<IoTAlert> newAlerts = [];

      if (latestData.isEmpty) return;

      // Verificar alertas activas (alert = 1)
      if (latestData.containsKey('alert') && latestData['alert']!.value > 0) {
        newAlerts.add(
          IoTAlert(
            id: 'ALERT_${latestData['alert']!.deviceId}',
            title: 'Alerta del Sistema',
            message: 'Alerta activa en ${latestData['alert']!.deviceId}',
            severity: IoTAlertSeverity.critical,
            timestamp: latestData['alert']!.timestamp,
            deviceId: latestData['alert']!.deviceId,
            sensorType: 'Sistema BMS',
          ),
        );
      }

      // Verificar voltaje de batería bajo (<22V)
      if (latestData.containsKey('v_bat_conv') &&
          latestData['v_bat_conv']!.value < 22.0) {
        newAlerts.add(
          IoTAlert(
            id: 'LOW_VBAT_${latestData['v_bat_conv']!.deviceId}',
            title: 'Voltaje de Batería Bajo',
            message:
                'Batería: ${latestData['v_bat_conv']!.value.toStringAsFixed(2)}V (Mínimo: 22V)',
            severity: IoTAlertSeverity.warning,
            timestamp: latestData['v_bat_conv']!.timestamp,
            deviceId: latestData['v_bat_conv']!.deviceId,
            sensorType: 'Voltaje',
          ),
        );
      }

      // Verificar SOC bajo (<20%)
      if (latestData.containsKey('soc_percent') &&
          latestData['soc_percent']!.value < 20.0) {
        newAlerts.add(
          IoTAlert(
            id: 'LOW_SOC_${latestData['soc_percent']!.deviceId}',
            title: 'Estado de Carga Crítico',
            message:
                'SOC: ${latestData['soc_percent']!.value.toStringAsFixed(1)}% (Mínimo: 20%)',
            severity: IoTAlertSeverity.critical,
            timestamp: latestData['soc_percent']!.timestamp,
            deviceId: latestData['soc_percent']!.deviceId,
            sensorType: 'Estado de Carga',
          ),
        );
      }

      // Verificar SOH bajo (<70%)
      if (latestData.containsKey('soh_percent') &&
          latestData['soh_percent']!.value < 70.0) {
        newAlerts.add(
          IoTAlert(
            id: 'LOW_SOH_${latestData['soh_percent']!.deviceId}',
            title: 'Salud de Batería Degradada',
            message:
                'SOH: ${latestData['soh_percent']!.value.toStringAsFixed(1)}% (Mínimo: 70%)',
            severity: IoTAlertSeverity.warning,
            timestamp: latestData['soh_percent']!.timestamp,
            deviceId: latestData['soh_percent']!.deviceId,
            sensorType: 'Salud Batería',
          ),
        );
      }

      if (mounted) {
        setState(() {
          _activeAlerts = newAlerts;
        });
      }
    } catch (e) {
      // Manejar errores silenciosamente
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
