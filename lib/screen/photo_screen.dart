import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Import for base64 encoding

import '../service/object_detection.dart';
import '../widget/custom_app_bar.dart';
import '../widget/custom_button.dart';

class DetectionData {
  final List<ObjectResult> results;
  final String duration;
  final String image;

  DetectionData(
      {required this.results, required this.duration, required this.image});

  Map<String, dynamic> toJson() {
    return {
      'results': results.map((result) => result.toJson()).toList(),
      'duration': duration,
      'image': image,
    };
  }

  static DetectionData fromJson(Map<String, dynamic> json) {
    return DetectionData(
      results: (json['results'] ?? [])
          .map<ObjectResult>((data) => ObjectResult.fromJson(data ?? {}))
          .toList(),
      duration: json['duration'],
      image: json['image'],
    );
  }
}

class PhotoScreen extends StatefulWidget {
  const PhotoScreen({super.key});

  @override
  State<PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  final imagePicker = ImagePicker();
  ObjectDetection? objectDetection;

  Uint8List? image;
  DetectionData? detectionData;

  @override
  void initState() {
    super.initState();
    objectDetection = ObjectDetection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Deteksi Dengan Gambar"),
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: Center(
              child: (image != null)
                  ? Image.memory(image!)
                  : const Text("No image selected",
                      style: TextStyle(fontSize: 20, color: Colors.grey)),
            ),
          ),
          const SizedBox(height: 10),
          _statsWidget(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result =
              await imagePicker.pickImage(source: ImageSource.gallery);
          if (result != null) {
            var (imageResult, detectionResult, durationResult) =
                objectDetection!.analyseImage(result.path);

            image = imageResult;
            detectionData = DetectionData(
              results: detectionResult,
              duration: durationResult.toString(),
              image: base64Encode(imageResult), // Convert image to base64
            );
            setState(() {});
          }
        },
        child: const Icon(Icons.photo, size: 32),
      ),
    );
  }

  Widget _statsWidget() {
    return (image != null && detectionData != null)
        ? Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(200),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Jumlah Deteksi (${detectionData!.results.length})",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: detectionData!.results.length,
                      itemBuilder: (context, index) {
                        final e = detectionData!.results[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: LinearPercentIndicator(
                            animation: true,
                            lineHeight: 25.0,
                            animationDuration: 1000,
                            percent: e.score,
                            leading: Text(e.object, textAlign: TextAlign.start),
                            center: Text(
                                "${(e.score * 100).toStringAsFixed(1)}%",
                                textAlign: TextAlign.center),
                            barRadius: const Radius.circular(10),
                            progressColor: Colors.green,
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      "Durasi: ${detectionData!.duration} ms",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    onPressed: _saveData,
                    text: "Simpan Data",
                    width: double.infinity,
                  ),
                ],
              ),
            ),
          )
        : const SizedBox.shrink();
  }

  Future<void> _saveData() async {
    if (detectionData != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String jsonData = jsonEncode(detectionData!.toJson());
      List<String>? existingResults =
          prefs.getStringList('detectionResults_v2') ?? [];
      existingResults.add(jsonData);
      await prefs
          .setStringList('detectionResults_v2', existingResults)
          .then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Data berhasil disimpan!"),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      });

      // Show a simple snackbar notification
    }
  }
}
