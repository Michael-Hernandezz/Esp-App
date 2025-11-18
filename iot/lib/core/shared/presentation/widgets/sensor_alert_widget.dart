import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core.dart';
import '../../domain/entities/sensor_range.dart';

/// Widget glassmorphic para mostrar alertas de sensores
class SensorAlertWidget extends StatelessWidget {
  final SensorAlert alert;
  final bool compact;
  final VoidCallback? onDismiss;

  const SensorAlertWidget({
    super.key,
    required this.alert,
    this.compact = false,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(18),
            child: compact ? _buildCompactContent() : _buildFullContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildFullContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icono de alerta
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.15),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Icon(_getAlertIcon(), color: _getAlertColor(), size: 24),
        ),

        const SizedBox(width: 16),

        // Contenido de la alerta
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Encabezado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.variable,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.95),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _getAlertTitle(),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Timestamp
                  Text(
                    _formatTimestamp(alert.timestamp),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Detalles del valor
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white.withValues(alpha: 0.1),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Valor Actual:',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '${alert.value.toStringAsFixed(2)} ${_getUnit(alert.variable)}',
                      style: TextStyle(
                        color: _getAlertColor().withValues(alpha: 0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Botón de cerrar si se proporciona callback
              if (onDismiss != null) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onDismiss,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    child: Text(
                      'Cerrar',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactContent() {
    return Row(
      children: [
        Icon(_getAlertIcon(), color: _getAlertColor(), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                alert.variable,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.95),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${alert.value.toStringAsFixed(1)} ${_getUnit(alert.variable)}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        if (onDismiss != null)
          IconButton(
            onPressed: onDismiss,
            icon: Icon(
              Icons.close,
              color: Colors.white.withValues(alpha: 0.6),
              size: 18,
            ),
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minHeight: 24, minWidth: 24),
          ),
      ],
    );
  }

  IconData _getAlertIcon() {
    switch (alert.alertType) {
      case AlertType.critical:
        return Icons.error;
      case AlertType.abnormal:
        return Icons.warning;
      case AlertType.below:
        return Icons.info;
      case AlertType.normal:
        return Icons.check_circle;
    }
  }

  String _getAlertTitle() {
    switch (alert.alertType) {
      case AlertType.critical:
        return 'Alerta Crítica';
      case AlertType.abnormal:
        return 'Valor Anormal';
      case AlertType.below:
        return 'Valor Bajo';
      case AlertType.normal:
        return 'Normal';
    }
  }

  Color _getAlertColor() {
    switch (alert.alertType) {
      case AlertType.critical:
        return SHColors.chartError;
      case AlertType.abnormal:
        return SHColors.chartWarning;
      case AlertType.below:
        return SHColors.chartPrimary;
      case AlertType.normal:
        return Colors.green;
    }
  }

  String _getUnit(String variable) {
    final range = SensorRangeConfig.ranges[variable];
    return range?.unit ?? '';
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }
}

/// Widget banner flotante para alertas urgentes
class FloatingAlertBanner extends StatelessWidget {
  final SensorAlert alert;
  final VoidCallback? onDismiss;
  final Duration? duration;

  const FloatingAlertBanner({
    super.key,
    required this.alert,
    this.onDismiss,
    this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                SHColors.chartError.withValues(alpha: 0.9),
                SHColors.chartError.withValues(alpha: 0.8),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    child: Icon(Icons.warning, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'ALERTA CRÍTICA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          alert.variable,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.95),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${alert.value.toStringAsFixed(2)} ${SensorRangeConfig.ranges[alert.variable]?.unit ?? ''}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onDismiss != null)
                    IconButton(
                      onPressed: onDismiss,
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minHeight: 32,
                        minWidth: 32,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
