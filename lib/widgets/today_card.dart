import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class TodayCard extends StatefulWidget {
  const TodayCard({super.key});

  @override
  State<TodayCard> createState() => _TodayCardState();
}

class _TodayCardState extends State<TodayCard> {
  final String todayDate =
      DateFormat('EEE, dd MMM yyyy').format(DateTime.now());

  String locationText = "Fetching location...";
  double? temperature;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  // 🌡️ WEATHER API
  Future<void> fetchWeather(double lat, double lon) async {
    const apiKey = "2d76d0c16b0c4f2cf6b933137a74c288";

    final url =
        "https://api.openweathermap.org/data/2.5/weather"
        "?lat=$lat&lon=$lon&units=metric&appid=$apiKey";

    try {
      final response = await http.get(Uri.parse(url));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          temperature = data['main']['temp'].roundToDouble();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  // 📍 LOCATION (GPS)
  Future<void> getLocation() async {
    try {
      bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() => locationText = "Location disabled");
        return;
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() => locationText = "Permission denied");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await fetchWeather(position.latitude, position.longitude);

      List<Placemark> placemarks =
          await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      final place = placemarks.first;

      setState(() {
        locationText =
            "${place.locality}, ${place.administrativeArea}";
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        locationText = "Location unavailable";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        color: const Color(0xFF3F6EEB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: -120,
            right: 14,
            child: Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF5B8FF9),
              ),
            ),
          ),
          Positioned(
            top: -150,
            left: 13,
            child: Container(
              width: 220,
              height: 220,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF5B8FF9),
              ),
            ),
          ),
          const Positioned(
            top: 10,
            left: 20,
            child: Text(
              'Today',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ),
          Positioned(
            top: 45,
            left: 20,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLoading || temperature == null
                      ? "..."
                      : temperature!.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 0.9,
                  ),
                ),
                const Text(
                  "°C",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Text(
              locationText,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: Text(
              todayDate,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
