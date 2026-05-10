import 'package:flutter/material.dart';
import 'bus_stops.dart';
import 'passenger_screen.dart';

class RouteScreen extends StatefulWidget {
  const RouteScreen({super.key});

  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  BusStop? fromStop;
  BusStop? toStop;
  List<BusStop> routeStops = getStopsByRoute('Mandya-Melkote');

  void _showStopPicker(bool isFrom) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Icon(
                    isFrom ? Icons.trip_origin : Icons.location_on,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isFrom
                        ? 'ಎಲ್ಲಿಂದ ಹೊರಡುತ್ತೀರಿ? (From where?)'
                        : 'ಎಲ್ಲಿಗೆ ಹೋಗುತ್ತೀರಿ? (Where to?)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Village list
            Expanded(
              child: ListView.builder(
                itemCount: routeStops.length,
                itemBuilder: (context, index) {
                  final stop = routeStops[index];
                  bool isSelected = isFrom
                      ? fromStop?.nameKannada == stop.nameKannada
                      : toStop?.nameKannada == stop.nameKannada;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          isSelected ? Colors.green : Colors.grey.shade200,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      stop.nameKannada,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color:
                            isSelected ? Colors.green : Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      stop.nameEnglish,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                    onTap: () {
                      setState(() {
                        if (isFrom) {
                          fromStop = stop;
                        } else {
                          toStop = stop;
                        }
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B5E20),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Header
              const Row(
                children: [
                  Icon(Icons.directions_bus, color: Colors.white, size: 40),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ವಿಲೇಜ್ ಬಸ್ ಟ್ರ್ಯಾಕರ್',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'ಮಂಡ್ಯ - ಮೇಲುಕೋಟೆ ರೂಟ್',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Main card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    // FROM button
                    GestureDetector(
                      onTap: () => _showStopPicker(true),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: fromStop != null
                              ? Colors.green.shade50
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: fromStop != null
                                ? Colors.green
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.trip_origin,
                              color: fromStop != null
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'ಎಲ್ಲಿಂದ (FROM)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    fromStop != null
                                        ? fromStop!.nameKannada
                                        : 'ಊರು ಆಯ್ಕೆ ಮಾಡಿ (Select village)',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: fromStop != null
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                  ),
                                  if (fromStop != null)
                                    Text(
                                      fromStop!.nameEnglish,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: fromStop != null
                                  ? Colors.green
                                  : Colors.grey,
                              size: 30,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Swap button
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            BusStop? temp = fromStop;
                            fromStop = toStop;
                            toStop = temp;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green),
                          ),
                          child: const Icon(
                            Icons.swap_vert,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // TO button
                    GestureDetector(
                      onTap: () => _showStopPicker(false),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: toStop != null
                              ? Colors.green.shade50
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: toStop != null
                                ? Colors.green
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color:
                                  toStop != null ? Colors.green : Colors.grey,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'ಎಲ್ಲಿಗೆ (TO)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    toStop != null
                                        ? toStop!.nameKannada
                                        : 'ಗಮ್ಯ ಆಯ್ಕೆ ಮಾಡಿ (Select destination)',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: toStop != null
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                  ),
                                  if (toStop != null)
                                    Text(
                                      toStop!.nameEnglish,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color:
                                  toStop != null ? Colors.green : Colors.grey,
                              size: 30,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Track button
              if (fromStop != null && toStop != null)
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PassengerScreen(
                            fromStop: fromStop!,
                            toStop: toStop!,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.track_changes, color: Color(0xFF1B5E20)),
                        SizedBox(width: 8),
                        Text(
                          'ಬಸ್ ಟ್ರ್ಯಾಕ್ ಮಾಡಿ 🚌',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}