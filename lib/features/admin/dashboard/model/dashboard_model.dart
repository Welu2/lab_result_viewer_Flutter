class DashboardStats {
  final int totalAppointments;
  final int totalPatients;
  final int totalLabResults;
  final List<Appointment> upcomingAppointments;

  DashboardStats({
    required this.totalAppointments,
    required this.totalPatients,
    required this.totalLabResults,
    required this.upcomingAppointments,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalAppointments: json['totalAppointments'],
      totalPatients: json['totalPatients'],
      totalLabResults: json['totalLabResults'],
      upcomingAppointments: (json['upcomingAppointments'] as List)
          .map((item) => Appointment.fromJson(item))
          .toList(),
    );
  }
}

class Appointment {
  final String time;
  final String patientId;
  final String patientName;
  final String testType;

  Appointment({
    required this.time,
    required this.patientId,
    required this.patientName,
    required this.testType,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      time: json['time'] ?? 'N/A',
      patientId: json['patientId'] ?? 'N/A',
      patientName: json['patientName'] ?? 'Unknown',
      testType: json['testType'] ?? 'Unknown',
    );
  }
}
