import 'package:flutter/material.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text("Hizmetlerimiz")),
        body: Column(
          children: [
            GridView.count(
              crossAxisCount:
                  2, // Yan yana kaç tane sığsın? (Senin tasarımda 2)
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
                      print("1. Karta Tıklandı");
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.directions_bus, size: 30),
                        SizedBox(width: 10),
                        Text("1. Kart"),
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
                      print("2. Karta Tıklandı");
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.directions_bus, size: 30),
                        SizedBox(width: 10),
                        Text("2. Kart"),
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
                      print("3. Karta Tıklandı");
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.directions_bus, size: 30),
                        SizedBox(width: 10),
                        Text("3. Kart"),
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
                      print("4. Karta Tıklandı");
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.directions_bus, size: 30),
                        SizedBox(width: 10),
                        Text("4. Kart"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
