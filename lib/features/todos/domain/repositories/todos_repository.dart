import '../entities/todo.dart';

abstract class TodosRepository {
  Future<List<Todo>> getTodos({bool forceLocal = false});

  Future<void> saveTodo(Todo todo);

  Future<List<String>> syncTodos(List<Todo> todos);

  Future<int> getPendingSyncCount();

  Future<List<Todo>> getPendingTodos();
}
