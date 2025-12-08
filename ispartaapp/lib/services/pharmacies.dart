import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // JSON okumak için
import 'package:url_launcher/url_launcher.dart'; // Harita ve Telefon için
import 'package:ispartaapp/services/colors.dart'; // Renk dosyan

class Pharmacies extends StatefulWidget {
  const Pharmacies({super.key});

  @override
  State<Pharmacies> createState() => _PharmaciesState();
}

class _PharmaciesState extends State<Pharmacies> {
  List<dynamic> _allPharmacies = []; // Tüm liste
  List<dynamic> _filteredPharmacies =
      []; // Ekranda gösterilen (filtrelenmiş) liste
  List<String> _districts = ["Tümü"]; // İlçe listesi
  String _selectedDistrict = "Tümü"; // Seçili filtre
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPharmacyData();
  }

  // --- 1. FIRESTORE'DAN VERİ ÇEKME VE ANALİZ ---
  Future<void> _loadPharmacyData() async {
    try {
      // 1. Firestore'dan Veri Çek
      // Botumuz veriyi 'eczaneler' koleksiyonuna yazıyordu.
      final snapshot = await FirebaseFirestore.instance
          .collection('eczaneler')
          .get(); // Tüm dökümanları çek

      // Dökümanları List<Map> formatına çevir
      final List<dynamic> data = snapshot.docs
          .map((doc) => doc.data())
          .toList();

      // İlçeleri analiz et (Tekrarları önlemek için Set kullanıyoruz)
      Set<String> districtSet = {};
      for (var item in data) {
        // Data içindeki 'ilce' alanının varlığını ve null olmadığını kontrol et
        if (item.containsKey('ilce') && item['ilce'] != null) {
          districtSet.add(item['ilce']);
        }
      }

      // Listeyi oluştur: Önce "Tümü", sonra alfabetik ilçeler
      List<String> districtList = ["Tümü"];
      districtList.addAll(districtSet.toList()..sort());

      print("✅ Firestore Eczane Bağlantısı Başarılı!");
      print("Toplam Eczane: ${data.length}");

      setState(() {
        _allPharmacies = data;
        _filteredPharmacies = data; // Başlangıçta hepsi görünsün
        _districts = districtList;
        _isLoading = false;
      });
    } catch (e) {
      print("🚨 HATA: Firestore Eczane Verisi okunamadı! -> $e");
      // Hata durumunda yüklemeyi durdur ve kullanıcıyı bilgilendir
      setState(() {
        _isLoading = false;
        // İsteğe bağlı olarak bir uyarı mesajı (Snackbar) gösterilebilir.
      });
    }
  }

  // --- 2. FİLTRELEME FONKSİYONU ---
  void _filterPharmacies(String district) {
    setState(() {
      _selectedDistrict = district;
      if (district == "Tümü") {
        _filteredPharmacies = _allPharmacies;
      } else {
        _filteredPharmacies = _allPharmacies
            .where((pharmacy) => pharmacy['ilce'] == district)
            .toList();
      }
    });
  }

  // --- 3. DİREKT ROTA OLUŞTURMA ---
  Future<void> _openMapRoute(String name, String district) async {
    // Sadece adres yerine "Eczane Adı + İlçe + Isparta" şeklinde aratmak
    // Google Maps'in nokta atışı yapmasını ve direkt işletmeyi bulmasını sağlar.
    final String query = Uri.encodeComponent(
      "$name Eczanesi $district Isparta",
    );

    // 'google.navigation:q=' kodu direkt Navigasyon modunu başlatır.
    Uri googleMapsUrl = Uri.parse("google.navigation:q=$query");

    // Eğer Android değilse veya bu şema çalışmazsa web linkine düş
    if (!await canLaunchUrl(googleMapsUrl)) {
      googleMapsUrl = Uri.parse(
        "https://www.google.com/maps/dir/?api=1&destination=$query",
      );
    }

    try {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      print("Harita açılamadı: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harita uygulaması başlatılamadı.")),
      );
    }
  }

  // --- 4. TELEFON ARAMA ---
  Future<void> _callPharmacy(String phone) async {
    final String cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final Uri telUrl = Uri.parse("tel:$cleanPhone");
    try {
      await launchUrl(telUrl);
    } catch (e) {
      print("Arama yapılamadı: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        scrolledUnderElevation: 0.0,

        title: const Text("Nöbetçi Eczaneler"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.texts,
      ),
      body: Column(
        children: [
          // --- YATAY İLÇE FİLTRESİ ---
          if (!_isLoading)
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                itemCount: _districts.length,
                itemBuilder: (context, index) {
                  final district = _districts[index];
                  final isSelected = district == _selectedDistrict;
                  return GestureDetector(
                    onTap: () => _filterPharmacies(district),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.grey.shade300,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          district,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // --- ECZANE LİSTESİ ---
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPharmacies.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_off,
                          size: 60,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Bu ilçede nöbetçi eczane bulunamadı.",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: _filteredPharmacies.length,
                    itemBuilder: (context, index) {
                      final pharmacy = _filteredPharmacies[index];
                      return _buildPharmacyCard(pharmacy);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // --- KART TASARIMI ---
  Widget _buildPharmacyCard(dynamic pharmacy) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          // Karta basınca direkt rota oluştur
          _openMapRoute(pharmacy['eczane_adi'], pharmacy['ilce']);
        },
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst Kısım: İkon + İsim + İlçe
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_pharmacy,
                      color: Colors.red,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pharmacy['eczane_adi'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            pharmacy['ilce'], // Burada ilçe yazıyor
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Arama Butonu
                  IconButton(
                    icon: const Icon(Icons.call, color: Colors.green),
                    onPressed: () {
                      _callPharmacy(pharmacy['telefon']);
                    },
                  ),
                ],
              ),
              const Divider(height: 20),

              // Alt Kısım: Adres
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 20,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      pharmacy['adres'],
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Rota Butonu
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.directions, size: 20, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      "Yol Tarifi Başlat",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
