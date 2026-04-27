# Lesson 11: Frontend Widget Tests

In Lesson 10, we added frontend form validation.

Lesson 11 adds tests for that validation.

Tests help us answer:

```text
Does this still work after we change the code?
```

That is the main reason developers write tests.

## What We Added

We added one focused widget test file:

```text
frontend/todoflutterapp/test/app_text_field_validation_test.dart
```

## Widget Test

Widget tests check what the user sees.

Our widget test builds a real `Form` with `AppTextField`:

```dart
Form(
  key: formKey,
  child: AppTextField(
    validator: (value) {
      if (value == null || value.trim().isEmpty) {
        return 'Todo title is required';
      }

      return null;
    },
  ),
)
```

This local validator keeps the test simple.

In Flutter form validation:

```text
error string = invalid
null = valid
```

Then the test taps the button:

```dart
await tester.tap(find.text('Save'));
await tester.pump();
```

After that, it expects the error text to appear:

```dart
expect(find.text('Todo title is required'), findsOneWidget);
```

Then it types a valid todo title and validates again:

```dart
await tester.enterText(find.byType(TextFormField), 'Buy milk');
await tester.tap(find.text('Save'));
await tester.pump();
```

Now the error should disappear:

```dart
expect(find.text('Todo title is required'), findsNothing);
```

## Important Testing Words

`testWidgets`

```text
Creates a Flutter widget test.
```

`WidgetTester`

```text
The testing robot that can build widgets, tap buttons, type text, and inspect the screen.
```

`pumpWidget`

```text
Builds a widget in the test.
```

`pump`

```text
Moves the test forward by one frame so Flutter can update the UI.
```

`find.text`

```text
Searches the screen for visible text.
```

`expect`

```text
Checks that the result is what we believe it should be.
```

## How To Run Frontend Tests

From the Flutter app folder:

```bash
cd frontend/todoflutterapp
flutter test
```

If all tests pass, Flutter prints a success result.

## Why This Matters

Before this lesson, we had to manually open the app and try the form.

Now we have automated proof for an important UI behavior:

```text
AppTextField shows validation errors
AppTextField clears validation errors after valid input
```

That gives us confidence when we keep building.

## Why We Did Not Start With Localization Tests

Our real validators use translation helpers like:

```dart
'todos.title_required'.tr()
```

Those are important, but localization-aware tests need extra setup.

For a beginner lesson, the first goal is simpler:

```text
Learn how to build a widget.
Learn how to tap a button.
Learn how to type text.
Learn how to check what appears on screen.
```

We can add deeper localization and validator tests later.
