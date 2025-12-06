import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:ispartaapp/constants/profilepage.dart';
import 'package:ispartaapp/constants/services.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Color bg = HexColor('#F7F7F9');
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    MainPageContent(),
    ServicesPage(),
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
                icon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.red,
            onTap: _onItemTapped,
          ),
          backgroundColor: bg,
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
            crossAxisCount: 2, // Yan yana kaç tane sığsın? (Senin tasarımda 2)
            crossAxisSpacing: 12, // Yatay boşluk
            mainAxisSpacing: 12, // Dikey boşluk
            childAspectRatio:
                2.8, // Kartların en/boy oranı (Dikdörtgen olması için)
            shrinkWrap: true, // İçindeki elemanlar kadar yer kaplasın
            physics:
                const NeverScrollableScrollPhysics(), // Sayfanın kendi kaydırmasını kullansın
            padding: const EdgeInsets.all(10), // Kenar boşluğu
            children: [
              // KARTLAR
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(15),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () {
                    print("Otobüs Seferleri");
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_bus, size: 30),
                      SizedBox(width: 10),
                      Text("Otobüs Seferleri"),
                    ],
                  ),
                ),
              ),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(15),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () {
                    print("Etkinlikler");
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_bus, size: 30),
                      SizedBox(width: 10),
                      Text("Etkinlikler"),
                    ],
                  ),
                ),
              ),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(15),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () {
                    print("Acil Numaralar");
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_bus, size: 30),
                      SizedBox(width: 10),
                      Text("Acil Numaralar"),
                    ],
                  ),
                ),
              ),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(15),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () {
                    print("Nöbetçi Eczaneler");
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_bus, size: 30),
                      SizedBox(width: 10),
                      Text("Nöbetçi Eczaneler"),
                    ],
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
