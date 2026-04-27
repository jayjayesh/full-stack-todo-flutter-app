import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todoflutterapp/src/shared/widgets/app_text_field.dart';

void main() {
  testWidgets('AppTextField shows todo title validation errors',
      (WidgetTester tester) async {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController();

    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: Column(
              children: [
                AppTextField(
                  label: 'Todo title',
                  controller: controller,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Todo title is required';
                    }

                    return null;
                  },
                ),
                ElevatedButton(
                  onPressed: () => formKey.currentState!.validate(),
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(find.text('Todo title is required'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Buy milk');
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(find.text('Todo title is required'), findsNothing);
  });
}
