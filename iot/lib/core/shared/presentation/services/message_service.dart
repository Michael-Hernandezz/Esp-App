import 'package:flutter/material.dart';

class MessageService {
  static void showDeviceMessage(
    BuildContext context,
    String deviceName,
    bool isOn,
  ) {
    final message = isOn ? '$deviceName iniciado' : '$deviceName pausado';

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isOn ? Icons.check_circle : Icons.pause_circle,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              message,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ],
        ),
        backgroundColor: isOn ? Colors.green.shade600 : Colors.orange.shade600,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static void showLightMessage(BuildContext context, bool isOn) {
    showDeviceMessage(context, 'Luces', isOn);
  }

  static void showMusicMessage(BuildContext context, bool isOn) {
    showDeviceMessage(context, 'Música', isOn);
  }

  static void showTimerMessage(BuildContext context, bool isOn) {
    showDeviceMessage(context, 'Timer', isOn);
  }

  static void showAirConditionMessage(BuildContext context, bool isOn) {
    showDeviceMessage(context, 'Aire acondicionado', isOn);
  }

  static void showIntensityMessage(BuildContext context, int intensity) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.lightbulb, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'Intensidad de luz ajustada a $intensity%',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ],
        ),
        backgroundColor: Colors.blue.shade600,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static void showTemperatureMessage(BuildContext context, int temperature) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.thermostat, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'Temperatura ajustada a $temperature°C',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ],
        ),
        backgroundColor: Colors.indigo.shade600,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
