import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:iot/core/shared/data/services/sensor_alert_service.dart';
import 'package:iot/core/shared/domain/entities/sensor_range.dart';
import 'package:iot/core/theme/sh_colors.dart';

/// Widget para probar y simular alertas del sistema de monitoreo
class AlertTestWidget extends StatefulWidget {
  const AlertTestWidget({super.key});

  @override
  State<AlertTestWidget> createState() => _AlertTestWidgetState();
}

class _AlertTestWidgetState extends State<AlertTestWidget> {
  late SensorAlertService _alertService;

  @override
  void initState() {
    super.initState();
    _alertService = SensorAlertService();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SHColors.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Simulador de Alertas',
            style: TextStyle(
              color: SHColors.textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Presiona los botones para simular valores fuera de rango:',
            style: TextStyle(color: SHColors.textColor),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTestButton(
                'Voltaje Bajo',
<<<<<<< Updated upstream
<<<<<<< Updated upstream
                () => _simulateAlert('v_conv_in', 7.5, 'Voltaje convertidor entrada'),
=======
=======
>>>>>>> Stashed changes
                () => _simulateAlert(
                  'v_conv_in',
                  7.5,
                  'Voltaje convertidor entrada',
                ),
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
                Colors.orange,
              ),
              _buildTestButton(
                'Voltaje Alto',
<<<<<<< Updated upstream
<<<<<<< Updated upstream
                () => _simulateAlert('v_conv_in', 13.0, 'Voltaje convertidor entrada'),
=======
=======
>>>>>>> Stashed changes
                () => _simulateAlert(
                  'v_conv_in',
                  13.0,
                  'Voltaje convertidor entrada',
                ),
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
                Colors.red,
              ),
              _buildTestButton(
                'Celda Baja',
                () => _simulateAlert('v_cell_1', 3.2, 'Voltaje celda 1'),
                Colors.orange,
              ),
              _buildTestButton(
                'Batería Baja',
<<<<<<< Updated upstream
<<<<<<< Updated upstream
                () => _simulateAlert('soc_percent', 60.0, 'Salud de la batería'),
=======
                () =>
                    _simulateAlert('soc_percent', 60.0, 'Salud de la batería'),
>>>>>>> Stashed changes
=======
                () =>
                    _simulateAlert('soc_percent', 60.0, 'Salud de la batería'),
>>>>>>> Stashed changes
                Colors.red,
              ),
              _buildTestButton(
                'Corriente Alta',
<<<<<<< Updated upstream
<<<<<<< Updated upstream
                () => _simulateAlert('i_circuit', 4.5, 'Corriente de las celdas'),
=======
                () =>
                    _simulateAlert('i_circuit', 4.5, 'Corriente de las celdas'),
>>>>>>> Stashed changes
=======
                () =>
                    _simulateAlert('i_circuit', 4.5, 'Corriente de las celdas'),
>>>>>>> Stashed changes
                Colors.red,
              ),
              _buildTestButton(
                'Limpiar Alertas',
                () => _alertService.dismissAllAlerts(),
                Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                _alertService.isMonitoring ? Icons.sensors : Icons.sensors_off,
                color: _alertService.isMonitoring ? Colors.green : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Monitoreo: ${_alertService.isMonitoring ? 'ACTIVO' : 'INACTIVO'}',
                style: TextStyle(
<<<<<<< Updated upstream
<<<<<<< Updated upstream
                  color: _alertService.isMonitoring ? Colors.green : Colors.grey,
=======
                  color: _alertService.isMonitoring
                      ? Colors.green
                      : Colors.grey,
>>>>>>> Stashed changes
=======
                  color: _alertService.isMonitoring
                      ? Colors.green
                      : Colors.grey,
>>>>>>> Stashed changes
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  if (_alertService.isMonitoring) {
                    _alertService.stopMonitoring();
                  } else {
                    _alertService.startMonitoring();
                  }
                  setState(() {});
                },
                child: Text(
                  _alertService.isMonitoring ? 'Detener' : 'Iniciar',
                  style: const TextStyle(color: SHColors.textColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTestButton(String label, VoidCallback onPressed, Color color) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
<<<<<<< Updated upstream
<<<<<<< Updated upstream
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
=======
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
>>>>>>> Stashed changes
=======
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
>>>>>>> Stashed changes
      ),
      child: Text(label),
    );
  }

  void _simulateAlert(String variable, double value, String variableName) {
    // Crear una alerta simulada
    final range = SensorRangeConfig.getRangeFor(variable);
    if (range != null) {
      final alertType = range.getAlertType(value);
      final alert = SensorAlert(
        variable: variable,
        value: value,
        alertType: alertType,
        message: range.getAlertMessage(value),
        timestamp: DateTime.now(),
      );

      // Agregar la alerta usando el método público
      _alertService.addTestAlert(alert);

      // Mostrar notificación personalizada con estilo glassmorphism
      _showGlassmorphismNotification(context, alert);
    }
  }

  void _showGlassmorphismNotification(BuildContext context, SensorAlert alert) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).viewPadding.top + 60,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 500),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, -50 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: _getNotificationGradient(alert.alertType),
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    _getNotificationIcon(alert.alertType),
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
<<<<<<< Updated upstream
<<<<<<< Updated upstream
                                    crossAxisAlignment: CrossAxisAlignment.start,
=======
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
>>>>>>> Stashed changes
=======
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
>>>>>>> Stashed changes
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${_getNotificationTitle(alert.alertType)} SIMULADA',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        alert.message,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(6),
                                      onTap: () => overlayEntry.remove(),
                                      child: const Padding(
                                        padding: EdgeInsets.all(6),
                                        child: Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Auto-remover después de 4 segundos
    Future.delayed(const Duration(seconds: 4), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  List<Color> _getNotificationGradient(AlertType alertType) {
    switch (alertType) {
      case AlertType.critical:
        return [
          const Color(0xFFE57373).withOpacity(0.4),
          const Color(0xFFF44336).withOpacity(0.3),
        ];
      case AlertType.abnormal:
        return [
          const Color(0xFFFFB74D).withOpacity(0.4),
          const Color(0xFFFF9800).withOpacity(0.3),
        ];
      case AlertType.below:
        return [
          const Color(0xFFFFF176).withOpacity(0.4),
          const Color(0xFFFFEB3B).withOpacity(0.3),
        ];
      case AlertType.normal:
        return [
          const Color(0xFF81C784).withOpacity(0.4),
          const Color(0xFF4CAF50).withOpacity(0.3),
        ];
    }
  }

  IconData _getNotificationIcon(AlertType alertType) {
    switch (alertType) {
      case AlertType.critical:
        return Icons.dangerous_rounded;
      case AlertType.abnormal:
        return Icons.warning_rounded;
      case AlertType.below:
        return Icons.trending_down_rounded;
      case AlertType.normal:
        return Icons.check_circle_rounded;
    }
  }

  String _getNotificationTitle(AlertType alertType) {
    switch (alertType) {
      case AlertType.critical:
        return 'ALERTA CRÍTICA';
      case AlertType.abnormal:
        return 'ALERTA ANORMAL';
      case AlertType.below:
        return 'VALOR BAJO';
      case AlertType.normal:
        return 'VALOR NORMAL';
    }
  }
<<<<<<< Updated upstream
<<<<<<< Updated upstream
}
=======
}
>>>>>>> Stashed changes
=======
}
>>>>>>> Stashed changes
