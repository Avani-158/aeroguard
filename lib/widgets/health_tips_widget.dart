import 'package:flutter/material.dart';

class HealthTipsWidget extends StatefulWidget {
  final int aqi;

  const HealthTipsWidget({super.key, required this.aqi});

  @override
  State<HealthTipsWidget> createState() => _HealthTipsWidgetState();
}

class _HealthTipsWidgetState extends State<HealthTipsWidget> {
  int _currentTipIndex = 0;

  List<Map<String, dynamic>> _getHealthTips(int aqi) {
    if (aqi <= 50) {
      return [
        {
          'icon': Icons.check_circle,
          'color': Colors.green,
          'title': 'Air Quality is Good!',
          'tip': 'Perfect time for outdoor activities. Enjoy fresh air!',
        },
        {
          'icon': Icons.directions_run,
          'color': Colors.blue,
          'title': 'Exercise Outdoors',
          'tip': 'Great conditions for jogging, cycling, or any outdoor exercise.',
        },
        {
          'icon': Icons.window,
          'color': Colors.teal,
          'title': 'Open Windows',
          'tip': 'Ventilate your home to bring in the fresh outdoor air.',
        },
      ];
    } else if (aqi <= 100) {
      return [
        {
          'icon': Icons.warning_amber,
          'color': const Color(0xFF26A69A),
          'title': 'Moderate Air Quality',
          'tip': 'Sensitive individuals should limit prolonged outdoor exertion.',
        },
        {
          'icon': Icons.masks,
          'color': Colors.orange,
          'title': 'Consider a Mask',
          'tip': 'Wear a mask if you have respiratory conditions.',
        },
        {
          'icon': Icons.home,
          'color': Colors.blue,
          'title': 'Stay Indoors',
          'tip': 'Keep windows closed and use air purifiers if available.',
        },
      ];
    } else {
      return [
        {
          'icon': Icons.dangerous,
          'color': Colors.red,
          'title': 'Poor Air Quality',
          'tip': 'Avoid outdoor activities. Stay indoors with filtered air.',
        },
        {
          'icon': Icons.air,
          'color': Colors.purple,
          'title': 'Use Air Purifier',
          'tip': 'Run air purifiers and keep windows closed.',
        },
        {
          'icon': Icons.medical_services,
          'color': Colors.red.shade700,
          'title': 'Health Alert',
          'tip': 'Monitor symptoms and consult healthcare provider if needed.',
        },
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final tips = _getHealthTips(widget.aqi);
    final currentTip = tips[_currentTipIndex];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: currentTip['color'],
          width: 2,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              currentTip['color'].withOpacity(0.1),
              currentTip['color'].withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  currentTip['icon'],
                  size: 32,
                  color: currentTip['color'],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentTip['title'],
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: currentTip['color'],
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentTip['tip'],
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_currentTipIndex + 1} of ${tips.length}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.chevron_left,
                        color: _currentTipIndex > 0 ? currentTip['color'] : Colors.grey,
                      ),
                      onPressed: _currentTipIndex > 0
                          ? () => setState(() => _currentTipIndex--)
                          : null,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.chevron_right,
                        color: _currentTipIndex < tips.length - 1 ? currentTip['color'] : Colors.grey,
                      ),
                      onPressed: _currentTipIndex < tips.length - 1
                          ? () => setState(() => _currentTipIndex++)
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
