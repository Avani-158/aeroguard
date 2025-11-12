import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/device_provider.dart';
import '../widgets/control_button.dart';

class ControlPanelScreen extends StatelessWidget {
  const ControlPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DeviceProvider>(
      builder: (context, deviceProvider, _) {
        final deviceData = deviceProvider.deviceData;

        if (deviceData == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                'Manual Control Panel',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Override device controls manually',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 24),

              // Control Buttons Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  ControlButton(
                    icon: Icons.water_drop,
                    label: 'Water Sprinkler',
                    isActive: deviceData.sprinkler == 'on',
                    onTap: () {
                      deviceProvider.toggleSprinkler();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            deviceData.sprinkler == 'on'
                                ? 'Turning sprinkler OFF...'
                                : 'Turning sprinkler ON...',
                          ),
                        ),
                      );
                    },
                    activeColor: Colors.blue,
                  ),
                  ControlButton(
                    icon: Icons.alarm,
                    label: 'Buzzer Alarm',
                    isActive: deviceData.buzzer == 'on',
                    onTap: () {
                      deviceProvider.toggleBuzzer();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            deviceData.buzzer == 'on'
                                ? 'Turning buzzer OFF...'
                                : 'Turning buzzer ON...',
                          ),
                        ),
                      );
                    },
                    activeColor: Colors.red,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Fire Alarm Acknowledge
              if (deviceData.fire || deviceData.smoke)
                Card(
                    color: Colors.red.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.warning, color: Colors.red, size: 32),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Fire Alarm Active',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Acknowledge to reset the alarm',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              deviceProvider.acknowledgeFireAlarm();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Fire alarm acknowledged'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            icon: const Icon(Icons.check_circle),
                            label: const Text('Acknowledge Alarm'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Status Info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Status',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      _StatusRow(
                        label: 'Device Status',
                        value: deviceData.online ? 'Online' : 'Offline',
                        isGood: deviceData.online,
                      ),
                      const Divider(),
                      _StatusRow(
                        label: 'Sprinkler',
                        value: deviceData.sprinkler.toUpperCase(),
                        isGood: deviceData.sprinkler == 'off',
                      ),
                      const Divider(),
                      _StatusRow(
                        label: 'Buzzer',
                        value: deviceData.buzzer.toUpperCase(),
                        isGood: deviceData.buzzer == 'off',
                      ),
                      const Divider(),
                      _StatusRow(
                        label: 'Fire Detection',
                        value: deviceData.fire ? 'DETECTED' : 'Safe',
                        isGood: !deviceData.fire,
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

class _StatusRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isGood;

  const _StatusRow({
    required this.label,
    required this.value,
    required this.isGood,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Row(
          children: [
            Icon(
              isGood ? Icons.check_circle : Icons.error,
              color: isGood ? Colors.green : Colors.red,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isGood ? Colors.green : Colors.red,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}

