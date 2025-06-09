class PatientProfile {
  final int id;
  final String name;
  final String? relative;
  final String dateOfBirth;
  final String gender;
  final double? weight;
  final double? height;
  final String? bloodType;
  final String? phoneNumber;
  final String patientId;
  final String email;

  PatientProfile({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    required this.gender,
    this.weight,
    this.height,
    this.bloodType,
    this.phoneNumber,
    this.relative,
    required this.patientId,
    required this.email,
  });

  factory PatientProfile.fromJson(Map<String, dynamic> json) {
    return PatientProfile(
      id: json['id'],
      name: json['name'],
      relative: json['relative'],
      dateOfBirth: json['dateOfBirth'],
      gender: json['gender'],
      weight: json['weight']?.toDouble(),
      height: json['height']?.toDouble(),
      bloodType: json['bloodType'],
      phoneNumber: json['phoneNumber'],
      patientId: json['patientId'],
      email: json['user'] is Map<String, dynamic>
          ? json['user']['email'] ?? 'Unknown'
          : 'Unknown',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'relative': relative,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
        'weight': weight,
        'height': height,
        'bloodType': bloodType,
        'phoneNumber': phoneNumber,
      };

  PatientProfile copyWith({
    int? id,
    String? name,
    String? relative,
    String? dateOfBirth,
    String? gender,
    double? weight,
    double? height,
    String? bloodType,
    String? phoneNumber,
    String? patientId,
    String? email,
  }) {
    return PatientProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      relative: relative ?? this.relative,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      bloodType: bloodType ?? this.bloodType,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      patientId: patientId ?? this.patientId,
      email: email ?? this.email,
    );
  }
}
