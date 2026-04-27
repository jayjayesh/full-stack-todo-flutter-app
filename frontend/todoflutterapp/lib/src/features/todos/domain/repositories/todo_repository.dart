import 'package:todoflutterapp/src/imports/core_imports.dart';
import 'package:todoflutterapp/src/features/todos/domain/entities/todo.dart';

abstract class TodoRepository {
  FutureEither<List<Todo>> getTodos();

  FutureEither<Todo> createTodo({required String title});

  FutureEither<Todo> updateTodo({
    required String id,
    String? title,
    bool? isCompleted,
  });

  FutureEither<void> deleteTodo({required String id});
}
