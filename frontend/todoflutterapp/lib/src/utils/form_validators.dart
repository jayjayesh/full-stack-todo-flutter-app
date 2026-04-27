import 'package:easy_localization/easy_localization.dart';

import 'app_utils.dart';

class FormValidators {
  static String? requiredName(String? value) {
    final name = value?.trim() ?? '';

    if (AppUtils.isBlank(name)) {
      return 'auth.name_required'.tr();
    }

    if (name.length < 2) {
      return 'auth.name_too_short'.tr();
    }

    if (name.length > 80) {
      return 'auth.name_too_long'.tr();
    }

    return null;
  }

  static String? requiredEmail(String? value) {
    final email = value?.trim() ?? '';

    if (AppUtils.isBlank(email)) {
      return 'auth.email_required'.tr();
    }

    if (!AppUtils.isValidEmail(email)) {
      return 'auth.email_invalid'.tr();
    }

    return null;
  }

  static String? requiredPassword(String? value) {
    if (AppUtils.isBlank(value)) {
      return 'auth.password_required'.tr();
    }

    if (value!.length < 6) {
      return 'auth.password_too_short'.tr();
    }

    return null;
  }

  static String? requiredConfirmPassword({
    required String? value,
    required String password,
  }) {
    if (AppUtils.isBlank(value)) {
      return 'auth.confirm_password_required'.tr();
    }

    if (value != password) {
      return 'auth.passwords_do_not_match'.tr();
    }

    return null;
  }

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
}
