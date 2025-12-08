import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

// Duyuru modeli (Aynı kaldı)
class Announcement {
  final String id;
  final String title;
  final String link;
  final DateTime date;

  Announcement({
    required this.id,
    required this.title,
    required this.link,
    required this.date,
  });

  factory Announcement.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Announcement(
      id: doc.id,
      title: data['baslik'] ?? 'Başlıksız Duyuru',
      link: data['link'] ?? '',
      date: (data['tarih'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class AnnouncementPage extends StatefulWidget {
  const AnnouncementPage({super.key});

  @override
  State<AnnouncementPage> createState() => _AnnouncementPageState();
}

// Sıralama seçenekleri (Aynı kaldı)
enum SortOrder { newestFirst, oldestFirst }

class _AnnouncementPageState extends State<AnnouncementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchText = '';
  SortOrder _currentSortOrder = SortOrder.newestFirst;

  // Isparta Valiliği Duyurular URL'si (Tıklamada kullanılacak sabit URL)
  final String _ispartaGovDuyurularUrl = "http://www.isparta.gov.tr/duyurular";

  // URL Açma Fonksiyonu (Aynı kaldı)
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: Duyuru linki açılamadı: $urlString')),
        );
      }
    }
  }

  // Stream sorgusu (Aynı kaldı)
  Stream<List<Announcement>> _announcementsStream() {
    Query query = _firestore.collection('duyurular');

    query = query.orderBy(
      'tarih',
      descending: _currentSortOrder == SortOrder.newestFirst,
    );

    return query.snapshots().map((snapshot) {
      List<Announcement> allAnnouncements = snapshot.docs
          .map((doc) => Announcement.fromFirestore(doc))
          .toList();

      if (_searchText.isEmpty) {
        return allAnnouncements;
      } else {
        final lowerCaseSearch = _searchText.toLowerCase();
        return allAnnouncements.where((announcement) {
          return announcement.title.toLowerCase().contains(lowerCaseSearch) ||
              announcement.link.toLowerCase().contains(lowerCaseSearch);
        }).toList();
      }
    });
  }

  // Tarih formatlama yardımcı metodu (Aynı kaldı)
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 🔥🔥🔥 ARAMA ÇUBUĞU VE SIRALAMA ENTEGRASYONU 🔥🔥🔥
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Duyuru Ara (Başlık/Link)',
                prefixIcon: const Icon(Icons.search),
                // Oval şekil için ayar
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 20.0,
                ),

                // Sıralama Butonu (Suffix Icon)
                suffixIcon: PopupMenuButton<SortOrder>(
                  icon: Icon(Icons.sort, color: Colors.blue),
                  onSelected: (SortOrder result) {
                    setState(() {
                      _currentSortOrder = result;
                    });
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<SortOrder>>[
                        PopupMenuItem<SortOrder>(
                          value: SortOrder.newestFirst,
                          child: Text(
                            'Yeniden Eskiye (Seçili)',
                            style: TextStyle(
                              fontWeight:
                                  _currentSortOrder == SortOrder.newestFirst
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: _currentSortOrder == SortOrder.newestFirst
                                  ? Colors.blue
                                  : Colors.black,
                            ),
                          ),
                        ),
                        const PopupMenuDivider(),
                        PopupMenuItem<SortOrder>(
                          value: SortOrder.oldestFirst,
                          child: Text(
                            'Eskiden Yeniye',
                            style: TextStyle(
                              fontWeight:
                                  _currentSortOrder == SortOrder.oldestFirst
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: _currentSortOrder == SortOrder.oldestFirst
                                  ? Colors.blue
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ],
                ),
              ),
            ),
          ),

          // Duyuru Listesi
          Expanded(
            child: StreamBuilder<List<Announcement>>(
              stream: _announcementsStream(),
              builder: (context, snapshot) {
                // ... (Hata ve yükleme durumları aynı) ...
                if (snapshot.hasError) {
                  return Center(child: Text('Hata: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('Henüz duyuru bulunmamaktadır.'),
                  );
                }

                final announcements = snapshot.data!;

                return ListView.separated(
                  itemCount: announcements.length,
                  // 🔥 Kartlar arasındaki boşluğu artırdık
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10.0),
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),

                  itemBuilder: (context, index) {
                    final announcement = announcements[index];
                    return Card(
                      elevation: 3, // Daha belirgin gölge
                      // 🔥 Kartın genel görünüm boşluğunu düzenledik
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),

                        title: Text(
                          announcement.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Yayınlanma Tarihi: ${_formatDate(announcement.date)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13.0,
                            ),
                          ),
                        ),
                        trailing: const Icon(
                          Icons.open_in_new,
                          color: Colors.blue,
                        ),
                        onTap: () {
                          // Duyuru linki var ise sabit Valilik sayfasına yönlendir
                          if (announcement.link.isNotEmpty) {
                            _launchUrl(_ispartaGovDuyurularUrl);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Bu duyuru için bir link bulunamadı.',
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
