import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Mandya Bus Stand coordinates
const double busStandLat = 12.5218;
const double busStandLng = 76.8950;
const double geofenceRadius = 500; // 500 meters

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'bus_tracker_channel',
      initialNotificationTitle: '🚌 Village Bus Tracker',
      initialNotificationContent: 'Starting...',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );

  await service.startService();
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Initialize Firebase in background
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  bool isSharing = false;
  DateTime? stoppedTime;

  // Check time every minute
  Timer.periodic(const Duration(minutes: 1), (timer) async {
    final now = DateTime.now();
    final hour = now.hour;

    // Active hours: 7AM to 9PM only
    bool isActiveTime = hour >= 7 && hour < 21;

    if (!isActiveTime) {
      // Outside active hours — stop everything!
      isSharing = false;
      stoppedTime = null;
      await FirebaseDatabase.instance.ref('bus/location').remove();

      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: '🚌 Village Bus Tracker',
          content: 'Inactive. Resumes at 7AM ⏰',
        );
      }
    }
  });

  // Request location permission
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  // Listen to GPS updates
  Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 50,
    ),
  ).listen((position) async {
    final now = DateTime.now();
    final hour = now.hour;

    // Only track between 7AM and 9PM
    bool isActiveTime = hour >= 7 && hour < 21;

    if (!isActiveTime) {
      // Outside hours — don't track!
      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: '🚌 Village Bus Tracker',
          content: 'Inactive. Resumes at 7AM ⏰',
        );
      }
      return;
    }

    double speedKmph = position.speed * 3.6;

    // Check distance from Mandya bus stand (Geofence)
    double distanceFromBusStand = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      busStandLat,
      busStandLng,
    );

    bool nearBusStand = distanceFromBusStand <= geofenceRadius;

    // Update notification
    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: '🚌 Village Bus Tracker',
        content: nearBusStand
            ? '📍 Near bus stand — Ready!'
            : isSharing
                ? '🟢 Sharing — ${speedKmph.toStringAsFixed(0)} km/h'
                : '👀 Monitoring... Active till 9PM',
      );
    }

    // Geofence OR already sharing
    if (nearBusStand || isSharing) {
      if (speedKmph > 5) {
        // Bus is MOVING — share location!
        isSharing = true;
        stoppedTime = null;

        await FirebaseDatabase.instance.ref('bus/location').set({
          'latitude': position.latitude,
          'longitude': position.longitude,
          'speed': speedKmph,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'status': 'moving',
        });
      } else {
        // Bus STOPPED
        stoppedTime ??= DateTime.now();

        if (stoppedTime != null) {
          Duration stoppedDuration =
              DateTime.now().difference(stoppedTime!);

          // Update notification with stopped time
          if (service is AndroidServiceInstance) {
            service.setForegroundNotificationInfo(
              title: '🚌 Village Bus Tracker',
              content:
                  '🔴 Bus stopped — ${stoppedDuration.inMinutes} mins',
            );
          }

          // Stop sharing after 10 minutes of no movement
          if (stoppedDuration.inMinutes >= 10) {
            isSharing = false;
            stoppedTime = null;
            await FirebaseDatabase.instance
                .ref('bus/location')
                .remove();
          }
        }
      }
    }
  });
}