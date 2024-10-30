import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Import for base64 decoding

import '../widget/home_header_widget.dart';
import 'old_photo_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<DetectionData> detectionHistory = []; // Store detection history

  @override
  void initState() {
    super.initState();
    _loadSavedData(); // Load saved detection history on init
  }

  Future<void> _loadSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? jsonList = prefs.getStringList('detectionResults_v2');

    if (jsonList != null) {
      detectionHistory = jsonList.map((json) {
        return DetectionData.fromJson(jsonDecode(json));
      }).toList();
      setState(() {});
    }
  }

  Future<void> _clearHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('detectionResults_v2');
    setState(() {
      detectionHistory.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildDetectionHistory(), // Show detection history
            const SizedBox(height: 20),
          ],
        ),
      ),
      // bottomNavigationBar: const CustomBottomNavbar(),
    );
  }

  Widget _buildDetectionHistory() {
    if (detectionHistory.isEmpty) {
      return const SizedBox();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      decoration: BoxDecoration(
        // color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Riwayat Deteksi",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.clear, color: Colors.red),
                onPressed: _clearHistory,
              ),
            ],
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: detectionHistory.length,
            itemBuilder: (context, index) {
              final detection = detectionHistory[index];
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: detection.image.isNotEmpty
                      ? Image.memory(base64Decode(detection.image),
                          width: 50, fit: BoxFit.cover)
                      : const Icon(Icons.image, size: 50),
                  title: Text("Deteksi: ${detection.results.length} Objek"),
                  subtitle: Text(
                    "Durasi: ${detection.duration} ms",
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
