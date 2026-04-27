import 'package:todoflutterapp/src/features/todos/data/repositories/todo_repository_impl.dart';
import 'package:todoflutterapp/src/features/todos/domain/entities/todo.dart';
import 'package:todoflutterapp/src/features/todos/domain/repositories/todo_repository.dart';
import 'package:todoflutterapp/src/imports/packages_imports.dart';

final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  return TodoRepositoryImpl();
});

final todoControllerProvider =
    StateNotifierProvider<TodoController, TodoState>((ref) {
  return TodoController(repository: ref.read(todoRepositoryProvider));
});

class TodoState extends Equatable {
  const TodoState({
    this.todos = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
  });

  final List<Todo> todos;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;

  int get completedCount => todos.where((todo) => todo.isCompleted).length;

  int get activeCount => todos.length - completedCount;

  TodoState copyWith({
    List<Todo>? todos,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TodoState(
      todos: todos ?? this.todos,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        todos,
        isLoading,
        isSaving,
        errorMessage,
      ];
}

class TodoController extends StateNotifier<TodoState> {
  TodoController({required TodoRepository repository})
      : _repository = repository,
        super(const TodoState()) {
    loadTodos();
  }

  final TodoRepository _repository;

  void clearSessionData() {
    state = const TodoState();
  }

  Future<void> loadTodos() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.getTodos();

    if (!mounted) return;

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (todos) => state = state.copyWith(
        todos: todos,
        isLoading: false,
        clearError: true,
      ),
    );
  }

  Future<void> createTodo(String title) async {
    final cleanedTitle = title.trim();
    if (cleanedTitle.isEmpty) return;

    state = state.copyWith(isSaving: true, clearError: true);

    final result = await _repository.createTodo(title: cleanedTitle);

    if (!mounted) return;

    result.fold(
      (failure) => state = state.copyWith(
        isSaving: false,
        errorMessage: failure.message,
      ),
      (todo) => state = state.copyWith(
        todos: [todo, ...state.todos],
        isSaving: false,
        clearError: true,
      ),
    );
  }

  Future<void> toggleTodo(Todo todo) async {
    final previousTodo = state.todos.firstWhere(
      (item) => item.id == todo.id,
      orElse: () => todo,
    );
    final optimisticTodo = previousTodo.copyWith(
      isCompleted: !previousTodo.isCompleted,
    );

    state = state.copyWith(
      todos: [
        for (final item in state.todos)
          if (item.id == optimisticTodo.id) optimisticTodo else item,
      ],
      clearError: true,
    );

    final result = await _repository.updateTodo(
      id: todo.id,
      isCompleted: optimisticTodo.isCompleted,
    );

    if (!mounted) return;

    result.fold(
      (failure) => state = state.copyWith(
        todos: [
          for (final item in state.todos)
            if (item.id == previousTodo.id) previousTodo else item,
        ],
        errorMessage: failure.message,
      ),
      (updatedTodo) {
        final updatedTodos = [
          for (final item in state.todos)
            if (item.id == updatedTodo.id) updatedTodo else item,
        ];

        state = state.copyWith(todos: updatedTodos, clearError: true);
      },
    );
  }

  Future<void> updateTodoTitle(Todo todo, String title) async {
    final cleanedTitle = title.trim();
    if (cleanedTitle.isEmpty || cleanedTitle == todo.title) return;

    final previousTodo = state.todos.firstWhere(
      (item) => item.id == todo.id,
      orElse: () => todo,
    );
    final optimisticTodo = previousTodo.copyWith(title: cleanedTitle);

    state = state.copyWith(
      todos: [
        for (final item in state.todos)
          if (item.id == optimisticTodo.id) optimisticTodo else item,
      ],
      clearError: true,
    );

    final result = await _repository.updateTodo(
      id: todo.id,
      title: cleanedTitle,
    );

    if (!mounted) return;

    result.fold(
      (failure) => state = state.copyWith(
        todos: [
          for (final item in state.todos)
            if (item.id == previousTodo.id) previousTodo else item,
        ],
        errorMessage: failure.message,
      ),
      (updatedTodo) {
        final updatedTodos = [
          for (final item in state.todos)
            if (item.id == updatedTodo.id) updatedTodo else item,
        ];

        state = state.copyWith(todos: updatedTodos, clearError: true);
      },
    );
  }

  Future<void> deleteTodo(Todo todo) async {
    final previousIndex = state.todos.indexWhere((item) => item.id == todo.id);
    if (previousIndex == -1) return;

    final previousTodo = state.todos[previousIndex];
    state = state.copyWith(
      todos: state.todos.where((item) => item.id != todo.id).toList(),
      clearError: true,
    );

    final result = await _repository.deleteTodo(id: todo.id);

    if (!mounted) return;

    result.fold(
      (failure) {
        final restoredTodos = [...state.todos];
        final restoreIndex =
            previousIndex.clamp(0, restoredTodos.length).toInt();

        if (!restoredTodos.any((item) => item.id == previousTodo.id)) {
          restoredTodos.insert(restoreIndex, previousTodo);
        }

        state = state.copyWith(
          todos: restoredTodos,
          errorMessage: failure.message,
        );
      },
      (_) => state = state.copyWith(clearError: true),
    );
  }
}
