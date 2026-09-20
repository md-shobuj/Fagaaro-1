import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';
import '../../../../core/network/api_response.dart';
import '../models/todo_model.dart';

part 'todos_remote_data_source.g.dart';

@RestApi()
@lazySingleton
abstract class TodosRemoteDataSource {
  @factoryMethod
  factory TodosRemoteDataSource(Dio dio) = _TodosRemoteDataSource;

  @GET('/todos')
  Future<ApiResponse<List<TodoModel>>> getTodos();

  @PATCH('/todos/{id}')
  Future<void> saveTodo(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  @POST('/todos/sync')
  Future<dynamic> syncTodos(@Body() Map<String, dynamic> body);
}
