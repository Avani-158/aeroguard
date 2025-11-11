import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _aqiThresholdController = TextEditingController();
  final _smokeThresholdController = TextEditingController();
  final _tempThresholdController = TextEditingController();
  final _fireBrigadeController = TextEditingController();
  final _ownerContactController = TextEditingController();
  final _ownerEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final settings = Provider.of<SettingsProvider>(context, listen: false).settings;
    _aqiThresholdController.text = settings.aqiThreshold.toStringAsFixed(0);
    _smokeThresholdController.text = settings.smokeThreshold.toStringAsFixed(0);
    _tempThresholdController.text = settings.temperatureThreshold.toStringAsFixed(1);
    _fireBrigadeController.text = settings.fireBrigadeContact;
    _ownerContactController.text = settings.ownerContact;
    _ownerEmailController.text = settings.ownerEmail;
  }

  @override
  void dispose() {
    _aqiThresholdController.dispose();
    _smokeThresholdController.dispose();
    _tempThresholdController.dispose();
    _fireBrigadeController.dispose();
    _ownerContactController.dispose();
    _ownerEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Theme Toggle
              Card(
                child: SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Toggle between light and dark theme'),
                  value: settingsProvider.isDarkMode,
                  onChanged: (value) {
                    settingsProvider.toggleDarkMode();
                  },
                  secondary: const Icon(Icons.dark_mode),
                ),
              ),

              const SizedBox(height: 16),

              // Thresholds Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alert Thresholds',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _aqiThresholdController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'AQI Threshold',
                          helperText: 'Alert when AQI exceeds this value',
                          prefixIcon: Icon(Icons.air),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          final threshold = double.tryParse(value);
                          if (threshold != null) {
                            settingsProvider.updateThresholds(
                              aqiThreshold: threshold,
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _smokeThresholdController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Smoke Threshold',
                          helperText: 'Alert when smoke level exceeds this value',
                          prefixIcon: Icon(Icons.smoke_free),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          final threshold = double.tryParse(value);
                          if (threshold != null) {
                            settingsProvider.updateThresholds(
                              smokeThreshold: threshold,
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _tempThresholdController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Temperature Threshold (°C)',
                          helperText: 'Alert when temperature exceeds this value',
                          prefixIcon: Icon(Icons.thermostat),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          final threshold = double.tryParse(value);
                          if (threshold != null) {
                            settingsProvider.updateThresholds(
                              temperatureThreshold: threshold,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Contacts Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Emergency Contacts',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _fireBrigadeController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Fire Brigade Contact',
                          helperText: 'Phone number for fire brigade',
                          prefixIcon: Icon(Icons.local_fire_department),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          settingsProvider.updateContacts(
                            fireBrigadeContact: value,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _ownerContactController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Owner Contact',
                          helperText: 'Your phone number',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          settingsProvider.updateContacts(
                            ownerContact: value,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _ownerEmailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Owner Email',
                          helperText: 'Your email address',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          settingsProvider.updateContacts(
                            ownerEmail: value,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Gamification Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Air Quality Streak',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.local_fire_department,
                              color: Colors.orange, size: 32),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${settingsProvider.settings.dailyStreak} days',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                Text(
                                  'Consecutive days with good air quality',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Share on social media
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Share feature coming soon!'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.share),
                        label: const Text('Share Air Score'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Account Section
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(
                        Provider.of<AuthProvider>(context, listen: false)
                                .user
                                ?.email ??
                            'Not signed in',
                      ),
                      subtitle: const Text('Logged in user'),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text('Sign Out'),
                      onTap: () {
                        Provider.of<AuthProvider>(context, listen: false)
                            .signOut();
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // App Info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Icon(Icons.info_outline, size: 48),
                      const SizedBox(height: 8),
                      Text(
                        'IoT Air Quality Monitor',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Version 1.0.0',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

