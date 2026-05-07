import '../../imports/imports.dart';

/// Dismisses the on-screen keyboard when tapping outside focused inputs.
class DismissKeyboardWrapper extends StatelessWidget {
  const DismissKeyboardWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: child,
    );
  }
}
