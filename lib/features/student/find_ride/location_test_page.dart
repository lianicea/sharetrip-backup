
import 'package:flutter/material.dart';
import '../../../core/services/location_service.dart';
import 'package:geolocator/geolocator.dart';

class LocationTestPage extends StatefulWidget {
  const LocationTestPage({super.key});

  @override
  State<LocationTestPage> createState() =>
      _LocationTestPageState();
}

class _LocationTestPageState extends State<LocationTestPage> {
  final LocationService locationService = LocationService();

  Position? currentPosition;

  bool isLoading = false;
  String? errorMessage;

  Future<void> _getLocation() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final position =
          await locationService.getCurrentLocation();

      if (!mounted) return;

      setState(() {
        currentPosition = position;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString().replaceFirst(
          'Exception: ',
          '',
        );
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FC),

      appBar: AppBar(
        title: const Text(
          'ShareTrip GPS Test',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        backgroundColor: const Color(0xFF5427C8),
        foregroundColor: Colors.white,
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),

          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),

            child: Column(
              children: [
                Container(
                  width: 75,
                  height: 75,

                  decoration: BoxDecoration(
                    color: const Color(0xFFF0EAFF),
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: const Icon(
                    Icons.my_location,
                    color: Color(0xFF5427C8),
                    size: 38,
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Current Location',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Find your current location using your device GPS.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 46,

                  child: ElevatedButton.icon(
                    onPressed: isLoading
                        ? null
                        : _getLocation,

                    icon: isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.location_searching,
                            size: 17,
                          ),

                    label: Text(
                      isLoading
                          ? 'Getting Location...'
                          : 'Use My Current Location',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5427C8),
                      foregroundColor: Colors.white,
                      elevation: 0,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                if (errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(13),

                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(10),
                    ),

                    child: Text(
                      errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),

                if (currentPosition != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),

                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F0FC),
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 18,
                            ),
                            SizedBox(width: 7),
                            Text(
                              'Location Found!',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        _locationInfo(
                          'Latitude',
                          currentPosition!.latitude.toString(),
                        ),

                        const SizedBox(height: 12),

                        _locationInfo(
                          'Longitude',
                          currentPosition!.longitude.toString(),
                        ),

                        const SizedBox(height: 12),

                        _locationInfo(
                          'Accuracy',
                          '${currentPosition!.accuracy.toStringAsFixed(1)} meters',
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _locationInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 10,
          ),
        ),

        const SizedBox(height: 4),

        SelectableText(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
