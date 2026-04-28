import 'package:todoflutterapp/src/imports/core_imports.dart';
import 'package:todoflutterapp/src/imports/packages_imports.dart';

import 'package:todoflutterapp/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:todoflutterapp/src/features/auth/presentation/widgets/auth_status_message.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ref.read(authControllerProvider.notifier).clearError();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;
    final errorMessage = authState.errorMessage;

    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    Future<void> handleForgotPassword() async {
      if (!(_formKey.currentState?.validate() ?? false)) {
        return;
      }

      await ref.read(authControllerProvider.notifier).forgotPassword(
            context: context,
            email: _emailController.text,
          );
    }

    return Scaffold(
      appBar: const AppTopBar(title: ''),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: AppSpacing.xl),
                Text(
                  'auth.forgot_password_title'.tr(),
                  style:
                      tt.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'auth.forgot_password_subtitle'.tr(),
                  textAlign: TextAlign.center,
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                SizedBox(height: AppSpacing.xxxl),
                // Form Card
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      AppTextField(
                        controller: _emailController,
                        enabled: !isLoading,
                        keyboardType: TextInputType.emailAddress,
                        label: 'auth.email'.tr(),
                        prefixIcon: const Icon(Icons.email_outlined),
                        onChanged: (_) => ref
                            .read(authControllerProvider.notifier)
                            .clearError(),
                        validator: FormValidators.requiredEmail,
                      ),
                      SizedBox(height: AppSpacing.lg),
                      AppButton(
                        label: 'Send Reset Link',
                        isLoading: isLoading,
                        onPressed: isLoading ? null : handleForgotPassword,
                        width: ButtonSize.large,
                        isFullWidth: false,
                      ),
                      AuthStatusMessage(
                        isLoading: isLoading,
                        loadingMessage: 'Sending reset link...',
                        errorMessage: errorMessage,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.xxxl),
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: Text(
                    'auth.back_to_login'.tr(),
                    style: tt.labelLarge?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
