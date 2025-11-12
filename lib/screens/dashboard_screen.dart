import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/device_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/aqi_indicator.dart';
import '../widgets/sensor_card.dart';
import '../widgets/weather_widget.dart';
import '../widgets/health_tips_widget.dart';
import '../widgets/quick_actions_widget.dart';
import '../widgets/cities_aqi_widget.dart';
import '../widgets/air_quality_recommendations_widget.dart';
import '../widgets/air_quality_goals_widget.dart';
import 'control_panel_screen.dart';
import 'charts_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/logo.png',
              height: 45,
            ),
            const SizedBox(width: 0),
            const Text(
              'Aerosense',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Consumer<DeviceProvider>(
            builder: (context, deviceProvider, _) {
              final isOnline = deviceProvider.deviceData?.online ?? false;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 12,
                      color: isOnline ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isOnline ? 'Online' : 'Offline',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).signOut();
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          _DashboardContent(),
          ControlPanelScreen(),
          ChartsScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_remote),
            label: 'Control',
          ),
          NavigationDestination(
            icon: Icon(Icons.show_chart),
            label: 'Charts',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<DeviceProvider>(
      builder: (context, deviceProvider, _) {
        final deviceData = deviceProvider.deviceData;
        final settings = Provider.of<SettingsProvider>(context);
        final userSettings = settings.settings;

        final List<_ThresholdAlert> thresholdAlerts = [];
        if (deviceData != null) {
          if (deviceData.aqi > userSettings.aqiThreshold) {
            thresholdAlerts.add(
              _ThresholdAlert(
                title: 'AQI Alert',
                message:
                    'Current AQI ${deviceData.aqi.toStringAsFixed(0)} exceeds your threshold of ${userSettings.aqiThreshold.toStringAsFixed(0)}.',
                color: Colors.red,
                icon: Icons.air,
              ),
            );
          }

          if (deviceData.pm2_5 > userSettings.smokeThreshold) {
            thresholdAlerts.add(
              _ThresholdAlert(
                title: 'Particle Alert',
                message:
                    'PM2.5 level ${deviceData.pm2_5.toStringAsFixed(1)} µg/m³ exceeds your smoke threshold of ${userSettings.smokeThreshold.toStringAsFixed(1)} µg/m³.',
                color: Colors.deepOrange,
                icon: Icons.smoke_free,
              ),
            );
          }

          if (deviceData.temperature > userSettings.temperatureThreshold) {
            thresholdAlerts.add(
              _ThresholdAlert(
                title: 'Temperature Alert',
                message:
                    'Temperature ${deviceData.temperature.toStringAsFixed(1)}°C exceeds your threshold of ${userSettings.temperatureThreshold.toStringAsFixed(1)}°C.',
                color: Colors.orange,
                icon: Icons.thermostat,
              ),
            );
          }
        }

        // Update daily streak if needed
        if (deviceData != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Provider.of<SettingsProvider>(context, listen: false)
                .updateDailyStreak(deviceData.aqi.toInt());
          });
        }

        return RefreshIndicator(
          onRefresh: () async {
            // Refresh data
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Fire/Smoke Alert Banner
                if (deviceData != null && (deviceData.fire || deviceData.smoke))
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.white, size: 32),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'FIRE/SMOKE DETECTED!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                deviceData.fire
                                    ? 'Fire detected! Take immediate action.'
                                    : 'Smoke detected! Check the area.',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            deviceProvider.acknowledgeFireAlarm();
                          },
                        ),
                      ],
                    ),
                  ),

                if (thresholdAlerts.isNotEmpty)
                  _ThresholdAlertCard(alerts: thresholdAlerts),

                // AQI Indicator and Cities AQI Side by Side
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AQIIndicator(deviceData: deviceData),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: const CitiesAQIWidget(),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Weather Widget
                if (deviceData != null)
                  WeatherWidget(
                    temperature: deviceData.temperature,
                    humidity: deviceData.humidity,
                    weatherCondition: deviceData.temperature > 25 ? 'Sunny' :
                                    deviceData.temperature > 20 ? 'Cloudy' : 'Cool',
                  ),

                const SizedBox(height: 16),

                // Health Tips
                if (deviceData != null)
                  HealthTipsWidget(aqi: deviceData.aqi.toInt()),

                const SizedBox(height: 16),

                // Air Quality Goals & Recommendations
                if (deviceData != null)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 700;
                      if (isNarrow) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AirQualityGoalsWidget(currentAQI: deviceData.aqi),
                            const SizedBox(height: 16),
                            AirQualityRecommendationsWidget(
                              deviceData: deviceData,
                            ),
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AirQualityGoalsWidget(currentAQI: deviceData.aqi),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AirQualityRecommendationsWidget(
                              deviceData: deviceData,
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                const SizedBox(height: 16),

                // Daily Streak
                Consumer<SettingsProvider>(
                  builder: (context, settingsProvider, _) {
                    return Card(
                      color: Colors.blue.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Colors.blue,
                          width: 2,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const Icon(Icons.local_fire_department,
                                color: Colors.orange, size: 32),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Daily Streak',
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                  Text(
                                    '${settingsProvider.settings.dailyStreak} days',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Quick Actions (moved below Daily Streak)
                const QuickActionsWidget(),

                const SizedBox(height: 16),

                // Sensor Cards Grid
                if (deviceData != null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: SensorCard(
                          icon: Icons.thermostat,
                          label: 'Temperature',
                          value: deviceData.temperature.toStringAsFixed(1),
                          unit: '°C',
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SensorCard(
                          icon: Icons.water_drop,
                          label: 'Humidity',
                          value: deviceData.humidity.toStringAsFixed(1),
                          unit: '%',
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: SensorCard(
                          icon: Icons.volume_up,
                          label: 'Noise',
                          value: deviceData.noise.toStringAsFixed(0),
                          unit: 'dB',
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SensorCard(
                          icon: Icons.cloud,
                          label: 'PM2.5',
                          value: deviceData.pm2_5.toStringAsFixed(1),
                          unit: 'μg/m³',
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: SensorCard(
                          icon: Icons.cloud_queue,
                          label: 'PM10',
                          value: deviceData.pm10.toStringAsFixed(1),
                          unit: 'μg/m³',
                          color: Colors.indigo,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SensorCard(
                          icon: deviceData.fire || deviceData.smoke
                              ? Icons.warning
                              : Icons.check_circle,
                          label: 'Fire Status',
                          value: deviceData.fire || deviceData.smoke
                              ? 'Danger'
                              : 'Safe',
                          unit: '',
                          color: deviceData.fire || deviceData.smoke
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ] else
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ThresholdAlert {
  final String title;
  final String message;
  final Color color;
  final IconData icon;

  const _ThresholdAlert({
    required this.title,
    required this.message,
    required this.color,
    required this.icon,
  });
}

class _ThresholdAlertCard extends StatelessWidget {
  final List<_ThresholdAlert> alerts;

  const _ThresholdAlertCard({required this.alerts});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.red.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber, color: Colors.red, size: 28),
                const SizedBox(width: 8),
                Text(
                  'Threshold Alerts',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...alerts.map(
              (alert) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: alert.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: alert.color.withOpacity(0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(alert.icon, color: alert.color),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alert.title,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: alert.color,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            alert.message,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.black87,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

