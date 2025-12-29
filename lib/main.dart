
import 'package:absensi_proyek/screens/home_main.dart';
import 'package:absensi_proyek/screens/landing_page_screen.dart';
import 'package:absensi_proyek/screens/log_in_screen.dart';
import 'package:absensi_proyek/screens/userprofileview.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // home: LandingPagesScreen(),
      // home: LoginPage(),
      // home: HomeMain(),
      home: UserProfileView()
    );
  }
}
