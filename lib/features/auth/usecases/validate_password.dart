String? validatePassword(String? password) {
  if (password == null || password.isEmpty) {
    return "Password is required";
  }
  if (password.length < 6) {
    return "Password must be at least 6 characters long";
  }
  if (password.length > 20) {
    return "Password must be less than 20 characters long";
  }
  return null;
}
