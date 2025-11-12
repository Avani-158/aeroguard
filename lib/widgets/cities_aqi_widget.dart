import 'package:flutter/material.dart';
import '../services/openaq_service.dart';

class CitiesAQIWidget extends StatefulWidget {
  const CitiesAQIWidget({super.key});

  @override
  State<CitiesAQIWidget> createState() => _CitiesAQIWidgetState();
}

class _CitiesAQIWidgetState extends State<CitiesAQIWidget> {
  final OpenAQService _service = OpenAQService();

  // Default city list (order preserved)
  final List<String> _cities = [
    'Delhi',
    'Mumbai',
    'Bangalore',
    'New York',
    'London',
    'Tokyo',
  ];

  // Fallback/mock map
  static const Map<String, int> _mockAQI = {
    'Delhi': 156,
    'Mumbai': 82,
    'Bangalore': 65,
    'New York': 45,
    'London': 38,
    'Tokyo': 52,
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
          final measurements = await _service.fetchLatestForCity(city);
          // prefer pm25, fallback to pm10 if pm25 not present
          double? pm25 = measurements['pm25'];
          if (pm25 != null) {
            results[city] = _service.pm25ToAqi(pm25);
          } else if (measurements['pm10'] != null) {
            // Approximate AQI using pm10 -> pm2.5 ratio fallback is not ideal;
            // here we simply use pm10 directly with pm25ToAqi (coarse).
            results[city] = _service.pm25ToAqi(measurements['pm10']!);
          } else {
            // No data, fallback to mock
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
