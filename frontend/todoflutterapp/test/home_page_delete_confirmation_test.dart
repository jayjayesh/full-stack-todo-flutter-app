import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:todoflutterapp/src/features/auth/domain/entities/user.dart';
import 'package:todoflutterapp/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:todoflutterapp/src/features/auth/presentation/providers/auth_repository_provider.dart';
import 'package:todoflutterapp/src/features/home/presentation/screens/home_page.dart';
import 'package:todoflutterapp/src/features/todos/domain/entities/todo.dart';
import 'package:todoflutterapp/src/features/todos/domain/repositories/todo_repository.dart';
import 'package:todoflutterapp/src/features/todos/presentation/providers/todo_provider.dart';
import 'package:todoflutterapp/src/utils/failure.dart';
import 'package:todoflutterapp/src/utils/typedefs.dart';

void main() {
  final createdAt = DateTime(2026);
  final todo = Todo(
    id: 'todo-1',
    title: 'Delete me carefully',
    isCompleted: false,
    createdAt: createdAt,
    updatedAt: createdAt,
  );
  final anotherTodo = Todo(
    id: 'todo-2',
    title: 'Keep me here',
    isCompleted: false,
    createdAt: createdAt,
    updatedAt: createdAt,
  );

  testWidgets('cancel keeps todo and does not call delete', (tester) async {
    final todoRepository = _FakeTodoRepository(initialTodos: [todo]);

    await tester.pumpWidget(
      _TestApp(
        todoRepository: todoRepository,
      ),
    );

    await tester.pump();

    expect(find.text(todo.title), findsOneWidget);

    await tester.tap(find.byTooltip('Delete todo').first);
    await tester.pumpAndSettle();

    expect(find.text('Delete todo?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text(todo.title), findsOneWidget);
    expect(todoRepository.deleteCallCount, 0);
  });

  testWidgets('confirm deletes todo', (tester) async {
    final todoRepository = _FakeTodoRepository(
      initialTodos: [todo, anotherTodo],
    );

    await tester.pumpWidget(
      _TestApp(
        todoRepository: todoRepository,
      ),
    );

    await tester.pump();

    expect(find.text(todo.title), findsOneWidget);

    await tester.tap(find.byTooltip('Delete todo').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text(todo.title), findsNothing);
    expect(find.text(anotherTodo.title), findsOneWidget);
    expect(todoRepository.deleteCallCount, 1);
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.todoRepository});

  final _FakeTodoRepository todoRepository;

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomePage(),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        todoRepositoryProvider.overrideWithValue(todoRepository),
        authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
      ],
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }
}

class _FakeTodoRepository implements TodoRepository {
  _FakeTodoRepository({required this.initialTodos});

  final List<Todo> initialTodos;
  int deleteCallCount = 0;

  @override
  FutureEither<List<Todo>> getTodos() async => right(initialTodos);

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
    throw UnimplementedError();
  }

  @override
  FutureEither<void> deleteTodo({required String id}) async {
    deleteCallCount++;
    return right(unit);
  }
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Stream<AppUser?> get onAuthStateChanged => const Stream.empty();

  @override
  FutureEither<AppUser?> checkAuthState() async {
    return right(
      const AppUser(
        id: 'user-1',
        email: 'test@example.com',
        name: 'Test User',
      ),
    );
  }

  @override
  FutureEither<void> forgotPassword({required String email}) {
    throw UnimplementedError();
  }

  @override
  FutureEither<AppUser> login({
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  FutureEither<void> logout() async => right(unit);

  @override
  FutureEither<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }
}
