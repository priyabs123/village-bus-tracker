import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('bus/location');
  double? busLat;
  double? busLng;
  double busSpeed = 0.0;
  bool busOnline = false;

  @override
  void initState() {
    super.initState();
    _listenToBus();
  }

  void _listenToBus() {
    _dbRef.onValue.listen((event) {
      if (!mounted) return;
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        setState(() {
          busLat = double.parse(data['latitude'].toString());
          busLng = double.parse(data['longitude'].toString());
          busSpeed = double.parse(data['speed'].toString());
          busOnline = true;
        });
      } else {
        setState(() { busOnline = false; });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;  // ✅ mounted check
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: busOnline ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: busOnline ? Colors.green : Colors.red),
              ),
              child: Column(
                children: [
                  Icon(Icons.directions_bus, size: 60, color: busOnline ? Colors.green : Colors.red),
                  const SizedBox(height: 12),
                  Text(busOnline ? '🟢 Bus is LIVE' : '🔴 Bus is OFFLINE', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: busOnline ? Colors.green : Colors.red)),
                  if (busOnline) ...[
                    const SizedBox(height: 8),
                    Text('Speed: ${busSpeed.toStringAsFixed(1)} km/h', style: const TextStyle(fontSize: 16)),
                    Text('Location: ${busLat?.toStringAsFixed(4)}, ${busLng?.toStringAsFixed(4)}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue)), child: const Column(children: [Icon(Icons.route, color: Colors.blue, size: 30), SizedBox(height: 8), Text('1', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)), Text('Active Routes')]))),
                const SizedBox(width: 12),
                Expanded(child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange)), child: const Column(children: [Icon(Icons.directions_bus, color: Colors.orange, size: 30), SizedBox(height: 8), Text('1', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange)), Text('Total Buses')]))),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Active Route', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 8),
                  Row(children: [Icon(Icons.trip_origin, color: Colors.green, size: 16), SizedBox(width: 8), Text('ಮಂಡ್ಯ (Mandya)')]),
                  SizedBox(height: 4),
                  Row(children: [Icon(Icons.location_on, color: Colors.red, size: 16), SizedBox(width: 8), Text('ಮೇಲುಕೋಟೆ (Melkote)')]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}