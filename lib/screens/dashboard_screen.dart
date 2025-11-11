import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/device_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/aqi_indicator.dart';
import '../widgets/sensor_card.dart';
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
        title: const Text('IoT Air Quality Monitor'),
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

                // AQI Indicator
                AQIIndicator(deviceData: deviceData),

                const SizedBox(height: 16),

                // Daily Streak
                Consumer<SettingsProvider>(
                  builder: (context, settingsProvider, _) {
                    return Card(
                      color: Colors.blue.withValues(alpha: 0.1),
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

