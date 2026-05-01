import 'package:todoflutterapp/src/imports/core_imports.dart';
import 'package:todoflutterapp/src/imports/packages_imports.dart';

import 'package:todoflutterapp/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:todoflutterapp/src/features/auth/presentation/widgets/auth_status_message.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final bool _showSocialSignIn = false;

  @override
  void initState() {
    super.initState();
    ref.read(authControllerProvider.notifier).clearError();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;
    final errorMessage = authState.errorMessage;

    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    Future<void> handleSignup() async {
      if (!(_formKey.currentState?.validate() ?? false)) {
        return;
      }

      final didSignUp = await ref.read(authControllerProvider.notifier).signUp(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      if (!context.mounted || !didSignUp) return;

      showToast(
        context,
        message: 'auth.signup_success'.tr(),
        status: 'success',
      );
      context.go(AppRoutes.home);
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: AppSpacing.xl),
                Text(
                  'auth.create_account'.tr(),
                  style:
                      tt.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ).animate().fadeIn().slideY(begin: 0.2),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'auth.create_account_subtitle'.tr(),
                  textAlign: TextAlign.center,
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ).animate().fadeIn().slideY(begin: 0.2),
                SizedBox(height: AppSpacing.xxxl),
                // Form Card
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      AppTextField(
                        controller: _nameController,
                        enabled: !isLoading,
                        label: 'auth.name'.tr(),
                        prefixIcon: const Icon(Icons.person_outline),
                        onChanged: (_) => ref
                            .read(authControllerProvider.notifier)
                            .clearError(),
                        validator: FormValidators.requiredName,
                      ),
                      SizedBox(height: AppSpacing.md),
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
                      SizedBox(height: AppSpacing.md),
                      AppTextField(
                        controller: _passwordController,
                        enabled: !isLoading,
                        label: 'auth.password'.tr(),
                        obscureText: _obscurePassword,
                        prefixIcon: const Icon(Icons.lock_outline),
                        onChanged: (_) => ref
                            .read(authControllerProvider.notifier)
                            .clearError(),
                        suffixIcon: IconButton(
                          tooltip: _obscurePassword
                              ? 'Show password'
                              : 'Hide password',
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed:
                              isLoading ? null : _togglePasswordVisibility,
                        ),
                        validator: FormValidators.requiredPassword,
                      ),
                      SizedBox(height: AppSpacing.md),
                      AppTextField(
                        controller: _confirmPasswordController,
                        enabled: !isLoading,
                        label: 'auth.confirm_password'.tr(),
                        obscureText: _obscureConfirmPassword,
                        prefixIcon: const Icon(Icons.lock_outline),
                        onChanged: (_) => ref
                            .read(authControllerProvider.notifier)
                            .clearError(),
                        suffixIcon: IconButton(
                          tooltip: _obscureConfirmPassword
                              ? 'Show confirm password'
                              : 'Hide confirm password',
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: isLoading
                              ? null
                              : _toggleConfirmPasswordVisibility,
                        ),
                        validator: (value) =>
                            FormValidators.requiredConfirmPassword(
                          value: value,
                          password: _passwordController.text,
                        ),
                      ),
                      SizedBox(height: AppSpacing.lg),
                      AppButton(
                        label: 'Create Account',
                        isLoading: isLoading,
                        onPressed: isLoading ? null : handleSignup,
                        width: ButtonSize.large,
                        isFullWidth: false,
                      ),
                      AuthStatusMessage(
                        isLoading: isLoading,
                        loadingMessage: 'Creating account...',
                        errorMessage: errorMessage,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.xxxl),
                if (_showSocialSignIn)
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 20,
                        children: [
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: TextButton(
                              onPressed: isLoading ? null : () {},
                              style: TextButton.styleFrom(
                                backgroundColor: const Color(0xFFEA4335)
                                    .withValues(alpha: 0.8),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: AppBorders.button,
                                ),
                              ),
                              child: SvgPicture.asset(AppAssets.googleIcon),
                            ),
                          ),
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: TextButton(
                              onPressed: isLoading ? null : () {},
                              style: TextButton.styleFrom(
                                backgroundColor: const Color(0xFF4285F4),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: AppBorders.button,
                                ),
                              ),
                              child: SvgPicture.asset(AppAssets.facebookIcon),
                            ),
                          ),
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: TextButton(
                              onPressed: isLoading ? null : () {},
                              style: TextButton.styleFrom(
                                backgroundColor: const Color(0xFF000000),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: AppBorders.button,
                                ),
                              ),
                              child: SvgPicture.asset(AppAssets.appleIcon),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                InkWell(
                  onTap: isLoading ? null : () => Navigator.pop(context),
                  child: RichText(
                    text: TextSpan(
                      text: 'auth.already_have_account'.tr(),
                      style:
                          tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                      children: [
                        TextSpan(
                          text: 'auth.sign_in'.tr(),
                          style: TextStyle(
                            color: cs.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
