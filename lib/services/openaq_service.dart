import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAQService {
  // Fetch latest measurements for a city using OpenAQ v3 measurements endpoint.
  // Returns a map of parameter -> value (e.g., {'pm25': 12.3}) or throws.
  Future<Map<String, double>> fetchLatestForCity(String city, {String? country}) async {
    // Prefer pm25; fallback to pm10
    final baseQuery = <String, String>{'city': city, if (country != null) 'country': country};
    final pm25 = await _fetchLatestMeasurement(parameter: 'pm25', query: baseQuery);
    final pm10 = pm25 == null ? await _fetchLatestMeasurement(parameter: 'pm10', query: baseQuery) : null;

    final measurements = <String, double>{};
    if (pm25 != null) measurements['pm25'] = pm25;
    if (pm10 != null) measurements['pm10'] = pm10;
    if (measurements.isEmpty) {
      throw Exception('No measurements from OpenAQ v3 for $city');
    }
    return measurements;
  }

  // Fetch latest measurements using coordinates (lat,lon) with a search radius (meters) via v3
  // Returns a map of parameter -> value (e.g., {'pm25': 12.3}) or throws.
  Future<Map<String, double>> fetchLatestForCoordinates({
    required double latitude,
    required double longitude,
    int radiusMeters = 15000,
  }) async {
    final coords = '${latitude.toStringAsFixed(4)},${longitude.toStringAsFixed(4)}';

    final pm25 = await _fetchLatestMeasurement(parameter: 'pm25', query: {
      'coordinates': coords,
      'radius': '$radiusMeters',
    });
    final pm10 = pm25 == null
        ? await _fetchLatestMeasurement(parameter: 'pm10', query: {
            'coordinates': coords,
            'radius': '$radiusMeters',
          })
        : null;

    final measurements = <String, double>{};
    if (pm25 != null) measurements['pm25'] = pm25;
    if (pm10 != null) measurements['pm10'] = pm10;
    if (measurements.isEmpty) {
      throw Exception('No measurements from OpenAQ v3 for coordinates ($coords)');
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

  // Internal helper: fetch the most recent single measurement value for a parameter
  Future<double?> _fetchLatestMeasurement({
    required String parameter,
    required Map<String, String> query,
  }) async {
    final qp = {
      ...query,
      'parameter': parameter,
      'limit': '1',
      'page': '1',
      'sort': 'desc',
      'order_by': 'datetime',
    };
    final uri = Uri.https('api.openaq.org', '/v3/measurements', qp);

    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      return null;
    }
    final decoded = json.decode(resp.body);
    if (decoded is! Map<String, dynamic>) return null;
    final results = decoded['results'];
    if (results is! List || results.isEmpty) return null;
    final first = results.first;
    if (first is! Map<String, dynamic>) return null;
    final value = first['value'];
    if (value is num) return value.toDouble();
    return null;
  }
}
