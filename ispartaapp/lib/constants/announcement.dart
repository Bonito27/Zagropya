import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart'; // url_launcher eklendi

// Duyuru modeli (Alan adları Firebase'inize göre günceldir)
class Announcement {
  final String id;
  final String title; // baslik alanını alır
  final String link; // link alanını alır
  final DateTime date; // tarih alanını alır

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
      link: data['link'] ?? '', // 'link' alanını içerik yerine tutuyoruz
      date: (data['tarih'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class AnnouncementPage extends StatefulWidget {
  const AnnouncementPage({super.key});

  @override
  State<AnnouncementPage> createState() => _AnnouncementPageState();
}

enum SortOrder { newestFirst, oldestFirst }

class _AnnouncementPageState extends State<AnnouncementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchText = '';
  SortOrder _currentSortOrder = SortOrder.newestFirst;

  // URL Açma Fonksiyonu
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      if (mounted) {
        // Hata durumunda kullanıcıya bilgi ver
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: Duyuru linki açılamadı: $urlString')),
        );
      }
    }
  }

  // Stream sorgusu (Önceki haliyle aynı, alan adları 'tarih' ve 'baslik' ile çalışıyor)
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
          // Arama artık 'title' (yani 'baslik') ve 'link' alanlarında yapılıyor
          return announcement.title.toLowerCase().contains(lowerCaseSearch) ||
              announcement.link.toLowerCase().contains(lowerCaseSearch);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Arama Çubuğu
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Duyuru Ara (Başlık/Link)',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
            ),
          ),
          // Sıralama Seçeneği
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('Sırala:'),
                const SizedBox(width: 8.0),
                DropdownButton<SortOrder>(
                  value: _currentSortOrder,
                  icon: const Icon(Icons.filter_list),
                  underline: Container(),
                  onChanged: (SortOrder? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _currentSortOrder = newValue;
                      });
                    }
                  },
                  items: const <DropdownMenuItem<SortOrder>>[
                    DropdownMenuItem(
                      value: SortOrder.newestFirst,
                      child: Text('Yeniden Eskiye'),
                    ),
                    DropdownMenuItem(
                      value: SortOrder.oldestFirst,
                      child: Text('Eskiden Yeniye'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Duyuru Listesi
          Expanded(
            child: StreamBuilder<List<Announcement>>(
              stream: _announcementsStream(),
              builder: (context, snapshot) {
                // ... (Hata ve yükleme durumları aynı)
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
                  // ListView.builder yerine ListView.separated kullandık
                  // Böylece araya çizgi (Divider) koyarak boşluk ekleyebiliriz.
                  itemCount: announcements.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 1.0, // Varsayılan boşluğu ayarlar
                    color: Colors.grey,
                    indent: 16.0,
                    endIndent: 16.0,
                  ),
                  itemBuilder: (context, index) {
                    final announcement = announcements[index];
                    return Card(
                      // Card'ın kenar boşluğunu biraz azalttık
                      margin: const EdgeInsets.symmetric(
                        horizontal: 4.0,
                        vertical: 2.0,
                      ),
                      child: ListTile(
                        // Başlıkların tamamının görünmesi için wrap ayarı
                        title: Text(
                          announcement.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 3, // Başlık uzunsa 3 satıra kadar sığdır
                          overflow:
                              TextOverflow.ellipsis, // Taşarsa sonuna ... koy
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          // Link yerine sadece Tarih bilgisini gösteriyoruz
                          child: Text(
                            'Yayınlanma Tarihi: ${_formatDate(announcement.date)}',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ),
                        trailing: const Icon(
                          Icons.open_in_new,
                        ), // Link açılacağını belirten ikon
                        // 🔥🔥🔥 Tıklama Özelliği (Link Açma) 🔥🔥🔥
                        onTap: () {
                          if (announcement.link.isNotEmpty) {
                            _launchUrl("http://www.isparta.gov.tr/duyurular");
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

  // Tarih formatlama yardımcı metodu
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
