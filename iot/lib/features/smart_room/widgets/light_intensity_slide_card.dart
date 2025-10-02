import 'package:flutter/material.dart';

import '../../../core/core.dart';

class LightIntensitySliderCard extends StatelessWidget {
  const LightIntensitySliderCard({required this.room, super.key});

  final SmartRoom room;

  @override
  Widget build(BuildContext context) {
    final roomStateNotifier = RoomStateProvider.of(context);

    return SHCard(
      childrenPadding: const EdgeInsets.all(12),
      children: [
        _LightSwitcher(room: room),
        Row(
          children: [
            const Icon(SHIcons.lightMin),
            Expanded(
              child: Slider(
                value: room.lights.value / 100.0,
                onChanged: (value) {
                  final intensity = (value * 100).round();
                  roomStateNotifier?.updateLightIntensity(room.id, intensity);
                  MessageService.showIntensityMessage(context, intensity);
                },
              ),
            ),
            const Icon(SHIcons.lightMax),
          ],
        ),
      ],
    );
  }
}

class _LightSwitcher extends StatelessWidget {
  const _LightSwitcher({required this.room});

  final SmartRoom room;

  @override
  Widget build(BuildContext context) {
    final roomStateNotifier = RoomStateProvider.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text('Light intensity'),
          ),
        ),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${room.lights.value}%',
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        SHSwitcher(
          value: room.lights.isOn,
          onChanged: (value) {
            roomStateNotifier?.updateLightsState(room.id, value);
            MessageService.showLightMessage(context, value);
          },
        ),
      ],
    );
  }
}
