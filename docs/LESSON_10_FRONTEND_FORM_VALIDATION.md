# Lesson 10: Frontend Form Validation

In Lesson 8, we added backend validation.

The backend now rejects bad input like:

```text
invalid email
short password
blank todo title
very long todo title
```

Lesson 10 adds validation in Flutter too.

## Why Validate In Flutter?

Frontend validation gives fast feedback.

If the user taps a button with an empty email field, Flutter can immediately show:

```text
Email is required
```

That is better than sending a request to the backend first.

## Why Still Validate In The Backend?

Frontend validation is for user experience.

Backend validation is for protection.

The Flutter app can be bypassed. Someone can still send requests using:

```text
curl
Postman
another script
a broken app version
```

So the rule is:

```text
Validate in Flutter to help the user.
Validate in the backend to protect the app.
```

## New Validator File

We added:

```text
frontend/todoflutterapp/lib/src/utils/form_validators.dart
```

It contains reusable validators:

```text
requiredName()
requiredEmail()
requiredPassword()
requiredConfirmPassword()
requiredTodoTitle()
```

This keeps validation rules out of the screens.

## Before

The login screen had validation directly inside the widget:

```dart
validator: (value) {
  if (AppUtils.isBlank(value)) {
    return 'auth.email_required'.tr();
  }
  if (!AppUtils.isValidEmail(value!)) {
    return 'auth.email_invalid'.tr();
  }
  return null;
}
```

That works, but if another screen needs the same email rule, we copy the code.

## After

Now the screen can say:

```dart
validator: FormValidators.requiredEmail,
```

That is easier to read.

It also means every screen uses the same email rule.

## What A Validator Returns

A Flutter form validator returns:

```text
null
```

when the field is valid.

It returns:

```text
an error message string
```

when the field is invalid.

Example:

```dart
static String? requiredTodoTitle(String? value) {
  final title = value?.trim() ?? '';

  if (AppUtils.isBlank(title)) {
    return 'todos.title_required'.tr();
  }

  if (title.length > 120) {
    return 'todos.title_too_long'.tr();
  }

  return null;
}
```

Read it as:

```text
If title is blank, show an error.
If title is too long, show an error.
Otherwise, the title is valid.
```

## How A Form Uses Validation

The form has a key:

```dart
final GlobalKey<FormState> _todoFormKey = GlobalKey<FormState>();
```

Before creating a todo, we ask the form:

```dart
if (!(_todoFormKey.currentState?.validate() ?? false)) {
  return;
}
```

That means:

```text
Run every validator in this form.
If any field is invalid, stop here.
```

Only valid data reaches the provider.

## Todo Composer Validation

The todo composer now rejects:

```text
blank todo titles
todo titles longer than 120 characters
```

This matches the backend rule from Lesson 8.

That is important. If frontend and backend rules disagree, the app feels confusing.

## Translation Messages

Validation messages live in:

```text
frontend/todoflutterapp/assets/translations/en.json
frontend/todoflutterapp/assets/translations/es.json
```

We added messages like:

```text
todos.title_required
todos.title_too_long
auth.name_too_short
auth.name_too_long
```

The validators return translation keys converted with `.tr()`, so the UI shows real text.

## Beginner Summary

Frontend form validation means:

```text
check input before sending a request
show helpful messages near the fields
reuse validation rules across screens
keep frontend rules aligned with backend rules
```

The big idea:

```text
Frontend validation helps the user fix mistakes.
Backend validation decides what the system will accept.
```
