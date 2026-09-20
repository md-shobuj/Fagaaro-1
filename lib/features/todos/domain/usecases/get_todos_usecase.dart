import 'package:injectable/injectable.dart';
import '../entities/todo.dart';
import '../repositories/todos_repository.dart';

@injectable
class GetTodosUseCase {
  final TodosRepository _repository;

  GetTodosUseCase(this._repository);

  Future<List<Todo>> call({bool forceLocal = false}) {
    return _repository.getTodos(forceLocal: forceLocal);
  }
}
