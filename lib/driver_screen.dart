import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';

class DriverScreen extends StatefulWidget {
  const DriverScreen({super.key});

  @override
  State<DriverScreen> createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> {
  bool isSharingLocation = false;
  bool isAutoMode = true;
  double? latitude;
  double? longitude;
  double currentSpeed = 0.0;
  String statusMessage = 'Auto mode ON - Waiting for movement...';
  String autoStatus = '🟡 Bus is STOPPED';

  final DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref('bus/location');

  StreamSubscription<Position>? _positionStream;
  Timer? _stopTimer;
  bool _stopTimerActive = false;

  // Mandya Bus Stand coordinates (Geofence)
  final double busStandLat = 12.5218;
  final double busStandLng = 76.8950;
  final double geofenceRadius = 500;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  Future<void> _startListening() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          statusMessage = 'Location permission denied!';
        });
        return;
      }
    }

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 50,
      ),
    ).listen((Position position) {
      double speedKmph = (position.speed * 3.6);

      // Check active hours (7AM to 9PM)
      final now = DateTime.now();
      final hour = now.hour;
      bool isActiveTime = hour >= 7 && hour < 21;

      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
        currentSpeed = speedKmph;
      });

      if (!isActiveTime) {
        setState(() {
          statusMessage = 'Inactive time. Active 7AM - 9PM only!';
          autoStatus = '⏰ Outside active hours';
        });
        return;
      }

      // Check geofence
      double distanceFromBusStand = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        busStandLat,
        busStandLng,
      );
      bool nearBusStand = distanceFromBusStand <= geofenceRadius;

      if (isAutoMode) {
        _handleAutoMode(position, speedKmph, nearBusStand);
      }
    });
  }

  void _handleAutoMode(
      Position position, double speedKmph, bool nearBusStand) {
    if (speedKmph > 5) {
      _stopTimer?.cancel();
      _stopTimerActive = false;

      if (!isSharingLocation) {
        setState(() {
          isSharingLocation = true;
          autoStatus = '🟢 Bus is MOVING';
          statusMessage = 'Auto detected movement! Sharing location...';
        });
      }

      _dbRef.set({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'speed': speedKmph,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      setState(() {
        autoStatus = '🟢 Bus is MOVING';
      });
    } else {
      setState(() {
        autoStatus = nearBusStand
            ? '📍 Near bus stand - Ready!'
            : '🔴 Bus is STOPPED';
      });

      if (isSharingLocation && !_stopTimerActive) {
        _stopTimerActive = true;
        setState(() {
          statusMessage = 'Bus stopped. Will stop sharing in 10 minutes...';
        });

        _stopTimer = Timer(const Duration(minutes: 10), () {
          _dbRef.remove();
          setState(() {
            isSharingLocation = false;
            _stopTimerActive = false;
            statusMessage = 'Auto mode ON - Waiting for movement...';
            autoStatus = '🟡 Bus is STOPPED';
          });
        });
      }
    }
  }

  void _toggleManualSharing() async {
    if (!isSharingLocation) {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      await _dbRef.set({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'speed': 0,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      setState(() {
        isSharingLocation = true;
        statusMessage = 'Manually sharing location...';
      });
    } else {
      await _dbRef.remove();
      setState(() {
        isSharingLocation = false;
        statusMessage = 'Location sharing stopped.';
      });
    }
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _stopTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Panel - ಚಾಲಕ'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          Row(
            children: [
              const Text('Auto', style: TextStyle(color: Colors.white)),
              Switch(
                value: isAutoMode,
                onChanged: (val) {
                  setState(() {
                    isAutoMode = val;
                    statusMessage = val
                        ? 'Auto mode ON - Waiting for movement...'
                        : 'Manual mode - Press START to share';
                  });
                },
                activeThumbColor: Colors.white,
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Auto mode badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isAutoMode ? Colors.blue.shade50 : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isAutoMode ? Colors.blue : Colors.orange,
                ),
              ),
              child: Text(
                isAutoMode ? '🤖 AUTO MODE' : '👆 MANUAL MODE',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isAutoMode ? Colors.blue : Colors.orange,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Status icon
            Icon(
              isSharingLocation ? Icons.location_on : Icons.location_off,
              size: 80,
              color: isSharingLocation ? Colors.green : Colors.grey,
            ),
            const SizedBox(height: 10),

            // Auto status
            Text(
              autoStatus,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              statusMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Speed indicator
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.speed, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    'Speed: ${currentSpeed.toStringAsFixed(1)} km/h',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Location info
            if (latitude != null && longitude != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green),
                ),
                child: Column(
                  children: [
                    const Text(
                      '📍 Current Location',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Lat: ${latitude!.toStringAsFixed(6)}'),
                    Text('Lng: ${longitude!.toStringAsFixed(6)}'),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Manual button
            if (!isAutoMode)
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _toggleManualSharing,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isSharingLocation ? Colors.red : Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isSharingLocation ? '🛑 STOP Sharing' : '🚀 START Sharing',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}