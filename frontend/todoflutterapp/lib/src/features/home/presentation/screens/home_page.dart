import 'package:todoflutterapp/src/imports/core_imports.dart';
import 'package:todoflutterapp/src/imports/packages_imports.dart';

import 'package:todoflutterapp/src/features/auth/presentation/providers/session_provider.dart';
import 'package:todoflutterapp/src/features/todos/domain/entities/todo.dart';
import 'package:todoflutterapp/src/features/todos/presentation/providers/todo_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final GlobalKey<FormState> _todoFormKey = GlobalKey<FormState>();
  final TextEditingController _todoController = TextEditingController();

  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }

  Future<void> _createTodo() async {
    if (!(_todoFormKey.currentState?.validate() ?? false)) {
      return;
    }

    final title = _todoController.text;

    await ref.read(todoControllerProvider.notifier).createTodo(title);

    if (!mounted) return;
    if (ref.read(todoControllerProvider).errorMessage == null) {
      _todoController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Log out?'),
          content: const Text('This will clear this session on this device.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              // icon: const Icon(Icons.logout_rounded),
              label: const Text('Log out'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true || !mounted) return;

    _todoController.clear();
    await ref.read(sessionProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final session = ref.watch(sessionProvider);
    final user = session.user;
    final todoState = ref.watch(todoControllerProvider);

    ref.listen<TodoState>(todoControllerProvider, (previous, next) {
      final message = next.errorMessage;

      if (message != null && message != previous?.errorMessage) {
        showToast(context, message: message, status: 'error');
      }
    });

    ref.listen<SessionState>(sessionProvider, (previous, next) {
      final message = next.errorMessage;

      if (message != null && message != previous?.errorMessage) {
        showToast(context, message: message, status: 'error');
      }
    });

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppTopBar(
        title: 'My Todos',
        showBackButton: false,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: todoState.isLoading
                ? null
                : ref.read(todoControllerProvider.notifier).loadTodos,
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: 'Log out',
            onPressed: session.isLoggingOut ? null : _confirmLogout,
            icon: session.isLoggingOut
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: ref.read(todoControllerProvider.notifier).loadTodos,
          child: ListView(
            padding: EdgeInsets.all(AppSpacing.md),
            children: [
              Text(
                'Welcome, ${user?.name ?? user?.email ?? 'friend'}',
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: AppSpacing.md),
              _TodoComposer(
                formKey: _todoFormKey,
                controller: _todoController,
                isSaving: todoState.isSaving,
                onSubmit: _createTodo,
              ),
              SizedBox(height: AppSpacing.md),
              _TodoStats(
                total: todoState.todos.length,
                active: todoState.activeCount,
                completed: todoState.completedCount,
              ),
              SizedBox(height: AppSpacing.lg),
              _TodoListSection(state: todoState),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodoComposer extends StatelessWidget {
  const _TodoComposer({
    required this.formKey,
    required this.controller,
    required this.isSaving,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final bool isSaving;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Form(
        key: formKey,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextField(
                controller: controller,
                enabled: !isSaving,
                hint: 'Add a new todo',
                textInputAction: TextInputAction.done,
                validator: FormValidators.requiredTodoTitle,
                onFieldSubmitted: (_) => onSubmit(),
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            SizedBox.square(
              dimension: 48,
              child: IconButton.filled(
                tooltip: 'Add todo',
                onPressed: isSaving ? null : onSubmit,
                icon: isSaving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodoStats extends StatelessWidget {
  const _TodoStats({
    required this.total,
    required this.active,
    required this.completed,
  });

  final int total;
  final int active;
  final int completed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatTile(label: 'Total', value: total)),
        SizedBox(width: AppSpacing.sm),
        Expanded(child: _StatTile(label: 'Active', value: active)),
        SizedBox(width: AppSpacing.sm),
        Expanded(child: _StatTile(label: 'Done', value: completed)),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
  });

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final textTheme = context.theme.textTheme;

    return AppCard(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.ms,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value.toString(),
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _TodoListSection extends ConsumerWidget {
  const _TodoListSection({required this.state});

  final TodoState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.isLoading && state.todos.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: AppLoading(message: 'Loading your todos...'),
      );
    }

    if (state.errorMessage != null && state.todos.isEmpty) {
      return AppErrorWidget(
        title: 'Could not load todos',
        message: state.errorMessage,
        onRetry: ref.read(todoControllerProvider.notifier).loadTodos,
      );
    }

    if (state.todos.isEmpty) {
      return AppEmptyState(
        icon: Icons.check_circle_outline_rounded,
        title: 'No todos yet',
        subtitle: 'Add your first todo above.',
        actionLabel: 'Refresh',
        onAction: ref.read(todoControllerProvider.notifier).loadTodos,
      );
    }

    return Column(
      children: [
        if (state.isLoading) ...[
          const _TodoRefreshStatus(),
          SizedBox(height: AppSpacing.sm),
        ],
        for (final todo in state.todos) ...[
          _TodoListItem(todo: todo),
          SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _TodoRefreshStatus extends StatelessWidget {
  const _TodoRefreshStatus();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final textTheme = context.theme.textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.primary,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Text(
              'Refreshing todos...',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodoListItem extends ConsumerWidget {
  const _TodoListItem({required this.todo});

  final Todo todo;

  Future<void> _editTodo(BuildContext context, WidgetRef ref) async {
    final updatedTitle = await showDialog<String>(
      context: context,
      builder: (_) => _EditTodoDialog(todo: todo),
    );

    if (updatedTitle == null) return;

    await ref
        .read(todoControllerProvider.notifier)
        .updateTodoTitle(todo, updatedTitle);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.theme.colorScheme;
    final textTheme = context.theme.textTheme;

    return AppCard(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Checkbox(
            value: todo.isCompleted,
            onChanged: (_) {
              ref.read(todoControllerProvider.notifier).toggleTodo(todo);
            },
          ),
          Expanded(
            child: Text(
              todo.title,
              style: textTheme.bodyLarge?.copyWith(
                color: todo.isCompleted
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.onSurface,
                decoration:
                    todo.isCompleted ? TextDecoration.lineThrough : null,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            tooltip: 'Edit todo',
            onPressed: () {
              _editTodo(context, ref);
            },
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Delete todo',
            onPressed: () {
              ref.read(todoControllerProvider.notifier).deleteTodo(todo);
            },
            icon: Icon(
              Icons.delete_outline_rounded,
              color: colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditTodoDialog extends StatefulWidget {
  const _EditTodoDialog({required this.todo});

  final Todo todo;

  @override
  State<_EditTodoDialog> createState() => _EditTodoDialogState();
}

class _EditTodoDialogState extends State<_EditTodoDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.todo.title);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit todo'),
      content: Form(
        key: _formKey,
        child: AppTextField(
          controller: _controller,
          autofocus: true,
          label: 'Todo title',
          textInputAction: TextInputAction.done,
          validator: FormValidators.requiredTodoTitle,
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Save'),
        ),
      ],
    );
  }
}
