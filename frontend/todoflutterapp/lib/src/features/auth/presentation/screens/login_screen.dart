import 'package:todoflutterapp/src/imports/core_imports.dart';
import 'package:todoflutterapp/src/imports/packages_imports.dart';

import 'package:todoflutterapp/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:todoflutterapp/src/features/auth/presentation/widgets/auth_status_message.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;
    final errorMessage = authState.errorMessage;

    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    Future<void> handleLogin() async {
      if (!(_formKey.currentState?.validate() ?? false)) {
        return;
      }

      await ref.read(authControllerProvider.notifier).login(
            context: context,
            email: _emailController.text,
            password: _passwordController.text,
          );
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
                  'auth.log_in'.tr(),
                  style:
                      tt.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'auth.log_in_subtitle'.tr(),
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
                      SizedBox(height: AppSpacing.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            spacing: 5,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: Checkbox(
                                  value: true,
                                  onChanged: isLoading ? null : (value) {},
                                ),
                              ),
                              Text(
                                'auth.remember_me'.tr(),
                                style: tt.bodySmall
                                    ?.copyWith(color: cs.onSurfaceVariant),
                              ),
                            ],
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: isLoading
                                ? null
                                : () {
                                    context.push(AppRoutes.forgotPassword);
                                  },
                            child: Text(
                              'auth.forgot_password'.tr(),
                              style: tt.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.lg),
                      AppButton(
                        label: 'Sign In',
                        isLoading: isLoading,
                        onPressed: isLoading ? null : handleLogin,
                        width: ButtonSize.large,
                        isFullWidth: false,
                      ),
                      AuthStatusMessage(
                        isLoading: isLoading,
                        loadingMessage: 'Signing in...',
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
                  onTap: isLoading
                      ? null
                      : () {
                          context.push(AppRoutes.signup);
                        },
                  child: RichText(
                    text: TextSpan(
                      text: 'auth.dont_have_account'.tr(),
                      style:
                          tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                      children: [
                        TextSpan(
                          text: 'auth.sign_up'.tr(),
                          style: TextStyle(
                            color: cs.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
