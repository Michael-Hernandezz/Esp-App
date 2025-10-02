import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/core.dart';

class AirConditionerControlsCard extends StatelessWidget {
  const AirConditionerControlsCard({required this.room, super.key});

  final SmartRoom room;

  @override
  Widget build(BuildContext context) {
    return SHCard(
      childrenPadding: const EdgeInsets.all(12),
      children: [
        _AirSwitcher(room: room),
        const _AirIcons(),
        Column(
          children: [
            Row(
              children: [
                Container(
                  width: 120,
                  height: 50,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    border: Border.all(width: 10, color: Colors.white38),
                  ),
                ),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Icon(
                          SHIcons.waterDrop,
                          color: Colors.white38,
                          size: 20,
                        ),
                        Text(
                          'Air humidity',
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            color: Colors.white60,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${room.airHumidity.toInt()}%'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _AirIcons extends StatelessWidget {
  const _AirIcons();

  @override
  Widget build(BuildContext context) {
    return const IconTheme(
      data: IconThemeData(size: 30, color: Colors.white38),
      child: Row(
        children: [
          Icon(SHIcons.snowFlake),
          SizedBox(width: 8),
          Icon(SHIcons.wind),
          SizedBox(width: 8),
          Icon(SHIcons.waterDrop),
          SizedBox(width: 8),
          Icon(SHIcons.timer, color: SHColors.selectedColor),
        ],
      ),
    );
  }
}

class _AirSwitcher extends StatelessWidget {
  const _AirSwitcher({required this.room});

  final SmartRoom room;

  @override
  Widget build(BuildContext context) {
    final roomStateNotifier = RoomStateProvider.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Air conditioning'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SHSwitcher(
                icon: const Icon(SHIcons.fan),
                value: room.airCondition.isOn,
                onChanged: (value) {
                  roomStateNotifier?.updateAirConditionState(room.id, value);
                  MessageService.showAirConditionMessage(context, value);
                },
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                _showTemperatureDialog(context, room);
              },
              child: Text(
                '${room.airCondition.value}˚',
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showTemperatureDialog(BuildContext context, SmartRoom room) {
    final roomStateNotifier = RoomStateProvider.of(context);
    int selectedTemp = room.airCondition.value;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Ajustar Temperatura',
          style: TextStyle(color: Colors.white),
        ),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$selectedTemp°C',
                style: const TextStyle(fontSize: 32, color: Colors.white),
              ),
              Slider(
                value: selectedTemp.toDouble(),
                min: 10,
                max: 30,
                divisions: 20,
                onChanged: (value) {
                  setState(() {
                    selectedTemp = value.round();
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              roomStateNotifier?.updateAirConditionTemperature(
                room.id,
                selectedTemp,
              );
              MessageService.showTemperatureMessage(context, selectedTemp);
              Navigator.pop(context);
            },
            child: const Text('Ajustar'),
          ),
        ],
      ),
    );
  }
}
