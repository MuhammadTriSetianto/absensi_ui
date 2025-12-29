import 'package:flutter/material.dart';

class CurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    // Titik awal kiri (lebih tinggi)
    path.moveTo(size.width , size.height * 0.1);

    // Lengkungan landai ke kanan (lebih rendah)
    path.quadraticBezierTo(
      size.width * 0.5, // kontrol di tengah
      size.height * 0.5, // tarik ke atas (halus)
      0, // ujung kanan
      size.height * 0.5, // turun di kanan
    );

    // Tutup shape ke bawah
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
