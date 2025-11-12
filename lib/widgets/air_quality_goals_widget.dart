import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class AirQualityGoalsWidget extends StatefulWidget {
  final double currentAQI;

  const AirQualityGoalsWidget({super.key, required this.currentAQI});

  @override
  State<AirQualityGoalsWidget> createState() => _AirQualityGoalsWidgetState();
}

class _AirQualityGoalsWidgetState extends State<AirQualityGoalsWidget> {
  late TextEditingController _goalController;
  int? _targetAQI;

  @override
  void initState() {
    super.initState();
    _goalController = TextEditingController();
    // Load saved goal from settings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGoal();
    });
  }

  void _loadGoal() {
    final settings = Provider.of<SettingsProvider>(context, listen: false).settings;
    setState(() {
      _targetAQI = settings.targetAQI ?? 50; // Default target: 50
    });
  }

  void _setGoal() {
    final value = int.tryParse(_goalController.text);
    if (value != null && value > 0 && value <= 500) {
      setState(() {
        _targetAQI = value;
      });
      Provider.of<SettingsProvider>(context, listen: false)
          .updateTargetAQI(value);
      _goalController.clear();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Goal set to $value AQI')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid AQI value (1-500)')),
      );
    }
  }

  void _showGoalDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Air Quality Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your target AQI value:'),
            const SizedBox(height: 16),
            TextField(
              controller: _goalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'e.g., 50',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixText: 'AQI',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Lower is better. Recommended: 0-50 (Good)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _setGoal,
            child: const Text('Set Goal'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_targetAQI == null) {
      return const SizedBox.shrink();
    }

    final progress = ((_targetAQI! - widget.currentAQI) / _targetAQI! * 100)
        .clamp(0.0, 100.0);
    final isGoalMet = widget.currentAQI <= _targetAQI!;
    final goalColor = isGoalMet ? Colors.green : Colors.orange;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: goalColor,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Air Quality Goal',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _showGoalDialog,
                  tooltip: 'Edit goal',
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Goal Status
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: goalColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: goalColor, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isGoalMet ? '✓ Goal Met!' : 'Not Yet',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: goalColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Current: ${widget.currentAQI.toStringAsFixed(0)} AQI',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  Text(
                    'Target: $_targetAQI',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: goalColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress to Goal',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${progress.toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: goalColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    minHeight: 8,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(goalColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Tips
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isGoalMet
                          ? 'Keep windows closed to maintain good air quality!'
                          : 'Use air purifier to improve air quality.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.blue[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
