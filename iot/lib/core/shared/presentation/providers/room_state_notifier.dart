import 'package:flutter/foundation.dart';
import 'package:iot/core/shared/domain/entities/smart_room.dart';
import 'package:iot/core/shared/domain/entities/smart_device.dart';
import 'package:iot/core/shared/domain/entities/music_info.dart';
import 'package:iot/core/shared/data/services/iot_data_service.dart';

class RoomStateNotifier extends ValueNotifier<List<SmartRoom>> {
  RoomStateNotifier() : super([]) {
    _loadRealData();
  }

  /// Carga datos reales de InfluxDB
  Future<void> _loadRealData() async {
    try {
      final realData = await IoTDataService.getRealIoTData();
      value = realData;
      print('Datos IoT cargados: ${realData.length} habitaciones');
    } catch (e) {
      print('Error cargando datos IoT, usando datos de respaldo: $e');
      value = SmartRoom.fakeValues;
    }
  }

  /// Refresca los datos desde InfluxDB
  Future<void> refreshData() async {
    await _loadRealData();
  }

  void updateMusicState(String roomId, bool isOn) {
    final updatedRooms = value.map((room) {
      if (room.id == roomId) {
        return room.copyWith(
          musicInfo: MusicInfo(
            isOn: isOn,
            currentSong: room.musicInfo.currentSong,
          ),
        );
      }
      return room;
    }).toList();
    value = updatedRooms;
  }

  void updateLightsState(String roomId, bool isOn) {
    final updatedRooms = value.map((room) {
      if (room.id == roomId) {
        return room.copyWith(
          lights: SmartDevice(isOn: isOn, value: room.lights.value),
        );
      }
      return room;
    }).toList();
    value = updatedRooms;
  }

  void updateTimerState(String roomId, bool isOn) {
    final updatedRooms = value.map((room) {
      if (room.id == roomId) {
        return room.copyWith(
          timer: SmartDevice(isOn: isOn, value: room.timer.value),
        );
      }
      return room;
    }).toList();
    value = updatedRooms;
  }

  void updateAirConditionState(String roomId, bool isOn) {
    final updatedRooms = value.map((room) {
      if (room.id == roomId) {
        return room.copyWith(
          airCondition: SmartDevice(isOn: isOn, value: room.airCondition.value),
        );
      }
      return room;
    }).toList();
    value = updatedRooms;
  }

  void updateLightIntensity(String roomId, int intensity) {
    final updatedRooms = value.map((room) {
      if (room.id == roomId) {
        return room.copyWith(
          lights: SmartDevice(isOn: room.lights.isOn, value: intensity),
        );
      }
      return room;
    }).toList();
    value = updatedRooms;
  }

  void updateAirConditionTemperature(String roomId, int temperature) {
    final updatedRooms = value.map((room) {
      if (room.id == roomId) {
        return room.copyWith(
          airCondition: SmartDevice(
            isOn: room.airCondition.isOn,
            value: temperature,
          ),
        );
      }
      return room;
    }).toList();
    value = updatedRooms;
  }

  SmartRoom getRoomById(String roomId) {
    return value.firstWhere((room) => room.id == roomId);
  }
}
