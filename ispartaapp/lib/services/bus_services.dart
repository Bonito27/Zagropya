import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart'; // EKLENDİ: Favoriler için

// ====================================================================
// 0. TEMA AYARLARI
// ====================================================================
class AppTheme {
  static const Color primary = Color(0xFF1565C0);
  static const Color secondary = Color(0xFFFF6F00);
  static const Color background = Color(0xFFF5F7FA);
  static const Color textDark = Color(0xFF263238);
  static const Color textGrey = Color(0xFF78909C);
}

class BusServices extends StatefulWidget {
  const BusServices({super.key});

  @override
  State<BusServices> createState() => _BusServicesState();
}

class _BusServicesState extends State<BusServices> {
  List<dynamic> _allBusLines = [];
  List<dynamic> _displayBusLines = [];

  // 🔥 FAVORİ LİSTESİ
  List<String> _favoriteLines = [];

  TextEditingController _searchController = TextEditingController();
  bool _showOnlyActive = false;

  @override
  void initState() {
    super.initState();
    _loadBusData();
    _loadFavorites(); // Başlarken favorileri çek
  }

  // --- FAVORİ İŞLEMLERİ ---
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoriteLines = prefs.getStringList('favorite_bus_lines') ?? [];
    });
  }

  Future<void> _toggleFavorite(String lineName) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favoriteLines.contains(lineName)) {
        _favoriteLines.remove(lineName); // Varsa çıkar
      } else {
        _favoriteLines.add(lineName); // Yoksa ekle
      }
    });
    // Güncel listeyi kaydet
    await prefs.setStringList('favorite_bus_lines', _favoriteLines);
  }
  // -------------------------

  Future<void> _loadBusData() async {
    try {
      final String response = await rootBundle.loadString(
        'jsons/otobus_saatleri.json',
      );
      final List<dynamic> data = json.decode(response);

      setState(() {
        _allBusLines = data;
        _displayBusLines = data;
      });
    } catch (e) {
      print("JSON Okuma Hatası: $e");
    }
  }

  void _applyFilters() {
    String keyword = _searchController.text.toLowerCase();

    setState(() {
      _displayBusLines = _allBusLines.where((line) {
        bool matchesName = line["hat_adi"].toString().toLowerCase().contains(
          keyword,
        );

        bool matchesActive = true;
        if (_showOnlyActive) {
          String status = _getBusStatusText(line['saatler']);
          matchesActive =
              status.contains("Sıradaki") || status.contains("Son Sefer");
        }

        return matchesName && matchesActive;
      }).toList();
    });
  }

  int _timeToMinutes(String time) {
    try {
      final parts = time.split(':');
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    } catch (e) {
      return 0;
    }
  }

  String _getBusStatusText(List<dynamic> rawTimes) {
    List<String> times = rawTimes.map((e) => e.toString()).toSet().toList();
    times.sort((a, b) => _timeToMinutes(a).compareTo(_timeToMinutes(b)));

    if (times.isEmpty) return "Sefer yok";

    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;

    final firstBusMinutes = _timeToMinutes(times.first);
    final lastBusMinutes = _timeToMinutes(times.last);

    if (currentMinutes < firstBusMinutes) {
      return "Henüz başlamadı (İlk: ${times.first})";
    } else if (currentMinutes > lastBusMinutes) {
      return "Seferler tamamlandı";
    } else {
      for (var time in times) {
        if (_timeToMinutes(time) >= currentMinutes) {
          if (time == times.last) {
            return "Son Sefer: $time";
          }
          return "Sıradaki: $time";
        }
      }
      return "Seferler tamamlandı";
    }
  }

  void _showBusTimes(
    BuildContext context,
    String title,
    List<dynamic> rawTimes,
  ) {
    List<String> times = rawTimes.map((e) => e.toString()).toSet().toList();
    times.sort((a, b) => _timeToMinutes(a).compareTo(_timeToMinutes(b)));

    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;

    String? nextBusTime;
    int targetIndex = 0;

    for (int i = 0; i < times.length; i++) {
      if (_timeToMinutes(times[i]) >= currentMinutes) {
        nextBusTime = times[i];
        targetIndex = i;
        break;
      }
    }

    final ScrollController scrollController = ScrollController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.hasClients && nextBusTime != null) {
            double offset = (targetIndex / 4).floor() * 50.0;
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
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Text(
                "$title Saatleri",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _legendItem(Colors.grey[300]!, "Geçmiş", Colors.grey[600]!),
                  const SizedBox(width: 15),
                  _legendItem(AppTheme.secondary, "Sıradaki", Colors.white),
                  const SizedBox(width: 15),
                  _legendItem(Colors.redAccent, "Son Sefer", Colors.white),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.2,
                  ),
                  itemCount: times.length,
                  itemBuilder: (context, index) {
                    final timeStr = times[index];
                    final timeMinutes = _timeToMinutes(timeStr);

                    Color bgColor;
                    Color textColor;
                    Border? border;

                    if (timeStr == nextBusTime) {
                      if (timeStr == times.last) {
                        bgColor = Colors.redAccent;
                      } else {
                        bgColor = AppTheme.secondary;
                      }
                      textColor = Colors.white;
                    } else if (timeMinutes < currentMinutes) {
                      bgColor = Colors.grey[200]!;
                      textColor = Colors.grey[500]!;
                    } else {
                      bgColor = Colors.white;
                      textColor = AppTheme.textDark;
                      border = Border.all(color: Colors.grey[300]!);
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(8),
                        border: border,
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

  Widget _legendItem(
    Color bg,
    String text,
    Color textCol, {
    bool border = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: border ? Border.all(color: Colors.grey[300]!) : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: textCol,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        title: const Text("Otobüs Saatleri"),
        centerTitle: true,
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textDark,
          ),
          onPressed: () {
            // 🔥 Geri dönerken 'true' gönderiyoruz ki MainPage güncellensin
            Navigator.pop(context, true);
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 10.0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
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
                      onChanged: (value) => _applyFilters(),
                      decoration: const InputDecoration(
                        hintText: 'Hat Ara (Örn: 32)',
                        hintStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(Icons.search, color: AppTheme.primary),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () {
                    setState(() {
                      _showOnlyActive = !_showOnlyActive;
                      _applyFilters();
                    });
                  },
                  borderRadius: BorderRadius.circular(15),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: _showOnlyActive
                          ? AppTheme.secondary
                          : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: _showOnlyActive
                          ? null
                          : Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: Icon(
                      Icons.access_time_filled_rounded,
                      color: _showOnlyActive ? Colors.white : AppTheme.textGrey,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_showOnlyActive)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                "Sadece şu an aktif olan seferler gösteriliyor.",
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          Expanded(
            child: _displayBusLines.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.directions_bus_outlined,
                          size: 60,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Hat bulunamadı.",
                          style: TextStyle(color: AppTheme.textGrey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: _displayBusLines.length,
                    itemBuilder: (context, index) {
                      final line = _displayBusLines[index];
                      String lineName = line['hat_adi'];
                      String statusText = _getBusStatusText(line['saatler']);

                      bool isLastBus = statusText.contains("Son Sefer");
                      bool isActive = statusText.contains("Sıradaki");

                      // 🔥 FAVORİ KONTROLÜ
                      bool isFavorite = _favoriteLines.contains(lineName);

                      Color statusColor;
                      Color stripColor;
                      IconData statusIcon;

                      if (isLastBus) {
                        statusColor = Colors.redAccent;
                        stripColor = Colors.redAccent;
                        statusIcon = Icons.warning_amber_rounded;
                      } else if (isActive) {
                        statusColor = Colors.green[700]!;
                        stripColor = Colors.green;
                        statusIcon = Icons.timelapse;
                      } else {
                        statusColor = AppTheme.textGrey;
                        stripColor = Colors.grey[300]!;
                        statusIcon = Icons.info_outline;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(color: stripColor, width: 5),
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              title: Text(
                                lineName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      statusIcon,
                                      size: 16,
                                      color: statusColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      statusText,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: statusColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // 🔥 SAĞ TARAF: FAVORİ BUTONU VE OK
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Favori Butonu
                                  IconButton(
                                    icon: Icon(
                                      isFavorite
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_border_rounded,
                                      color: isFavorite
                                          ? Colors.redAccent
                                          : Colors.grey[400],
                                    ),
                                    onPressed: () => _toggleFavorite(lineName),
                                  ),
                                  // Ok Butonu
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppTheme.background,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 14,
                                      color: AppTheme.textGrey,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                _showBusTimes(
                                  context,
                                  lineName,
                                  line['saatler'],
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
