import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/storage_repository.dart';
import '../models/user_model.dart';

class StorageService implements StorageRepository {
  static const String _userDataKey = 'user_data';
  static const String _tokenKey = 'influxdb_token';

  final FlutterSecureStorage _secureStorage;

  const StorageService(this._secureStorage);

  @override
  Future<void> saveUserData(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userModel = UserModel.fromEntity(user);
      final jsonString = jsonEncode(userModel.toJson());
      await prefs.setString(_userDataKey, jsonString);
    } catch (e) {
      throw Exception('Error al guardar datos del usuario: $e');
    }
  }

  @override
  Future<User?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_userDataKey);

      if (jsonString == null) return null;

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final userModel = UserModel.fromJson(json);
      return userModel.toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveSecureToken(String token) async {
    try {
      await _secureStorage.write(key: _tokenKey, value: token);
    } catch (e) {
      throw Exception('Error al guardar token: $e');
    }
  }

  @override
  Future<String?> getSecureToken() async {
    try {
      return await _secureStorage.read(key: _tokenKey);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userDataKey);
      await _secureStorage.delete(key: _tokenKey);
    } catch (e) {
      throw Exception('Error al limpiar datos: $e');
    }
  }

  @override
  Future<bool> hasUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_userDataKey);
    } catch (e) {
      return false;
    }
  }
}
