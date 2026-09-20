import 'package:injectable/injectable.dart';
import '../entities/todo.dart';
import '../repositories/todos_repository.dart';

@injectable
class SaveTodoUseCase {
  final TodosRepository _repository;

  SaveTodoUseCase(this._repository);

  Future<void> call(Todo todo) {
    return _repository.saveTodo(todo);
  }
}
