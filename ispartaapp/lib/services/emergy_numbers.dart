import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Arama yapmak için
import 'package:ispartaapp/services/colors.dart'; // Renk dosyan

class EmergyNumbers extends StatefulWidget {
  const EmergyNumbers({super.key});

  @override
  State<EmergyNumbers> createState() => _EmergyNumbersState();
}

class _EmergyNumbersState extends State<EmergyNumbers> {
  // --- TELEFON ARAMA FONKSİYONU (GÜNCELLENDİ) ---
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);

    try {
      // canLaunchUrl kontrolünü atlayıp direkt deniyoruz.
      // Bu yöntem Android 11+ ve emülatörlerde daha kararlı çalışır.
      await launchUrl(launchUri);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Arama başlatılamadı.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text("Acil Numaralar"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.texts,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            const Text(
              "Tıklayarak doğrudan arama yapabilirsiniz.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 15),

            // --- 1. EN ÖNEMLİ: TEK ACİL ÇAĞRI (112) ---
            // Tıklanma özelliği burada GestureDetector ile sağlanıyor
            GestureDetector(
              onTap: () => _makePhoneCall("112"),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red[600], // Acil durum kırmızısı
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Sol Taraf: Büyük 112 Yazısı
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        "112",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w900,
                          fontSize: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Sağ Taraf: Açıklamalar
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "TEK ACİL ÇAĞRI",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Ambulans • Polis • İtfaiye\nJandarma • AFAD • Orman",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.call, color: Colors.white, size: 30),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // --- 2. DİĞER ÖNEMLİ NUMARALAR (GRID) ---
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.1, // Taşma olmaması için oranı düzelttim
                children: [
                  _buildEmergencyCard(
                    title: "Doğalgaz Acil",
                    number: "187",
                    icon: Icons.fire_extinguisher,
                    color: Colors.orange,
                  ),
                  _buildEmergencyCard(
                    title: "Elektrik Arıza",
                    number: "186",
                    icon: Icons.electric_bolt,
                    color: Colors.yellow[700]!,
                  ),
                  _buildEmergencyCard(
                    title: "Su Arıza",
                    number: "185",
                    icon: Icons.water_drop,
                    color: Colors.blue,
                  ),
                  _buildEmergencyCard(
                    title: "Belediye / Zabıta",
                    subtitle: "Beyaz Masa",
                    number: "153",
                    icon: Icons.location_city,
                    color: Colors.blueGrey,
                  ),
                  _buildEmergencyCard(
                    title: "Zehir Danışma",
                    number: "114",
                    icon: Icons.warning_amber_rounded,
                    color: Colors.purple,
                  ),
                  _buildEmergencyCard(
                    title: "Cenaze Hizmetleri",
                    number: "188",
                    icon: Icons.volunteer_activism,
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- KART TASARIMI ---
  // Her kartı burada üretiyoruz ve hepsine GestureDetector ekliyoruz
  Widget _buildEmergencyCard({
    required String title,
    required String number,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    // BURASI ÖNEMLİ: Her kartı sarmalayan tıklama algılayıcı
    return GestureDetector(
      onTap: () => _makePhoneCall(number),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // İkon Kutusu
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 10),

            // Başlık
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1, // Taşmayı önlemek için
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.texts,
              ),
            ),

            // Varsa Alt Başlık
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),

            const SizedBox(height: 5),

            // Numara
            Text(
              number,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 22,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
