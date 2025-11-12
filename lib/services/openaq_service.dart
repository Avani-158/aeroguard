import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAQService {
  // Fetch latest measurements for a city using OpenAQ v3
  // Returns a map of parameter -> value (e.g., {'pm25': 12.3}) or throws
  Future<Map<String, double>> fetchLatestForCity(String city) async {
    final uri = Uri.parse('https://api.openaq.org/v3/latest?city=${Uri.encodeComponent(city)}&limit=1');
    final resp = await http.get(uri);

    if (resp.statusCode != 200) {
      throw Exception('OpenAQ request failed: ${resp.statusCode}');
    }

    final data = json.decode(resp.body) as Map<String, dynamic>;
    if (data['results'] == null || (data['results'] as List).isEmpty) {
      throw Exception('No results from OpenAQ for $city');
    }

    final first = (data['results'] as List).first as Map<String, dynamic>;
    final measurements = <String, double>{};

    if (first['measurements'] != null) {
      for (final m in (first['measurements'] as List)) {
        final param = (m['parameter'] as String).toLowerCase();
        final value = (m['value'] as num).toDouble();
        measurements[param] = value;
      }
    }

    return measurements;
  }

  // Convert PM2.5 concentration (μg/m³) to an approximate US EPA AQI (0-500)
  // using standard breakpoints and linear interpolation.
  int pm25ToAqi(double pm25) {
    // Breakpoints
    final breakpoints = [
      {'cLow': 0.0, 'cHigh': 12.0, 'iLow': 0, 'iHigh': 50},
      {'cLow': 12.1, 'cHigh': 35.4, 'iLow': 51, 'iHigh': 100},
      {'cLow': 35.5, 'cHigh': 55.4, 'iLow': 101, 'iHigh': 150},
      {'cLow': 55.5, 'cHigh': 150.4, 'iLow': 151, 'iHigh': 200},
      {'cLow': 150.5, 'cHigh': 250.4, 'iLow': 201, 'iHigh': 300},
      {'cLow': 250.5, 'cHigh': 350.4, 'iLow': 301, 'iHigh': 400},
      {'cLow': 350.5, 'cHigh': 500.4, 'iLow': 401, 'iHigh': 500},
    ];

    for (final bp in breakpoints) {
      final cLow = bp['cLow'] as double;
      final cHigh = bp['cHigh'] as double;
      final iLow = bp['iLow'] as int;
      final iHigh = bp['iHigh'] as int;

      if (pm25 >= cLow && pm25 <= cHigh) {
        final aqi = ((iHigh - iLow) / (cHigh - cLow) * (pm25 - cLow) + iLow).round();
        return aqi.clamp(0, 500);
      }
    }

    return 500; // Extremely high
  }
}
