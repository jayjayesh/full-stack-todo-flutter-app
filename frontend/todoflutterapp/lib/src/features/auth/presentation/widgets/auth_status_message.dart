import 'package:todoflutterapp/src/imports/core_imports.dart';

class AuthStatusMessage extends StatelessWidget {
  const AuthStatusMessage({
    super.key,
    required this.isLoading,
    required this.loadingMessage,
    this.errorMessage,
  });

  final bool isLoading;
  final String loadingMessage;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final message = isLoading ? loadingMessage : errorMessage;

    return AnimatedSwitcher(
      duration: AppDurations.fast,
      child: message == null
          ? const SizedBox.shrink(key: ValueKey('empty-auth-status'))
          : Padding(
              key: ValueKey('auth-status-$isLoading-$message'),
              padding: EdgeInsets.only(top: AppSpacing.sm),
              child: _AuthStatusContent(
                isLoading: isLoading,
                message: message,
              ),
            ),
    );
  }
}

class _AuthStatusContent extends StatelessWidget {
  const _AuthStatusContent({
    required this.isLoading,
    required this.message,
  });

  final bool isLoading;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final backgroundColor =
        isLoading ? colorScheme.primaryContainer : colorScheme.errorContainer;
    final foregroundColor = isLoading
        ? colorScheme.onPrimaryContainer
        : colorScheme.onErrorContainer;

    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: AppBorders.input,
        ),
        child: Row(
          children: [
            if (isLoading)
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foregroundColor,
                ),
              )
            else
              Icon(
                Icons.error_outline,
                color: colorScheme.error,
                size: 20,
              ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: context.theme.textTheme.bodySmall?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
