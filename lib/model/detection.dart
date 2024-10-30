import '../service/object_detection.dart';

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
