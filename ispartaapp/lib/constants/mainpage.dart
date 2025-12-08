import 'dart:convert'; // JSON verisini okumak için gerekli
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http; // İnternet isteği için gerekli

import 'package:ispartaapp/constants/announcement.dart';
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
          appBar: AppBar(
            scrolledUnderElevation: 0.0,

            title: const Text("Isparta App"),
            backgroundColor: AppColors.bg,
          ),
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
  // --- HAVA DURUMU DEĞİŞKENLERİ ---
  String temperature = ""; // Sıcaklık
  String status = "Yükleniyor..."; // Durum (Örn: Parçalı Bulutlu)
  String city = "Isparta";
  IconData weatherIcon = Icons.cloud_download; // Varsayılan ikon
  bool isLoading = true; // Yükleniyor mu kontrolü

  @override
  void initState() {
    super.initState();
    getWeatherData(); // Uygulama açılınca veriyi çek
  }

  // API'den Veri Çeken Fonksiyon
  Future<void> getWeatherData() async {
    // Senin verdiğin API Key ile URL
    final url = Uri.parse(
      "https://api.openweathermap.org/data/2.5/weather?q=Isparta&appid=c2e800ef8351c139fee8ff027ee1c756&units=metric&lang=tr",
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        setState(() {
          // Sıcaklığı yuvarla (Örn: 12.5 -> 13)
          double tempVal = data['main']['temp'];
          temperature = "${tempVal.round()}°C";

          // Hava durumunu al (İlk harfleri büyük yap)
          String rawStatus = data['weather'][0]['description'];
          status = rawStatus[0].toUpperCase() + rawStatus.substring(1);

          // İkonu belirle (Hava durumuna göre değişir)
          String mainStatus = data['weather'][0]['main'];
          weatherIcon = _getIconForWeather(mainStatus);

          isLoading = false; // Yükleme bitti
        });
      } else {
        setState(() {
          status = "Hata oluştu";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        status = "Bağlantı yok";
        isLoading = false;
      });
      print("Hata: $e");
    }
  }

  // Hava durumuna göre ikon seçen yardımcı fonksiyon
  IconData _getIconForWeather(String mainStatus) {
    switch (mainStatus) {
      case 'Clear':
        return Icons.wb_sunny; // Güneşli
      case 'Clouds':
        return Icons.cloud; // Bulutlu
      case 'Rain':
        return Icons.umbrella; // Yağmurlu
      case 'Drizzle':
        return Icons.grain; // Çiseleme
      case 'Thunderstorm':
        return Icons.flash_on; // Fırtına
      case 'Snow':
        return Icons.ac_unit; // Karlı
      default:
        return Icons.cloud; // Varsayılan
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          _buildHeader("Hava Durumu"),
          const SizedBox(height: 10),

          // --- GÜNCELLENMİŞ HAVA DURUMU KARTI ---
          _buildWeatherCard(),

          const SizedBox(height: 20),

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

  // --- HAVA DURUMU KARTI TASARIMI ---
  Widget _buildWeatherCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ) // Yüklenirken
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Dinamik İkon
                    Icon(weatherIcon, size: 50, color: Colors.white),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          city,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          status, // API'den gelen durum (Örn: Parçalı az bulutlu)
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  temperature, // API'den gelen sıcaklık
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
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
