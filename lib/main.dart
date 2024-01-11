import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/weather': (context) => WeatherScreen(),
        '/settings': (context) => SettingsPage(),
        '/hourlyForecast': (context) => HourlyForecastPage(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/weather');
          },
          child: const Text('Check Weather'),
        ),
      ),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late TextEditingController _controller;
  late Map<String, dynamic> weatherData;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    weatherData = {};
  }

  Future<void> fetchWeatherData(String city) async {
    final apiKey =
        'b061df5a57fc9c5c4a3fa48ce8b9429c'; // Replace with your API key
    final apiUrl =
        'http://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey';

    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      setState(() {
        weatherData = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Enter City'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                fetchWeatherData(_controller.text);
              },
              child: const Text('Get Weather'),
            ),
            if (weatherData.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                'Temperature: ${(weatherData['main']['temp'] - 273.15).toStringAsFixed(2)}°C',
                style: const TextStyle(fontSize: 20),
              ),
              Text(
                'Description: ${weatherData['weather'][0]['description']}',
                style: const TextStyle(fontSize: 20),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/hourlyForecast');
                },
                child: const Text('Get Hourly Forecast'),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class HourlyForecastPage extends StatefulWidget {
  const HourlyForecastPage({Key? key}) : super(key: key);

  @override
  _HourlyForecastPageState createState() => _HourlyForecastPageState();
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Go Back'),
        ),
      ),
    );
  }
}

class _HourlyForecastPageState extends State<HourlyForecastPage> {
  late Map<String, dynamic> hourlyForecast;

  @override
  void initState() {
    super.initState();
    hourlyForecast = {};
  }

  Future<void> fetchHourlyForecast(String city) async {
    final apiKey =
        'b061df5a57fc9c5c4a3fa48ce8b9429c'; // Replace with your API key
    final apiUrl =
        'http://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey';

    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      setState(() {
        hourlyForecast = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load hourly forecast');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hourly Forecast'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              onSubmitted: (value) {
                fetchHourlyForecast(value);
              },
              decoration: const InputDecoration(labelText: 'Enter City'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                fetchHourlyForecast('London');
              },
              child: const Text('Get Hourly Forecast'),
            ),
            if (hourlyForecast.isNotEmpty) ...[
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: hourlyForecast['list'].length,
                  itemBuilder: (context, index) {
                    final forecast = hourlyForecast['list'][index];
                    final dateTime = DateTime.fromMillisecondsSinceEpoch(
                        forecast['dt'] * 1000);
                    final temperature =
                        (forecast['main']['temp'] - 273.15).toStringAsFixed(2);

                    return ListTile(
                      title: Text(
                        'Time: ${dateTime.hour}:${dateTime.minute} | Temperature: $temperature°C',
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
