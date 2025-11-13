import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sentineleye/models/detection_result.dart';
import 'package:sentineleye/services/ml_service.dart';
import 'package:sentineleye/widgets/bounding_box_overlay.dart';
import 'package:sentineleye/widgets/top_panel.dart';
import 'package:sentineleye/widgets/bottom_bar.dart';
import 'package:sentineleye/widgets/detection_list_panel.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _currentCameraIndex = 0;
  List<DetectionResult> _detections = [];
  bool _isProcessing = false;
  bool _isInitialized = false;
  String? _error;
  int _frameCount = 0;
  int _fps = 0;
  Timer? _fpsTimer;
  bool _isFlashOn = false;
  double _confidenceThreshold = 0.5;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _startFpsCounter();
  }

  void _startFpsCounter() {
    _fpsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _fps = _frameCount;
          _frameCount = 0;
        });
      }
    });
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() => _error = 'No cameras available');
        return;
      }

      await _setupCamera(_currentCameraIndex);
    } catch (e) {
      setState(() => _error = 'Failed to initialize camera: $e');
    }
  }

  Future<void> _setupCamera(int cameraIndex) async {
    if (_controller != null) {
      await _controller!.dispose();
    }

    _controller = CameraController(
      _cameras[cameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await _controller!.initialize();

    if (!mounted) return;

    setState(() => _isInitialized = true);

    _controller!.startImageStream((image) async {
      if (!_isProcessing) {
        _isProcessing = true;
        _frameCount++;

        try {
          final results = await compute(MLService.mockInference, image);

          if (mounted) {
            setState(() => _detections = results);
          }
        } catch (e) {
          debugPrint('Error processing frame: $e');
        } finally {
          _isProcessing = false;
        }
      }
    });
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;

    setState(() {
      _isInitialized = false;
      _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;
    });

    await _setupCamera(_currentCameraIndex);
  }

  Future<void> _toggleFlash() async {
    if (_controller == null) return;

    try {
      final newFlashMode = _isFlashOn ? FlashMode.off : FlashMode.torch;
      await _controller!.setFlashMode(newFlashMode);
      setState(() => _isFlashOn = !_isFlashOn);
    } catch (e) {
      debugPrint('Error toggling flash: $e');
    }
  }

  @override
  void dispose() {
    _fpsTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _error != null
            ? _buildErrorView(theme)
            : !_isInitialized
                ? _buildLoadingView(theme)
                : _buildCameraView(isDarkMode),
      ),
    );
  }

  Widget _buildErrorView(ThemeData theme) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 24),
            Text(_error!,
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: theme.colorScheme.error),
                textAlign: TextAlign.center),
          ],
        ),
      );

  Widget _buildLoadingView(ThemeData theme) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: theme.colorScheme.primary),
            const SizedBox(height: 24),
            Text('Initializing Camera...',
                style:
                    theme.textTheme.titleMedium?.copyWith(color: Colors.white)),
          ],
        ),
      );

  Widget _buildCameraView(bool isDarkMode) {
    final size = MediaQuery.of(context).size;
    final cameraAspectRatio = _controller!.value.aspectRatio;
    final filteredDetections =
        _detections.where((d) => d.score >= _confidenceThreshold).toList();

    return Stack(
      children: [
        Center(
          child: AspectRatio(
            aspectRatio: cameraAspectRatio,
            child: CameraPreview(_controller!),
          ),
        ),
        Positioned.fill(
          child: BoundingBoxOverlay(
            detections: filteredDetections,
            previewSize: size,
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: TopPanel(
            fps: _fps,
            confidenceThreshold: _confidenceThreshold,
            onConfidenceChanged: (value) {
              setState(() => _confidenceThreshold = value);
            },
          ),
        ),
        DetectionListPanel(
          detections: _detections,
          confidenceThreshold: _confidenceThreshold,
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: BottomBar(
            detectionCount: filteredDetections.length,
            controller: _controller,
            onSwitchCamera: _switchCamera,
            isFlashOn: _isFlashOn,
            onToggleFlash: _toggleFlash,
          ),
        ),
      ],
    );
  }
}

class DetectionItem extends StatelessWidget {
  final DetectionResult detection;
  final bool isDarkMode;

  const DetectionItem({
    super.key,
    required this.detection,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final confidence = (detection.score * 100).toStringAsFixed(1);
    final iconMap = {
      'Safety Helmet': Icons.construction,
      'Fire Extinguisher': Icons.fire_extinguisher,
      'Safety Vest': Icons.safety_check,
      'Emergency Exit': Icons.exit_to_app,
      'First Aid Kit': Icons.medical_services,
      'Warning Sign': Icons.warning,
      'Safety Goggles': Icons.remove_red_eye,
    };

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                (isDarkMode ? const Color(0xFF34D399) : const Color(0xFF10B981))
                    .withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(iconMap[detection.label] ?? Icons.check_circle,
              size: 20,
              color: isDarkMode
                  ? const Color(0xFF34D399)
                  : const Color(0xFF10B981)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(detection.label,
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text('Confidence: $confidence%',
                  style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.7))),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color:
                (isDarkMode ? const Color(0xFF34D399) : const Color(0xFF10B981))
                    .withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text('$confidence%',
              style: theme.textTheme.labelMedium?.copyWith(
                  color: isDarkMode
                      ? const Color(0xFF34D399)
                      : const Color(0xFF10B981),
                  fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}
