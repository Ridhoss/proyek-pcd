import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:logbook_app_059/features/logbook/models/log_model.dart';
import 'package:logbook_app_059/services/log_local_service.dart';

void main() {
  group('log_local test', () {
    late LogLocalService service;
    late Directory tempDir;

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp();

      Hive.init(tempDir.path);

      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(LogModelAdapter());
      }
    });

    setUp(() async {
      service = LogLocalService();

      if (Hive.isBoxOpen(LogLocalService.boxName)) {
        await Hive.box<LogModel>(LogLocalService.boxName).clear();
      } else {
        final box = await Hive.openBox<LogModel>(LogLocalService.boxName);
        await box.clear();
      }
    });

    tearDownAll(() async {
      await Hive.close();
      await Hive.deleteFromDisk();
    });

    LogModel createLog({
      String? id = "1",
      int teamId = 1,
      bool isSynced = false,
      bool isDeleted = false,
      String description = "Desc",
    }) {
      return LogModel(
        id: id,
        iduser: 1,
        title: "Test",
        date: "2025-01-01",
        description: description,
        category: "Cat",
        type: "Type",
        teamId: teamId,
        isSynced: isSynced,
        isDeleted: isDeleted,
      );
    }

    group('Save & Get Logs', () {
      test('TC01 - Save log berhasil', () async {
        final log = createLog(id: "1");

        await service.saveLog(log);
        final logs = await service.getLogs();

        expect(logs.length, 1);
        expect(logs.first.id, "1");
      });

      test('TC02 - Get semua log', () async {
        await service.saveLog(createLog(id: "1"));
        await service.saveLog(createLog(id: "2"));

        final logs = await service.getLogs();

        expect(logs.length, 2);
      });

      test('TC03 - Filter berdasarkan teamId', () async {
        await service.saveLog(createLog(id: "1", teamId: 1));
        await service.saveLog(createLog(id: "2", teamId: 2));

        final logs = await service.getLogs(1);

        expect(logs.length, 1);
        expect(logs.first.teamId, 1);
      });
    });

    group('Delete Logs', () {
      test('TC04 - Delete log berhasil', () async {
        await service.saveLog(createLog(id: "1"));

        await service.deleteLog("1");
        final logs = await service.getLogs();

        expect(logs.isEmpty, true);
      });

      test('TC09 - Delete id tidak ada', () async {
        await service.deleteLog("999");

        final logs = await service.getLogs();
        expect(logs.isEmpty, true);
      });
    });

    group('Filter Logs', () {
      test('TC07 - isDeleted tidak ditampilkan', () async {
        await service.saveLog(createLog(id: "1", isDeleted: true));

        final logs = await service.getLogs();

        expect(logs.isEmpty, true);
      });

      test('TC08 - teamId tidak cocok', () async {
        await service.saveLog(createLog(id: "1", teamId: 1));

        final logs = await service.getLogs(99);

        expect(logs.isEmpty, true);
      });
    });

    group('Sync Logs', () {
      test('TC05 - Get unsynced logs', () async {
        await service.saveLog(createLog(id: "1", isSynced: false));
        await service.saveLog(createLog(id: "2", isSynced: true));

        final logs = await service.getUnsyncedLogs();

        expect(logs.length, 1);
        expect(logs.first.isSynced, false);
      });

      test('TC10 - Tidak ada unsynced logs', () async {
        await service.saveLog(createLog(id: "1", isSynced: true));

        final logs = await service.getUnsyncedLogs();

        expect(logs.isEmpty, true);
      });

      test('TC06 - Get logs for sync', () async {
        await service.saveLog(createLog(id: "1"));
        await service.saveLog(createLog(id: "2"));

        final logs = await service.getLogsForSync();

        expect(logs.length, 2);
      });

      test('TC12 - Get logs for sync saat kosong', () async {
        final logs = await service.getLogsForSync();

        expect(logs.isEmpty, true);
      });
    });
    
  });
}
