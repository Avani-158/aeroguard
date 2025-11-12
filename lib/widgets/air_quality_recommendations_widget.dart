import 'package:flutter/material.dart';
import '../models/device_data.dart';

class AirQualityRecommendationsWidget extends StatelessWidget {
  final DeviceData? deviceData;

  const AirQualityRecommendationsWidget({super.key, this.deviceData});

  List<Map<String, dynamic>> _generateRecommendations() {
    if (deviceData == null) return [];

    final aqi = deviceData!.aqi;
    final humidity = deviceData!.humidity;
    final temperature = deviceData!.temperature;
    final pm2_5 = deviceData!.pm2_5;
    final pm10 = deviceData!.pm10;

    final List<Map<String, dynamic>> recommendations = [];

    // AQI-based recommendations
    if (aqi <= 50) {
      recommendations.add({
        'icon': Icons.thumb_up,
        'title': 'Great Air Quality',
        'description': 'Air quality is excellent. Enjoy outdoor activities!',
        'color': Colors.green,
        'priority': 1,
      });
    } else if (aqi <= 100) {
      recommendations.add({
        'icon': Icons.info,
        'title': 'Moderate Air Quality',
        'description': 'Air quality is acceptable. Consider light ventilation.',
        'color': const Color(0xFF26A69A),
        'priority': 2,
      });
    } else if (aqi <= 150) {
      recommendations.add({
        'icon': Icons.warning,
        'title': 'Turn On Air Purifier',
        'description': 'AQI is unhealthy. Activate your air purifier now.',
        'color': Colors.orange,
        'priority': 1,
      });
    } else if (aqi <= 200) {
      recommendations.add({
        'icon': Icons.warning_amber,
        'title': 'Severe Air Quality',
        'description': 'AQI is very unhealthy. Use air purifier + close windows.',
        'color': Colors.deepOrange,
        'priority': 1,
      });
    } else {
      recommendations.add({
        'icon': Icons.error,
        'title': 'Hazardous Air Quality',
        'description': 'AQI is hazardous. Stay indoors with air purifier on.',
        'color': Colors.red,
        'priority': 1,
      });
    }

    // Window opening recommendations based on outdoor vs indoor (assume outdoor is better)
    if (aqi > 100 && aqi <= 150) {
      recommendations.add({
        'icon': Icons.open_in_browser,
        'title': 'Keep Windows Closed',
        'description': 'Current indoor AQI is better. Keep windows closed.',
        'color': Colors.orange,
        'priority': 2,
      });
    }

    // Humidity recommendations
    if (humidity < 30) {
      recommendations.add({
        'icon': Icons.water_drop,
        'title': 'Increase Humidity',
        'description': 'Humidity is too low (${humidity.toStringAsFixed(1)}%). Use humidifier.',
        'color': Colors.blue,
        'priority': 3,
      });
    } else if (humidity > 60) {
      recommendations.add({
        'icon': Icons.cloud_queue,
        'title': 'Reduce Humidity',
        'description': 'Humidity is high (${humidity.toStringAsFixed(1)}%). Improve ventilation.',
        'color': Colors.lightBlue,
        'priority': 3,
      });
    }

    // Temperature recommendations
    if (temperature < 18) {
      recommendations.add({
        'icon': Icons.thermostat,
        'title': 'Room Too Cold',
        'description': 'Temperature is ${temperature.toStringAsFixed(1)}°C. Consider heating.',
        'color': Colors.blue,
        'priority': 3,
      });
    } else if (temperature > 28) {
      recommendations.add({
        'icon': Icons.thermostat,
        'title': 'Room Too Hot',
        'description': 'Temperature is ${temperature.toStringAsFixed(1)}°C. Improve cooling.',
        'color': Colors.red,
        'priority': 3,
      });
    }

    // PM2.5 specific recommendations
    if (pm2_5 > 35) {
      recommendations.add({
          'icon': Icons.cloud,
        'title': 'High PM2.5 Levels',
        'description': 'PM2.5 is ${pm2_5.toStringAsFixed(1)} μg/m³. Use air purifier.',
        'color': Colors.orange,
        'priority': 2,
      });
    }

    // Sort by priority (lower number = higher priority)
    recommendations.sort((a, b) => a['priority'].compareTo(b['priority']));

    return recommendations;
  }

  @override
  Widget build(BuildContext context) {
    final recommendations = _generateRecommendations();

    if (recommendations.isEmpty || deviceData == null) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.lightGreen,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  color: Colors.amber,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Recommendations',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recommendations.length,
              itemBuilder: (context, index) {
                final rec = recommendations[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (rec['color'] as Color).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: rec['color'] as Color,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        rec['icon'] as IconData,
                        color: rec['color'] as Color,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rec['title'] as String,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: rec['color'] as Color,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              rec['description'] as String,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[700],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
