class LabResult {
  final int id;
  final String? title;
  final String? reportDate;
  final String? reportType;
  final String? status;
  final String? downloadUrl;

  LabResult({
    required this.id,
    this.title,
    this.reportDate,
    this.reportType,
    this.status,
    this.downloadUrl,
  });

  factory LabResult.fromJson(Map<String, dynamic> json) {
  final rawId = json['id'];
  final int? parsedId = rawId is int ? rawId : int.tryParse(rawId.toString());

  if (parsedId == null) {
    throw FormatException('Invalid lab result ID: $rawId');
  }

  return LabResult(
    id: parsedId,
    title: json['title'],
    reportDate: json['reportDate'],
    reportType: json['reportType'],
    status: json['status'],
    downloadUrl: json['downloadUrl'] ?? 'http://192.168.100.7:3001/lab-results/download/$parsedId',
  );
}

} 