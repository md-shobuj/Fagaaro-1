import 'dart:convert';
import 'dart:async';
import 'package:injectable/injectable.dart';
import '../../../../core/network/network_info.dart';
import '../../../todos/data/models/todo_model.dart';
import '../../../todos/domain/repositories/todos_repository.dart';
import '../../../todos/data/datasources/todos_local_data_source.dart';

@lazySingleton
class SyncManager {
  final NetworkInfo _networkInfo;
  final TodosLocalDataSource _localDataSource;
  final TodosRepository _todosRepository;
  StreamSubscription<bool>? _connectivitySubscription;

  SyncManager({
    required NetworkInfo networkInfo,
    required TodosLocalDataSource localDataSource,
    required TodosRepository todosRepository,
  })  : _networkInfo = networkInfo,
        _localDataSource = localDataSource,
        _todosRepository = todosRepository;

  @postConstruct
  void initialize() {
    _connectivitySubscription = _networkInfo.onConnectivityChanged.listen((isConnected) {
      if (isConnected) {
        processSyncQueue();
      }
    });
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }

  Future<void> processSyncQueue() async {
    try {
      final queue = await _localDataSource.getSyncQueue();
      if (queue.isEmpty) return;

      final grouped = <String, List<TodoModel>>{};
      for (var item in queue) {
        if (item.action == 'save') {
          final todoJson = jsonDecode(item.payloadJson) as Map<String, dynamic>;
          final model = TodoModel.fromJson(todoJson);
          grouped.putIfAbsent(model.id, () => []).add(model);
        }
      }

      final latestChanges = <TodoModel>[];
      for (var todoId in grouped.keys) {
        final models = grouped[todoId]!;
        models.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        latestChanges.add(models.first);
      }

      if (latestChanges.isNotEmpty) {
        final entities = latestChanges.map((m) => m.toEntity()).toList();
        final syncedIds = await _todosRepository.syncTodos(entities);
        
        for (var item in queue) {
          if (syncedIds.contains(item.id)) {
            await _localDataSource.removeFromSyncQueue(item.id);
          }
        }
      }
    } catch (_) {}
  }
}
