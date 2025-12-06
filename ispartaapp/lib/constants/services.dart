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
                      print("Arıza Bildirim / Talep");
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.directions_bus, size: 30),
                        SizedBox(width: 10),
                        Text("Arıza Bildirim / Talep"),
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
                      print("Yeşil alanlar");
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.directions_bus, size: 30),
                        SizedBox(width: 10),
                        Text("Yeşil alanlar"),
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
