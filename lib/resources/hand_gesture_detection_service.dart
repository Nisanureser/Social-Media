import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

enum HandGestureType {
  none,
  like, // Beğeni için kullanılacak hareket
}

class HandGestureDetectionService {
  static final HandGestureDetectionService _instance =
      HandGestureDetectionService._internal();
  factory HandGestureDetectionService() => _instance;
  HandGestureDetectionService._internal();

  final PoseDetector _poseDetector = GoogleMlKit.vision.poseDetector();

  CameraController? _cameraController;
  bool _isProcessing = false;
  bool _isCameraInitialized = false;
  Function(HandGestureType)? _onGestureDetected;
  // Sürekli hareket algılamasını önlemek için
  DateTime? _lastDetectionTime;
  static const _detectionCooldown =
      Duration(seconds: 5); // Algılama aralığını artırdık

  Future<void> initialize() async {
    if (_isCameraInitialized) return;

    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      if (kDebugMode) {
        print('Kamera bulunamadı');
      }
      return;
    }

    // Kullanıcı deneyimi için ön kamerayı kullanıyoruz
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      _isCameraInitialized = true;
      if (kDebugMode) {
        print('Kamera başarıyla başlatıldı');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Kamera başlatılırken hata oluştu: $e');
      }
    }
  }

  void startDetection(Function(HandGestureType) onGestureDetected) {
    if (!_isCameraInitialized || _cameraController == null) {
      if (kDebugMode) {
        print('Kamera başlatılmadı');
      }
      return;
    }

    _onGestureDetected = onGestureDetected;

    _cameraController!.startImageStream((CameraImage image) {
      if (_isProcessing) return;
      _isProcessing = true;

      _processImage(image);
    });

    if (kDebugMode) {
      print('El hareketi algılama başlatıldı');
    }
  }

  void stopDetection() {
    if (_cameraController != null &&
        _cameraController!.value.isStreamingImages) {
      _cameraController!.stopImageStream();
      if (kDebugMode) {
        print('El hareketi algılama durduruldu');
      }
    }
  }

  void dispose() {
    _poseDetector.close();
    _cameraController?.dispose();
    _isCameraInitialized = false;
    if (kDebugMode) {
      print('El hareketi algılama servisi kapatıldı');
    }
  }

  Future<void> _processImage(CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());

    final imageRotation = InputImageRotation.values.firstWhere(
      (element) =>
          element.rawValue == _cameraController!.description.sensorOrientation,
      orElse: () => InputImageRotation.rotation0deg,
    );

    final inputImageFormat = InputImageFormat.nv21; // Default format

    final inputImageData = InputImageMetadata(
      size: imageSize,
      rotation: imageRotation,
      format: inputImageFormat,
      bytesPerRow: image.planes.first.bytesPerRow,
    );

    final inputImage = InputImage.fromBytes(
      bytes: bytes,
      metadata: inputImageData,
    );

    try {
      final poses = await _poseDetector.processImage(inputImage);
      _detectLikeGesture(poses);
    } catch (e) {
      if (kDebugMode) {
        print('Görüntü işlenirken hata oluştu: $e');
      }
    } finally {
      _isProcessing = false;
    }
  }

  void _detectLikeGesture(List<Pose> poses) {
    // Eğer yakın zamanda bir hareket algıladıysak, belirli bir süre bekleyelim
    if (_lastDetectionTime != null) {
      final timeSinceLastDetection =
          DateTime.now().difference(_lastDetectionTime!);
      if (timeSinceLastDetection < _detectionCooldown) {
        return;
      }
    }

    if (poses.isEmpty) return;

    final pose = poses.first;

    // Omuzların ve ellerin pozisyonlarını kontrol et
    final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];

    // Omuzları referans olarak kullanmak için
    if (rightShoulder == null && leftShoulder == null) return;

    // Sağ el yukarıda mı kontrol et
    if (rightShoulder != null && rightWrist != null) {
      // El omuzdan yukarıda ise (y değeri küçükse yukarıdadır)
      if (rightWrist.y < rightShoulder.y - 0.1) {
        // Biraz boşluk bırak
        if (kDebugMode) {
          print(
              'Sağ el yukarıda algılandı: ${rightWrist.y} < ${rightShoulder.y}');
        }
        _lastDetectionTime = DateTime.now();
        if (_onGestureDetected != null) {
          _onGestureDetected!(HandGestureType.like);
        }
        return;
      }
    }

    // Sol el yukarıda mı kontrol et
    if (leftShoulder != null && leftWrist != null) {
      if (leftWrist.y < leftShoulder.y - 0.1) {
        // Biraz boşluk bırak
        if (kDebugMode) {
          print(
              'Sol el yukarıda algılandı: ${leftWrist.y} < ${leftShoulder.y}');
        }
        _lastDetectionTime = DateTime.now();
        if (_onGestureDetected != null) {
          _onGestureDetected!(HandGestureType.like);
        }
      }
    }
  }

  // Kamera önizleme widget'ı
  Widget getCameraPreviewWidget() {
    if (!_isCameraInitialized || _cameraController == null) {
      return const Center(child: Text('Kamera başlatılmadı'));
    }

    if (!_cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return CameraPreview(_cameraController!);
  }
}
