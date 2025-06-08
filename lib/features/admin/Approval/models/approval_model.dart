class Appointment {
  final int id;
  final String status;
  final String date;
  final String time;
  final String testType;
  final Patient patient;

  Appointment({
    required this.id,
    required this.status,
    required this.date,
    required this.time,
    required this.testType,
    required this.patient,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] ?? "N/A",
      status: json['status'] ?? "N/A",
      date: json['date'] ?? "N/A",
      time: json['time'] ?? "N/A",
      testType: json['testType'] ?? "N/A",
      patient: Patient.fromJson(json['patient']),
    );
  }
}

class Patient {
  final String? patientId;

  Patient({this.patientId});

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(patientId: json['patientId']);
  }
}
