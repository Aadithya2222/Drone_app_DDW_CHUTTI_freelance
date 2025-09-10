import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'control.dart';

// ---------------- DRONE MODEL ----------------
class DroneDevice {
  final String id;
  final String name;
  final String model;
  final double signalStrength;
  final String status;
  final double batteryLevel;
  final double distance;
  final bool isConnected;

  DroneDevice({
    required this.id,
    required this.name,
    required this.model,
    required this.signalStrength,
    required this.status,
    required this.batteryLevel,
    required this.distance,
    this.isConnected = false,
  });

  DroneDevice copyWith({bool? isConnected}) {
    return DroneDevice(
      id: id,
      name: name,
      model: model,
      signalStrength: signalStrength,
      status: status,
      batteryLevel: batteryLevel,
      distance: distance,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}

// ---------------- SCAN PAGE ----------------
class ScanPage extends StatefulWidget {
  const ScanPage({super.key});   // ✅ add const constructor

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  List<DroneDevice> discoveredDrones = [];
  bool isScanning = false;
  Timer? scanTimer;
  DroneDevice? connectedDrone;
  bool isConnecting = false;
  String connectingToId = '';

  final List<Map<String, dynamic>> availableDrones = [
    {
      'id': 'DJI_001',
      'name': 'DJI Mini 3 Pro',
      'model': 'Mini 3 Pro',
      'baseSignal': 85.0,
      'status': 'Ready',
      'baseBattery': 87.0,
    },
    {
      'id': 'MAVIC_002',
      'name': 'DJI Mavic Air 2',
      'model': 'Mavic Air 2',
      'baseSignal': 92.0,
      'status': 'Idle',
      'baseBattery': 64.0,
    },
    {
      'id': 'PHANTOM_003',
      'name': 'DJI Phantom 4 Pro',
      'model': 'Phantom 4 Pro',
      'baseSignal': 78.0,
      'status': 'Ready',
      'baseBattery': 91.0,
    },
    {
      'id': 'CUSTOM_004',
      'name': 'Custom Quadcopter',
      'model': 'DIY Build',
      'baseSignal': 68.0,
      'status': 'Testing',
      'baseBattery': 45.0,
    },
    {
      'id': 'RACING_005',
      'name': 'FPV Racing Drone',
      'model': 'Racing X1',
      'baseSignal': 74.0,
      'status': 'Sport Mode',
      'baseBattery': 78.0,
    },
  ];

  @override
  void initState() {
    super.initState();
    startScanning();
  }

  @override
  void dispose() {
    scanTimer?.cancel();
    super.dispose();
  }

  void startScanning() {
    setState(() {
      isScanning = true;
      discoveredDrones.clear();
    });

    scanTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (discoveredDrones.length < availableDrones.length) {
        final droneData = availableDrones[discoveredDrones.length];
        final random = Random();

        final drone = DroneDevice(
          id: droneData['id'],
          name: droneData['name'],
          model: droneData['model'],
          signalStrength: droneData['baseSignal'] + random.nextDouble() * 10 - 5,
          status: droneData['status'],
          batteryLevel: droneData['baseBattery'] + random.nextDouble() * 6 - 3,
          distance: 10 + random.nextDouble() * 100,
        );

        setState(() {
          discoveredDrones.add(drone);
        });
      } else {
        setState(() {
          isScanning = false;
        });
        timer.cancel();
      }
    });
  }

  void refreshScan() {
    scanTimer?.cancel();
    startScanning();
  }

  Future<void> connectToDrone(DroneDevice drone) async {
  setState(() {
    isConnecting = true;
    connectingToId = drone.id;
  });

  await Future.delayed(const Duration(seconds: 2));
  final random = Random();
  bool connectionSuccess = random.nextDouble() > 0.1; // 90% success rate

  if (connectionSuccess) {
    setState(() {
      connectedDrone = drone.copyWith(isConnected: true);
      isConnecting = false;
      connectingToId = '';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Connected to ${drone.name}"),
        backgroundColor: Colors.green,
      ),
    );

    // ✅ Navigate to ControlPage for ANY drone status
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ControlPage(
          droneName: drone.name,
          batteryLevel: drone.batteryLevel,
          isConnected: true,
        ),
      ),
    );
  } else {
    setState(() {
      isConnecting = false;
      connectingToId = '';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Failed to connect to ${drone.name}. Try again."),
        backgroundColor: Colors.red,
      ),
    );
  }
}


  Color getSignalColor(double strength) {
    if (strength > 80) return Colors.green;
    if (strength > 60) return Colors.orange;
    return Colors.red;
  }

  IconData getSignalIcon(double strength) {
    if (strength > 40) return Icons.wifi;
    return Icons.signal_wifi_off;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Devices"),
        actions: [
          IconButton(
            onPressed: isScanning ? null : refreshScan,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: isScanning ? Colors.blue[50] : Colors.grey[100],
            child: Row(
              children: [
                if (isScanning) ...[
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  const Text("Scanning for devices..."),
                ] else ...[
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 12),
                  Text("Scan complete - ${discoveredDrones.length} devices found"),
                ],
              ],
            ),
          ),
          Expanded(
            child: discoveredDrones.isEmpty && !isScanning
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text("No devices found"),
                        const SizedBox(height: 8),
                        ElevatedButton(onPressed: refreshScan, child: const Text("Scan Again")),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: discoveredDrones.length,
                    itemBuilder: (context, index) {
                      final drone = discoveredDrones[index];
                      final isCurrentlyConnecting =
                          isConnecting && connectingToId == drone.id;

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: getSignalColor(drone.signalStrength),
                            child: const Icon(Icons.flight_takeoff, color: Colors.white),
                          ),
                          title: Text(drone.name,
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Model: ${drone.model}"),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(getSignalIcon(drone.signalStrength),
                                      size: 16, color: getSignalColor(drone.signalStrength)),
                                  const SizedBox(width: 4),
                                  Text("${drone.signalStrength.toStringAsFixed(0)}%"),
                                  const SizedBox(width: 16),
                                  const Icon(Icons.battery_full,
                                      size: 16, color: Colors.green),
                                  const SizedBox(width: 4),
                                  Text("${drone.batteryLevel.toStringAsFixed(0)}%"),
                                ],
                              ),
                              Text(
                                "${drone.distance.toStringAsFixed(0)}m • ${drone.status}",
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                            ],
                          ),
                          trailing: isCurrentlyConnecting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : ElevatedButton(
                                  onPressed:
                                      isConnecting ? null : () => connectToDrone(drone),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        drone.signalStrength > 70 ? Colors.blue : Colors.grey,
                                  ),
                                  child: const Text("Connect",
                                      style: TextStyle(fontSize: 12)),
                                ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: isScanning ? null : refreshScan,
        child: Icon(isScanning ? Icons.stop : Icons.search),
        tooltip: isScanning ? "Stop Scanning" : "Start Scanning",
      ),
    );
  }
}
