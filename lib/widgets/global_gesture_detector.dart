import 'package:flutter/material.dart';
import 'package:social_media/utils/hand_gesture_detection_service.dart';

class GlobalGestureDetector extends StatefulWidget {
  final Widget child;
  final Function(HandGestureType) onGestureDetected;
  final bool enabled;

  const GlobalGestureDetector({
    Key? key,
    required this.child,
    required this.onGestureDetected,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<GlobalGestureDetector> createState() => _GlobalGestureDetectorState();
}

class _GlobalGestureDetectorState extends State<GlobalGestureDetector> {
  final HandGestureDetectionService _gestureService =
      HandGestureDetectionService();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      _initializeGestureDetection();
    }
  }

  @override
  void didUpdateWidget(GlobalGestureDetector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _initializeGestureDetection();
      } else {
        _gestureService.stopDetection();
      }
    }
  }

  Future<void> _initializeGestureDetection() async {
    await _gestureService.initialize();

    if (mounted) {      setState(() {
        _isInitialized = true;
      });
      
      _gestureService.startDetection((gesture) {
        if (gesture == HandGestureType.like) {
          print('El hareketi algılandı: Beğeni hareketi!');
          if (mounted && widget.onGestureDetected != null) {
            // Hareket algılandığında sadece bir kez çağırılacak
            widget.onGestureDetected(gesture);
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _gestureService.stopDetection();
    _gestureService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.enabled && _isInitialized)
          Positioned(
            top: 60,
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
      ],
    );
  }
}
