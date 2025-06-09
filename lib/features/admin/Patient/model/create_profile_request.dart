class CreateProfileRequest {
  final String email;
  final String password;
  final String role;
  final String name;
  final String dateOfBirth;
  final String gender;
  final double? weight;
  final double? height;
  final String? bloodType;
  final String? phoneNumber;
  final String? relative;

  CreateProfileRequest({
    required this.email,
    required this.password,
    required this.role,
    required this.name,
    required this.dateOfBirth,
    required this.gender,
    this.weight,
    this.height,
    this.bloodType,
    this.phoneNumber,
    this.relative,
  });

  Map<String, dynamic> toUserJson() {
    return {
      'email': email,
      'password': password,
      'role': role,
    };
  }

  Map<String, dynamic> toProfileJson(int userId) {
    return {
      'userId': userId,
      'name': name,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      if (weight != null) 'weight': weight,
      if (height != null) 'height': height,
      if (bloodType != null) 'bloodType': bloodType,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (relative != null) 'relative': relative,
    };
  }

  Map<String, dynamic> toRegisterJson() {
    return {
      'email': email,
      'password': password,
      'role': role,
      'name': name,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      if (weight != null) 'weight': weight,
      if (height != null) 'height': height,
      if (bloodType != null) 'bloodType': bloodType,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (relative != null) 'relative': relative,
    };
  }
}
