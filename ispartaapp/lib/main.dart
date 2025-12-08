import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Tam ekran için
import 'package:firebase_core/firebase_core.dart';
import 'package:ispartaapp/constants/mainpage.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const MainPage());
}
