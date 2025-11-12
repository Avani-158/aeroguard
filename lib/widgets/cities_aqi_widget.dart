import 'package:flutter/material.dart';
import '../services/openaq_service.dart';
import '../services/waqi_service.dart';

class CitiesAQIWidget extends StatefulWidget {
  const CitiesAQIWidget({super.key});

  @override
  State<CitiesAQIWidget> createState() => _CitiesAQIWidgetState();
}

class _CitiesAQIWidgetState extends State<CitiesAQIWidget> {
  final OpenAQService _service = OpenAQService();
  // Provide your WAQI token here to enable WAQI (more reliable) before OpenAQ
  final WAQIService _waqi = WAQIService(token: '801fd6f45bf52bd8b6895b79600b98dd5097c6fb');

  // Default city list (order preserved)
  final List<String> _cities = [
    'Los Angeles',
    'Beijing',
    'Paris',
    'Singapore',
    'Sydney',
    'Mexico City',
  ];

  // Coordinates for cities (lat, lon)
  // Sources: general known city center coordinates
  final Map<String, List<double>> _cityCoords = const {
    'Los Angeles': [34.0522, -118.2437],
    'Beijing': [39.9042, 116.4074],
    'Paris': [48.8566, 2.3522],
    'Singapore': [1.3521, 103.8198],
    'Sydney': [-33.8688, 151.2093],
    'Mexico City': [19.4326, -99.1332],
  };

  // Country ISO codes for cities (used to disambiguate v3 queries)
  final Map<String, String> _cityCountry = const {
    'Los Angeles': 'US',
    'Beijing': 'CN',
    'Paris': 'FR',
    'Singapore': 'SG',
    'Sydney': 'AU',
    'Mexico City': 'MX',
  };

  // Fallback/mock map
  static const Map<String, int> _mockAQI = {
    'Los Angeles': 72,
    'Beijing': 165,
    'Paris': 40,
    'Singapore': 55,
    'Sydney': 35,
    'Mexico City': 98,
  };

  Map<String, int> _aqis = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAllCities();
  }

  Future<void> _loadAllCities() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final Map<String, int> results = {};

    try {
      for (final city in _cities) {
        try {
          Map<String, double> measurements = {};

          // 0) Try WAQI first if token provided (returns AQI directly)
          if (_waqi.isEnabled) {
            try {
              final aqi = await _waqi.fetchAqiForCity(city);
              results[city] = aqi;
              continue; // move to next city
            } catch (_) {
              // fall through to OpenAQ flows
            }
          }

          // 1) Try coordinates (most reliable) with a wider radius
          final coords = _cityCoords[city];
          if (coords != null) {
            measurements = await _service.fetchLatestForCoordinates(
              latitude: coords[0],
              longitude: coords[1],
              radiusMeters: 30000,
            );
          }

          // 2) If empty, fallback to city query
          if (measurements.isEmpty) {
            final country = _cityCountry[city];
            measurements = await _service.fetchLatestForCity(city, country: country);
          }

          // prefer pm25, fallback to pm10 if pm25 not present
          final double? pm25 = measurements['pm25'];
          final double? pm10 = measurements['pm10'];

          if (pm25 != null) {
            results[city] = _service.pm25ToAqi(pm25);
          } else if (pm10 != null) {
            // Using pm10 with the pm2.5 AQI curve is approximate but gives a coarse indicator
            results[city] = _service.pm25ToAqi(pm10);
          } else {
            results[city] = _mockAQI[city] ?? 0;
          }
        } catch (_) {
          // Per-city error: use mock
          results[city] = _mockAQI[city] ?? 0;
        }
      }
      setState(() {
        _aqis = results;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
        _aqis = Map<String, int>.from(_mockAQI);
      });
    }
  }

  String _getAQICategory(int aqi) {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy';
    if (aqi <= 200) return 'Severe';
    return 'Hazardous';
  }

  Color _getAQIColor(int aqi) {
    if (aqi <= 50) return const Color(0xFF4CAF50);
    if (aqi <= 100) return const Color(0xFF26A69A);
    if (aqi <= 150) return Colors.orange;
    if (aqi <= 200) return Colors.red;
    if (aqi <= 300) return Colors.purple;
    return Colors.deepPurple;
  }

  @override
  Widget build(BuildContext context) {
    final displayMap = _aqis.isNotEmpty ? _aqis : _mockAQI;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.teal,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'AQI in Popular Cities',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadAllCities,
                  tooltip: 'Refresh',
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_loading)
              const Center(child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ))
            else ...[
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _cities.length,
                separatorBuilder: (context, index) => Divider(
                  color: Colors.grey[300],
                  height: 8,
                ),
                itemBuilder: (context, index) {
                  final city = _cities[index];
                  final aqi = displayMap[city] ?? (_mockAQI[city] ?? 0);
                  final color = _getAQIColor(aqi);
                  final category = _getAQICategory(aqi);

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          city,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: color, width: 0.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              aqi.toString(),
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              category,
                              style: TextStyle(
                                color: color,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text('Live data error: $_error', style: TextStyle(color: Colors.red[700], fontSize: 12)),
              ]
            ]
          ],
        ),
      ),
    );
  }
}
