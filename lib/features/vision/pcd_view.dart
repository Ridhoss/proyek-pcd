import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:logbook_app_059/features/vision/vision_view.dart';
import 'pcd_controller.dart';

class PcdView extends StatefulWidget {
  const PcdView({super.key});

  @override
  State<PcdView> createState() => _PcdViewState();
}

class _PcdViewState extends State<PcdView> {
  late PcdController controller;

  @override
  void initState() {
    super.initState();
    controller = PcdController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PCD Image Processing")),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return Column(
            children: [
              _buildPreview(),
              const Divider(),

              _buildUploadSection(),
              const Divider(),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildBasicOperations(),
                      const Divider(),
                      _buildAdjustmentControls(),
                      // const Divider(),
                      // _buildAdvancedOperations(),
                      // const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ================= PREVIEW =================

  Widget _buildPreview() {
    return SizedBox(
      height: 250,
      child: Row(
        children: [
          Expanded(child: _imageBox(controller.originalImage, "Original")),
          Expanded(child: _imageBox(controller.processedImage, "Processed")),
        ],
      ),
    );
  }

  Widget _imageBox(Uint8List? image, String title) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            color: Colors.black12,
            width: double.infinity,
            child: Text(title, textAlign: TextAlign.center),
          ),
          Expanded(
            child: image == null
                ? const Center(child: Text("No Image"))
                : Image.memory(image, fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }

  // ================= UPLOAD =================

  Widget _buildUploadSection() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 10,
        children: [
          ElevatedButton.icon(
            onPressed: () async {
              final image = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const VisionView(mode: VisionMode.capture),
                ),
              );

              if (image != null) {
                controller.setImage(image);
              }
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text("Take Photo"),
          ),
          ElevatedButton.icon(
            onPressed: controller.pickImage,
            icon: const Icon(Icons.upload),
            label: const Text("Upload"),
          ),
          ElevatedButton.icon(
            onPressed: controller.reset,
            icon: const Icon(Icons.refresh),
            label: const Text("Reset"),
          ),
        ],
      ),
    );
  }

  // ================= BASIC =================

  Widget _buildBasicOperations() {
    return Column(
      children: [
        const Text(
          "Basic Operations",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _btn("Grayscale", controller.applyGrayscale),
            _btn("Equalize", controller.applyEqualize),
            _btn("Inverse", controller.applyInverse),
            _btn("Edge", controller.applyEdge),
          ],
        ),
      ],
    );
  }

  // ================= ADJUSTMENT (+ / -) =================

  Widget _buildAdjustmentControls() {
    return Column(
      children: [
        const Text(
          "Adjustments (+ / -)",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        _adjustRow(
          "Brightness",
          controller.brightnessLevel,
          controller.decBrightness,
          controller.incBrightness,
        ),

        _adjustRow(
          "Contrast",
          controller.contrastLevel,
          controller.decContrast,
          controller.incContrast,
        ),

        _adjustRow(
          "Blur",
          controller.blurLevel,
          controller.decBlur,
          controller.incBlur,
        ),

        _adjustRow(
          "Sharpen",
          controller.sharpenLevel,
          controller.decSharpen,
          controller.incSharpen,
        ),
      ],
    );
  }

  Widget _adjustRow(
    String title,
    int value,
    VoidCallback minus,
    VoidCallback plus,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$title (${value >= 0 ? '+' : ''}$value)"),
          Row(
            children: [
              IconButton(
                onPressed: controller.hasImage ? minus : null,
                icon: const Icon(Icons.remove),
              ),
              IconButton(
                onPressed: controller.hasImage ? plus : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= ADVANCED =================

  // Widget _buildAdvancedOperations() {
  //   return Column(
  //     children: [
  //       const Text(
  //         "Advanced Operations",
  //         style: TextStyle(fontWeight: FontWeight.bold),
  //       ),
  //       Wrap(
  //         spacing: 8,
  //         runSpacing: 8,
  //         children: [
  //           _btn("Histogram", controller.applyHistogram),
  //           // _btn("High Pass", controller.applyHighPass),
  //           _btn("Denoise", controller.applyDenoise),
  //           // _btn("Fourier", controller.applyFourier),
  //           // _btn("Statistics", controller.calculateStats),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  // ================= BUTTON =================

  Widget _btn(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: controller.hasImage ? onPressed : null,
      child: Text(text),
    );
  }
}
