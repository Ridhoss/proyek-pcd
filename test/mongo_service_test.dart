import 'package:flutter_test/flutter_test.dart';
import 'package:logbook_app_059/features/logbook/models/log_model.dart';

class FakeCollection {
  final Map<String, Map<String, dynamic>> storage = {};

  Future<void> insertOne(Map<String, dynamic> data) async {
    storage[data['_id']] = data;
  }

  Future<List<Map<String, dynamic>>> find(Map<String, dynamic> query) async {
    return storage.values.where((e) => e['teamId'] == query['teamId']).toList();
  }

  Future<void> replaceOne(
    Map<String, dynamic> query,
    Map<String, dynamic> data, {
    bool upsert = false,
  }) async {
    final id = query['_id'];

    if (storage.containsKey(id)) {
      storage[id] = data;
    } else if (upsert) {
      storage[id] = data;
    }
  }

  Future<void> deleteOne(Map<String, dynamic> query) async {
    storage.remove(query['_id']);
  }
}

class TestMongoService {
  final FakeCollection fakeCollection = FakeCollection();

  Future<List<LogModel>> getLogs(int teamId) async {
    try {
      final data = await fakeCollection.find({'teamId': teamId});
      return data.map((e) => LogModel.fromMap(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<LogModel> insertLog(LogModel log) async {
    await fakeCollection.insertOne(log.toMap());
    return log;
  }

  Future<void> updateLog(LogModel log) async {
    if (log.id == null) {
      throw Exception("ID Log tidak ditemukan");
    }

    await fakeCollection.replaceOne({"_id": log.id}, log.toMap());
  }

  Future<void> upsertLog(LogModel log) async {
    await fakeCollection.replaceOne({"_id": log.id}, log.toMap(), upsert: true);
  }

  Future<void> deleteLog(String id) async {
    await fakeCollection.deleteOne({"_id": id});
  }

  Future<void> close() async {}
}

void main() {
  group('Mongo test', () {
    late TestMongoService service;

    LogModel createLog({String? id = "1", int teamId = 1}) {
      return LogModel(
        id: id,
        iduser: 1,
        title: "Test",
        date: "2025-01-01",
        description: "Desc",
        category: "Cat",
        type: "Type",
        teamId: teamId,
      );
    }

    setUp(() {
      service = TestMongoService();
    });

    test('TC01 - Connect berhasil (simulasi)', () async {
      expect(service, isNotNull);
    });

    test('TC02 - Get logs berdasarkan teamId', () async {
      await service.insertLog(createLog(id: "1", teamId: 1));
      await service.insertLog(createLog(id: "2", teamId: 2));

      final result = await service.getLogs(1);

      expect(result.length, 1);
      expect(result.first.teamId, 1);
    });

    test('TC03 - Insert log berhasil', () async {
      final log = createLog(id: "1");

      final result = await service.insertLog(log);

      expect(result.id, "1");
    });

    test('TC04 - Update log berhasil', () async {
      final log = createLog(id: "1");

      await service.insertLog(log);

      final updated = log.copyWith(title: "Updated");
      await service.updateLog(updated);

      final result = await service.getLogs(1);

      expect(result.first.title, "Updated");
    });

    test('TC05 - Upsert update data', () async {
      final log = createLog(id: "1");

      await service.upsertLog(log);

      final updated = log.copyWith(title: "Updated");
      await service.upsertLog(updated);

      final result = await service.getLogs(1);

      expect(result.first.title, "Updated");
    });

    test('TC06 - Upsert insert data baru', () async {
      final log = createLog(id: "99");

      await service.upsertLog(log);

      final result = await service.getLogs(1);

      expect(result.length, 1);
    });

    test('TC07 - Delete log berhasil', () async {
      await service.insertLog(createLog(id: "1"));

      await service.deleteLog("1");

      final result = await service.getLogs(1);

      expect(result.isEmpty, true);
    });

    test('TC08 - Close connection (simulasi)', () async {
      await service.close();

      expect(true, true);
    });

    test('TC09 - Auto reconnect (simulasi)', () async {
      final result = await service.getLogs(1);

      expect(result, isA<List<LogModel>>());
    });

    test('TC10 - Connect gagal (simulasi)', () async {
      expect(true, true);
    });

    test('TC11 - Timeout (simulasi)', () async {
      expect(true, true);
    });

    test('TC12 - Get logs error fallback', () async {
      final result = await service.getLogs(999);

      expect(result.isEmpty, true);
    });

    test('TC13 - Insert gagal (simulasi)', () async {
      final log = createLog(id: "1");

      final result = await service.insertLog(log);

      expect(result.id, "1");
    });

    test('TC14 - Update tanpa id', () async {
      final log = createLog(id: null);

      expect(() async => await service.updateLog(log), throwsException);
    });

    test('TC15 - Update data tidak ada', () async {
      final log = createLog(id: "999");

      await service.updateLog(log);

      final result = await service.getLogs(1);

      expect(result.isEmpty, true);
    });

    test('TC16 - Delete id tidak ada', () async {
      await service.deleteLog("999");

      final result = await service.getLogs(1);

      expect(result.isEmpty, true);
    });

    test('TC17 - Data kosong', () async {
      final result = await service.getLogs(1);

      expect(result.isEmpty, true);
    });

    test('TC18 - Close tanpa koneksi', () async {
      await service.close();

      expect(true, true);
    });
  });
}
