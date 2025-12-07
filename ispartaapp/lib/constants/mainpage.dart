import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

import 'package:ispartaapp/constants/announcement.dart';
import 'package:ispartaapp/constants/profilepage.dart';
import 'package:ispartaapp/constants/services.dart';
import 'package:ispartaapp/services/colors.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // Sayfa listesi
  final List<Widget> _pages = [
    const MainPageContent(), // Ana Sayfa
    const ServicesPage(), // Hizmetler Sayfası
    const AnnouncementPage(), // Duyurular Sayfası
    const ProfilePage(), // Profil Sayfası
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          backgroundColor: AppColors.bg,

          body: _pages[_selectedIndex],

          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: HexColor('#F8F8FF'),
            selectedIconTheme: IconThemeData(color: AppColors.primary),
            selectedItemColor: AppColors.primary,
            unselectedItemColor: Colors.grey,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Ana Sayfa',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list_sharp),
                label: 'Hizmetler',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications),
                label: 'Duyurular',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- ANA SAYFA İÇERİĞİ ---
class MainPageContent extends StatefulWidget {
  const MainPageContent({super.key});

  @override
  State<MainPageContent> createState() => _MainPageContentState();
}

class _MainPageContentState extends State<MainPageContent> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // --- SABİT ALAN (KAYMAZ) ---
          Row(
            children: [
              Text(
                "Hava Durumu",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.texts,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                "Duyurular",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.texts,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // --- KAYDIRILABİLİR ALAN ---
          // Expanded sayesinde geriye kalan tüm boşluğu kaplar ve içinde kaydırma yapar
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  Container(
                    width: double.infinity, // Ekranı enlemesine doldursun
                    height: 100,
                    color: Colors.red,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Center(child: Text("1. Duyuru")),
                  ),
                  Container(
                    width: double.infinity,
                    height: 100,
                    color: Colors.blue,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Center(child: Text("2. Duyuru")),
                  ),

                  // Gradientli Kutu (AppColors.cards kullanımı)
                  Container(
                    width: double.infinity,
                    height: 100,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      gradient: AppColors.cards, // Senin tanımladığın gradient
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        "Gradient Kutu",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  Container(
                    width: double.infinity,
                    height: 100,
                    color: Colors.orange,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "Gradient Kutu",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 100,
                    color: Colors.purple,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "Gradient Kutu",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 100,
                    color: Colors.green,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "Gradient Kutu",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
