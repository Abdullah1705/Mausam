import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MausamApp());

class MausamApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mausam',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => WeatherHomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[300],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud, size: 100, color: Colors.white),
            SizedBox(height: 20),
            Text('Mausam', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            Text('Made by ABD'),
            SizedBox(height: 30),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  @override
  _WeatherHomePageState createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  final TextEditingController _controller = TextEditingController();
  Map<String, dynamic>? weatherData;
  String city = "Lahore";
  final String apiKey = "YOUR_API_KEY_HERE"; // Get from openweathermap.org

  Future<void> fetchWeather(String cityName) async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      setState(() {
        weatherData = json.decode(response.body);
        city = cityName;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('City not found'),
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWeather(city);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[300],
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(14),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                onSubmitted: (value) {
                  if (value.isNotEmpty) fetchWeather(value);
                },
                decoration: InputDecoration(
                  hintText: "Search any city",
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                ),
              ),
              SizedBox(height: 20),
              weatherData == null
                  ? CircularProgressIndicator()
                  : Expanded(
                      child: Column(
                        children: [
                          weatherBox(
                            icon: Icons.cloud,
                            label: weatherData!['weather'][0]['description'],
                            sublabel: "In $city",
                          ),
                          SizedBox(height: 10),
                          weatherBox(
                            icon: Icons.thermostat,
                            label: "${weatherData!['main']['temp']} °C",
                            sublabel: "Temperature",
                            largeFont: true,
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: weatherBox(
                                  icon: Icons.air,
                                  label: "${weatherData!['wind']['speed']} km/hr",
                                  sublabel: "Wind Speed",
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: weatherBox(
                                  icon: Icons.water_drop,
                                  label: "${weatherData!['main']['humidity']}%",
                                  sublabel: "Humidity",
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          Text("Made by Abd\nData provided by OpenWeatherMap.org",
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget weatherBox({
    required IconData icon,
    required String label,
    required String sublabel,
    bool largeFont = false,
  }) {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, size: 30),
          SizedBox(height: 8),
          Text(sublabel, style: TextStyle(fontSize: 16)),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: largeFont ? 36 : 20,
              fontWeight: largeFont ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
