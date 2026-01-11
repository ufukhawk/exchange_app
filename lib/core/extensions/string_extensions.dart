extension StringExtensions on String {
  double toDoubleOrZero() {
    return double.tryParse(this) ?? 0.0;
  }

  int toIntOrZero() {
    return int.tryParse(this) ?? 0;
  }

  bool get isNotNullOrEmpty {
    return isNotEmpty;
  }
}
