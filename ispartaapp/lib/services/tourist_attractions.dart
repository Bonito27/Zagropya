import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Harita için
import 'package:ispartaapp/services/colors.dart'; // Renk dosyan

class TouristAttractions extends StatefulWidget {
  const TouristAttractions({super.key});

  @override
  State<TouristAttractions> createState() => _TouristAttractionsState();
}

class _TouristAttractionsState extends State<TouristAttractions> {
  // --- GEZİLECEK YERLER VERİTABANI ---
  // DİKKAT: Buradaki 'color', 'icon' ve 'needs' alanları yeni tasarım için şarttır.
  final List<Map<String, dynamic>> _places = [
    {
      "name": "Davraz Kayak Merkezi",
      "desc":
          "Akdeniz'in incisi. Kış sporları ve eşsiz Eğirdir Gölü manzarası eşliğinde kayak keyfi.",
      "location": "Davraz Kayak Merkezi Isparta",
      "icon": Icons.downhill_skiing,
      "color": Colors.cyan, // Kar/Buz rengi
      "needs": ["Kalın Mont", "Güneş Gözlüğü", "Kayak Eldiveni", "Yedek Çorap"],
    },
    {
      "name": "Kuyucak Lavanta Köyü",
      "desc":
          "Türkiye'nin lavanta cenneti. Temmuz ayında mor tarlalarda harika fotoğraflar çekin.",
      "location": "Kuyucak Köyü Keçiborlu Isparta",
      "icon": Icons.camera_alt,
      "color": Colors.purple, // Lavanta rengi
      "needs": ["Şapka", "Güneş Kremi", "Açık Renk Kıyafet", "Powerbank"],
    },
    {
      "name": "Eğirdir Gölü",
      "desc":
          "Yedi renkli göl. Altınkum plajında yüzebilir, Yeşilada'da balık yiyebilirsiniz.",
      "location": "Eğirdir Gölü Isparta",
      "icon": Icons.water,
      "color": Colors.blue, // Göl rengi
      "needs": ["Mayo & Havlu", "Güneş Kremi", "Kamp Sandalyesi", "Terlik"],
    },
    {
      "name": "Yazılı Kanyon",
      "desc":
          "Tarih ve doğanın buluştuğu yer. Turkuaz sularda serinleyin ve Kral Yolu'nda yürüyün.",
      "location": "Yazılı Kanyon Tabiat Parkı Isparta",
      "icon": Icons.landscape,
      "color": Colors.teal, // Doğa/Orman rengi
      "needs": ["Yürüyüş Ayakkabısı", "Sırt Çantası", "Su Matarası", "Mayo"],
    },
    {
      "name": "Gölcük Tabiat Parkı",
      "desc":
          "Şehir merkezine yakın, volkanik bir krater gölü. Sakin bir piknik ve yürüyüş için ideal.",
      "location": "Gölcük Tabiat Parkı Isparta",
      "icon": Icons.park,
      "color": Colors.green, // Orman rengi
      "needs": ["Piknik Örtüsü", "Atıştırmalıklar", "Termos", "Rahat Ayakkabı"],
    },
    {
      "name": "Zindan Mağarası",
      "desc":
          "765 metre uzunluğunda, içinden dere akan, Roma döneminden kalma köprüsüyle ünlü mağara.",
      "location": "Zindan Mağarası Aksu Isparta",
      "icon": Icons.flashlight_on,
      "color": Colors.brown, // Mağara/Toprak rengi
      "needs": [
        "El Feneri",
        "Kaymaz Ayakkabı",
        "İnce Hırka (Serin Olur)",
        "Su",
      ],
    },
    {
      "name": "Isparta Müzesi",
      "desc":
          "Bölgenin zengin arkeolojik ve etnografik geçmişine ışık tutan kapsamlı bir müze.",
      "location": "Isparta Müzesi",
      "icon": Icons.museum,
      "color": Colors.orange, // Tarih rengi
      "needs": ["Müze Kart", "Not Defteri", "Kulaklık (Sesli Rehber İçin)"],
    },
  ];

  // --- HARİTA AÇMA FONKSİYONU ---
  Future<void> _openMap(String locationName) async {
    final String query = Uri.encodeComponent(locationName);
    Uri googleMapsUrl = Uri.parse("google.navigation:q=$query");

    // Android/iOS uyumluluğu için kontrol
    if (!await canLaunchUrl(googleMapsUrl)) {
      googleMapsUrl = Uri.parse(
        "https://www.google.com/maps/dir/?api=1&destination=$query",
      );
    }

    try {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      print("Harita hatası: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harita uygulaması açılamadı.")),
      );
    }
  }

  // --- DETAY PENCERESİ (MODAL) ---
  void _showPlaceDetails(BuildContext context, Map<String, dynamic> place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Köşelerin oval durması için
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: const EdgeInsets.all(25),
          height: 550,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Kapatma Çizgisi (Görsel detay)
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 2. Başlık ve İkon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      // HATA ÇÖZÜMÜ: Eğer renk null gelirse varsayılan gri yap
                      color: (place['color'] ?? Colors.grey).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      place['icon'],
                      color: place['color'] ?? Colors.grey,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      place['name'],
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.texts,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 3. Açıklama
              const Text(
                "Hakkında",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                place['desc'],
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),

              // 4. Yanınızda Bulunsun Kısmı
              Row(
                children: [
                  Icon(
                    Icons.backpack_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Yanınızda Bulunsun",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (place['needs'] as List<String>).map((item) {
                  return Chip(
                    label: Text(item),
                    backgroundColor: Colors.grey[100],
                    avatar: const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.green,
                    ),
                    side: BorderSide.none,
                  );
                }).toList(),
              ),

              const Spacer(),

              // 5. Rota Butonu
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // Pencereyi kapat
                    _openMap(place['location']); // Haritayı aç
                  },
                  icon: const Icon(Icons.directions, color: Colors.white),
                  label: const Text(
                    "Rotayı Başlat",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        scrolledUnderElevation: 0.0,

        title: const Text("Gezilecek Yerler"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.texts,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: _places.length,
        itemBuilder: (context, index) {
          final place = _places[index];
          return _buildPlaceCard(place);
        },
      ),
    );
  }

  // --- LİSTE KARTI TASARIMI ---
  Widget _buildPlaceCard(Map<String, dynamic> place) {
    // Hata önlemek için renk kontrolü
    Color itemColor = place['color'] ?? Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => _showPlaceDetails(context, place), // Detayları aç
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              // Sol Taraftaki Renkli İkon Kutusu
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: itemColor.withOpacity(
                    0.15,
                  ), // Burada hata veriyordu, düzelttik
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(place['icon'], color: itemColor, size: 30),
              ),
              const SizedBox(width: 15),

              // Yazılar
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      place['desc'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              // Sağ Ok
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[300]),
            ],
          ),
        ),
      ),
    );
  }
}
