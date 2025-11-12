import 'dart:convert';
import 'package:http/http.dart' as http;

class WAQIService {
  // Set your token here (get one from https://aqicn.org/data-platform/token/#/)
  // Leave empty to disable WAQI usage.
  final String token;

  WAQIService({required this.token});

  bool get isEnabled => token.isNotEmpty;

  // Fetch AQI for a city; returns AQI index or throws
  Future<int> fetchAqiForCity(String city) async {
    final uri = Uri.parse('https://api.waqi.info/feed/${Uri.encodeComponent(city)}/?token=$token');
    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('WAQI request failed: ${resp.statusCode}');
    }
    final decoded = json.decode(resp.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid WAQI response');
    }
    if (decoded['status'] != 'ok') {
      throw Exception('WAQI status: ${decoded['status']}');
    }
    final data = decoded['data'];
    if (data is Map<String, dynamic>) {
      final aqi = data['aqi'];
      if (aqi is num) return aqi.toInt();
    }
    throw Exception('WAQI data missing AQI');
  }
}

