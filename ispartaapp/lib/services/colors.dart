import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class AppColors {
  // 'static' olarak tanımlayarak bağladığımız dosyalar için erişilebilir hale getiriyoruz
  static Color bg = HexColor('#F5FEFD'); // Beyaz arka plan
  static Color primary = HexColor('#E68EB2'); // Gül pembesi
  static Color secondary = HexColor('#7A3E65'); // Koyu Gül kurusu
  static Color texts = HexColor('#5A5A5A');

  static Gradient cards = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[primary, secondary],
  );
}
