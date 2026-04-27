import 'package:todoflutterapp/src/imports/core_imports.dart';
import 'package:todoflutterapp/src/features/todos/data/models/todo_model.dart';

class TodoService {
  TodoService._();
  static final TodoService instance = TodoService._();

  final DioService _dioService = DioService.instance;

  FutureEither<List<TodoModel>> getTodos() async {
    final result = await _dioService.get<Map<String, dynamic>>('/todos');

    return result.map((response) {
      final todos = response.data?['todos'] as List<dynamic>? ?? [];
      return todos
          .map((todo) => TodoModel.fromJson(todo as Map<String, dynamic>))
          .toList();
    });
  }

  FutureEither<TodoModel> createTodo({required String title}) async {
    final result = await _dioService.post<Map<String, dynamic>>(
      '/todos',
      data: {'title': title},
    );

    return result.map((response) {
      return TodoModel.fromJson(response.data!['todo']);
    });
  }

  FutureEither<TodoModel> updateTodo({
    required String id,
    String? title,
    bool? isCompleted,
  }) async {
    final body = <String, dynamic>{};

    if (title != null) body['title'] = title;
    if (isCompleted != null) body['isCompleted'] = isCompleted;

    final result = await _dioService.patch<Map<String, dynamic>>(
      '/todos/$id',
      data: body,
    );

    return result.map((response) {
      return TodoModel.fromJson(response.data!['todo']);
    });
  }

  FutureEither<void> deleteTodo({required String id}) async {
    final result = await _dioService.delete<void>('/todos/$id');
    return result.map((_) {});
  }
}
