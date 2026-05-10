import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'notification_service.dart';
import 'bus_stops.dart';

class PassengerScreen extends StatefulWidget {
  final BusStop fromStop;
  final BusStop toStop;

  const PassengerScreen({
    super.key,
    required this.fromStop,
    required this.toStop,
  });

  @override
  State<PassengerScreen> createState() => _PassengerScreenState();
}

class _PassengerScreenState extends State<PassengerScreen> {
  double? busLat;
  double? busLng;
  double busSpeed = 0.0;
  String statusMessage = 'Waiting for bus location...';
  bool busOnline = false;
  String etaText = 'Calculating...';
  String lastAnnouncedArea = '';
  final MapController _mapController = MapController();
  final FlutterTts _flutterTts = FlutterTts();
  final DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref('bus/location');

  @override
  void initState() {
    super.initState();
    _setupTts();
    _listenToBusLocation();
  }

  Future<void> _setupTts() async {
    await _flutterTts.setLanguage('en-IN');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  void _listenToBusLocation() {
    _dbRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(
            event.snapshot.value as Map);

        double lat = double.parse(data['latitude'].toString());
        double lng = double.parse(data['longitude'].toString());
        double speed = data['speed'] != null
            ? double.parse(data['speed'].toString())
            : 0.0;

        // Calculate distance to destination
        double distanceToDestination = Geolocator.distanceBetween(
          lat,
          lng,
          widget.toStop.latitude,
          widget.toStop.longitude,
        );

        // Calculate distance to from stop
        double distanceFromStop = Geolocator.distanceBetween(
          lat,
          lng,
          widget.fromStop.latitude,
          widget.fromStop.longitude,
        );

        // Send notification when bus is within 1km
        if (distanceFromStop < 1000) {
          NotificationService.showBusNearbyNotification(
            'ನಿಮ್ಮ ಬಸ್ ಹತ್ತಿರ ಬರುತ್ತಿದೆ! Bus is ${(distanceFromStop / 1000).toStringAsFixed(1)} km away!'
          );
        }

        // Calculate ETA
        double etaMinutes = 0;
        if (speed > 0) {
          etaMinutes = (distanceToDestination / 1000) / (speed / 60);
        }

        String newEtaText = '';
        if (speed > 0 && etaMinutes > 0) {
          newEtaText =
              'Arrives at ${widget.toStop.nameKannada} in ${etaMinutes.toStringAsFixed(0)} mins ⏱️';
        } else if (distanceFromStop < 500) {
          newEtaText = '🚌 Bus is near your stop!';
        } else {
          newEtaText =
              'Bus is ${(distanceToDestination / 1000).toStringAsFixed(1)} km away';
        }

        setState(() {
          busLat = lat;
          busLng = lng;
          busSpeed = speed;
          busOnline = true;
          statusMessage = 'Bus is Live! 🟢';
          etaText = newEtaText;
        });

        try {
          _mapController.move(LatLng(lat, lng), 15.0);
        } catch (e) {
          // ignore
        }

        _announceLocation(newEtaText);
      } else {
        setState(() {
          busOnline = false;
          statusMessage = 'Network weak - Showing last location 🟡';
          etaText = 'Bus offline';
        });
      }
    });
  }

  Future<void> _announceLocation(String text) async {
    if (text != lastAnnouncedArea && busOnline) {
      lastAnnouncedArea = text;
      await _flutterTts.speak(text);
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.fromStop.nameKannada} → ${widget.toStop.nameKannada}',
          style: const TextStyle(fontSize: 16),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up, color: Colors.white),
            onPressed: () async {
              await _flutterTts.speak(etaText);
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Status bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: busOnline ? Colors.green.shade50 : Colors.orange.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.circle,
                  color: busOnline ? Colors.green : Colors.orange,
                  size: 12,
                ),
                const SizedBox(width: 8),
                Text(
                  statusMessage,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: busOnline ? Colors.green : Colors.orange,
                  ),
                ),
                if (busOnline) ...[
                  const SizedBox(width: 16),
                  Text(
                    '🚌 ${busSpeed.toStringAsFixed(1)} km/h',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ]
              ],
            ),
          ),

          // ETA banner
          if (busOnline)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              color: Colors.orange.shade50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.access_time,
                      color: Colors.orange, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      etaText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Route info
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.blue.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.trip_origin,
                    color: Colors.green, size: 16),
                const SizedBox(width: 4),
                Text(
                  widget.fromStop.nameKannada,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 16),
                const SizedBox(width: 8),
                const Icon(Icons.location_on,
                    color: Colors.green, size: 16),
                const SizedBox(width: 4),
                Text(
                  widget.toStop.nameKannada,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Map
          Expanded(
            child: busLat == null
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.green),
                        SizedBox(height: 16),
                        Text(
                          'Waiting for bus...',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: LatLng(busLat!, busLng!),
                      initialZoom: 15.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName:
                            'com.example.village_bus_tracker',
                      ),
                      MarkerLayer(
                        markers: [
                          // Bus marker
                          Marker(
                            point: LatLng(busLat!, busLng!),
                            width: 60,
                            height: 60,
                            child: const Column(
                              children: [
                                Icon(
                                  Icons.directions_bus,
                                  color: Colors.green,
                                  size: 40,
                                ),
                                Text(
                                  'BUS',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // FROM marker
                          Marker(
                            point: LatLng(
                              widget.fromStop.latitude,
                              widget.fromStop.longitude,
                            ),
                            width: 80,
                            height: 60,
                            child: Column(
                              children: [
                                const Icon(Icons.trip_origin,
                                    color: Colors.blue, size: 30),
                                Text(
                                  widget.fromStop.nameKannada,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // TO marker
                          Marker(
                            point: LatLng(
                              widget.toStop.latitude,
                              widget.toStop.longitude,
                            ),
                            width: 80,
                            height: 60,
                            child: Column(
                              children: [
                                const Icon(Icons.location_on,
                                    color: Colors.red, size: 30),
                                Text(
                                  widget.toStop.nameKannada,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // All route stops as green dots
                          ...getStopsByRoute('Mandya-Melkote').map(
                            (stop) => Marker(
                              point: LatLng(stop.latitude, stop.longitude),
                              width: 20,
                              height: 20,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),

          // WhatsApp share button
          if (busOnline && busLat != null)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    String message =
                        '🚌 Bus is Live!\nFrom: ${widget.fromStop.nameKannada}\nTo: ${widget.toStop.nameKannada}\n📍 Location: https://www.google.com/maps?q=$busLat,$busLng\n⚡ Speed: ${busSpeed.toStringAsFixed(1)} km/h\n⏱️ $etaText';
                    String whatsappUrl =
                        'whatsapp://send?text=${Uri.encodeComponent(message)}';
                    final uri = Uri.parse(whatsappUrl);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                  icon: const Icon(Icons.share, color: Colors.white),
                  label: const Text(
                    'Share on WhatsApp',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),

          // Bottom info
          if (busOnline && busLat != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Icon(Icons.location_on, color: Colors.green),
                      const Text('Distance',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey)),
                      Text(
                        '${(Geolocator.distanceBetween(busLat!, busLng!, widget.toStop.latitude, widget.toStop.longitude) / 1000).toStringAsFixed(1)} km',
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Icon(Icons.speed, color: Colors.green),
                      const Text('Speed',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey)),
                      Text(
                        '${busSpeed.toStringAsFixed(1)} km/h',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Icon(Icons.access_time, color: Colors.green),
                      const Text('Status',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey)),
                      const Text(
                        'LIVE 🟢',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}