class LabResult {
  final int id;
  final String title;
  final String description;
  final String filePath;
  final bool isSent;
  final String createdAt;
  final String patientId;
  final String patientName;

  LabResult({
    required this.id,
    required this.title,
    required this.description,
    required this.filePath,
    required this.isSent,
    required this.createdAt,
    required this.patientId,
    required this.patientName,
  });

  factory LabResult.fromJson(Map<String, dynamic> json) {
    return LabResult(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      filePath: json['filePath'],
      isSent: json['isSent'],
      createdAt: json['createdAt'],
      patientId: json['patientId'],
      patientName: json['user']?['profile']?['name'] ?? 'Unknown',
    );
  }
}
