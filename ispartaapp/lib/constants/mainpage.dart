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

  final List<Widget> _pages = [
    const MainPageContent(),
    const ServicesPage(),
    const AnnouncementPage(),
    const ProfilePage(),
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
          _buildHeader("Hava Durumu"),
          const SizedBox(height: 10),
          _buildHeader("Duyurular"),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  _buildContentCard(text: "1. Duyuru", color: Colors.red),
                  _buildContentCard(text: "2. Duyuru", color: Colors.blue),
                  _buildContentCard(
                    text: "Gradient Kutu",
                    gradient: AppColors.cards,
                  ),
                  _buildContentCard(text: "Turuncu Kutu", color: Colors.orange),
                  _buildContentCard(text: "Mor Kutu", color: Colors.purple),
                  _buildContentCard(text: "Yeşil Kutu", color: Colors.green),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.texts,
          ),
        ),
      ],
    );
  }

  Widget _buildContentCard({
    required String text,
    Color? color,
    Gradient? gradient,
  }) {
    return Container(
      width: double.infinity,
      height: 100,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color,
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
