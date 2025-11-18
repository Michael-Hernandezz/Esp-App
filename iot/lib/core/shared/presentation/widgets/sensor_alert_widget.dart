import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:iot/core/shared/domain/entities/sensor_range.dart';

/// Widget que muestra una notificación de alerta roja para rangos anormales
class SensorAlertWidget extends StatelessWidget {
  const SensorAlertWidget({
    super.key,
    required this.alert,
    this.onDismiss,
    this.compact = false,
  });

  final SensorAlert alert;
  final VoidCallback? onDismiss;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
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
                colors: _getGlassmorphismColors(),
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: compact ? _buildCompactContent() : _buildFullContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFullContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icono de alerta con efecto glassmorphism
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
<<<<<<< Updated upstream
<<<<<<< Updated upstream
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
=======
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
>>>>>>> Stashed changes
=======
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
>>>>>>> Stashed changes
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
<<<<<<< Updated upstream
<<<<<<< Updated upstream
          child: Icon(
            _getAlertIcon(),
            color: Colors.white,
            size: 24,
          ),
=======
          child: Icon(_getAlertIcon(), color: Colors.white, size: 24),
>>>>>>> Stashed changes
=======
          child: Icon(_getAlertIcon(), color: Colors.white, size: 24),
>>>>>>> Stashed changes
        ),
        const SizedBox(width: 12),
        // Contenido de la alerta
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título principal
              Text(
                _getAlertTitle(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              // Información del sensor
              Text(
                alert.message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              // Información de tiempo con contenedor glassmorphism
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      color: Colors.white.withOpacity(0.8),
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatTime(alert.timestamp),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Botón de cerrar con estilo glassmorphism
        if (onDismiss != null)
          Container(
            margin: const EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: onDismiss,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.white.withOpacity(0.9),
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCompactContent() {
    return Row(
      children: [
<<<<<<< Updated upstream
<<<<<<< Updated upstream
        Icon(
          _getAlertIcon(),
          color: Colors.white,
          size: 20,
        ),
=======
        Icon(_getAlertIcon(), color: Colors.white, size: 20),
>>>>>>> Stashed changes
=======
        Icon(_getAlertIcon(), color: Colors.white, size: 20),
>>>>>>> Stashed changes
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            _getAlertTitle(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ),
        if (onDismiss != null)
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: onDismiss,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    Icons.close,
                    color: Colors.white.withOpacity(0.8),
                    size: 16,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  List<Color> _getGlassmorphismColors() {
    switch (alert.alertType) {
      case AlertType.critical:
        return [
          const Color(0xFFE57373).withOpacity(0.3),
          const Color(0xFFF44336).withOpacity(0.2),
        ];
      case AlertType.abnormal:
        return [
          const Color(0xFFFFB74D).withOpacity(0.3),
          const Color(0xFFFF9800).withOpacity(0.2),
        ];
      case AlertType.below:
        return [
          const Color(0xFFFFF176).withOpacity(0.3),
          const Color(0xFFFFEB3B).withOpacity(0.2),
        ];
      case AlertType.normal:
        return [
          const Color(0xFF81C784).withOpacity(0.3),
          const Color(0xFF4CAF50).withOpacity(0.2),
        ];
    }
  }

  IconData _getAlertIcon() {
    switch (alert.alertType) {
      case AlertType.critical:
        return Icons.dangerous_rounded;
      case AlertType.abnormal:
        return Icons.warning_rounded;
      case AlertType.below:
<<<<<<< Updated upstream
<<<<<<< Updated upstream
        return Icons.trending_down_rounded; // Icono de flecha hacia abajo para valores bajos
=======
        return Icons
            .trending_down_rounded; // Icono de flecha hacia abajo para valores bajos
>>>>>>> Stashed changes
=======
        return Icons
            .trending_down_rounded; // Icono de flecha hacia abajo para valores bajos
>>>>>>> Stashed changes
      case AlertType.normal:
        return Icons.check_circle_rounded;
    }
  }

  String _getAlertTitle() {
    switch (alert.alertType) {
      case AlertType.critical:
        return 'RANGO CRÍTICO';
      case AlertType.abnormal:
        return 'RANGO ANORMAL';
      case AlertType.below:
        return 'VALOR BAJO'; // Título específico para valores bajos
      case AlertType.normal:
        return 'VALOR NORMAL';
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inHours < 1) {
      return 'hace ${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return 'hace ${difference.inHours}h';
    } else {
      return 'hace ${difference.inDays}d';
    }
  }
}

/// Widget que muestra una lista de alertas activas
class AlertListWidget extends StatelessWidget {
  const AlertListWidget({
    super.key,
    required this.alerts,
    this.onDismissAlert,
    this.onDismissAll,
    this.maxItems = 5,
  });

  final List<SensorAlert> alerts;
  final Function(SensorAlert)? onDismissAlert;
  final VoidCallback? onDismissAll;
  final int maxItems;

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return const SizedBox.shrink();
    }

    final displayAlerts = alerts.take(maxItems).toList();

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabecera con estilo glassmorphism
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.notifications_active,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Alertas Activas (${alerts.length})',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (onDismissAll != null && alerts.isNotEmpty)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: onDismissAll,
                              child: const Padding(
<<<<<<< Updated upstream
<<<<<<< Updated upstream
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
=======
=======
>>>>>>> Stashed changes
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
                                child: Text(
                                  'Limpiar Todo',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Lista de alertas
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
<<<<<<< Updated upstream
<<<<<<< Updated upstream
                    children: displayAlerts.map((alert) => SensorAlertWidget(
                          alert: alert,
                          onDismiss: onDismissAlert != null 
                              ? () => onDismissAlert!(alert) 
                              : null,
                        )).toList(),
=======
=======
>>>>>>> Stashed changes
                    children: displayAlerts
                        .map(
                          (alert) => SensorAlertWidget(
                            alert: alert,
                            onDismiss: onDismissAlert != null
                                ? () => onDismissAlert!(alert)
                                : null,
                          ),
                        )
                        .toList(),
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
                  ),
                ),
                // Indicador de más alertas si hay más
                if (alerts.length > maxItems)
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Container(
<<<<<<< Updated upstream
<<<<<<< Updated upstream
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
=======
=======
>>>>>>> Stashed changes
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '... y ${alerts.length - maxItems} alertas más',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
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
    );
  }
}

/// Widget flotante que muestra alertas críticas
class FloatingAlertBanner extends StatelessWidget {
  const FloatingAlertBanner({
    super.key,
    required this.alert,
    this.onTap,
    this.onDismiss,
  });

  final SensorAlert alert;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFE57373).withOpacity(0.4),
                      const Color(0xFFF44336).withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.warning_amber,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'RANGO ANORMAL',
                            style: TextStyle(
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
                    if (onDismiss != null)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(6),
                            onTap: onDismiss,
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
    );
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
