import 'package:flutter/material.dart';
import 'package:ispartaapp/services/bus_services.dart';
import 'package:ispartaapp/services/emergy_numbers.dart';
import 'package:ispartaapp/services/events.dart';
import 'package:ispartaapp/services/pharmacies.dart';
import 'package:ispartaapp/services/tourist_attractions.dart';
import 'package:url_launcher/url_launcher.dart';

// ====================================================================
// 0. TEMA AYARLARI (Tasarım Bütünlüğü İçin)
// ====================================================================
class AppTheme {
  static const Color background = Color(0xFFF5F7FA); // Modern Gri Zemin
  static const Color textDark = Color(0xFF263238);
}

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
        backgroundColor: AppTheme.background, // Yeni zemin rengi
        body: Column(
          children: [
            // --- Başlık Alanı ---
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              alignment: Alignment.centerLeft,
              child: const Text(
                "Hizmetler",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ),

            // --- Grid Menü ---
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                crossAxisCount: 2, // Yan yana 2 kutu
                crossAxisSpacing: 15, // Yatay boşluk
                mainAxisSpacing: 15, // Dikey boşluk
                childAspectRatio: 1.2, // Kart oranı (Genişlik/Yükseklik)
                children: [
                  // 1. OTOBÜS
                  _buildServiceCard(
                    title: "Otobüs Seferleri",
                    icon: Icons.directions_bus_rounded,
                    color: Colors.blueAccent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BusServices(),
                        ),
                      );
                    },
                  ),
                  // 2. ETKİNLİKLER
                  _buildServiceCard(
                    title: "Etkinlikler",
                    icon: Icons.confirmation_number_rounded,
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Events()),
                      );
                    },
                  ),
                  // 3. ECZANELER
                  _buildServiceCard(
                    title: "Nöbetçi Eczaneler",
                    icon: Icons.local_pharmacy_rounded,
                    color: Colors.redAccent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Pharmacies(),
                        ),
                      );
                    },
                  ),
                  // 4. ACİL NUMARALAR
                  _buildServiceCard(
                    title: "Acil Numaralar",
                    icon: Icons.phone_in_talk_rounded,
                    color: Colors.red[800]!,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EmergyNumbers(),
                        ),
                      );
                    },
                  ),
                  // 5. GEZİLECEK YERLER
                  _buildServiceCard(
                    title: "Gezilecek Yerler",
                    icon: Icons.map_rounded,
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TouristAttractions(),
                        ),
                      );
                    },
                  ),
                  // 6. WHATSAPP (ARIZA/TALEP)
                  _buildServiceCard(
                    title: "Arıza/Talep Bildir",
                    icon: Icons.support_agent_rounded,
                    color: const Color(0xFF25D366), // WhatsApp Yeşili
                    onTap: () {
                      _openWhatsApp();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WhatsApp Fonksiyonu (Aynen Korundu) ---
  Future<void> _openWhatsApp() async {
    String phoneNumber = "905397217332";
    String message = "Merhaba, bilgi almak istiyorum.";

    final Uri url = Uri.parse(
      "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}",
    );

    try {
      bool launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw 'Uygulama başlatılamadı';
      }
    } catch (e) {
      await launchUrl(url, mode: LaunchMode.platformDefault);
    }
  }

  // --- YENİ KART TASARIMI (BEYAZ KART + RENKLİ İKON) ---
  Widget _buildServiceCard({
    required String title,
    required IconData icon,
    required Color color, // Kartın tema rengi
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        print("$title tıklandı");
        onTap();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Beyaz zemin
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04), // Hafif modern gölge
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // İkon Kutusu
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1), // Rengin %10 saydam hali
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color), // İkon rengi
            ),
            const SizedBox(height: 15),
            // Başlık
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.textDark, // Koyu gri yazı
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
