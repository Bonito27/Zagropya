import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ispartaapp/services/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Events extends StatefulWidget {
  const Events({super.key});

  @override
  State<Events> createState() => _EventsState();
}

class _EventsState extends State<Events> {
  // Veri tipleri artık Map<String, dynamic> olarak daha spesifik tanımlandı.
  List<Map<String, dynamic>> _allEvents = [];
  List<Map<String, dynamic>> _filteredEvents = [];

  List<String> _uniqueArtists = [];
  String? _selectedArtistFilter;

  final TextEditingController _searchController = TextEditingController();
  // RangeValues başlangıçta 0'dan başlar.
  RangeValues _currentPriceRange = const RangeValues(0, 2000);
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadEventData();
    // Arama kutusunun değeri değiştikçe filtrelemeyi tetikle
    _searchController.addListener(_runFilter);
  }

  @override
  void dispose() {
    _searchController.removeListener(_runFilter);
    _searchController.dispose();
    super.dispose();
  }

  // --- 1. FIRESTORE'DAN VERİ ÇEKME VE ANALİZ (GÜVENLİ ERİŞİM EKLENDİ) ---
  Future<void> _loadEventData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('etkinlikler')
          .get();

      final List<Map<String, dynamic>> data = snapshot.docs
          .map((doc) => doc.data())
          .toList();

      // 🔥 Hata ayıklama için ilk veriyi konsola yazdırın
      if (data.isNotEmpty) {
        print("✅ İlk Etkinlik Verisi: ${data[0]}");
      }

      final Set<String> artistsSet = {};

      for (var event in data) {
        // Güvenli erişim: Alan var mı ve null değil mi?
        if (event.containsKey('sanatci') && event['sanatci'] is String) {
          String artistName = event['sanatci'].toString().trim();
          if (artistName.isNotEmpty) {
            artistsSet.add(artistName);
          }
        }
      }

      List<String> sortedArtists = artistsSet.toList()..sort();

      print("✅ Firestore Bağlantısı Başarılı! Toplam Etkinlik: ${data.length}");

      setState(() {
        _allEvents = data;
        _filteredEvents = data; // Başlangıçta tüm veriyi göster
        _uniqueArtists = sortedArtists;
      });
    } catch (e) {
      print("🚨 KRİTİK HATA: Firestore verisi okunamadı! -> $e");
      // Hata durumunda boş liste gösterilir
      setState(() {
        _allEvents = [];
        _filteredEvents = [];
      });
    }
  }

  // --- 2. FİLTRELEME MANTIĞI (GÜVENLİ ERİŞİM VE FİLTRE GÜNCELLEMESİ) ---
  void _runFilter() {
    List<Map<String, dynamic>> results = _allEvents;

    // A. Metin Arama
    if (_searchController.text.isNotEmpty) {
      final lowerSearch = _searchController.text.toLowerCase();
      results = results.where((event) {
        // Güvenli erişim ile sanatçı veya mekan metinlerini ara
        final artist = (event["sanatci"]?.toString() ?? '').toLowerCase();
        final venue = (event["mekan"]?.toString() ?? '').toLowerCase();
        return artist.contains(lowerSearch) || venue.contains(lowerSearch);
      }).toList();
    }

    // B. Sanatçı Seçimi
    if (_selectedArtistFilter != null) {
      results = results
          .where((event) => event["sanatci"] == _selectedArtistFilter)
          .toList();
    }

    // C. Fiyat Filtresi (Fiyat alanı eksikse/null ise 0 olarak kabul edilir)
    results = results.where((event) {
      final priceValue = event["fiyat"]?.toString() ?? '0';
      // Sadece rakamları ayıkla
      String priceStr = priceValue.replaceAll(RegExp(r'[^0-9]'), '');
      // Sayıya çevir, çevrilemezse 0 kabul et
      int price = int.tryParse(priceStr) ?? 0;

      return price >= _currentPriceRange.start &&
          price <= _currentPriceRange.end;
    }).toList();

    // D. Tarih Filtresi (Sadece gün numarasını aratma mantığı korunmuştur)
    if (_selectedDate != null) {
      String day = _selectedDate!.day.toString();
      results = results
          .where((event) => (event['tarih']?.toString() ?? '').startsWith(day))
          .toList();
    }

    setState(() {
      _filteredEvents = results;
    });
  }

  // --- 3. İNTERNET ARAMASI ---
  Future<void> _searchOnGoogle(String artist, String venue) async {
    final String query = "$artist $venue bilet";
    final Uri url = Uri.parse(
      "https://www.google.com/search?q=${Uri.encodeComponent(query)}",
    );
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Arama bağlantısı açılamadı.')),
        );
      }
    }
  }

  // --- 4. GELİŞMİŞ FİLTRE MODALI (Aynı kaldı) ---
  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                height: 550,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Filtreleme Seçenekleri",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Filtreleri Sıfırla
                            setState(() {
                              _currentPriceRange = const RangeValues(0, 2000);
                              _selectedArtistFilter = null;
                              _selectedDate = null;
                              _searchController.clear();
                              _runFilter();
                            });
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Temizle",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 10),

                    // 1. Sanatçı Seçimi (Dropdown)
                    const Text(
                      "Sanatçı Seç",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedArtistFilter,
                          hint: const Text("Tüm Sanatçılar"),
                          isExpanded: true,
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text("Tüm Sanatçılar"),
                            ),
                            // Sanatçı listesi boşsa hata vermez
                            ..._uniqueArtists.map((artist) {
                              return DropdownMenuItem(
                                value: artist,
                                child: Text(artist),
                              );
                            }).toList(),
                          ],
                          onChanged: (value) {
                            setModalState(() {
                              _selectedArtistFilter = value;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 2. Fiyat Aralığı
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Fiyat Aralığı",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          "${_currentPriceRange.start.round()} - ${_currentPriceRange.end.round()} TL",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    RangeSlider(
                      values: _currentPriceRange,
                      min: 0,
                      max: 2000,
                      divisions: 40,
                      activeColor: AppColors.primary,
                      onChanged: (RangeValues values) {
                        setModalState(() {
                          _currentPriceRange = values;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    // 3. Tarih Seçimi
                    const Text(
                      "Tarih (Opsiyonel)",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          _selectedDate == null
                              ? "Tarih Seçiniz"
                              : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2026),
                          );
                          if (picked != null) {
                            setModalState(() {
                              _selectedDate = picked;
                            });
                          }
                        },
                      ),
                    ),

                    const Spacer(),

                    // Uygula Butonu
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          _runFilter();
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Sonuçları Göster",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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
        title: const Text("Isparta Etkinlikleri"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.texts,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // GELİŞMİŞ ARAMA ÇUBUĞU
            TextField(
              controller: _searchController,
              // onChanged: (value) => _runFilter(), // Listener eklediğimiz için bu satırı kaldırdık
              decoration: InputDecoration(
                hintText: 'Etkinlik ara...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          (_selectedArtistFilter != null ||
                              _selectedDate != null)
                          ? AppColors.primary.withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.tune, color: AppColors.primary),
                  ),
                  onPressed: _showFilterModal,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            // Aktif Filtre Bilgisi (Sanatçı)
            if (_selectedArtistFilter != null)
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 5),
                child: Row(
                  children: [
                    const Text(
                      "Seçilen Sanatçı: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: Chip(
                        label: Text(_selectedArtistFilter!),
                        onDeleted: () {
                          setState(() {
                            _selectedArtistFilter = null;
                            _runFilter();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 15),

            // Etkinlik Listesi
            Expanded(
              child: _filteredEvents.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            // Kullanıcı bir şey arıyorsa daha spesifik mesaj göster
                            _allEvents.isEmpty
                                ? "Veritabanında hiç etkinlik yok."
                                : "Aradığınız kriterlere uygun etkinlik yok.",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredEvents.length,
                      itemBuilder: (context, index) {
                        final event = _filteredEvents[index];
                        return _buildEventCard(event);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // --- KART TASARIMI (GÜVENLİ ERİŞİM EKLENDİ) ---
  Widget _buildEventCard(Map<String, dynamic> event) {
    // 🔥 Güvenli Erişim
    final String artist = event['sanatci']?.toString() ?? 'Bilinmiyor';
    final String venue = event['mekan']?.toString() ?? 'Mekan Yok';
    final String date = event['tarih']?.toString() ?? 'Tarih Yok';
    final String fiyat = event['fiyat']?.toString() ?? 'Ücretsiz/Bilinmiyor';
    final String imageUrl = event['resim']?.toString() ?? '';

    return GestureDetector(
      onTap: () {
        _searchOnGoogle(artist, venue);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 180,
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image, // Resim yüklenemedi ikonu
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          height: 180,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                ),
                // Fiyat Etiketi (Resmin üzerinde sağ üstte)
                Positioned(
                  top: 15,
                  right: 15,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      fiyat, // Güvenli değişkenden çekildi
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date, // Güvenli değişkenden çekildi
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    artist, // Güvenli değişkenden çekildi
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          venue, // Güvenli değişkenden çekildi
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
