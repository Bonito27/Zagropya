import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

// ====================================================================
// 0. TEMA AYARLARI (Diğer sayfalarla uyum için)
// ====================================================================
class AppTheme {
  static const Color primary = Color(0xFF1565C0); // Şehir Mavisi
  static const Color background = Color(0xFFF5F7FA); // Modern Gri Zemin
  static const Color textDark = Color(0xFF263238);
  static const Color textGrey = Color(0xFF78909C);
  static const Color surface = Colors.white;
}

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

enum SortOrder { newestFirst, oldestFirst }

class _AnnouncementPageState extends State<AnnouncementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchText = '';
  SortOrder _currentSortOrder = SortOrder.newestFirst;

  final String _ispartaGovDuyurularUrl = "http://www.isparta.gov.tr/duyurular";

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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background, // Modern gri zemin
      body: Column(
        children: [
          // --- Başlık ---
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            alignment: Alignment.centerLeft,
            child: const Text(
              "Resmi Duyurular",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
          ),

          // --- ARAMA ÇUBUĞU (Modern Tasarım) ---
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 10.0,
            ),
            child: Container(
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
                onChanged: (value) {
                  setState(() {
                    _searchText = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Duyurularda ara...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.search, color: AppTheme.primary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 15.0,
                    horizontal: 20.0,
                  ),

                  // Sıralama Butonu
                  suffixIcon: PopupMenuButton<SortOrder>(
                    icon: const Icon(
                      Icons.sort_rounded,
                      color: AppTheme.textGrey,
                    ),
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
                              'Yeniden Eskiye',
                              style: TextStyle(
                                color:
                                    _currentSortOrder == SortOrder.newestFirst
                                    ? AppTheme.primary
                                    : AppTheme.textDark,
                                fontWeight:
                                    _currentSortOrder == SortOrder.newestFirst
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          PopupMenuItem<SortOrder>(
                            value: SortOrder.oldestFirst,
                            child: Text(
                              'Eskiden Yeniye',
                              style: TextStyle(
                                color:
                                    _currentSortOrder == SortOrder.oldestFirst
                                    ? AppTheme.primary
                                    : AppTheme.textDark,
                                fontWeight:
                                    _currentSortOrder == SortOrder.oldestFirst
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                  ),
                ),
              ),
            ),
          ),

          // --- Duyuru Listesi ---
          Expanded(
            child: StreamBuilder<List<Announcement>>(
              stream: _announcementsStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Hata: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 60,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Henüz duyuru bulunmamaktadır.",
                          style: TextStyle(color: AppTheme.textGrey),
                        ),
                      ],
                    ),
                  );
                }

                final announcements = snapshot.data!;

                return ListView.separated(
                  itemCount: announcements.length,
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12.0),
                  itemBuilder: (context, index) {
                    final announcement = announcements[index];

                    // --- KART TASARIMI ---
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        // Sol tarafa mavi şerit (Resmiyet vurgusu)
                        border: const Border(
                          left: BorderSide(color: AppTheme.primary, width: 4),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            if (announcement.link.isNotEmpty) {
                              _launchUrl(_ispartaGovDuyurularUrl);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Bu duyuru için link yok.'),
                                ),
                              );
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ),
                            child: Row(
                              children: [
                                // İçerik
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        announcement.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15.0,
                                          color: AppTheme.textDark,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time_rounded,
                                            size: 14,
                                            color: Colors.grey[500],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _formatDate(announcement.date),
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // Ok İkonu
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.grey,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
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
