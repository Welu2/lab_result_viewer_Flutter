class Appointment {
  final String id;
  final String testType;
  final String date; // Format: YYYY-MM-DD
  final String time; // e.g., "09:00 AM"
  final String status;
  final Patient? patient; // Added for user appointments screen

  Appointment({
    required this.id,
    required this.testType,
    required this.date,
    required this.time,
    required this.status,
    this.patient,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'].toString(), // Ensure ID is String
      testType: json['testType'] as String,
      date: json['date'] as String,
      time: json['time'] as String,
      status: json['status'] as String,
      patient: json['patient'] != null ? Patient.fromJson(json['patient']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'testType': testType,
      'date': date,
      'time': time,
      'status': status,
      'patient': patient?.toJson(),
    };
  }
}

class Patient {
  final String? id; // Assuming patient has an ID
  final String? patientId;
  final String? email;
  final String? name;

  Patient({
    this.id,
    this.patientId,
    this.email,
    this.name,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id']?.toString(),
      patientId: json['patientId'] as String?,
      email: json['email'] as String?,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'email': email,
      'name': name,
    };
  }
}
