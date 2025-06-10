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
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString() ?? 'N/A',
      date: json['date']?.toString() ?? 'N/A',
      time: json['time']?.toString() ?? 'N/A',
      testType: json['testType']?.toString() ?? 'N/A',
      patient: json['patient'] != null ? Patient.fromJson(json['patient']) : Patient(),
    );
  }
}

class Patient {
  final String? patientId;

  Patient({this.patientId});

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(patientId: json['patientId']?.toString());
  }
}
