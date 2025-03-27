class ValidationUtils {
  // Validate email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  // Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    return null;
  }

  // Validate name
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    return null;
  }

  // Validate phone number
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone number is optional
    }
    
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }

  // Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    return null;
  }

  // Validate numeric value
  static String? validateNumeric(String? value, {String fieldName = 'Value'}) {
    if (value == null || value.isEmpty) {
      return null; // Allow empty value
    }
    
    if (double.tryParse(value) == null) {
      return '$fieldName must be a number';
    }
    
    return null;
  }

  // Validate date
  static String? validateDate(DateTime? value, {String fieldName = 'Date'}) {
    if (value == null) {
      return '$fieldName is required';
    }
    
    return null;
  }

  // Validate future date
  static String? validateFutureDate(DateTime? value, {String fieldName = 'Date'}) {
    if (value == null) {
      return '$fieldName is required';
    }
    
    if (value.isBefore(DateTime.now())) {
      return '$fieldName must be in the future';
    }
    
    return null;
  }
}

