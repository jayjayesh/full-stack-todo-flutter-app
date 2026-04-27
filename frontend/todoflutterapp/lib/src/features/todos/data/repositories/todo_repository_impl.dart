import 'package:todoflutterapp/src/features/todos/data/services/todo_service.dart';
import 'package:todoflutterapp/src/features/todos/domain/entities/todo.dart';
import 'package:todoflutterapp/src/features/todos/domain/repositories/todo_repository.dart';
import 'package:todoflutterapp/src/imports/core_imports.dart';

class TodoRepositoryImpl implements TodoRepository {
  TodoRepositoryImpl({TodoService? todoService})
      : _todoService = todoService ?? TodoService.instance;

  final TodoService _todoService;

  @override
  FutureEither<List<Todo>> getTodos() {
    return _todoService.getTodos();
  }

  @override
  FutureEither<Todo> createTodo({required String title}) {
    return _todoService.createTodo(title: title);
  }

  @override
  FutureEither<Todo> updateTodo({
    required String id,
    String? title,
    bool? isCompleted,
  }) {
    return _todoService.updateTodo(
      id: id,
      title: title,
      isCompleted: isCompleted,
    );
  }

  @override
  FutureEither<void> deleteTodo({required String id}) {
    return _todoService.deleteTodo(id: id);
  }
}
