import 'package:flutter/material.dart';
import 'package:ispartaapp/services/colors.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(title: const Text("Hizmetlerimiz")),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.8,
            children: [
              _buildServiceCard(
                title: "Otobüs Seferleri",
                icon: Icons.directions_bus,
                onTap: () {},
              ),
              _buildServiceCard(
                title: "Etkinlikler",
                icon: Icons.calendar_month,
                onTap: () {},
              ),
              _buildServiceCard(
                title: "Nöbetçi Eczaneler",
                icon: Icons.local_pharmacy,
                onTap: () {},
              ),
              _buildServiceCard(
                title: "Acil Numaralar",
                icon: Icons.phone_in_talk,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(gradient: AppColors.cards),
        child: InkWell(
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: Colors.white),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
