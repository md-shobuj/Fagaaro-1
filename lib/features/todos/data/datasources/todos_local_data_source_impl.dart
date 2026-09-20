import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/local_storage_facade.dart';
import '../../../sync/data/models/sync_queue_item_model.dart';
import '../models/todo_model.dart';
import 'todos_local_data_source.dart';

@LazySingleton(as: TodosLocalDataSource)
class TodosLocalDataSourceImpl implements TodosLocalDataSource {
  final LocalStorageFacade _storageFacade;

  static const String _todosBox = 'todos_box';
  static const String _syncQueueBox = 'sync_queue_box';

  TodosLocalDataSourceImpl(this._storageFacade);

  @override
  Future<List<TodoModel>> getCachedTodos() async {
    try {
      return await _storageFacade.getAllCache<TodoModel>(_todosBox);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> cacheTodos(List<TodoModel> todos) async {
    try {
      await _storageFacade.clearCache(_todosBox);
      for (final todo in todos) {
        await _storageFacade.saveCache<TodoModel>(_todosBox, todo.id, todo);
      }
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> cacheTodo(TodoModel todo) async {
    try {
      await _storageFacade.saveCache<TodoModel>(_todosBox, todo.id, todo);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> addToSyncQueue(SyncQueueItemModel item) async {
    try {
      await _storageFacade.saveCache<SyncQueueItemModel>(_syncQueueBox, item.id, item);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<List<SyncQueueItemModel>> getSyncQueue() async {
    try {
      return await _storageFacade.getAllCache<SyncQueueItemModel>(_syncQueueBox);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> removeFromSyncQueue(String id) async {
    try {
      await _storageFacade.deleteCache(_syncQueueBox, id);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> clearSyncQueue() async {
    try {
      await _storageFacade.clearCache(_syncQueueBox);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }
}
