import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

// ---------------- GAMIFIED JOYSTICK WIDGET ----------------
class Joystick extends StatefulWidget {
  final String label;
  final Function(Offset) onMove;

  const Joystick({super.key, required this.label, required this.onMove});

  @override
  State<Joystick> createState() => _JoystickState();
}

class _JoystickState extends State<Joystick> {
  Offset knobPosition = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final double baseSize = 140;
    final double knobSize = 50;
    final double radius = (baseSize - knobSize) / 2;

    return GestureDetector(
      onPanUpdate: (details) {
        Offset newPos = Offset(
          knobPosition.dx + details.delta.dx,
          knobPosition.dy + details.delta.dy,
        );

        // limit knob movement to circular boundary
        if (newPos.distance > radius) {
          newPos = Offset.fromDirection(newPos.direction, radius);
        }

        setState(() => knobPosition = newPos);

        // normalized offset -1 to 1
        widget.onMove(Offset(knobPosition.dx / radius, knobPosition.dy / radius));
      },
      onPanEnd: (_) {
        setState(() => knobPosition = Offset.zero);
        widget.onMove(Offset.zero);
      },
      child: SizedBox(
        width: baseSize,
        height: baseSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Base circle
            Container(
              width: baseSize,
              height: baseSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue[100],
                border: Border.all(color: Colors.blue, width: 3),
              ),
            ),
            // Movable knob
            Transform.translate(
              offset: knobPosition,
              child: Container(
                width: knobSize,
                height: knobSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue,
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
              ),
            ),
            // Label
            Positioned(
              bottom: 8,
              child: Text(
                widget.label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- CONTROL PAGE ----------------
class ControlPage extends StatefulWidget {
  final String droneName;
  final double batteryLevel;
  final bool isConnected;

  const ControlPage({
    super.key,
    required this.droneName,
    required this.batteryLevel,
    required this.isConnected,
  });

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  double droneHeight = 0.0;
  double droneHealth = 100.0;
  Offset leftJoystick = Offset.zero;
  Offset rightJoystick = Offset.zero;

  @override
  void initState() {
    super.initState();

    // Lock orientation to landscape
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Simulate drone height changes
    _simulateDroneTelemetry();
  }

  @override
  void dispose() {
    // Unlock orientations on exit
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  void _simulateDroneTelemetry() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          droneHeight = Random().nextDouble() * 100; // 0-100m
          droneHealth = 80 + Random().nextDouble() * 20; // 80-100%
        });
        _simulateDroneTelemetry();
      }
    });
  }

  void _emergencyLanding() {
    setState(() {
      droneHeight = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Emergency Landing Activated!"),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Row(
          children: [
            // LEFT JOYSTICK
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Joystick(
                    label: "",
                    onMove: (offset) {
                      setState(() => leftJoystick = offset);
                    },
                  ),
                ],
              ),
            ),

            // DRONE STATUS CENTER PANEL
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Text(widget.droneName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                widget.isConnected
                                    ? Icons.check_circle
                                    : Icons.error,
                                color: widget.isConnected
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Text(widget.isConnected
                                  ? "Connected"
                                  : "Disconnected"),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  const Icon(Icons.height, color: Colors.blue),
                                  Text("${droneHeight.toStringAsFixed(1)} m"),
                                ],
                              ),
                              Column(
                                children: [
                                  const Icon(Icons.battery_full,
                                      color: Colors.green),
                                  Text("${widget.batteryLevel.toStringAsFixed(0)}%"),
                                ],
                              ),
                              Column(
                                children: [
                                  const Icon(Icons.health_and_safety,
                                      color: Colors.orange),
                                  Text("${droneHealth.toStringAsFixed(0)}%"),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _emergencyLanding,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    icon: const Icon(Icons.warning),
                    label: const Text("Emergency Landing"),
                  ),
                ],
              ),
            ),

            // RIGHT JOYSTICK
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Joystick(
                    label: "",
                    onMove: (offset) {
                      setState(() => rightJoystick = offset);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
