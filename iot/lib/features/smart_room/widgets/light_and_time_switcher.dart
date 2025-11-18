import 'package:flutter/material.dart';

import 'package:iot/core/shared/domain/entities/smart_room.dart';
import 'package:iot/core/theme/sh_icons.dart';
import 'package:iot/core/shared/presentation/providers/room_state_provider.dart';
import 'package:iot/core/shared/presentation/services/message_service.dart';
import 'package:iot/core/shared/presentation/widgets/sh_card.dart';
import 'package:iot/core/shared/presentation/widgets/sh_switcher.dart';
import 'package:iot/core/shared/presentation/widgets/blue_dot_light.dart';

class LightsAndTimerSwitchers extends StatelessWidget {
  const LightsAndTimerSwitchers({required this.room, super.key});

  final SmartRoom room;

  @override
  Widget build(BuildContext context) {
    final roomStateNotifier = RoomStateProvider.of(context);

    return SHCard(
      childrenPadding: const EdgeInsets.all(12),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Lights'),
            const SizedBox(height: 8),
            SHSwitcher(
              value: room.lights.isOn,
              onChanged: (value) {
                roomStateNotifier?.updateLightsState(room.id, value);
                MessageService.showLightMessage(context, value);
              },
              icon: const Icon(SHIcons.lightBulbOutline),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(children: [Text('Timer'), Spacer(), BlueLightDot()]),
            const SizedBox(height: 8),
            SHSwitcher(
              icon: room.timer.isOn
                  ? const Icon(SHIcons.timer)
                  : const Icon(SHIcons.timerOff),
              value: room.timer.isOn,
              onChanged: (value) {
                roomStateNotifier?.updateTimerState(room.id, value);
                MessageService.showTimerMessage(context, value);
              },
            ),
          ],
        ),
      ],
    );
  }
}
