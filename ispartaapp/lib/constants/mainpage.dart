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
    MainPageContent(),
    ServicesPage(),
    AnnouncementPage(),
    ProfilePage(),
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
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: HexColor('#F8F8FF '),
            selectedIconTheme: IconThemeData(color: AppColors.primary),
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
                icon: Icon(Icons.settings),
                label: 'Duyurular',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: AppColors.primary,
            onTap: _onItemTapped,
          ),
          backgroundColor: AppColors.bg,
          body: _pages[_selectedIndex],
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
          Row(children: [Text("Hava durumu")]),
          Text("Duyurular"),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  color: Colors.red,
                  margin: EdgeInsets.all(8),
                ),
                Container(
                  width: 100,
                  height: 100,
                  color: Colors.red,
                  margin: EdgeInsets.all(8),
                ),
                Container(
                  width: 100,
                  height: 100,

                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(gradient: AppColors.cards),
                ),
                Container(
                  width: 100,
                  height: 100,
                  color: Colors.red,
                  margin: EdgeInsets.all(8),
                ),
                Container(
                  width: 100,
                  height: 100,
                  color: Colors.red,
                  margin: EdgeInsets.all(8),
                ),
                Container(
                  width: 100,
                  height: 100,
                  color: Colors.red,
                  margin: EdgeInsets.all(8),
                ),
              ],
            ),
          ),
          GridView.count(
            crossAxisCount: 2, //
            crossAxisSpacing: 12, // Yatay boşluk
            mainAxisSpacing: 12, // Dikey boşluk
            childAspectRatio:
                2.3, // Kartların en/boy oranı (Dikdörtgen olması için)
            shrinkWrap: true, // İçindeki elemanlar kadar yer kaplasın
            physics:
                const NeverScrollableScrollPhysics(), // Sayfanın kendi kaydırmasını kullansın
            padding: const EdgeInsets.all(10), // Kenar boşluğu
            children: [
              // KARTLAR
              Card(
                elevation: 4,
                // 1. ÖNEMLİ: Gradient köşelerden taşmasın diye bunu ekliyoruz
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  // 2. ADIM: Hazır gradient'i buraya veriyoruz
                  decoration: BoxDecoration(gradient: AppColors.cards),
                  child: InkWell(
                    onTap: () {
                      print("Otobüs Seferleri");
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(
                        0.0,
                      ), // İçerik biraz ferah dursun
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Arka plan renkli olduğu için ikon ve yazıyı beyaz yaptık
                          Icon(
                            Icons.directions_bus,
                            size: 30,
                            color: Colors.white,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Otobüs Seferleri",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Card(
                elevation: 4,
                // 1. ÖNEMLİ: Gradient köşelerden taşmasın diye bunu ekliyoruz
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  // 2. ADIM: Hazır gradient'i buraya veriyoruz
                  decoration: BoxDecoration(gradient: AppColors.cards),
                  child: InkWell(
                    onTap: () {
                      print("Otobüs Seferleri");
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(
                        0.0,
                      ), // İçerik biraz ferah dursun
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Arka plan renkli olduğu için ikon ve yazıyı beyaz yaptık
                          Icon(
                            Icons.directions_bus,
                            size: 30,
                            color: Colors.white,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Etkinlikler",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Card(
                elevation: 4,
                // 1. ÖNEMLİ: Gradient köşelerden taşmasın diye bunu ekliyoruz
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  // 2. ADIM: Hazır gradient'i buraya veriyoruz
                  decoration: BoxDecoration(gradient: AppColors.cards),
                  child: InkWell(
                    onTap: () {
                      print("Otobüs Seferleri");
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(
                        0.0,
                      ), // İçerik biraz ferah dursun
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Arka plan renkli olduğu için ikon ve yazıyı beyaz yaptık
                          Icon(
                            Icons.directions_bus,
                            size: 30,
                            color: Colors.white,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Nöbetçi Eczaneler",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Card(
                elevation: 4,
                // 1. ÖNEMLİ: Gradient köşelerden taşmasın diye bunu ekliyoruz
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  // 2. ADIM: Hazır gradient'i buraya veriyoruz
                  decoration: BoxDecoration(gradient: AppColors.cards),
                  child: InkWell(
                    onTap: () {
                      print("Otobüs Seferleri");
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(
                        0.0,
                      ), // İçerik biraz ferah dursun
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Arka plan renkli olduğu için ikon ve yazıyı beyaz yaptık
                          Icon(
                            Icons.directions_bus,
                            size: 30,
                            color: Colors.white,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Acil Numaralar",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
