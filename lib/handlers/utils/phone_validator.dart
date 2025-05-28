String? validateIndianPhone(String? value) {
  if (value == null || value.isEmpty) {
    return 'Enter phone number';
  }
  if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
    return 'Enter valid 10-digit Indian number';
  }
  return null;
}
