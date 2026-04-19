import 'dart:typed_data';
import 'dart:math' as math;
import 'package:opencv_dart/opencv_dart.dart' as cv;

class PcdService {
  
  static Uint8List _encode(cv.Mat mat) {
    final (success, bytes) = cv.imencode(".jpg", mat);
    if (!success) throw Exception("Encode gagal");
    return bytes;
  }

  static cv.Mat _decode(Uint8List bytes) {
    return cv.imdecode(bytes, cv.IMREAD_COLOR);
  }

  static cv.Mat _decodeGray(Uint8List bytes) {
    return cv.imdecode(bytes, cv.IMREAD_GRAYSCALE);
  }

  static Uint8List grayscale(Uint8List bytes) {
    final mat = _decode(bytes);
    final gray = cv.cvtColor(mat, cv.COLOR_BGR2GRAY);
    return _encode(gray);
  }

  static Uint8List equalize(Uint8List bytes) {
    final gray = _decodeGray(bytes);
    final eq = cv.equalizeHist(gray);
    return _encode(eq);
  }

  static Uint8List inverse(Uint8List bytes) {
    final mat = _decode(bytes);
    final inv = cv.bitwiseNOT(mat);
    return _encode(inv);
  }

  static Uint8List edge(Uint8List bytes) {
    final gray = _decodeGray(bytes);
    final edge = cv.canny(gray, 100, 200);
    return _encode(edge);
  }

  static Uint8List applyBrightness(Uint8List bytes, int value) {
    final mat = _decode(bytes);

    final result = cv.convertScaleAbs(mat, alpha: 1, beta: value.toDouble());

    return _encode(result);
  }

  // Contrast
  static Uint8List applyContrast(Uint8List bytes, int value) {
    final mat = _decode(bytes);

    double alpha = 1 + (value / 50.0);

    final result = cv.convertScaleAbs(mat, alpha: alpha, beta: 0);

    return _encode(result);
  }

  static Uint8List applyBlurLevel(Uint8List bytes, int level) {
    final mat = _decode(bytes);

    if (level == 0) return _encode(mat);

    int k = (level * 4) + 1;

    final result = cv.gaussianBlur(mat, (k, k), 0);
    return _encode(result);
  }

  static Uint8List applySharpenLevel(Uint8List bytes, int level) {
    var result = _decode(bytes);

    for (int i = 0; i < level; i++) {
      final blur = cv.gaussianBlur(result, (5, 5), 0);
      final detail = cv.subtract(result, blur);

      result = cv.add(result, detail);
      result = cv.add(result, detail);
    }

    return _encode(result);
  }

  static Uint8List highPass(Uint8List bytes) {
    final mat = _decode(bytes);
    final blur = cv.gaussianBlur(mat, (9, 9), 0);
    final result = cv.subtract(mat, blur);
    return _encode(result);
  }

  static Uint8List histogram(Uint8List bytes) {
    final gray = _decodeGray(bytes);

    final result = cv.Mat.zeros(gray.rows, gray.cols, gray.type);

    cv.normalize(gray, result, alpha: 0, beta: 255, normType: cv.NORM_MINMAX);

    return _encode(result);
  }

  static Uint8List denoise(Uint8List bytes) {
    final mat = _decode(bytes);
    final result = cv.gaussianBlur(mat, (7, 7), 0);
    return _encode(result);
  }

  static Uint8List fourier(Uint8List bytes) {
    final gray = _decodeGray(bytes);

    final dft = cv.dft(gray);

    final result = cv.Mat.zeros(dft.rows, dft.cols, dft.type);

    cv.normalize(dft, result, alpha: 0, beta: 255, normType: cv.NORM_MINMAX);

    return _encode(result);
  }

  static Map<String, double> calculateStatistics(Uint8List bytes) {
    final gray = _decodeGray(bytes);

    double sum = 0;
    double sumSq = 0;
    int total = gray.rows * gray.cols;

    for (int i = 0; i < gray.rows; i++) {
      for (int j = 0; j < gray.cols; j++) {
        final val = gray.at(i, j);

        double pixel;
        if (val is num) {
          pixel = val.toDouble();
        } else if (val is List) {
          pixel = val[0].toDouble();
        } else {
          pixel = 0;
        }

        sum += pixel;
        sumSq += pixel * pixel;
      }
    }

    final mean = sum / total;
    final variance = (sumSq / total) - (mean * mean);

    return {"mean": mean, "std": math.sqrt(variance)};
  }
}
