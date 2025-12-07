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
      final String response = await rootBundle.loadString(
        '../Python/assets/otobus_saatleri.json',
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
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  // Detay Penceresini Açan Fonksiyon (Saatleri Gösterir)
  void _showBusTimes(
    BuildContext context,
    String title,
    List<dynamic> rawTimes,
  ) {
    // 1. Saatleri Temizle: Tekrarlayanları kaldır ve String'e çevir
    List<String> times = rawTimes.map((e) => e.toString()).toSet().toList();

    // 2. Saatleri Sırala (Sabah 07:00, akşam 19:00'dan önce gelsin)
    times.sort((a, b) => _timeToMinutes(a).compareTo(_timeToMinutes(b)));

    // 3. Şu anki saati al
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;

    // 4. En yakın gelecek saati bul
    String? nextBusTime;
    for (var time in times) {
      if (_timeToMinutes(time) >= currentMinutes) {
        nextBusTime = time;
        break; // İlk bulduğumuz gelecek saat, en yakın saattir.
      }
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 500,
          child: Column(
            children: [
              // Başlık
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

              // Renk Açıklamaları (Lejant)
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

              // Saatler Izgarası
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, // Yan yana 4 saat
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.0,
                  ),
                  itemCount: times.length,
                  itemBuilder: (context, index) {
                    final timeStr = times[index];
                    final timeMinutes = _timeToMinutes(timeStr);

                    // RENK MANTIĞI
                    Color bgColor;
                    Color textColor;

                    if (timeStr == nextBusTime) {
                      // En yakın saat (YEŞİL)
                      bgColor = Colors.green;
                      textColor = Colors.white;
                    } else if (timeMinutes < currentMinutes) {
                      // Geçmiş saat (GRİ)
                      bgColor = Colors.grey.shade300;
                      textColor = Colors.grey.shade700;
                    } else {
                      // Gelecek diğer saatler (SİYAH/BEYAZ)
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

  // Renk açıklaması için küçük yardımcı widget
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
        title: const Text("Otobüs Hatları"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.texts,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            // Arama Çubuğu
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

            // Hat Listesi
            Expanded(
              child: _filteredBusLines.isEmpty
                  ? const Center(child: Text("Hat bulunamadı"))
                  : ListView.builder(
                      itemCount: _filteredBusLines.length,
                      itemBuilder: (context, index) {
                        final line = _filteredBusLines[index];
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
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                            onTap: () {
                              // Karta basınca saatleri göster
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
