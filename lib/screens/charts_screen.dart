import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/device_provider.dart';
import '../widgets/chart_widget.dart';
import '../models/device_data.dart';

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key});

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  int _selectedHours = 24;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<DeviceProvider>(
      builder: (context, deviceProvider, _) {
        return FutureBuilder<List<DeviceData>>(
          future: _isLoading
              ? deviceProvider.getHistoricalData(hours: _selectedHours)
              : null,
          builder: (context, snapshot) {
            List<DeviceData> historicalData = [];
            if (snapshot.hasData) {
              historicalData = snapshot.data!;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Time Range Selector
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Time Range',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
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
                                        _isLoading = true;
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
                                        _isLoading = true;
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
                                        _isLoading = true;
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
                              onPressed: () {
                                setState(() {
                                  _isLoading = true;
                                });
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Load Data'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Charts
                  if (_isLoading && !snapshot.hasData)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (historicalData.isEmpty && snapshot.hasData)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Center(
                          child: Text(
                            'No historical data available',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey,
                                ),
                          ),
                        ),
                      ),
                    )
                  else if (historicalData.isNotEmpty) ...[
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
                  ] else
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.show_chart,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Select time range and load data',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

