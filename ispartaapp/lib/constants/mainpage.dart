import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart'; // EKLENDİ: Favoriler için şart

// --- PROJENİZDEKİ MEVCUT SAYFALARIN IMPORTLARI ---
import 'package:ispartaapp/services/bus_services.dart';
import 'package:ispartaapp/services/emergy_numbers.dart';
import 'package:ispartaapp/services/events.dart';
import 'package:ispartaapp/services/pharmacies.dart';
import 'package:ispartaapp/services/tourist_attractions.dart';
import 'package:ispartaapp/constants/announcement.dart';

// ====================================================================
// 0. TEMA VE RENK AYARLARI
// ====================================================================
class AppTheme {
  static const Color primary = Color(0xFF1565C0);
  static const Color secondary = Color(0xFFFF6F00);
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Colors.white;
  static const Color textDark = Color(0xFF263238);
  static const Color textGrey = Color(0xFF78909C);

  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: textDark),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey,
        elevation: 10,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

// ====================================================================
// 1. MODEL VE SERVİS YARDIMCILARI (ANA SAYFA İÇİN)
// ====================================================================

class CombinedItem {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final String type;
  final String? venue;
  final String? price;

  CombinedItem({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.type,
    this.venue,
    this.price,
  });

  factory CombinedItem.fromFirestore(DocumentSnapshot doc, String type) {
    final data = doc.data() as Map<String, dynamic>;
    String title;
    String content;
    String? venue;
    String? price;
    final DateTime date = (data['tarih'] is Timestamp
        ? (data['tarih'] as Timestamp).toDate()
        : DateTime.now());

    if (type == 'Etkinlik') {
      String rawTitle = data['sanatci']?.toString() ?? 'Başlıksız Etkinlik';
      title = rawTitle.replaceAll('₺', '').trim();
      venue = data['mekan']?.toString();
      price = data['fiyat']?.toString();
      content = venue ?? 'Mekan Yok';
    } else {
      title = data['baslik']?.toString() ?? 'Duyuru';
      content =
          data['icerik']?.toString() ??
          (data['link']?.toString() ?? 'Detaylar');
    }

    return CombinedItem(
      id: doc.id,
      title: title,
      content: content,
      date: date,
      type: type,
      venue: venue,
      price: price,
    );
  }
}

final Uri _ispartaGovDuyurularUrl = Uri.parse(
  'http://www.isparta.gov.tr/duyurular',
);

Future<void> _searchOnGoogle(
  String title,
  String venue,
  BuildContext context,
) async {
  final String query = "$title $venue bilet";
  final Uri url = Uri.parse(
    "https://www.google.com/search?q=${Uri.encodeComponent(query)}",
  );
  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Bağlantı açılamadı.')));
    }
  }
}

Future<void> _launchIspartaGovDuyurular(BuildContext context) async {
  if (!await launchUrl(
    _ispartaGovDuyurularUrl,
    mode: LaunchMode.externalApplication,
  )) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Duyurular sayfası açılamadı.')),
      );
    }
  }
}

Stream<List<CombinedItem>> getCombinedItemsStream() {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final Stream<QuerySnapshot> duyurularStream = firestore
      .collection('duyurular')
      .snapshots();
  final Stream<QuerySnapshot> etkinliklerStream = firestore
      .collection('etkinlikler')
      .snapshots();

  return Rx.combineLatest2(duyurularStream, etkinliklerStream, (
    QuerySnapshot duyurularSnapshot,
    QuerySnapshot etkinliklerSnapshot,
  ) {
    List<CombinedItem> duyurular = duyurularSnapshot.docs
        .map((doc) => CombinedItem.fromFirestore(doc, 'Duyuru'))
        .toList();
    List<CombinedItem> etkinlikler = etkinliklerSnapshot.docs
        .map((doc) => CombinedItem.fromFirestore(doc, 'Etkinlik'))
        .toList();
    List<CombinedItem> combined = [...duyurular, ...etkinlikler];
    final now = DateTime.now();
    combined.sort((a, b) {
      final durationA = a.date.difference(now).abs();
      final durationB = b.date.difference(now).abs();
      return durationA.compareTo(durationB);
    });
    return combined.take(5).toList();
  });
}

// ====================================================================
// 2. MAIN PAGE (NAVİGASYON)
// ====================================================================
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const MainPageContent(),
    const ServicesPage(),
    const AnnouncementPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      home: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_city_rounded,
                color: AppTheme.primary,
                size: 26,
              ),
              const SizedBox(width: 8),
              const Text("Şehir Cebinde"),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () {},
            ),
          ],
        ),
        body: _pages[_selectedIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Ana Sayfa',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.grid_view),
                activeIcon: Icon(Icons.grid_view_rounded),
                label: 'Hizmetler',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications_none),
                activeIcon: Icon(Icons.notifications_active),
                label: 'Duyurular',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ====================================================================
// 3. MAIN PAGE CONTENT (ANA İÇERİK - GÜNCELLENDİ)
// ====================================================================
class MainPageContent extends StatefulWidget {
  const MainPageContent({super.key});

  @override
  State<MainPageContent> createState() => _MainPageContentState();
}

class _MainPageContentState extends State<MainPageContent> {
  // Hava Durumu Değişkenleri
  String temperature = "--";
  String status = "Yükleniyor...";
  IconData weatherIcon = Icons.cloud;
  bool isLoading = true;

  // 🔥 Favori Otobüs Değişkenleri
  List<dynamic> _allBusLines = [];
  List<String> _favoriteLineNames = [];
  List<dynamic> _favoriteBusData = [];

  @override
  void initState() {
    super.initState();
    getWeatherData();
    _loadBusDataAndFavorites(); // Favorileri yükle
  }

  // --- OTOBÜS & FAVORİ MANTIĞI ---
  Future<void> _loadBusDataAndFavorites() async {
    try {
      // 1. JSON Oku
      final String response = await rootBundle.loadString(
        'jsons/otobus_saatleri.json',
      );
      final List<dynamic> busData = json.decode(response);

      // 2. Favorileri Oku
      final prefs = await SharedPreferences.getInstance();
      final List<String> favs = prefs.getStringList('favorite_bus_lines') ?? [];

      if (mounted) {
        setState(() {
          _allBusLines = busData;
          _favoriteLineNames = favs;
          _matchFavorites(); // Eşleştir
        });
      }
    } catch (e) {
      print("Favori Yükleme Hatası: $e");
    }
  }

  void _matchFavorites() {
    _favoriteBusData = _allBusLines.where((bus) {
      return _favoriteLineNames.contains(bus['hat_adi']);
    }).toList();
  }

  // Saat Hesaplama
  int _timeToMinutes(String time) {
    try {
      final parts = time.split(':');
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    } catch (e) {
      return 0;
    }
  }

  String _getNextBusTime(List<dynamic> rawTimes) {
    List<String> times = rawTimes.map((e) => e.toString()).toSet().toList();
    times.sort((a, b) => _timeToMinutes(a).compareTo(_timeToMinutes(b)));
    if (times.isEmpty) return "Sefer Yok";

    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;

    for (var time in times) {
      if (_timeToMinutes(time) >= currentMinutes) {
        return time; // Sıradaki saat
      }
    }
    return "Bitti"; // Günlük sefer bitti
  }
  // ------------------------------

  Future<void> getWeatherData() async {
    final url = Uri.parse(
      "https://api.openweathermap.org/data/2.5/weather?q=Isparta&appid=c2e800ef8351c139fee8ff027ee1c756&units=metric&lang=tr",
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          double tempVal = data['main']['temp'];
          temperature = "${tempVal.round()}°";
          String rawStatus = data['weather'][0]['description'];
          status = rawStatus[0].toUpperCase() + rawStatus.substring(1);
          weatherIcon = _getIconForWeather(data['weather'][0]['main']);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        status = "Hata";
        isLoading = false;
      });
    }
  }

  IconData _getIconForWeather(String mainStatus) {
    switch (mainStatus) {
      case 'Clear':
        return Icons.wb_sunny_rounded;
      case 'Clouds':
        return Icons.cloud_rounded;
      case 'Rain':
        return Icons.water_drop_rounded;
      case 'Snow':
        return Icons.ac_unit_rounded;
      case 'Thunderstorm':
        return Icons.flash_on_rounded;
      default:
        return Icons.wb_cloudy_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await getWeatherData();
        await _loadBusDataAndFavorites(); // Yenilemede favorileri tekrar çek
      },
      color: AppTheme.primary,
      child: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          // 1. Hava Durumu Kartı
          _buildWeatherCard(),
          const SizedBox(height: 25),

          // 🔥 2. FAVORİ DURAKLAR (Sadece favori varsa gösterir)
          if (_favoriteBusData.isNotEmpty) ...[
            const Text(
              "Favori Duraklar",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 110, // Kart yüksekliği
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _favoriteBusData.length,
                itemBuilder: (context, index) {
                  final bus = _favoriteBusData[index];
                  String nextTime = _getNextBusTime(bus['saatler']);
                  bool isFinished =
                      nextTime == "Bitti" || nextTime == "Sefer Yok";

                  return Container(
                    width: 150,
                    margin: const EdgeInsets.only(
                      right: 12,
                      bottom: 5,
                    ), // Bottom margin gölge için
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.withOpacity(0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.directions_bus_filled,
                              size: 18,
                              color: AppTheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                bus['hat_adi'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppTheme.textDark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isFinished ? "Durum" : "Sıradaki",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              nextTime,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: isFinished
                                    ? Colors.grey
                                    : AppTheme.secondary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 25),
          ],

          // 3. Etkinlikler Başlığı
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Şehrin Nabzı",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Son 5",
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // 4. Etkinlik Listesi
          const CombinedItemsList(),
        ],
      ),
    );
  }

  Widget _buildWeatherCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2962FF), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Isparta",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      status,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(weatherIcon, size: 52, color: Colors.amberAccent),
                    const SizedBox(width: 12),
                    Text(
                      temperature,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 46,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

// ====================================================================
// 4. LİSTE WIDGET'I (HOME PAGE İÇİN)
// ====================================================================
class CombinedItemsList extends StatelessWidget {
  const CombinedItemsList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CombinedItem>>(
      stream: getCombinedItemsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "Aktif içerik yok.",
              style: TextStyle(color: AppTheme.textGrey),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = items[index];
            final bool isEvent = item.type == 'Etkinlik';
            return InkWell(
              onTap: () {
                if (isEvent) {
                  _searchOnGoogle(item.title, item.venue ?? '', context);
                } else {
                  _launchIspartaGovDuyurular(context);
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isEvent
                            ? AppTheme.secondary.withOpacity(0.1)
                            : AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            item.date.day.toString(),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: isEvent
                                  ? AppTheme.secondary
                                  : AppTheme.primary,
                            ),
                          ),
                          Text(
                            _getShortMonth(item.date.month),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isEvent
                                  ? AppTheme.secondary
                                  : AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isEvent
                                  ? const Color(0xFFFFF3E0)
                                  : const Color(0xFFE3F2FD),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isEvent ? "ETKİNLİK" : "DUYURU",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isEvent
                                    ? Colors.orange[900]
                                    : Colors.blue[900],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isEvent
                                ? (item.venue ?? "Mekan belirtilmedi")
                                : "Detaylar için tıklayın",
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textGrey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
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
            );
          },
        );
      },
    );
  }

  String _getShortMonth(int month) {
    const months = [
      "OCK",
      "ŞUB",
      "MAR",
      "NİS",
      "MAY",
      "HAZ",
      "TEM",
      "AĞU",
      "EYL",
      "EKİ",
      "KAS",
      "ARA",
    ];
    return months[month - 1];
  }
}

// ====================================================================
// 5. HİZMETLER SAYFASI (YENİLENDİ: GERİ DÖNÜŞTE REFRESH YAPAR)
// ====================================================================
class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
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
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.2,
              children: [
                _buildServiceCard(
                  context,
                  "Otobüs Seferleri",
                  Icons.directions_bus_rounded,
                  Colors.blueAccent,
                  () async {
                    // 🔥 Burası önemli: Geri gelince ana sayfayı yenilemek için
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BusServices(),
                      ),
                    );
                  },
                ),
                _buildServiceCard(
                  context,
                  "Etkinlikler",
                  Icons.confirmation_number_rounded,
                  Colors.orange,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Events()),
                    );
                  },
                ),
                _buildServiceCard(
                  context,
                  "Nöbetçi Eczaneler",
                  Icons.local_pharmacy_rounded,
                  Colors.redAccent,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Pharmacies(),
                      ),
                    );
                  },
                ),
                _buildServiceCard(
                  context,
                  "Acil Numaralar",
                  Icons.phone_in_talk_rounded,
                  Colors.red[800]!,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EmergyNumbers(),
                      ),
                    );
                  },
                ),
                _buildServiceCard(
                  context,
                  "Gezilecek Yerler",
                  Icons.map_rounded,
                  Colors.green,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TouristAttractions(),
                      ),
                    );
                  },
                ),
                _buildServiceCard(
                  context,
                  "Arıza/Talep Bildir",
                  Icons.support_agent_rounded,
                  const Color(0xFF25D366),
                  () {
                    _openWhatsApp();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.textDark,
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
      if (!launched) throw 'Uygulama başlatılamadı';
    } catch (e) {
      await launchUrl(url, mode: LaunchMode.platformDefault);
    }
  }
}
