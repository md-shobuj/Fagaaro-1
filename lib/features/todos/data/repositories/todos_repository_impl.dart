import 'dart:convert';
import 'package:injectable/injectable.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todos_repository.dart';
import '../datasources/todos_local_data_source.dart';
import '../datasources/todos_remote_data_source.dart';
import '../models/todo_model.dart';
import '../../../sync/data/models/sync_queue_item_model.dart';

@LazySingleton(as: TodosRepository)
class TodosRepositoryImpl implements TodosRepository {
  final TodosRemoteDataSource _remoteDataSource;
  final TodosLocalDataSource _localDataSource;

  TodosRepositoryImpl({
    required TodosRemoteDataSource remoteDataSource,
    required TodosLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<List<Todo>> getTodos({bool forceLocal = false}) async {
    if (forceLocal) {
      try {
        final localTodos = await _localDataSource.getCachedTodos();
        return localTodos.map((model) => model.toEntity()).toList();
      } catch (_) {
        return [];
      }
    }
    try {
      final response = await _remoteDataSource.getTodos();
      final remoteTodos = response.data;
      await _localDataSource.cacheTodos(remoteTodos);
      return remoteTodos.map((model) => model.toEntity()).toList();
    } catch (_) {
      try {
        final localTodos = await _localDataSource.getCachedTodos();
        return localTodos.map((model) => model.toEntity()).toList();
      } catch (_) {
        try {
          await _localDataSource.cacheTodos([]);
        } catch (_) {}
        return [];
      }
    }
  }

  @override
  Future<void> saveTodo(Todo todo) async {
    final model = TodoModel.fromEntity(todo);
    try {
      await _remoteDataSource.saveTodo(model.id, {
        'is_completed': model.isCompleted,
        'updated_at': model.updatedAt.toUtc().toIso8601String(),
      });
      await _localDataSource.cacheTodo(model);
    } catch (_) {
      await _localDataSource.cacheTodo(model);
      final item = SyncQueueItemModel(
        id: todo.id,
        action: 'save',
        payloadJson: jsonEncode(model.toJson()),
        createdAt: DateTime.now(),
      );
      await _localDataSource.addToSyncQueue(item);
    }
  }

  @override
  Future<List<String>> syncTodos(List<Todo> todos) async {
    final models = todos.map((e) => TodoModel.fromEntity(e)).toList();
    try {
      final response = await _remoteDataSource.syncTodos({
        'changes': models
            .map((todo) => {
                  'todo_id': todo.id,
                  'is_completed': todo.isCompleted,
                  'updated_at': todo.updatedAt.toUtc().toIso8601String(),
                })
            .toList(),
      });
      
      final syncedIds = (response['synced_ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          <String>[];

      for (var model in models) {
        await _localDataSource.cacheTodo(model);
      }
      return syncedIds;
    } catch (_) {
      return <String>[];
    }
  }

  @override
  Future<int> getPendingSyncCount() async {
    final queue = await _localDataSource.getSyncQueue();
    return queue.length;
  }

  @override
  Future<List<Todo>> getPendingTodos() async {
    final queue = await _localDataSource.getSyncQueue();
    final list = <Todo>[];
    for (var item in queue) {
      if (item.action == 'save') {
        final todoJson = jsonDecode(item.payloadJson) as Map<String, dynamic>;
        final model = TodoModel.fromJson(todoJson);
        list.add(model.toEntity());
      }
    }
    return list;
  }
}
