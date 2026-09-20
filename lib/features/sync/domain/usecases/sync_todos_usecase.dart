import 'package:injectable/injectable.dart';
import '../../../todos/domain/entities/todo.dart';
import '../../../todos/domain/repositories/todos_repository.dart';

@injectable
class SyncTodosUseCase {
  final TodosRepository _repository;

  SyncTodosUseCase(this._repository);

  Future<List<String>> call(List<Todo> todos) {
    return _repository.syncTodos(todos);
  }
}
