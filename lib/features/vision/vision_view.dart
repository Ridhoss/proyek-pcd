import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:logbook_app_059/features/vision/vision_controller.dart';
import 'package:logbook_app_059/features/vision/damage_painter.dart';
import 'package:permission_handler/permission_handler.dart';

class VisionView extends StatefulWidget {
  const VisionView({super.key});

  @override
  State<VisionView> createState() => _VisionViewState();
}

class _VisionViewState extends State<VisionView> {
  late VisionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VisionController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Smart Patrol Vision")),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🔦 Flash
          FloatingActionButton(
            heroTag: "flash",
            backgroundColor: _controller.isFlashOn
                ? Colors.orange
                : Colors.grey,
            onPressed: _controller.toggleFlash,
            child: Icon(
              _controller.isFlashOn ? Icons.flash_on : Icons.flash_off,
            ),
          ),

          const SizedBox(width: 12),

          // 👁️ Overlay
          FloatingActionButton(
            heroTag: "overlay",
            backgroundColor: _controller.isOverlayOn
                ? Colors.blue
                : Colors.grey,
            onPressed: _controller.toggleOverlay,
            child: Icon(
              _controller.isOverlayOn ? Icons.visibility : Icons.visibility_off,
            ),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          if (!_controller.isInitialized) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Menghubungkan ke Sensor Visual..."),
                ],
              ),
            );
          }

          if (_controller.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    _controller.errorMessage!,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () async {
                      await openAppSettings();
                    },
                    child: const Text("Open Settings"),
                  ),
                ],
              ),
            );
          }

          return _buildVisionStack();
        },
      ),
    );
  }

  Widget _buildVisionStack() {
    final controller = _controller.controller!;

    return Stack(
      children: [
        Center(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: controller.value.previewSize!.height,
              height: controller.value.previewSize!.width,
              child: CameraPreview(controller),
            ),
          ),
        ),

        Positioned.fill(
          child: CustomPaint(
            painter: _controller.isOverlayOn
                ? DamagePainter(results: _controller.results)
                : null,
          ),
        ),
      ],
    );
  }
}
