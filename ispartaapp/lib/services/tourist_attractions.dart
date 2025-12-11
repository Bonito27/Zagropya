import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// ====================================================================
// 0. TEMA AYARLARI
// ====================================================================
class AppTheme {
  static const Color primary = Color(0xFF1565C0);
  static const Color secondary = Color(0xFFFF6F00);
  static const Color background = Color(0xFFF5F7FA);
  static const Color textDark = Color(0xFF263238);
  static const Color textGrey = Color(0xFF78909C);
}

class TouristAttractions extends StatefulWidget {
  const TouristAttractions({super.key});

  @override
  State<TouristAttractions> createState() => _TouristAttractionsState();
}

class _TouristAttractionsState extends State<TouristAttractions> {
  // --- GEZİLECEK YERLER VERİTABANI ---
  final List<Map<String, dynamic>> _places = [
    {
      "name": "Davraz Kayak Merkezi",
      "desc":
          "Akdeniz'in incisi. Kış sporları ve eşsiz Eğirdir Gölü manzarası eşliğinde kayak keyfi.",
      "location": "Davraz Kayak Merkezi Isparta",
      "icon": Icons.downhill_skiing,
      "color": Colors.cyan,
      "needs": ["Kalın Mont", "Güneş Gözlüğü", "Kayak Eldiveni", "Yedek Çorap"],
    },
    {
      "name": "Kuyucak Lavanta Köyü",
      "desc":
          "Türkiye'nin lavanta cenneti. Temmuz ayında mor tarlalarda harika fotoğraflar çekin.",
      "location": "Kuyucak Köyü Keçiborlu Isparta",
      "icon": Icons.camera_alt_rounded,
      "color": Colors.purple,
      "needs": ["Şapka", "Güneş Kremi", "Açık Renk Kıyafet", "Powerbank"],
    },
    {
      "name": "Eğirdir Gölü",
      "desc":
          "Yedi renkli göl. Altınkum plajında yüzebilir, Yeşilada'da balık yiyebilirsiniz.",
      "location": "Eğirdir Gölü Isparta",
      "icon": Icons.water_rounded,
      "color": Colors.blue,
      "needs": ["Mayo & Havlu", "Güneş Kremi", "Kamp Sandalyesi", "Terlik"],
    },
    {
      "name": "Yazılı Kanyon",
      "desc":
          "Tarih ve doğanın buluştuğu yer. Turkuaz sularda serinleyin ve Kral Yolu'nda yürüyün.",
      "location": "Yazılı Kanyon Tabiat Parkı Isparta",
      "icon": Icons.landscape_rounded,
      "color": Colors.teal,
      "needs": ["Yürüyüş Ayakkabısı", "Sırt Çantası", "Su Matarası", "Mayo"],
    },
    {
      "name": "Gölcük Tabiat Parkı",
      "desc":
          "Şehir merkezine yakın, volkanik bir krater gölü. Sakin bir piknik ve yürüyüş için ideal.",
      "location": "Gölcük Tabiat Parkı Isparta",
      "icon": Icons.park_rounded,
      "color": Colors.green,
      "needs": ["Piknik Örtüsü", "Atıştırmalıklar", "Termos", "Rahat Ayakkabı"],
    },
    {
      "name": "Zindan Mağarası",
      "desc":
          "765 metre uzunluğunda, içinden dere akan, Roma döneminden kalma köprüsüyle ünlü mağara.",
      "location": "Zindan Mağarası Aksu Isparta",
      "icon": Icons.flashlight_on_rounded,
      "color": Colors.brown,
      "needs": ["El Feneri", "Kaymaz Ayakkabı", "İnce Hırka", "Su"],
    },
    {
      "name": "Isparta Müzesi",
      "desc":
          "Bölgenin zengin arkeolojik ve etnografik geçmişine ışık tutan kapsamlı bir müze.",
      "location": "Isparta Müzesi",
      "icon": Icons.museum_rounded,
      "color": Colors.orange,
      "needs": ["Müze Kart", "Not Defteri", "Kulaklık"],
    },
  ];

  // --- HARİTA AÇMA ---
  Future<void> _openMap(String locationName) async {
    final String query = Uri.encodeComponent(locationName);
    Uri googleMapsUrl = Uri.parse("google.navigation:q=$query");

    if (!await canLaunchUrl(googleMapsUrl)) {
      googleMapsUrl = Uri.parse(
        "http://googleusercontent.com/maps.google.com/maps?q=$query",
      );
    }

    try {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Harita açılamadı.")));
    }
  }

  // --- DETAY PENCERESİ (MODAL) ---
  void _showPlaceDetails(BuildContext context, Map<String, dynamic> place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(25),
          child: Wrap(
            // İçerik kadar yükseklik
            children: [
              // Kapatma Çizgisi
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Başlık ve İkon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (place['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(place['icon'], color: place['color'], size: 32),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      place['name'],
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Açıklama
              Text(
                place['desc'],
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 25),

              // Yanınızda Bulunsun
              if (place['needs'] != null) ...[
                Row(
                  children: [
                    const Icon(
                      Icons.backpack_outlined,
                      size: 20,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Yanınızda Bulunsun",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (place['needs'] as List<String>).map((item) {
                    return Chip(
                      label: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textDark,
                        ),
                      ),
                      backgroundColor: AppTheme.background,
                      avatar: const Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: Colors.green,
                      ),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 30),
              ],

              // Rota Butonu
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _openMap(place['location']);
                  },
                  icon: const Icon(
                    Icons.directions_rounded,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Rotayı Başlat",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    shadowColor: AppTheme.primary.withOpacity(0.3),
                  ),
                ),
              ),
              const SizedBox(height: 20), // Alt boşluk
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        title: const Text("Gezilecek Yerler"),
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
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: _places.length,
        itemBuilder: (context, index) {
          return _buildPlaceCard(_places[index]);
        },
      ),
    );
  }

  // --- MODERN KART TASARIMI ---
  Widget _buildPlaceCard(Map<String, dynamic> place) {
    Color itemColor = place['color'] ?? Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showPlaceDetails(context, place),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // İkon Kutusu
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: itemColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(place['icon'], color: itemColor, size: 30),
                ),
                const SizedBox(width: 16),

                // Metinler
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place['name'],
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        place['desc'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textGrey,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

                // Ok İkonu
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Color(0xFFCFD8DC),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
