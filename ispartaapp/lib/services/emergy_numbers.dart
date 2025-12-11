import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// ====================================================================
// 0. TEMA AYARLARI
// ====================================================================
class AppTheme {
  static const Color primary = Color(0xFF1565C0);
  static const Color background = Color(0xFFF5F7FA);
  static const Color textDark = Color(0xFF263238);
  static const Color textGrey = Color(0xFF78909C);
}

class EmergyNumbers extends StatefulWidget {
  const EmergyNumbers({super.key});

  @override
  State<EmergyNumbers> createState() => _EmergyNumbersState();
}

class _EmergyNumbersState extends State<EmergyNumbers> {
  // --- TELEFON ARAMA FONKSİYONU ---
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      await launchUrl(launchUri);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Arama başlatılamadı.")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        title: const Text("Acil Numaralar"),
        centerTitle: true,
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // --- 1. HERO KART: 112 ACİL ---
            GestureDetector(
              onTap: () => _makePhoneCall("112"),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade700, Colors.red.shade500],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Numara Yuvarlağı
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        "112",
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w900,
                          fontSize: 26,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Metinler
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "TEK ACİL ÇAĞRI",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Polis • Ambulans • İtfaiye\nJandarma • AFAD",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Arama İkonu
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.phone_in_talk,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Başlık
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Diğer Hizmet Numaraları",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ),

            const SizedBox(height: 15),

            // --- 2. GRID KARTLAR ---
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.3, // Kartlar biraz daha yatay olsun
                padding: const EdgeInsets.only(bottom: 20),
                children: [
                  _buildEmergencyCard(
                    title: "Doğalgaz Acil",
                    number: "187",
                    icon: Icons.local_fire_department_rounded,
                    color: Colors.orange,
                  ),
                  _buildEmergencyCard(
                    title: "Elektrik Arıza",
                    number: "186",
                    icon: Icons.electric_bolt_rounded,
                    color: Colors.amber.shade700,
                  ),
                  _buildEmergencyCard(
                    title: "Su Arıza",
                    number: "185",
                    icon: Icons.water_drop_rounded,
                    color: Colors.blue,
                  ),
                  _buildEmergencyCard(
                    title: "Belediye / Zabıta",
                    subtitle: "Beyaz Masa",
                    number: "153",
                    icon: Icons.location_city_rounded,
                    color: Colors.blueGrey,
                  ),
                  _buildEmergencyCard(
                    title: "Zehir Danışma",
                    number: "114",
                    icon: Icons.health_and_safety_rounded,
                    color: Colors.purple,
                  ),
                  _buildEmergencyCard(
                    title: "Cenaze Hizmetleri",
                    number: "188",
                    icon: Icons.volunteer_activism_rounded,
                    color: Colors.teal,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- MODERN KART TASARIMI ---
  Widget _buildEmergencyCard({
    required String title,
    required String number,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return GestureDetector(
      onTap: () => _makePhoneCall(number),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // İkon ve Numara Satırı
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 10),
                Text(
                  number,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    color: color,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Başlık
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppTheme.textDark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Alt Başlık (Varsa)
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textGrey,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
