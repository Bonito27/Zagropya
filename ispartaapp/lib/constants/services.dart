import 'package:flutter/material.dart';
import 'package:ispartaapp/services/bus_services.dart';
import 'package:ispartaapp/services/colors.dart';

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
        backgroundColor: AppColors.bg,
        appBar: AppBar(title: const Text("Hizmetlerimiz")),
        body: Padding(
          padding: const EdgeInsets.all(15.0), // Kenar boşluğunu biraz artırdık
          child: Center(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 15, // Kartlar arası boşluk
              mainAxisSpacing: 15,
              // ÖNEMLİ: Bu değeri 2.8'den 1.1'e çektik.
              // Değer küçüldükçe kartın boyu uzar (Kareye yakın olur).
              childAspectRatio: 1.1,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildServiceCard(
                  title: "Otobüs Seferleri",
                  icon: Icons.directions_bus,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BusServices(),
                      ),
                    );
                  },
                ),
                _buildServiceCard(
                  title: "Etkinlikler",
                  icon: Icons.calendar_month,
                  onTap: () {},
                ),
                _buildServiceCard(
                  title: "Nöbetçi Eczaneler",
                  icon: Icons.local_pharmacy,
                  onTap: () {},
                ),
                _buildServiceCard(
                  title: "Acil Numaralar",
                  icon: Icons.phone_in_talk,
                  onTap: () {},
                ),
                _buildServiceCard(
                  title: "Gezilecek Yerler",
                  icon: Icons.map_outlined,
                  onTap: () {},
                ),
                _buildServiceCard(
                  title: "Arıza Bildir",
                  icon: Icons.build_circle,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    // İSTEĞİN ÜZERİNE GESTURE DETECTOR İLE SARMALADIM
    return GestureDetector(
      onTap: () {
        print("$title tıklandı"); // Konsola tıklandığını yazar
        onTap(); // Dışarıdan gelen fonksiyonu çalıştırır
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.cards, // Senin tanımladığın gradient
          borderRadius: BorderRadius.circular(20), // Köşeleri daha oval yaptık
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2), // Hafif gölge
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // İçeriği ortalar
          children: [
            // İkonu büyüttük ve çevreledik
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(
                  0.2,
                ), // İkonun arkasına hafif beyazlık
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 12), // İkon ile yazı arası boşluk
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16, // Yazı boyutunu artırdık
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
