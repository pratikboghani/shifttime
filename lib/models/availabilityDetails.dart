class AvailabilityDetails {
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String availabilityType; // Assuming you have an availability type

  AvailabilityDetails({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.availabilityType,
  });
  Map<String, String> toJson() {
    return {
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'availability_type': availabilityType,
    };
  }
}

