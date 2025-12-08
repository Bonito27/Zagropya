import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ispartaapp/constants/announcement.dart';
import 'package:ispartaapp/constants/services.dart';
import 'package:ispartaapp/services/colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rxdart/rxdart.dart';

// NOT: AppColors, AnnouncementPage, ServicesPage sınıflarınızın tanımlı olduğunu varsayıyoruz.

// ====================================================================
// 1. MODEL VE SERVİS YARDIMCILARI
// ====================================================================

// 🔥 Model: Etkinlik ve Duyuruları Temsil Eder (Başlık temizleme düzeltmesi yapıldı)
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

    // Tarih alanını güvenli bir şekilde alıyoruz
    final DateTime date = (data['tarih'] is Timestamp
        ? (data['tarih'] as Timestamp).toDate()
        : DateTime.now());

    if (type == 'Etkinlik') {
      // Etkinlikler için başlık (sanatçı) ve detayları al
      String rawTitle = data['sanatci']?.toString() ?? 'Başlıksız Etkinlik';

      // 🔥🔥🔥 DÜZELTME: Başlıktan "₺" işaretini ve boşlukları temizle 🔥🔥🔥
      title = rawTitle.replaceAll('₺', '').trim();

      venue = data['mekan']?.toString();
      price = data['fiyat']?.toString();

      // İçeriği (content) metin olarak birleştir
      content = "Mekan: ${venue ?? 'Yok'} | Fiyat: ${price ?? 'Ücretsiz'}";
    } else {
      // Duyurular
      // Duyurular için başlık ('baslik') ve link ('link') alanlarını kullanıyoruz.
      title = data['baslik']?.toString() ?? 'Başlıksız Duyuru';
      content = data['link']?.toString() ?? 'Detay bulunamadı.';
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

// 🔥 Gradient Renkleri
List<List<Color>> _cardGradients = [
  [const Color(0xFF8E2DE2), const Color(0xFF4A00E0)],
  [const Color(0xFFE55D87), const Color(0xFF5FC3E4)],
  [const Color(0xFF1D976C), const Color(0xFF93F9B9)],
  [const Color(0xFFF953C6), const Color(0xFFB91D73)],
  [const Color(0xFFFDC830), const Color(0xFFF37335)],
];

// Isparta Valiliği Duyurular Sayfası URL'si (Duyurular için sabit hedef)
final Uri _ispartaGovDuyurularUrl = Uri.parse(
  'http://www.isparta.gov.tr/duyurular',
);

// 🔥 Etkinlik için Google Araması Yapar
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Etkinlik için arama bağlantısı açılamadı.'),
        ),
      );
    }
  }
}

// 🔥 Duyuru için Valilik sayfasına yönlendirir
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

// 🔥 Firebase Veri Çekme, Birleştirme ve Sıralama Servisi
Stream<List<CombinedItem>> getCombinedItemsStream() {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final Stream<QuerySnapshot> duyurularStream = firestore
      .collection('duyurular')
      .snapshots();
  final Stream<QuerySnapshot> etkinliklerStream = firestore
      .collection('etkinlikler')
      .snapshots();

  // İki Stream'i RxDart ile birleştiriyoruz
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

    // En yakın tarihten en uzağa sırala (Hem geçmiş hem gelecek için)
    final now = DateTime.now();
    combined.sort((a, b) {
      final durationA = a.date.difference(now).abs();
      final durationB = b.date.difference(now).abs();
      return durationA.compareTo(durationB);
    });

    // Sadece ilk 5 öğeyi döndür
    return combined.take(5).toList();
  });
}

// ====================================================================
// MAİN PAGE KODU (NAVİGASYON)
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
    // Bu sayfa sınıflarının tanımlandığından emin olun:
    // const ServicesPage(),
    // const AnnouncementPage(),
    const ServicesPage(), // ServicesPage yerine geçici
    const AnnouncementPage(), // AnnouncementPage yerine geçici
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // AppColors tanımlı değilse, geçici olarak tanımlayalım
    // const AppColors = _AppColorsTemp();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 0.0,
            title: const Text("Isparta App"),
            centerTitle: true,
            // backgroundColor: AppColors.bg, // Eğer AppColors tanımlı değilse bu satırı yoruma alın
            backgroundColor: AppColors.bg, // Geçici
          ),
          // backgroundColor: AppColors.bg, // Eğer AppColors tanımlı değilse bu satırı yoruma alın
          backgroundColor: AppColors.bg, // Geçici
          body: _pages[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: HexColor('#F8F8FF'),
            // selectedIconTheme: IconThemeData(color: AppColors.primary), // Eğer AppColors tanımlı değilse bu satırları yoruma alın
            // selectedItemColor: AppColors.primary,
            selectedIconTheme: const IconThemeData(
              color: Colors.blue,
            ), // Geçici
            selectedItemColor: Colors.blue, // Geçici
            unselectedItemColor: Colors.grey,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Ana Sayfa',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list_sharp),
                label: 'Hizmetler',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications),
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
// MAİN PAGECONTENT KODU (ANA SAYFA İÇERİĞİ)
// ====================================================================
class MainPageContent extends StatefulWidget {
  const MainPageContent({super.key});

  @override
  State<MainPageContent> createState() => _MainPageContentState();
}

class _MainPageContentState extends State<MainPageContent> {
  // ... (Hava durumu değişkenleri, initState, getWeatherData, _getIconForWeather metotları aynı kalır) ...
  // --- HAVA DURUMU DEĞİŞKENLERİ ---
  String temperature = "";
  String status = "Yükleniyor...";
  String city = "Isparta";
  IconData weatherIcon = Icons.cloud_download;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getWeatherData();
  }

  // API'den Veri Çeken Fonksiyon (Hava Durumu)
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
          temperature = "${tempVal.round()}°C";
          String rawStatus = data['weather'][0]['description'];
          status = rawStatus[0].toUpperCase() + rawStatus.substring(1);
          String mainStatus = data['weather'][0]['main'];
          weatherIcon = _getIconForWeather(mainStatus);
          isLoading = false;
        });
      } else {
        setState(() {
          status = "Hata oluştu";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        status = "Bağlantı yok";
        isLoading = false;
      });
    }
  }

  // Hava durumuna göre ikon seçen yardımcı fonksiyon
  IconData _getIconForWeather(String mainStatus) {
    switch (mainStatus) {
      case 'Clear':
        return Icons.wb_sunny;
      case 'Clouds':
        return Icons.cloud;
      case 'Rain':
        return Icons.umbrella;
      case 'Drizzle':
        return Icons.grain;
      case 'Thunderstorm':
        return Icons.flash_on;
      case 'Snow':
        return Icons.ac_unit;
      default:
        return Icons.cloud;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Eğer AppColors.texts tanımlı değilse, geçici bir renk kullanıyoruz.
    final Color headerColor = Colors.black87;

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          _buildHeader("Hava Durumu", headerColor),
          const SizedBox(height: 10),
          _buildWeatherCard(),
          const SizedBox(height: 20),
          _buildHeader("Güncel Duyuru ve Etkinlikler", headerColor),
          const SizedBox(height: 10),
          const Expanded(child: CombinedItemsList()),
        ],
      ),
    );
  }

  // --- HAVA DURUMU KARTI TASARIMI ---
  Widget _buildWeatherCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(weatherIcon, size: 50, color: Colors.white),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          city,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          status,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  temperature,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader(String title, Color color) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ====================================================================
// WIDGET: BİRLEŞTİRİLMİŞ DUYURU/ETKİNLİK LİSTESİ
// ====================================================================
class CombinedItemsList extends StatelessWidget {
  const CombinedItemsList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CombinedItem>>(
      stream: getCombinedItemsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Veri çekme hatası: ${snapshot.error}',
              textAlign: TextAlign.center,
            ),
          );
        }

        final items = snapshot.data;
        if (items == null || items.isEmpty) {
          return const Center(
            child: Text(
              'Şu anda listelenecek güncel içerik bulunmamaktadır.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final List<Color> gradientColors =
                _cardGradients[index % _cardGradients.length];

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () {
                  if (item.type == 'Etkinlik') {
                    final venueName = item.venue ?? 'Isparta';
                    _searchOnGoogle(item.title, venueName, context);
                  } else if (item.type == 'Duyuru') {
                    _launchIspartaGovDuyurular(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Bu içerik için tanımlı bir aksiyon yok.',
                        ),
                      ),
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors[1].withOpacity(0.4),
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item.title}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '#${item.type} • ${_formatDate(item.date)}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                      if (item.type == 'Etkinlik' &&
                          (item.price != null || item.venue != null))
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            '${item.price ?? 'Ücretsiz'} / ${item.venue ?? 'Mekan Yok'}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Tarih formatlama yardımcı metodu
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
