class AppNotification {
  final int id;
  final String message;
  final bool isRead;
  final String type;
  final String recipientType;
  final String createdAt;
  final String? patientId;

  AppNotification({
    required this.id,
    required this.message,
    required this.isRead,
    required this.type,
    required this.recipientType,
    required this.createdAt,
    this.patientId,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      message: json['message'],
      isRead: json['isRead'],
      type: json['type'],
      recipientType: json['recipientType'],
      createdAt: json['createdAt'],
      patientId: json['patientId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'isRead': isRead,
      'type': type,
      'recipientType': recipientType,
      'createdAt': createdAt,
      'patientId': patientId,
    };
  }
} 