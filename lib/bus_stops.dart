class BusStop {
  final String nameKannada;
  final String nameEnglish;
  final double latitude;
  final double longitude;
  final String district;
  final String route;
  final int stopOrder;

  BusStop({
    required this.nameKannada,
    required this.nameEnglish,
    required this.latitude,
    required this.longitude,
    required this.district,
    required this.route,
    required this.stopOrder,
  });
}

// Get stops by route
List<BusStop> getStopsByRoute(String route) {
  return allBusStops
      .where((stop) => stop.route == route)
      .toList()
    ..sort((a, b) => a.stopOrder.compareTo(b.stopOrder));
}

final List<BusStop> allBusStops = [
  BusStop(
    nameKannada: 'ಮಂಡ್ಯ',
    nameEnglish: 'Mandya',
    latitude: 12.5218,
    longitude: 76.8950,
    district: 'Mandya',
    route: 'Mandya-Melkote',
    stopOrder: 1,
  ),
  BusStop(
    nameKannada: 'ಹೊಳಲು',
    nameEnglish: 'Holalu',
    latitude: 12.5500,
    longitude: 76.8200,
    district: 'Mandya',
    route: 'Mandya-Melkote',
    stopOrder: 2,
  ),
  BusStop(
    nameKannada: 'ಮಲ್ಲನಾಯಕನ ಕಟ್ಟೆ',
    nameEnglish: 'Mallanayakana Katte',
    latitude: 12.5667,
    longitude: 76.8000,
    district: 'Mandya',
    route: 'Mandya-Melkote',
    stopOrder: 3,
  ),
  BusStop(
    nameKannada: 'ವಿಸಿ ಫಾರ್ಮ್',
    nameEnglish: 'VC Farm',
    latitude: 12.5833,
    longitude: 76.7833,
    district: 'Mandya',
    route: 'Mandya-Melkote',
    stopOrder: 4,
  ),
  BusStop(
    nameKannada: 'ಶಿವಳ್ಳಿ',
    nameEnglish: 'Shivalli',
    latitude: 12.6000,
    longitude: 76.7667,
    district: 'Mandya',
    route: 'Mandya-Melkote',
    stopOrder: 5,
  ),
  BusStop(
    nameKannada: 'ದುದ್ದ',
    nameEnglish: 'Dudda',
    latitude: 12.6167,
    longitude: 76.7500,
    district: 'Mandya',
    route: 'Mandya-Melkote',
    stopOrder: 6,
  ),
  BusStop(
    nameKannada: 'ಬಿ ಹೊನ್ನೇನಹಳ್ಳಿ',
    nameEnglish: 'B Honnenahalli',
    latitude: 12.6333,
    longitude: 76.7333,
    district: 'Mandya',
    route: 'Mandya-Melkote',
    stopOrder: 7,
  ),
  BusStop(
    nameKannada: 'ಬೆವಕಲ್ಲು',
    nameEnglish: 'Bevakallu',
    latitude: 12.6500,
    longitude: 76.7167,
    district: 'Mandya',
    route: 'Mandya-Melkote',
    stopOrder: 8,
  ),
  BusStop(
    nameKannada: 'ಬಿ ಹತ್ನ',
    nameEnglish: 'B Hatna',
    latitude: 12.6667,
    longitude: 76.7000,
    district: 'Mandya',
    route: 'Mandya-Melkote',
    stopOrder: 9,
  ),
  BusStop(
    nameKannada: 'ಜಾವನಹಳ್ಳಿ',
    nameEnglish: 'Javanahalli',
    latitude: 12.6833,
    longitude: 76.6833,
    district: 'Mandya',
    route: 'Mandya-Melkote',
    stopOrder: 10,
  ),
  BusStop(
    nameKannada: 'ಲೋಕಪಾವನಿ',
    nameEnglish: 'Lokapavani',
    latitude: 12.6433,
    longitude: 76.6700,
    district: 'Mandya',
    route: 'Mandya-Melkote',
    stopOrder: 11,
  ),
  BusStop(
    nameKannada: 'ಜಿ ಹೊಸಹಳ್ಳಿ',
    nameEnglish: 'G Hosahalli',
    latitude: 12.6550,
    longitude: 76.6600,
    district: 'Mandya',
    route: 'Mandya-Melkote',
    stopOrder: 12,
  ),
  BusStop(
    nameKannada: 'ಜಕ್ಕನಹಳ್ಳಿ',
    nameEnglish: 'Jakkanahalli',
    latitude: 12.6580,
    longitude: 76.6520,
    district: 'Mandya',
    route: 'Mandya-Melkote',
    stopOrder: 13,
  ),
  BusStop(
    nameKannada: 'ಮೇಲುಕೋಟೆ',
    nameEnglish: 'Melkote',
    latitude: 12.6597,
    longitude: 76.6463,
    district: 'Mandya',
    route: 'Mandya-Melkote',
    stopOrder: 14,
  ),
];