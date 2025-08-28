class InputValidators {
  static String? required(String? value, [String fieldName = 'Поле']) {
    if (value == null || value.trim().isEmpty) return '$fieldName обязательно';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email обязателен';
    if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(value)) {
      return 'Неверный email';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return 'Номер обязателен';
    if (!RegExp(r"^\+?[0-9]{7,15}$").hasMatch(value)) {
      return 'Неверный номер телефона';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.length < 6) {
      return 'Пароль должен быть не менее 6 символов';
    }
    return null;
  }

  static String? confirmPassword(String? value, String originalPassword) {
    if (value != originalPassword) {
      return 'Пароли не совпадают';
    }
    return null;
  }
}
