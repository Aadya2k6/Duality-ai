# Safety Detection App Architecture

## Overview
A high-performance real-time object detection application using Flutter with isolate-based ML inference pipeline for maximum performance.

## Technical Architecture

### 1. Data Models
- **DetectionResult** (`lib/models/detection_result.dart`)
  - Normalized bounding box coordinates [x_min, y_min, x_max, y_max] (0.0-1.0)
  - Detection label (Safety Helmet, Fire Extinguisher, etc.)
  - Confidence score
  - JSON serialization for isolate communication

### 2. Services Layer
- **MLService** (`lib/services/ml_service.dart`)
  - Mock inference function with 50ms latency simulation
  - Accepts raw CameraImage input
  - Returns list of DetectionResult objects
  - Production-ready: Single function swap for real TFLite model
  - Runs in background isolate via `compute()`

### 3. UI Components
- **CameraScreen** (`lib/screens/camera_screen.dart`)
  - Camera initialization and lifecycle management
  - Real-time frame streaming pipeline
  - Isolate-based frame processing
  - State management for detection results
  - Layered UI: CameraPreview + BoundingBoxOverlay

- **BoundingBoxOverlay** (`lib/widgets/bounding_box_overlay.dart`)
  - CustomPainter implementation
  - Coordinate scaling (normalized → pixel)
  - Colored bounding boxes per detection
  - Label and confidence score rendering
  - Performance-optimized drawing

### 4. Design Approach
- Modern, sleek UI with vibrant colors
- Flat design without heavy shadows
- Real-time performance indicators
- Generous spacing and elegant typography
- Detection count and FPS display

## Performance Strategy
- Background isolate processing prevents UI blocking
- Target: <50ms inference latency
- Efficient frame streaming pipeline
- Optimized CustomPainter for overlay rendering

## Production Conversion
To convert to production with real ML model:
1. Add TFLite model file to assets
2. Replace `mockInference` in MLService with real TFLite inference
3. Keep all architecture, UI, and isolate pipeline unchanged
