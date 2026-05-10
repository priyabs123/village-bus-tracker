# 🚌 Village Bus Tracker - ವಿಲೇಜ್ ಬಸ್ ಟ್ರ್ಯಾಕರ್

A real-time bus tracking mobile app built for rural Karnataka villages, specifically designed for the Mandya-Melkote route.

## 📱 Demo
> App tracks live bus location and shows it on map with ETA for passengers.

## 🎯 Problem Statement
Village people in rural Karnataka have no way to know when their bus will arrive. They wait for hours at bus stops with zero information. This app solves that problem with real-time GPS tracking.

## ✨ Features

- 🗺️ **Real-time GPS Tracking** — Live bus location on map
- ⏱️ **ETA Calculation** — "Bus arrives in X minutes"
- 🔔 **Push Notifications** — Alert when bus is within 1km
- 🗣️ **Kannada Voice Alerts** — Announces bus location in Kannada
- 📍 **All Stops on Map** — Shows complete route with all stops
- 🌙 **Dark Mode** — Supports light and dark theme
- 📵 **Offline Support** — Shows last known location on poor network
- 💬 **WhatsApp Share** — Share bus location directly on WhatsApp
- 🤖 **Auto GPS** — Driver app auto-starts when bus moves (no manual effort)
- 📍 **Geofence Detection** — Auto activates when driver enters bus stand area

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| Flutter + Dart | Mobile App (Android/iOS) |
| Firebase Realtime Database | Live location sync |
| Firebase Authentication | User login |
| Geolocator | GPS tracking |
| Flutter Map | Map display |
| Flutter TTS | Kannada voice alerts |
| Flutter Local Notifications | Push notifications |
| Background Service | Auto GPS tracking |

## 📂 Project Structure
lib/
├── main.dart              # App entry point
├── splash_screen.dart     # Animated splash screen
├── driver_screen.dart     # Driver GPS tracking
├── passenger_screen.dart  # Live map for passengers
├── route_screen.dart      # Route selection
├── bus_stops.dart         # Village stops data
├── background_service.dart # Auto GPS service
├── notification_service.dart # Push notifications
├── admin_screen.dart      # Admin dashboard
└── login_screen.dart      # Authentication

## 🚀 How It Works
Driver opens app once
↓
App runs in background automatically (7AM - 9PM)
↓
Detects bus stand entry via Geofence
↓
Auto starts GPS sharing when bus moves
↓
Firebase stores real-time location
↓
Passenger app reads location
↓
Shows bus on map with ETA!

## 📍 Current Route

**Mandya → Melkote** with stops:
ಮಂಡ್ಯ → ಹೊಳಲು → ಮಲ್ಲನಾಯಕನ ಕಟ್ಟೆ → ವಿಸಿ ಫಾರ್ಮ್ → ಶಿವಳ್ಳಿ → ದುದ್ದ → ಬಿ ಹೊನ್ನೇನಹಳ್ಳಿ → ಬೆವಕಲ್ಲು → ಬಿ ಹತ್ನ → ಜಾವನಹಳ್ಳಿ → ಲೋಕಪಾವನಿ → ಜಿ ಹೊಸಹಳ್ಳಿ → ಜಕ್ಕನಹಳ್ಳಿ → ಮೇಲುಕೋಟೆ

## 🌍 Real World Impact

- Targets rural Karnataka villages where no tracking solution exists
- Works on 2G networks common in villages
- Kannada language support for local users
- Planned deployment through Gram Panchayat partnerships
- KSRTC collaboration planned for scaling

## 📲 Installation

1. Download APK from releases
2. Enable "Install from unknown sources"
3. Install and open app
4. Select Driver or Passenger
5. Start tracking!

## 🔮 Future Plans

- [ ] Add more Karnataka districts and routes
- [ ] Integrate with KSRTC for government buses
- [ ] Add bus schedule with timetable
- [ ] Multi-language support (Hindi, Telugu)
- [ ] GPS hardware device integration

## 👩‍💻 Developer

**Priya BS**
- 3rd Year Information Science Engineering
- GitHub: [@priyabs123](https://github.com/priyabs123)

## 📄 License

MIT License — feel free to use and contribute!
