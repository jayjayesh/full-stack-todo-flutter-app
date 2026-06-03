# Lesson 22: Frontend Localization Setup and Hindi Translations

In this lesson we connected the Flutter app to a real two-language localization setup.

Before this lesson, the app already had `easy_localization` in place, but only English was really supported in the active flow and a few visible labels were still hardcoded in English.

## The Goal

The goal was simple:

```text
Support English and Hindi
Keep the localization setup easy to understand
Move visible user text behind translation keys
```

## What Changed

We updated the localization wrapper so the app now supports:

```text
en
hi
```

The translation assets now live in:

```text
frontend/todoflutterapp/assets/translations/en.json
frontend/todoflutterapp/assets/translations/hi.json
```

The old Spanish file was removed because the project only needs English and Hindi for this milestone.

## Why We Moved More Text Into Translation Keys

Localization is only useful when the user actually sees translated text.

So we updated the visible strings in the main flow:

```text
onboarding screen
login screen
signup screen
forgot password screen
home screen
```

That includes button labels, tooltips, dialog text, loading text, empty states, and success messages.

## Why The Onboarding Data Moved Out Of initState

The onboarding page used `tr()` while building its local data list inside `initState`.

That works for a fixed language, but it is not a great pattern if the locale changes later.

We moved the translated strings into a getter so they are resolved during `build()` instead.

That keeps the screen aligned with the current locale.

## Translation Files

The English file is still the reference source:

```json
assets/translations/en.json
```

The Hindi file mirrors the same keys:

```json
assets/translations/hi.json
```

The important rule is:

```text
Same keys, different language values
```

That makes it easy to add another language later.

## Test Coverage

We updated the Flutter widget test so it now checks that Hindi translations load correctly.

That gives us a basic guard against accidentally breaking the locale wiring later.

## What You Learned

Localization is not just adding a file.

It has three parts:

```text
1. Tell the app which locales it supports.
2. Put the text into translation files.
3. Make the screens read translated keys instead of hardcoded strings.
```

Once those three pieces are in place, adding another language becomes mostly a data task instead of a rewrite.

## Files We Updated

```text
frontend/todoflutterapp/lib/src/shared/wrappers/localization_wrapper.dart
frontend/todoflutterapp/lib/src/features/onboarding/presentation/screens/onboarding_page.dart
frontend/todoflutterapp/lib/src/features/auth/presentation/screens/login_screen.dart
frontend/todoflutterapp/lib/src/features/auth/presentation/screens/signup_screen.dart
frontend/todoflutterapp/lib/src/features/auth/presentation/screens/forgot_password_screen.dart
frontend/todoflutterapp/lib/src/features/home/presentation/screens/home_page.dart
frontend/todoflutterapp/assets/translations/en.json
frontend/todoflutterapp/assets/translations/hi.json
frontend/todoflutterapp/test/widget_test.dart
docs/FRONTEND.md
README.md
```

## Next Recommended Lesson

Lesson 23 can focus on a new improvement that builds on this cleaner app foundation.
