class Appointment {
  final String id;
  final String testType;
  final String date; // Format: YYYY-MM-DD
  final String time; // e.g., "09:00 AM"
  final String status;

  Appointment({
    required this.id,
    required this.testType,
    required this.date,
    required this.time,
    required this.status,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String,
      testType: json['testType'] as String,
      date: json['date'] as String,
      time: json['time'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'testType': testType,
      'date': date,
      'time': time,
      'status': status,
    };
  }
}
