import 'package:flutter/material.dart';
import 'package:ispartaapp/services/bus_services.dart';
import 'package:ispartaapp/services/colors.dart';
import 'package:ispartaapp/services/emergy_numbers.dart';
import 'package:ispartaapp/services/events.dart';
import 'package:ispartaapp/services/pharmacies.dart';
import 'package:ispartaapp/services/tourist_attractions.dart';
import 'package:url_launcher/url_launcher.dart';

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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Events()),
                    );
                  },
                ),
                _buildServiceCard(
                  title: "Nöbetçi Eczaneler",
                  icon: Icons.local_pharmacy,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Pharmacies(),
                      ),
                    );
                  },
                ),
                _buildServiceCard(
                  title: "Acil Numaralar",
                  icon: Icons.phone_in_talk,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EmergyNumbers(),
                      ),
                    );
                  },
                ),
                _buildServiceCard(
                  title: "Gezilecek Yerler",
                  icon: Icons.map_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TouristAttractions(),
                      ),
                    );
                  },
                ),
                _buildServiceCard(
                  title: "Arıza/Talep  Bildir",
                  icon: Icons.build_circle,
                  onTap: () {
                    _openWhatsApp(); // <--
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Güncellenmiş ve Garantili WhatsApp Fonksiyonu
  Future<void> _openWhatsApp() async {
    // Numara formatı: 90 + 539... (Başında 0 olmadan, boşluksuz)
    String phoneNumber = "905397217332";
    String message = "Merhaba, bilgi almak istiyorum.";

    // 1. Evrensel Link Oluştur (Hem uygulama hem tarayıcı anlar)
    final Uri url = Uri.parse(
      "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}",
    );

    try {
      // 2. Önce Direkt Uygulamayı (WhatsApp) Açmayı Dene
      // 'externalApplication': İşletim sistemine bu linki bir uygulama ile açmasını emreder.
      bool launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        // Eğer false dönerse hata fırlat ki aşağıdaki catch bloğuna düşsün
        throw 'Uygulama başlatılamadı';
      }
    } catch (e) {
      // 3. Hata Oluşursa (Uygulama yoksa) Tarayıcıda Aç

      // 'platformDefault': İşletim sisteminin varsayılan davranışını (Tarayıcıyı) kullanır.
      await launchUrl(url, mode: LaunchMode.platformDefault);
    }
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
