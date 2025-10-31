import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class InfluxValidationService {
  /// Valida un token de InfluxDB intentando hacer una consulta simple
  static Future<bool> validateToken(String token, String organization) async {
    try {
      final baseUrl = dotenv.env['INFLUXDB_URL'] ?? 'http://10.0.2.2:8086';

      // Query simple para validar el token
      const query = '''
from(bucket: "telemetry")
  |> range(start: -1m)
  |> limit(n: 1)
''';

      final response = await http.post(
        Uri.parse('$baseUrl/api/v2/query?org=$organization'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
          'Accept': 'application/csv',
        },
        body: jsonEncode({'query': query}),
      );

      print('Validación InfluxDB - Status: ${response.statusCode}');

      // Token valido si la respuesta es 200 (incluso si no hay datos)
      return response.statusCode == 200;
    } catch (e) {
      print('Error validando token: $e');

      // MODO DEMO: Si no puede conectar a InfluxDB, permitir login con credenciales específicas
      if (token ==
              'm9dZ53tgCda7obiBCJn4xFVloD8q9zbqckGPvMzlPxJ3Jwb2ur6gGp-sgWD-KjHH5tvJIqgCSvpuVKeOHj66rw==' &&
          organization == 'microgrid') {
        print(
          'MODO DEMO: Permitiendo login offline con credenciales conocidas',
        );
        return true;
      }

      // Tambien permitir modo demo con credenciales simples
      if (token == 'demo123' && organization == 'microgrid') {
        print(
          'MODO DEMO: Permitiendo login offline con credenciales de demo',
        );
        return true;
      }

      return false;
    }
  }

  /// Obtiene información básica de la organizacion
  static Future<Map<String, String>?> getOrganizationInfo(
    String token,
    String organization,
  ) async {
    try {
      final baseUrl = dotenv.env['INFLUXDB_URL'] ?? 'http://10.0.2.2:8086';

      final response = await http.get(
        Uri.parse('$baseUrl/api/v2/orgs?org=$organization'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final orgs = data['orgs'] as List?;

        if (orgs != null && orgs.isNotEmpty) {
          final org = orgs.first;
          return {
            'id': org['id'] as String,
            'name': org['name'] as String,
            'description': org['description'] as String? ?? '',
          };
        }
      }

      return null;
    } catch (e) {
      print('Error obteniendo info de organización: $e');
      return null;
    }
  }

  /// Lista los buckets disponibles para validar acceso
  static Future<List<String>> getBuckets(
    String token,
    String organization,
  ) async {
    try {
      final baseUrl = dotenv.env['INFLUXDB_URL'] ?? 'http://10.0.2.2:8086';

      final response = await http.get(
        Uri.parse('$baseUrl/api/v2/buckets?org=$organization'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final buckets = data['buckets'] as List?;

        if (buckets != null) {
          return buckets.map((bucket) => bucket['name'] as String).toList();
        }
      }

      return [];
    } catch (e) {
      print('Error obteniendo buckets: $e');
      return [];
    }
  }
}
