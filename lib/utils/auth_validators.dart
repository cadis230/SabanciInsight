String? validateSabanciEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Email giriniz';
  }
  if (!value.trim().endsWith('@sabanciuniv.edu')) {
    return 'Sabancı Üniversitesi email adresi giriniz';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.length < 6) {
    return 'En az 6 karakter giriniz';
  }
  return null;
}

bool isValidSabanciEmail(String email) {
  return validateSabanciEmail(email) == null;
}