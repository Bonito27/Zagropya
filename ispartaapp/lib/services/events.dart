import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ====================================================================
// 0. TEMA AYARLARI
// ====================================================================
class AppTheme {
  static const Color primary = Color(0xFF1565C0); // Şehir Mavisi
  static const Color secondary = Color(0xFFFF6F00); // Enerjik Turuncu
  static const Color background = Color(0xFFF5F7FA); // Modern Gri Zemin
  static const Color textDark = Color(0xFF263238);
  static const Color textGrey = Color(0xFF78909C);
  static const Color surface = Colors.white;
}

class Events extends StatefulWidget {
  const Events({super.key});

  @override
  State<Events> createState() => _EventsState();
}

class _EventsState extends State<Events> {
  // Veri Değişkenleri
  List<Map<String, dynamic>> _allEvents = [];
  List<Map<String, dynamic>> _filteredEvents = [];
  List<String> _uniqueArtists = [];

  // Filtre Değişkenleri
  String? _selectedArtistFilter;
  final TextEditingController _searchController = TextEditingController();
  RangeValues _currentPriceRange = const RangeValues(0, 2000);
  DateTime? _selectedDate;
  bool _isLoading = true; // Yükleniyor durumu eklendi

  @override
  void initState() {
    super.initState();
    _loadEventData();
    _searchController.addListener(_runFilter);
  }

  @override
  void dispose() {
    _searchController.removeListener(_runFilter);
    _searchController.dispose();
    super.dispose();
  }

  // --- 1. VERİ ÇEKME ---
  Future<void> _loadEventData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('etkinlikler')
          .get();
      final List<Map<String, dynamic>> data = snapshot.docs
          .map((doc) => doc.data())
          .toList();

      final Set<String> artistsSet = {};
      for (var event in data) {
        if (event.containsKey('sanatci') && event['sanatci'] is String) {
          String artistName = event['sanatci'].toString().trim();
          if (artistName.isNotEmpty) artistsSet.add(artistName);
        }
      }

      List<String> sortedArtists = artistsSet.toList()..sort();

      if (mounted) {
        setState(() {
          _allEvents = data;
          _filteredEvents = data;
          _uniqueArtists = sortedArtists;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Hata: $e");
      if (mounted) {
        setState(() {
          _allEvents = [];
          _filteredEvents = [];
          _isLoading = false;
        });
      }
    }
  }

  // --- 2. FİLTRELEME MANTIĞI ---
  void _runFilter() {
    List<Map<String, dynamic>> results = _allEvents;

    // A. Metin Arama
    if (_searchController.text.isNotEmpty) {
      final lowerSearch = _searchController.text.toLowerCase();
      results = results.where((event) {
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

    // C. Fiyat Filtresi
    results = results.where((event) {
      final priceValue = event["fiyat"]?.toString() ?? '0';
      String priceStr = priceValue.replaceAll(RegExp(r'[^0-9]'), '');
      int price = int.tryParse(priceStr) ?? 0;
      return price >= _currentPriceRange.start &&
          price <= _currentPriceRange.end;
    }).toList();

    // D. Tarih Filtresi
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

  // --- 3. GOOGLE ARAMA ---
  Future<void> _searchOnGoogle(String artist, String venue) async {
    final String query = "$artist $venue bilet";
    final Uri url = Uri.parse(
      "https://www.google.com/search?q=${Uri.encodeComponent(query)}",
    );
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Bağlantı açılamadı.')));
      }
    }
  }

  // --- 4. FİLTRE MODALI ---
  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(25),
                height: 550,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Başlık ve Temizle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Filtrele",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
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
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 15),

                    // Sanatçı Seçimi
                    const Text(
                      "Sanatçı",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedArtistFilter,
                          hint: const Text("Tüm Sanatçılar"),
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text("Tüm Sanatçılar"),
                            ),
                            ..._uniqueArtists.map(
                              (artist) => DropdownMenuItem(
                                value: artist,
                                child: Text(artist),
                              ),
                            ),
                          ],
                          onChanged: (value) => setModalState(
                            () => _selectedArtistFilter = value,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Fiyat Aralığı
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Fiyat Aralığı",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "${_currentPriceRange.start.round()} - ${_currentPriceRange.end.round()} TL",
                          style: const TextStyle(
                            color: AppTheme.primary,
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
                      activeColor: AppTheme.primary,
                      onChanged: (values) =>
                          setModalState(() => _currentPriceRange = values),
                    ),
                    const SizedBox(height: 10),

                    // Tarih Seçimi
                    const Text(
                      "Tarih",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(
                          Icons.calendar_today_rounded,
                          size: 18,
                        ),
                        label: Text(
                          _selectedDate == null
                              ? "Tarih Seçiniz"
                              : "${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}",
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          foregroundColor: AppTheme.textDark,
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2026),
                            builder: (context, child) {
                              return Theme(
                                data: ThemeData.light().copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: AppTheme.primary,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null)
                            setModalState(() => _selectedDate = picked);
                        },
                      ),
                    ),
                    const Spacer(),

                    // Uygula Butonu
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                          shadowColor: AppTheme.primary.withOpacity(0.3),
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
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        title: const Text("Etkinlikler"),
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
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          children: [
            // --- ARAMA ÇUBUĞU ---
            Container(
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
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Etkinlik, sanatçı veya mekan ara...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: AppTheme.primary),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.tune_rounded,
                      color: AppTheme.secondary,
                    ),
                    onPressed: _showFilterModal,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),

            // --- AKTİF FİLTRE GÖSTERİMİ (CHIPS) ---
            if (_selectedArtistFilter != null || _selectedDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      if (_selectedArtistFilter != null)
                        _buildFilterChip("Sanatçı: $_selectedArtistFilter", () {
                          setState(() {
                            _selectedArtistFilter = null;
                            _runFilter();
                          });
                        }),
                      if (_selectedDate != null)
                        _buildFilterChip(
                          "Tarih: ${_selectedDate!.day}.${_selectedDate!.month}",
                          () {
                            setState(() {
                              _selectedDate = null;
                              _runFilter();
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 15),

            // --- ETKİNLİK LİSTESİ ---
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    )
                  : _filteredEvents.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy_rounded,
                            size: 70,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 15),
                          Text(
                            _allEvents.isEmpty
                                ? "Henüz etkinlik eklenmemiş."
                                : "Kriterlere uygun etkinlik bulunamadı.",
                            style: TextStyle(
                              color: AppTheme.textGrey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: _filteredEvents.length,
                      itemBuilder: (context, index) {
                        return _buildEventCard(_filteredEvents[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onDelete) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.primary),
        ),
        backgroundColor: AppTheme.primary.withOpacity(0.1),
        deleteIcon: const Icon(Icons.close, size: 16, color: AppTheme.primary),
        onDeleted: onDelete,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide.none,
        ),
      ),
    );
  }

  // --- MODERN ETKİNLİK KARTI ---
  Widget _buildEventCard(Map<String, dynamic> event) {
    final String artist = event['sanatci']?.toString() ?? 'Bilinmiyor';
    final String venue = event['mekan']?.toString() ?? 'Mekan Belirtilmemiş';
    final String date = event['tarih']?.toString() ?? '';
    final String fiyat = event['fiyat']?.toString() ?? 'Ücretsiz';
    final String imageUrl = event['resim']?.toString() ?? '';

    return GestureDetector(
      onTap: () => _searchOnGoogle(artist, venue),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Resim Alanı
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => _placeholderImage(),
                          )
                        : _placeholderImage(),
                  ),
                ),
                // Fiyat Rozeti (Sağ Üst)
                Positioned(
                  top: 15,
                  right: 15,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.secondary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      fiyat,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                // Tarih Rozeti (Sol Üst) - Eğer tarih varsa
                if (date.isNotEmpty)
                  Positioned(
                    top: 15,
                    left: 15,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_month_rounded,
                            size: 14,
                            color: AppTheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            date,
                            style: const TextStyle(
                              color: AppTheme.textDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // 2. Bilgi Alanı
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    artist,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 16,
                        color: AppTheme.textGrey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          venue,
                          style: const TextStyle(
                            color: AppTheme.textGrey,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Aksiyon Satırı
                  Row(
                    children: [
                      const Text(
                        "Bilet ve Detaylar",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 20,
                        color: AppTheme.primary,
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

  Widget _placeholderImage() {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Icon(
          Icons.music_note_rounded,
          size: 50,
          color: Colors.grey[300],
        ),
      ),
    );
  }
}
