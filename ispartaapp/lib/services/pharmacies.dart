import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

// ====================================================================
// 0. TEMA AYARLARI
// ====================================================================
class AppTheme {
  static const Color primary = Color(0xFF1565C0);
  static const Color background = Color(0xFFF5F7FA);
  static const Color textDark = Color(0xFF263238);
  static const Color textGrey = Color(0xFF78909C);
  static const Color pharmacyRed = Color(0xFFE53935); // Eczane kırmızısı
}

class Pharmacies extends StatefulWidget {
  const Pharmacies({super.key});

  @override
  State<Pharmacies> createState() => _PharmaciesState();
}

class _PharmaciesState extends State<Pharmacies> {
  List<dynamic> _allPharmacies = [];
  List<dynamic> _filteredPharmacies = [];
  List<String> _districts = ["Tümü"];
  String _selectedDistrict = "Tümü";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPharmacyData();
  }

  // --- 1. FIRESTORE'DAN VERİ ÇEKME ---
  Future<void> _loadPharmacyData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('eczaneler')
          .get();
      final List<dynamic> data = snapshot.docs
          .map((doc) => doc.data())
          .toList();

      Set<String> districtSet = {};
      for (var item in data) {
        if (item.containsKey('ilce') && item['ilce'] != null) {
          districtSet.add(item['ilce']);
        }
      }

      List<String> districtList = ["Tümü"];
      districtList.addAll(districtSet.toList()..sort());

      if (mounted) {
        setState(() {
          _allPharmacies = data;
          _filteredPharmacies = data;
          _districts = districtList;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Hata: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- 2. FİLTRELEME ---
  void _filterPharmacies(String district) {
    setState(() {
      _selectedDistrict = district;
      if (district == "Tümü") {
        _filteredPharmacies = _allPharmacies;
      } else {
        _filteredPharmacies = _allPharmacies
            .where((p) => p['ilce'] == district)
            .toList();
      }
    });
  }

  // --- 3. HARİTA VE ARAMA İŞLEMLERİ ---
  Future<void> _openMapRoute(String name, String district) async {
    final String query = Uri.encodeComponent(
      "$name Eczanesi $district Isparta",
    );
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

  Future<void> _callPharmacy(String phone) async {
    final String cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final Uri telUrl = Uri.parse("tel:$cleanPhone");
    try {
      await launchUrl(telUrl);
    } catch (e) {
      print("Arama hatası: $e");
    }
  }

  // Tarih Formatlayıcı
  String _getTodaysDate() {
    DateTime now = DateTime.now();
    List<String> months = [
      "Ocak",
      "Şubat",
      "Mart",
      "Nisan",
      "Mayıs",
      "Haziran",
      "Temmuz",
      "Ağustos",
      "Eylül",
      "Ekim",
      "Kasım",
      "Aralık",
    ];
    return "${now.day} ${months[now.month - 1]} ${now.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        title: const Text("Nöbetçi Eczaneler"),
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
      body: Column(
        children: [
          // --- TARİH BAŞLIĞI ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.pharmacyRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.calendar_today_rounded,
                    color: AppTheme.pharmacyRed,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTodaysDate(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const Text(
                      "Bugün nöbetçi olan eczaneler",
                      style: TextStyle(fontSize: 12, color: AppTheme.textGrey),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- İLÇE FİLTRESİ ---
          if (!_isLoading)
            Container(
              height: 50,
              margin: const EdgeInsets.only(bottom: 10),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                itemCount: _districts.length,
                itemBuilder: (context, index) {
                  final district = _districts[index];
                  final isSelected = district == _selectedDistrict;
                  return GestureDetector(
                    onTap: () => _filterPharmacies(district),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.pharmacyRed : Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.pharmacyRed
                              : Colors.grey.shade300,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppTheme.pharmacyRed.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        district,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.textGrey,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // --- LİSTE ---
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.pharmacyRed,
                    ),
                  )
                : _filteredPharmacies.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_off_rounded,
                          size: 60,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Bu bölgede nöbetçi eczane bulunamadı.",
                          style: TextStyle(color: AppTheme.textGrey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: _filteredPharmacies.length,
                    itemBuilder: (context, index) {
                      return _buildPharmacyCard(_filteredPharmacies[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // --- MODERN KART TASARIMI ---
  Widget _buildPharmacyCard(dynamic pharmacy) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Column(
        children: [
          // Üst Kısım: Bilgiler
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Eczane Logosu (E Harfi)
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.pharmacyRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      "E",
                      style: TextStyle(
                        color: AppTheme.pharmacyRed,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                // İsim ve Adres
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              pharmacy['eczane_adi'] ?? "Eczane",
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // İlçe Rozeti
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Text(
                              pharmacy['ilce'] ?? "",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        pharmacy['adres'] ?? "Adres bilgisi yok",
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textGrey,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Alt Kısım: Aksiyon Butonları (Gri Arka Planlı)
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                // Arama Butonu
                Expanded(
                  child: InkWell(
                    onTap: () => _callPharmacy(pharmacy['telefon'] ?? ""),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.phone_in_talk_rounded,
                          size: 18,
                          color: Colors.green,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Hemen Ara",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Dikey Çizgi
                Container(width: 1, height: 25, color: Colors.grey.shade300),
                // Yol Tarifi Butonu
                Expanded(
                  child: InkWell(
                    onTap: () => _openMapRoute(
                      pharmacy['eczane_adi'] ?? "",
                      pharmacy['ilce'] ?? "",
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.directions_rounded,
                          size: 20,
                          color: AppTheme.pharmacyRed,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Yol Tarifi",
                          style: TextStyle(
                            color: AppTheme.pharmacyRed,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
