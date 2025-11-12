import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/device_provider.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.green,
          width: 2,
        ),
      ),
      child: Container( 
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade50, Colors.green.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
            ),
            const SizedBox(height: 16),
            Consumer<DeviceProvider>(
              builder: (context, deviceProvider, _) {
                final deviceData = deviceProvider.deviceData;

                return GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.2,
                  children: [
                    _QuickActionButton(
                      icon: Icons.refresh,
                      label: 'Refresh Data',
                      color: Colors.blue,
                      onTap: () {
                        // Refresh logic would go here
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Refreshing data...')),
                        );
                      },
                    ),
                    _QuickActionButton(
                      icon: deviceData?.sprinkler == 'on' ? Icons.water_drop : Icons.water_drop_outlined,
                      label: deviceData?.sprinkler == 'on' ? 'Sprinkler ON' : 'Sprinkler OFF',
                      color: deviceData?.sprinkler == 'on' ? Colors.blue : Colors.grey,
                      onTap: () {
                        deviceProvider.toggleSprinkler();
                      },
                    ),
                    _QuickActionButton(
                      icon: deviceData?.buzzer == 'on' ? Icons.volume_up : Icons.volume_off,
                      label: deviceData?.buzzer == 'on' ? 'Buzzer ON' : 'Buzzer OFF',
                      color: deviceData?.buzzer == 'on' ? Colors.orange : Colors.grey,
                      onTap: () {
                        deviceProvider.toggleBuzzer();
                      },
                    ),
                    _QuickActionButton(
                      icon: Icons.history,
                      label: 'View History',
                      color: Colors.purple,
                      onTap: () {
                        // Navigate to history screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('History feature coming soon!')),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: color,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
