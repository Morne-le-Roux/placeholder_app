String? validateEmail(String? email) {
  if (email == null || email.isEmpty) {
    return "Email is required";
  }
  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
    return "Invalid email address";
  }
  return null;
}
