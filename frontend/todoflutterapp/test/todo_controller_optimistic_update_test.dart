import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:todoflutterapp/src/features/todos/domain/entities/todo.dart';
import 'package:todoflutterapp/src/features/todos/domain/repositories/todo_repository.dart';
import 'package:todoflutterapp/src/features/todos/presentation/providers/todo_provider.dart';
import 'package:todoflutterapp/src/utils/failure.dart';
import 'package:todoflutterapp/src/utils/typedefs.dart';

void main() {
  final createdAt = DateTime(2026);
  final todo = Todo(
    id: 'todo-1',
    title: 'Learn optimistic updates',
    isCompleted: false,
    createdAt: createdAt,
    updatedAt: createdAt,
  );

  test('toggleTodo updates immediately and keeps server result on success',
      () async {
    final repository = _FakeTodoRepository(initialTodos: [todo]);
    final controller = TodoController(repository: repository);
    addTearDown(controller.dispose);

    await pumpEventQueue();

    final updatedTodo = todo.copyWith(
      isCompleted: true,
      updatedAt: createdAt.add(const Duration(minutes: 1)),
    );

    final updateFuture = controller.toggleTodo(todo);

    expect(controller.state.todos.single.isCompleted, isTrue);

    repository.completeUpdate(right(updatedTodo));
    await updateFuture;

    expect(controller.state.todos.single, updatedTodo);
    expect(controller.state.errorMessage, isNull);
  });

  test('toggleTodo rolls back when backend update fails', () async {
    final repository = _FakeTodoRepository(initialTodos: [todo]);
    final controller = TodoController(repository: repository);
    addTearDown(controller.dispose);

    await pumpEventQueue();

    final updateFuture = controller.toggleTodo(todo);

    expect(controller.state.todos.single.isCompleted, isTrue);

    repository.completeUpdate(left(const ServerFailure('Update failed')));
    await updateFuture;

    expect(controller.state.todos.single, todo);
    expect(controller.state.errorMessage, 'Update failed');
  });

  test('updateTodoTitle updates immediately and keeps server result on success',
      () async {
    final repository = _FakeTodoRepository(initialTodos: [todo]);
    final controller = TodoController(repository: repository);
    addTearDown(controller.dispose);

    await pumpEventQueue();

    final updatedTodo = todo.copyWith(
      title: 'Learn edit flow',
      updatedAt: createdAt.add(const Duration(minutes: 2)),
    );

    final updateFuture = controller.updateTodoTitle(todo, 'Learn edit flow');

    expect(controller.state.todos.single.title, 'Learn edit flow');

    repository.completeUpdate(right(updatedTodo));
    await updateFuture;

    expect(controller.state.todos.single, updatedTodo);
    expect(controller.state.errorMessage, isNull);
  });

  test('updateTodoTitle rolls back when backend update fails', () async {
    final repository = _FakeTodoRepository(initialTodos: [todo]);
    final controller = TodoController(repository: repository);
    addTearDown(controller.dispose);

    await pumpEventQueue();

    final updateFuture = controller.updateTodoTitle(todo, 'Broken edit');

    expect(controller.state.todos.single.title, 'Broken edit');

    repository.completeUpdate(left(const ServerFailure('Edit failed')));
    await updateFuture;

    expect(controller.state.todos.single, todo);
    expect(controller.state.errorMessage, 'Edit failed');
  });

  test('deleteTodo removes immediately and restores when backend delete fails',
      () async {
    final repository = _FakeTodoRepository(initialTodos: [todo]);
    final controller = TodoController(repository: repository);
    addTearDown(controller.dispose);

    await pumpEventQueue();

    final deleteFuture = controller.deleteTodo(todo);

    expect(controller.state.todos, isEmpty);

    repository.completeDelete(left(const ServerFailure('Delete failed')));
    await deleteFuture;

    expect(controller.state.todos, [todo]);
    expect(controller.state.errorMessage, 'Delete failed');
  });

  test('clearSessionData removes private todos and pending UI state', () async {
    final repository = _FakeTodoRepository(initialTodos: [todo]);
    final controller = TodoController(repository: repository);
    addTearDown(controller.dispose);

    await pumpEventQueue();

    expect(controller.state.todos, [todo]);

    controller.clearSessionData();

    expect(controller.state.todos, isEmpty);
    expect(controller.state.isLoading, isFalse);
    expect(controller.state.isSaving, isFalse);
    expect(controller.state.errorMessage, isNull);
  });
}

class _FakeTodoRepository implements TodoRepository {
  _FakeTodoRepository({required this.initialTodos});

  final List<Todo> initialTodos;
  late Completer<Either<Failure, Todo>> _updateCompleter;
  late Completer<Either<Failure, void>> _deleteCompleter;

  @override
  FutureEither<List<Todo>> getTodos() async {
    return right(initialTodos);
  }

  @override
  FutureEither<Todo> createTodo({required String title}) {
    throw UnimplementedError();
  }

  @override
  FutureEither<Todo> updateTodo({
    required String id,
    String? title,
    bool? isCompleted,
  }) {
    _updateCompleter = Completer<Either<Failure, Todo>>();
    return _updateCompleter.future;
  }

  void completeUpdate(Either<Failure, Todo> result) {
    _updateCompleter.complete(result);
  }

  @override
  FutureEither<void> deleteTodo({required String id}) {
    _deleteCompleter = Completer<Either<Failure, void>>();
    return _deleteCompleter.future;
  }

  void completeDelete(Either<Failure, void> result) {
    _deleteCompleter.complete(result);
  }
}
