class CreateProfileRequest {
  final String name;
  final String dateOfBirth;
  final String gender;
  final double? weight;
  final double? height;
  final String? bloodType;
  final String? phoneNumber;
  final String? emergencyContactRelation;

  CreateProfileRequest({
    required this.name,
    required this.dateOfBirth,
    required this.gender,
    this.weight,
    this.height,
    this.bloodType,
    this.phoneNumber,
    this.emergencyContactRelation,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dateOfBirth': dateOfBirth,
      'gender': gender.toLowerCase(),
      if (weight != null) 'weight': weight,
      if (height != null) 'height': height,
      if (bloodType != null) 'bloodType': bloodType,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (emergencyContactRelation != null) 'emergencyContactRelation': emergencyContactRelation,
    };
  }
} 