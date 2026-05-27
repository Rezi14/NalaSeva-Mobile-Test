class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }
    final normalized = value.trim();
    if (normalized.contains(' ')) {
      return 'Format email tidak valid';
    }
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');
    if (!emailRegex.hasMatch(normalized)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  static String? validateRequiredText(String? value, {String message = 'Field tidak boleh kosong'}) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? validatePositiveInteger(String? value, {String message = 'Harus berupa angka lebih dari 0'}) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed <= 0) {
      return message;
    }
    return null;
  }
}
