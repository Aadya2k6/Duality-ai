import 'dart:math';
import 'package:camera/camera.dart';
import 'package:sentineleye/models/detection_result.dart';

class MLService {
  static final List<String> _safetyLabels = [
    'Safety Helmet',
    'Fire Extinguisher',
    'Safety Vest',
    'Emergency Exit',
    'First Aid Kit',
    'Warning Sign',
    'Safety Goggles',
  ];

  static Future<List<DetectionResult>> mockInference(CameraImage image) async {
    await Future.delayed(const Duration(milliseconds: 50));

    final random = Random();
    final results = <DetectionResult>[];

    final helmetBox = [
      0.15 + random.nextDouble() * 0.1,
      0.1 + random.nextDouble() * 0.1,
      0.35 + random.nextDouble() * 0.1,
      0.3 + random.nextDouble() * 0.1,
    ];
    results.add(DetectionResult(
      box: helmetBox,
      label: 'Safety Helmet',
      score: 0.85 + random.nextDouble() * 0.14,
    ));

    final extinguisherBox = [
      0.55 + random.nextDouble() * 0.1,
      0.5 + random.nextDouble() * 0.1,
      0.75 + random.nextDouble() * 0.1,
      0.8 + random.nextDouble() * 0.1,
    ];
    results.add(DetectionResult(
      box: extinguisherBox,
      label: 'Fire Extinguisher',
      score: 0.88 + random.nextDouble() * 0.11,
    ));

    if (random.nextDouble() > 0.6) {
      final vestBox = [
        0.3 + random.nextDouble() * 0.2,
        0.35 + random.nextDouble() * 0.15,
        0.5 + random.nextDouble() * 0.2,
        0.65 + random.nextDouble() * 0.15,
      ];
      results.add(DetectionResult(
        box: vestBox,
        label: 'Safety Vest',
        score: 0.80 + random.nextDouble() * 0.18,
      ));
    }

    return results;
  }

  static List<DetectionResult> processCameraImage(CameraImage image) {
    throw UnimplementedError(
        'Use compute() to call mockInference in background isolate');
  }
}
