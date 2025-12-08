import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // JSON okumak için
import 'package:ispartaapp/services/colors.dart'; // Renk dosyan

class BusServices extends StatefulWidget {
  const BusServices({super.key});

  @override
  State<BusServices> createState() => _BusServicesState();
}

class _BusServicesState extends State<BusServices> {
  List<dynamic> _allBusLines = []; // Tüm hatlar
  List<dynamic> _filteredBusLines = []; // Arama sonucu hatlar
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBusData();
  }

  // JSON Verisini Okuma
  Future<void> _loadBusData() async {
    try {
      // JSON dosya yolunu buraya tam olarak yazıyoruz
      // NOT: Dosya yolunun pubspec.yaml ile uyumlu olduğundan emin ol.

      final String response = await rootBundle.loadString(
        'jsons/otobus_saatleri.json',
      );
      final List<dynamic> data = json.decode(response);

      setState(() {
        _allBusLines = data;
        _filteredBusLines = data;
      });
    } catch (e) {
      print("JSON Okuma Hatası: $e");
    }
  }

  // Arama Fonksiyonu
  void _runFilter(String enteredKeyword) {
    List<dynamic> results = [];
    if (enteredKeyword.isEmpty) {
      results = _allBusLines;
    } else {
      results = _allBusLines
          .where(
            (line) => line["hat_adi"].toString().toLowerCase().contains(
              enteredKeyword.toLowerCase(),
            ),
          )
          .toList();
    }

    setState(() {
      _filteredBusLines = results;
    });
  }

  // Saatleri "Dakika" cinsine çevirir (Karşılaştırma yapmak için)
  int _timeToMinutes(String time) {
    try {
      final parts = time.split(':');
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    } catch (e) {
      return 0;
    }
  }

  // --- YENİ EKLENEN: Liste Kartı İçin Durum Metni ---
  String _getBusStatusText(List<dynamic> rawTimes) {
    List<String> times = rawTimes.map((e) => e.toString()).toSet().toList();
    times.sort((a, b) => _timeToMinutes(a).compareTo(_timeToMinutes(b)));

    if (times.isEmpty) return "Sefer yok";

    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;

    final firstBusMinutes = _timeToMinutes(times.first);
    final lastBusMinutes = _timeToMinutes(times.last);

    // Durum 1: Henüz seferler başlamadı (Sabah erken)
    if (currentMinutes < firstBusMinutes) {
      return "Henüz sefer başlamadı. İlk Sefer: ${times.first}";
    }
    // Durum 2: Seferler bitti (Gece geç)
    else if (currentMinutes > lastBusMinutes) {
      return "Seferler tamamlandı. Son Sefer: ${times.last}";
    }
    // Durum 3: Gün içi (Sıradaki seferi göster)
    else {
      for (var time in times) {
        if (_timeToMinutes(time) >= currentMinutes) {
          return "Sıradaki Sefer: $time";
        }
      }
      return "Seferler tamamlandı";
    }
  }

  // Detay Penceresini Açan Fonksiyon (Saatleri Gösterir)
  void _showBusTimes(
    BuildContext context,
    String title,
    List<dynamic> rawTimes,
  ) {
    // 1. Saatleri Temizle ve Sırala
    List<String> times = rawTimes.map((e) => e.toString()).toSet().toList();
    times.sort((a, b) => _timeToMinutes(a).compareTo(_timeToMinutes(b)));

    // 2. Şu anki saati al
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;

    // 3. En yakın gelecek saati ve indexini bul
    String? nextBusTime;
    int targetIndex = 0; // Kaydırma yapılacak hedef index

    for (int i = 0; i < times.length; i++) {
      if (_timeToMinutes(times[i]) >= currentMinutes) {
        nextBusTime = times[i];
        targetIndex = i;
        break;
      }
    }

    // Scroll Controller (Otomatik kaydırma için)
    final ScrollController scrollController = ScrollController();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // --- YENİ EKLENEN: Otomatik Kaydırma Mantığı ---
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.hasClients && nextBusTime != null) {
            // Grid yapısında satır sayısını hesapla (4 sütunlu olduğu için 4'e bölüyoruz)
            // Her satırın yaklaşık yüksekliği + boşluk ile çarpıyoruz (Örn: 50px)
            double offset = (targetIndex / 4).floor() * 50.0;

            // Eğer listenin sonlarına doğruysa offset hatası vermemesi için clamp kullanılır
            // Ama basitçe animateTo çoğu durumda iş görür.
            scrollController.animateTo(
              offset,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
            );
          }
        });

        return Container(
          padding: const EdgeInsets.all(20),
          height: 500,
          child: Column(
            children: [
              Text(
                "$title Hareket Saatleri",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _legendItem(Colors.grey, "Geçmiş"),
                  const SizedBox(width: 10),
                  _legendItem(Colors.green, "Sıradaki"),
                  const SizedBox(width: 10),
                  _legendItem(Colors.black, "Gelecek"),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  controller: scrollController, // Controller'ı buraya bağladık
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.0,
                  ),
                  itemCount: times.length,
                  itemBuilder: (context, index) {
                    final timeStr = times[index];
                    final timeMinutes = _timeToMinutes(timeStr);

                    Color bgColor;
                    Color textColor;

                    if (timeStr == nextBusTime) {
                      bgColor = Colors.green;
                      textColor = Colors.white;
                    } else if (timeMinutes < currentMinutes) {
                      bgColor = Colors.grey.shade300;
                      textColor = Colors.grey.shade700;
                    } else {
                      bgColor = Colors.white;
                      textColor = Colors.black;
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        timeStr,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _legendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        title: const Text("Otobüs Hatları"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.texts,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: (value) => _runFilter(value),
              decoration: InputDecoration(
                labelText: 'Hat Ara (Örn: Hat 32)',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _filteredBusLines.isEmpty
                  ? const Center(child: Text("Hat bulunamadı"))
                  : ListView.builder(
                      itemCount: _filteredBusLines.length,
                      itemBuilder: (context, index) {
                        final line = _filteredBusLines[index];
                        // Her satır için durum metnini hesapla
                        String statusText = _getBusStatusText(line['saatler']);

                        // Duruma göre renk belirle (Opsiyonel: Görsellik katar)
                        Color statusColor = Colors.grey;
                        if (statusText.contains("Sıradaki")) {
                          statusColor = Colors.green;
                        } else if (statusText.contains("Henüz")) {
                          statusColor = Colors.orange;
                        }

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.directions_bus,
                                color: AppColors.primary,
                              ),
                            ),
                            title: Text(
                              line['hat_adi'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            // --- YENİ EKLENEN: Alt Başlık (Durum Bilgisi) ---
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                statusText,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: statusColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                            onTap: () {
                              _showBusTimes(
                                context,
                                line['hat_adi'],
                                line['saatler'],
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
