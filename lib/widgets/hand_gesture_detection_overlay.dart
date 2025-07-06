import 'dart:async';

import 'package:flutter/material.dart';
import 'package:social_media/resources/hand_gesture_detection_service.dart';

class HandGestureDetectionOverlay extends StatefulWidget {
  final VoidCallback onLikeDetected;
  final bool showPreview;

  const HandGestureDetectionOverlay({
    Key? key,
    required this.onLikeDetected,
    this.showPreview = false,
  }) : super(key: key);

  @override
  State<HandGestureDetectionOverlay> createState() =>
      _HandGestureDetectionOverlayState();
}

class _HandGestureDetectionOverlayState
    extends State<HandGestureDetectionOverlay> {
  final HandGestureDetectionService _gestureService =
      HandGestureDetectionService();
  bool _isInitialized = false;
  bool _gestureDetected = false;
  Timer? _gestureTimer;

  @override
  void initState() {
    super.initState();
    _initializeGestureDetection();
  }

  Future<void> _initializeGestureDetection() async {
    await _gestureService.initialize();

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });

      _gestureService.startDetection((gesture) {
        if (gesture == HandGestureType.like) {
          // Show visual feedback that gesture was detected
          setState(() {
            _gestureDetected = true;
          });

          // Cancel existing timer if one exists
          _gestureTimer?.cancel();

          // Reset the gesture detected state after 1 second
          _gestureTimer = Timer(const Duration(seconds: 1), () {
            if (mounted) {
              setState(() {
                _gestureDetected = false;
              });
            }
          });

          widget.onLikeDetected();
        }
      });
    }
  }

  @override
  void dispose() {
    _gestureTimer?.cancel();
    _gestureService.stopDetection();
    _gestureService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showPreview && !_gestureDetected) {
      return const SizedBox.shrink();
    }

    // Stack for showing both camera preview and gesture indicator
    return Stack(
      children: [
        // Camera preview (if enabled)
        if (widget.showPreview && _isInitialized)
          Positioned(
            top: 60, // Ekranın üst kısmında göster
            right: 10,
            child: Container(
              width: 100,
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: _gestureService.getCameraPreviewWidget(),
            ),
          ),

        // Gesture detected indicator
        if (_gestureDetected)
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  const Text(
                    'Beğeni Algılandı!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
