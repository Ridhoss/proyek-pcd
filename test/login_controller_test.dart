import 'package:flutter_test/flutter_test.dart';
import 'package:logbook_app_059/controller/login_controller.dart';

void main() {
  group('Login Tests', () {
    late LoginController controller;

    setUp(() {
      controller = LoginController();
    });

    test('TC01 - Login admin berhasil', () {
      final result = controller.login('admin', '123');

      expect(result, isNotNull);
      expect(result!.role, 'project_manager');
    });

    test('TC02 - Login ridho berhasil', () {
      final result = controller.login('ridho', '123');

      expect(result, isNotNull);
      expect(result!.role, 'frontend');
    });

    test('TC03 - Login salma berhasil', () {
      final result = controller.login('salma', '123');

      expect(result, isNotNull);
      expect(result!.role, 'backend');
    });

    test('TC04 - Get username id 1', () {
      final result = controller.getUsernameById(1);

      expect(result, 'admin');
    });

    test('TC05 - Get username id 2 (duplicate ambil pertama)', () {
      final result = controller.getUsernameById(2);

      expect(result, 'ridho');
    });

    test('TC06 - Login gagal username salah', () {
      final result = controller.login('salah', '123');

      expect(result, isNull);
    });

    test('TC07 - Login gagal password salah', () {
      final result = controller.login('admin', 'wrong');

      expect(result, isNull);
    });

    test('TC08 - Login dengan input kosong', () {
      final result = controller.login('', '');

      expect(result, isNull);
    });

    test('TC09 - Login password kosong', () {
      final result = controller.login('admin', '');

      expect(result, isNull);
    });

    test('TC10 - Get username id tidak ditemukan', () {
      final result = controller.getUsernameById(99);

      expect(result, 'Unknown');
    });

    test('TC11 - Login case sensitive username', () {
      final result = controller.login('Admin', '123');

      expect(result, isNull);
    });

    test('TC12 - Login dengan input aneh (SQL injection-like)', () {
      final result = controller.login("' OR 1=1", '123');

      expect(result, isNull);
    });
  });
}
