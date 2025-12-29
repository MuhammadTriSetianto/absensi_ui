import 'package:absensi_proyek/screens/home_main.dart';
import 'package:absensi_proyek/screens/landing_page_screen.dart';
import 'package:absensi_proyek/screens/log_in_screen.dart';
import 'package:absensi_proyek/screens/userprofileview.dart';
import 'package:absensi_proyek/screens/form_izin.dart';
import 'package:flutter/material.dart';
import 'package:absensi_proyek/screens/from_cuti.dart';
import 'package:absensi_proyek/screens/aktiviti.dart';
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
      // home: UserProfileView()
      // home: FormIzinScreen(),
      // home: FormCutiScreen(),
      home: Aktiviti(),
    );
  }
}
