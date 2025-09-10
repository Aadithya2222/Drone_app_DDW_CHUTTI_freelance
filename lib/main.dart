import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'scan.dart'; // ✅ new file for ScanPage

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DDWChuttiApp());
}

class DDWChuttiApp extends StatelessWidget {
  const DDWChuttiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "DDW Chutti",
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/scan': (context) => const ScanPage(),
      },
    );
  }
}
