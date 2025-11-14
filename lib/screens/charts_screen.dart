import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/device_provider.dart';
import '../models/device_data.dart';
import '../widgets/chart_widget.dart';

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key});

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  int _selectedHours = 24;
  late Future<List<DeviceData>> _historicalDataFuture;

  @override
  void initState() {
    super.initState();
    _historicalDataFuture = Future.value([]); // Initialize with empty list
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  void _initializeData() {
    if (!mounted) return;
    try {
      final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);
      setState(() {
        _historicalDataFuture =
            deviceProvider.getHistoricalData(hours: _selectedHours);
      });
    } catch (e) {
      print('Error initializing chart data: $e');
    }
  }

  void _loadHistoricalData() {
    setState(() {
      final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);
      _historicalDataFuture =
          deviceProvider.getHistoricalData(hours: _selectedHours);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DeviceProvider>(
      builder: (context, deviceProvider, _) {
        return FutureBuilder<List<DeviceData>>(
          future: _historicalDataFuture,
          builder: (context, snapshot) {
            List<DeviceData> historicalData = [];
            bool isMockMode = deviceProvider.firebaseService.isMockMode;

            if (snapshot.hasData) {
              historicalData = snapshot.data!;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ---------------- Time Range Selector ----------------
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Time Range',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ChoiceChip(
                                  label: const Text('6 Hours'),
                                  selected: _selectedHours == 6,
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _selectedHours = 6;
                                        _loadHistoricalData();
                                      });
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ChoiceChip(
                                  label: const Text('24 Hours'),
                                  selected: _selectedHours == 24,
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _selectedHours = 24;
                                        _loadHistoricalData();
                                      });
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ChoiceChip(
                                  label: const Text('7 Days'),
                                  selected: _selectedHours == 168,
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _selectedHours = 168;
                                        _loadHistoricalData();
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _loadHistoricalData,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Refresh Data'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ---------------- Chart Display Logic ----------------
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (historicalData.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Center(
                          child: Text(
                            isMockMode
                                ? 'Showing mock data (no Firebase connection)'
                                : 'No historical data available yet — your AQI samples will appear here once you start monitoring.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    )
                  else ...[
                    ChartWidget(
                      data: historicalData,
                      title: 'Air Quality Index (AQI)',
                      valueGetter: (data) => data.aqi,
                      unit: '',
                      color: Colors.purple,
                    ),
                    const SizedBox(height: 16),
                    ChartWidget(
                      data: historicalData,
                      title: 'Temperature',
                      valueGetter: (data) => data.temperature,
                      unit: '°C',
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    ChartWidget(
                      data: historicalData,
                      title: 'Humidity',
                      valueGetter: (data) => data.humidity,
                      unit: '%',
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    ChartWidget(
                      data: historicalData,
                      title: 'Noise Level',
                      valueGetter: (data) => data.noise,
                      unit: 'dB',
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    ChartWidget(
                      data: historicalData,
                      title: 'PM2.5',
                      valueGetter: (data) => data.pm2_5,
                      unit: 'μg/m³',
                      color: Colors.indigo,
                    ),
                    const SizedBox(height: 16),
                    ChartWidget(
                      data: historicalData,
                      title: 'PM10',
                      valueGetter: (data) => data.pm10,
                      unit: 'μg/m³',
                      color: Colors.teal,
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}
