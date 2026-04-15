import 'package:flutter/material.dart';
import 'package:logbook_app_059/features/logbook/models/log_model.dart';
import 'package:logbook_app_059/features/logbook/models/user_model.dart';
import 'package:logbook_app_059/repository/log_repository.dart';
import 'package:uuid/uuid.dart';

class LogController {
  final LogRepository repo = LogRepository();

  final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier([]);
  final ValueNotifier<bool> loadingNotifier = ValueNotifier(false);

  final UserModel currentUser;

  LogController(this.currentUser);

  Future<void> fetchLogs(int teamId) async {
    loadingNotifier.value = true;

    await _refreshLogs(teamId);

    loadingNotifier.value = false;
  }

  Future<void> _refreshLogs(int teamId) async {
    final logs = await repo.getLogs(teamId);

    final visibleLogs = logs.where((log) {
      final isPublic = log.type == "Public";
      final isOwner = log.iduser == currentUser.id;

      return isPublic || isOwner;
    }).toList();

    visibleLogs.sort(
      (a, b) => DateTime.parse(
        b.date,
      ).toLocal().compareTo(DateTime.parse(a.date).toLocal()),
    );

    logsNotifier.value = visibleLogs;
  }

  Future<void> addLog(
    String title,
    String desc,
    String category,
    String type,
    int teamId,
  ) async {
    final newLog = LogModel(
      id: const Uuid().v4(),
      iduser: currentUser.id,
      title: title,
      date: DateTime.now().toString(),
      description: desc.trim(),
      category: category,
      type: type,
      teamId: teamId,
      isSynced: false,
    );

    await repo.addLog(newLog);

    await _refreshLogs(teamId);
  }

  Future<void> updateLog(
    LogModel oldLog,
    String title,
    String desc,
    String category,
    String type,
    int teamId,
  ) async {
    final updatedLog = LogModel(
      id: oldLog.id,
      iduser: oldLog.iduser,
      title: title,
      date: DateTime.now().toString(),
      description: desc.trim(),
      category: category,
      type: type,
      teamId: teamId,
      isSynced: false,
    );

    await repo.updateLog(updatedLog);

    await _refreshLogs(teamId);
  }

  Future<void> removeLog(LogModel log) async {
    await repo.deleteLog(log);

    logsNotifier.value = logsNotifier.value
        .where((l) => l.id != log.id)
        .toList();
  }
}
