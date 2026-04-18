import 'dart:async';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:logbook_app_059/features/vision/damage_painter.dart';
import 'package:permission_handler/permission_handler.dart';

class VisionController extends ChangeNotifier with WidgetsBindingObserver {
  CameraController? controller;
  bool isInitialized = false;
  String? errorMessage;
  bool isFlashOn = false;
  bool isOverlayOn = true;
  Timer? _timer;

  VisionController() {
    WidgetsBinding.instance.addObserver(this);
    initCamera();
  }

  Future<void> initCamera() async {
    bool hasPermission = await checkCameraPermission();

    if (!hasPermission) {
      errorMessage = "No Camera Access";
      notifyListeners();
      return;
    }

    final cameras = await availableCameras();

    controller = CameraController(
      cameras[0],
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await controller!.initialize();

    isInitialized = true;
    startMockDetection();

    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (controller == null || !controller!.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      controller!.dispose();
    } else if (state == AppLifecycleState.resumed) {
      initCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    super.dispose();
  }

  List<DetectionResult> results = [];

  void startMockDetection() {
    final random = Random();

    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      results = [
        DetectionResult(
          rect: Rect.fromLTWH(
            random.nextDouble() * 0.6,
            random.nextDouble() * 0.6,
            0.2 + random.nextDouble() * 0.2,
            0.2 + random.nextDouble() * 0.2,
          ),
          label: "D40 Pothole",
          score: 0.7 + random.nextDouble() * 0.3,
        ),
        DetectionResult(
          rect: Rect.fromLTWH(
            random.nextDouble() * 0.6,
            random.nextDouble() * 0.6,
            0.2 + random.nextDouble() * 0.2,
            0.2 + random.nextDouble() * 0.2,
          ),
          label: "D20 Crack",
          score: 0.7 + random.nextDouble() * 0.3,
        ),
      ];

      notifyListeners();
    });
  }

  Future<void> toggleFlash() async {
    isFlashOn = !isFlashOn;

    if (controller != null) {
      await controller!.setFlashMode(
        isFlashOn ? FlashMode.torch : FlashMode.off,
      );
    }

    notifyListeners();
  }

  void toggleOverlay() {
    isOverlayOn = !isOverlayOn;
    notifyListeners();
  }

  Future<bool> checkCameraPermission() async {
    var status = await Permission.camera.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      status = await Permission.camera.request();
      return status.isGranted;
    }

    if (status.isPermanentlyDenied) {
      errorMessage = "No Camera Access";
      notifyListeners();
      return false;
    }

    return false;
  }
}
