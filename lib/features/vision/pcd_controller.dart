import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'pcd_service.dart';

class PcdController extends ChangeNotifier {
  Uint8List? originalImage;
  Uint8List? processedImage;

  final ImagePicker _picker = ImagePicker();

  // ================= STATE LEVEL =================

  int brightnessLevel = 0;
  int contrastLevel = 0;
  int blurLevel = 0;
  int sharpenLevel = 0;

  bool get hasImage => originalImage != null;

  // ================= IMAGE =================

  Future<void> pickImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    final bytes = await file.readAsBytes();

    originalImage = bytes;
    processedImage = bytes;

    _resetLevels();

    notifyListeners();
  }

  void reset() {
    originalImage = null;
    processedImage = null;

    _resetLevels();

    notifyListeners();
  }

  void _resetLevels() {
    brightnessLevel = 0;
    contrastLevel = 0;
    blurLevel = 0;
    sharpenLevel = 0;
  }

  void setImage(Uint8List bytes) {
    originalImage = bytes;
    processedImage = bytes;

    _resetLevels();
    notifyListeners();
  }

  // ================= PIPELINE =================

  void _reprocess() async {
    if (originalImage == null) return;

    Uint8List img = originalImage!;

    img = PcdService.applyBrightness(img, brightnessLevel);
    img = PcdService.applyContrast(img, contrastLevel);
    img = PcdService.applyBlurLevel(img, blurLevel);
    img = PcdService.applySharpenLevel(img, sharpenLevel);

    processedImage = img;
    notifyListeners();
  }

  // ================= ADJUSTMENT =================

  void incBrightness() {
    brightnessLevel = (brightnessLevel + 40).clamp(-255, 255);
    _reprocess();
  }

  void decBrightness() {
    brightnessLevel = (brightnessLevel - 40).clamp(-255, 255);
    _reprocess();
  }

  void incContrast() {
    contrastLevel = (contrastLevel + 20).clamp(-100, 100);
    _reprocess();
  }

  void decContrast() {
    contrastLevel = (contrastLevel - 20).clamp(-100, 100);
    _reprocess();
  }

  void incBlur() {
    blurLevel = (blurLevel + 1).clamp(0, 10);
    _reprocess();
  }

  void decBlur() {
    blurLevel = (blurLevel - 1).clamp(0, 10);
    _reprocess();
  }

  void incSharpen() {
    sharpenLevel = (sharpenLevel + 1).clamp(0, 10);
    _reprocess();
  }

  void decSharpen() {
    sharpenLevel = (sharpenLevel - 1).clamp(0, 10);
    _reprocess();
  }

  // ================= BASIC OPS =================

  void _apply(Uint8List Function(Uint8List) op) {
    if (originalImage == null) return;

    processedImage = op(originalImage!);
    notifyListeners();
  }

  void applyGrayscale() => _apply(PcdService.grayscale);

  void applyEqualize() => _apply(PcdService.equalize);

  void applyInverse() => _apply(PcdService.inverse);

  void applyEdge() => _apply(PcdService.edge);

  // ================= ADVANCED =================

  void applyHistogram() => _apply(PcdService.histogram);

  void applyHighPass() => _apply(PcdService.highPass);

  void applyDenoise() => _apply(PcdService.denoise);

  void applyFourier() => _apply(PcdService.fourier);

  Map<String, double>? lastStats;

  void calculateStats() {
    if (originalImage == null) return;

    lastStats = PcdService.calculateStatistics(originalImage!);

    debugPrint("Mean: ${lastStats!['mean']}");
    debugPrint("Std: ${lastStats!['std']}");

    notifyListeners();
  }
}
