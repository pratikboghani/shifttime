class BookoffRequest {
  final String userId;
  final int clientId;
  final String startDate;
  final String endDate;
  final String reasons;
  final bool isApproved;

  BookoffRequest({
    required this.userId,
    required this.clientId,
    required this.startDate,
    required this.endDate,
    required this.reasons,
    required this.isApproved,
  });

  factory BookoffRequest.fromJson(Map<String, dynamic> json) {
    return BookoffRequest(
      userId: json['userId'],
      clientId: json['clientId'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      reasons: json['reasons'],
      isApproved: json['isApproved'],
    );
  }
}