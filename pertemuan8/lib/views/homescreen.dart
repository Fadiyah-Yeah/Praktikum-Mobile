import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../data/locations.dart';
import '../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime? _scheduledTime;
  // Tambahan
  LocationData? _selectedLocation;

  // State LBS
  Position? _currentPosition;
  bool _isLoadingLocation = false;
  List<Map<String, dynamic>> _locationsWithDistance = [];


  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final date = DateTime(dt.year, dt.month, dt.day);

    String dateLabel;
    if (date == today) {
      dateLabel = 'Hari ini';
    } else if (date == tomorrow) {
      dateLabel = 'Besok';
    } else {
      dateLabel = '${dt.day}/${dt.month}/${dt.year}';
    }
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$dateLabel, $hour:$minute';
  }

  String _formatDistance(double meters) {
    if (meters < 1000) return '${meters.toStringAsFixed(0)} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate == null) return;
    if (!mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime == null) return;

    setState(() {
      _scheduledTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationsWithDistance = [];
    });

    // 1. Cek apakah GPS aktif
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('GPS tidak aktif.')));
      setState(() => _isLoadingLocation = false);
      return;
    }

    // 2. Cek dan minta permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permission lokasi ditolak.')),
          );
        setState(() => _isLoadingLocation = false);
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission lokasi diblokir.')),
        );
      setState(() => _isLoadingLocation = false);
      return;
    }

    // 3. Ambil posisi
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    // 4. Hitung jarak ke semua lokasi dummy
    final result = dummyLocations.map((loc) {
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        loc.lat,
        loc.lng,
      );
      return {'location': loc, 'distance': distance};
    }).toList();

    // 5. Urutkan dari terdekat
    result.sort(
      (a, b) => (a['distance'] as double).compareTo(b['distance'] as double),
    );

    setState(() {
      _currentPosition = position;
      _locationsWithDistance = result;
      _isLoadingLocation = false;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nearby Reminder',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Bagian 1: Immediate Notification ---
            const Text(
              'Notifikasi Langsung',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.notifications_active),
              label: const Text('Kirim Notifikasi Sekarang'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(14),
              ),
              onPressed: () async {
                await NotificationService().showInstantNotification(
                  title: 'Halo! 👋',
                  body: 'Ini adalah contoh immediate notification.',
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notifikasi dikirim!')),
                  );
                }
              },
            ),

            const SizedBox(height: 32),

            // Bagian 2: LBS
            const Text(
              'Lokasi Terdekat',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.my_location),
              label: const Text('Cek Lokasi Saya'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(14),
              ),
              onPressed: _isLoadingLocation ? null : _getCurrentLocation,
            ),
            if (_isLoadingLocation) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ],
            if (_currentPosition != null) ...[
              const SizedBox(height: 12),
              Text(
                'Posisi kamu: ${_currentPosition!.latitude.toStringAsFixed(5)}, '
                '${_currentPosition!.longitude.toStringAsFixed(5)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              ..._locationsWithDistance.map((item) {
                final loc = item['location'] as LocationData;
                final distance = item['distance'] as double;
                final isNear = distance < 150;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isNear ? Colors.green.shade50 : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isNear ? Colors.green : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: isNear ? Colors.green : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          loc.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isNear
                                ? Colors.green.shade700
                                : Colors.black,
                          ),
                        ),
                      ),
                      Text(
                        _formatDistance(distance),
                        style: TextStyle(
                          color: isNear ? Colors.green.shade700 : Colors.grey,
                          fontWeight: isNear
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      if (isNear) ...[
                        const SizedBox(width: 6),
                        const Text('✅', style: TextStyle(fontSize: 14)),
                      ],
                    ],
                  ),
                );
              }),
            ],
            const SizedBox(height: 32),

            // ── Bagian 3: Set Reminder ke Lokasi ──
            const Text(
              'Set Reminder ke Lokasi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Pilih lokasi tujuan dan waktu. Notifikasi akan mengingatkanmu '
              'untuk cek jarak ke lokasi tersebut.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<LocationData?>(
              value: _selectedLocation,
              decoration: const InputDecoration(
                labelText: 'Pilih lokasi tujuan',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Pilih lokasi...'),
                ),
                ...dummyLocations.map(
                  (loc) => DropdownMenuItem(value: loc, child: Text(loc.name)),
                ),
              ],
              onChanged: (val) => setState(() => _selectedLocation = val),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickDateTime,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _scheduledTime == null
                            ? 'Pilih tanggal & waktu reminder...'
                            : _formatDateTime(_scheduledTime!),
                        style: TextStyle(
                          color: _scheduledTime == null
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                    ),
                    if (_scheduledTime != null)
                      GestureDetector(
                        onTap: () => setState(() => _scheduledTime = null),
                        child: const Icon(
                          Icons.close,
                          color: Colors.grey,
                          size: 18,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.alarm),
              label: const Text('Set Reminder'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(14),
              ),
              onPressed: _selectedLocation == null || _scheduledTime == null
                  ? null
                  : () async {
                      await NotificationService().scheduleNotification(
                        id: 1,
                        title: 'Reminder: ${_selectedLocation!.name} 📍',
                        body:
                            'Buka app untuk cek seberapa jauh kamu '
                            'dari ${_selectedLocation!.name}',
                        scheduledTime: _scheduledTime!,
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Reminder ke ${_selectedLocation!.name} '
                              'di-set untuk ${_formatDateTime(_scheduledTime!)}',
                            ),
                          ),
                        );
                        setState(() {
                          _scheduledTime = null;
                          _selectedLocation = null;
                        });
                      }
                    },
            ),


          ],
        ),
      ),
    );
  }
}