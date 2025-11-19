import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  double? latitude;
  double? longitude;
  double? temperature;
  double? humidity;
  double? windSpeed;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Função para pegar a localização atual
  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      return; // Não tem permissão para acessar localização
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
    });

    // Agora que temos a localização, podemos buscar as informações do clima
    _fetchWeatherData();
  }

  // Função para buscar dados de clima na API OpenWeatherMap
  Future<void> _fetchWeatherData() async {
    if (latitude == null || longitude == null) return;

    final String apiKey =
        'SUA_CHAVE_DE_API_AQUI'; // Substitua com sua chave da API
    final String url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric&lang=pt_br';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          temperature = data['main']['temp'];
          humidity = data['main']['humidity'];
          windSpeed = data['wind']['speed'];
        });
      } else {
        throw Exception('Falha ao carregar dados do clima');
      }
    } catch (e) {
      print('Erro: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Clima Atual')),
        body: Center(
          child: latitude == null || longitude == null
              ? const CircularProgressIndicator() // Carregando enquanto pega a localização
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('Busca Local'),
                    const SizedBox(height: 10),
                    Text('Latitude: $latitude'),
                    Text('Longitude: $longitude'),
                    const SizedBox(height: 20),
                    if (temperature != null)
                      Text('Temperatura: ${temperature?.toStringAsFixed(1)}°C'),
                    if (humidity != null)
                      Text('Umidade: ${humidity?.toString()}%'),
                    if (windSpeed != null)
                      Text(
                          'Velocidade do Vento: ${windSpeed?.toStringAsFixed(1)} m/s'),
                  ],
                ),
        ),
      ),
    );
  }
}
