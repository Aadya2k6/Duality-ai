class DetectionResult {
  final List<double> box;
  final String label;
  final double score;

  DetectionResult({
    required this.box,
    required this.label,
    required this.score,
  });

  factory DetectionResult.fromJson(Map<String, dynamic> json) =>
      DetectionResult(
        box: List<double>.from(json['box']),
        label: json['label'] as String,
        score: json['score'] as double,
      );

  Map<String, dynamic> toJson() => {'box': box, 'label': label, 'score': score};
}
