import 'package:flutter/material.dart';
import 'package:sentineleye/models/detection_result.dart';

class DetectionListPanel extends StatelessWidget {
  final List<DetectionResult> detections;
  final double confidenceThreshold;

  const DetectionListPanel({
    super.key,
    required this.detections,
    required this.confidenceThreshold,
  });

  @override
  Widget build(BuildContext context) {
    final filteredDetections =
        detections.where((d) => d.score >= confidenceThreshold).toList();

    if (filteredDetections.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark
        ? Colors.black.withValues(alpha: 0.7)
        : Colors.white.withValues(alpha: 0.85);

    return Positioned(
      top: 120,
      right: 16,
      bottom: 120,
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Live Feed',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                itemCount: filteredDetections.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  return _DetectionCard(
                    detection: filteredDetections[index],
                    index: index,
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

class _DetectionCard extends StatelessWidget {
  final DetectionResult detection;
  final int index;

  const _DetectionCard({
    required this.detection,
    required this.index,
  });

  static const List<Color> _boxColors = [
    Color(0xFF34D399),
    Color(0xFF60A5FA),
    Color(0xFFFBBF24),
    Color(0xFFF87171),
    Color(0xFFA78BFA),
    Color(0xFFEC4899),
  ];

  Color get _boxColor => _boxColors[index % _boxColors.length];

  IconData _getIconForLabel(String label) {
    const iconMap = {
      'Safety Helmet': Icons.construction,
      'Fire Extinguisher': Icons.fire_extinguisher,
      'Safety Vest': Icons.safety_check,
      'Emergency Exit': Icons.exit_to_app,
      'First Aid Kit': Icons.medical_services,
      'Warning Sign': Icons.warning,
      'Safety Goggles': Icons.remove_red_eye,
    };
    return iconMap[label] ?? Icons.check_circle;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final confidence = (detection.score * 100).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _boxColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _boxColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _boxColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  detection.label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                _getIconForLabel(detection.label),
                size: 16,
                color: _boxColor,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _boxColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$confidence%',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _boxColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
