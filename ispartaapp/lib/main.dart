import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Tam ekran için
import 'package:firebase_core/firebase_core.dart'; // <-- 1. BU PAKETİ EKLE
import 'package:ispartaapp/constants/mainpage.dart';
import 'firebase_options.dart'; // <-- 2. BU DOSYAYI İMPORT ET (Hata verirse aşağıyı oku)

void main() async {
  // <-- 3. BURAYA 'async' EKLE
  // Flutter motorunu başlat (Async işlemler için şart)
  WidgetsFlutterBinding.ensureInitialized();

  // --- SENİN VERDİĞİN KOD BURAYA GELECEK ---
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // -----------------------------------------

  // Tam ekran modu (Daha önce eklemiştik)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const MainPage());
}
