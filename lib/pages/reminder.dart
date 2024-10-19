class Reminder {
  final String medicineName; // Name of the medicine
  final String dosage; // Dosage information
  final String duration; // Duration for taking the medicine
  final String timings; // Timings for the reminders

  Reminder({
    required this.medicineName,
    required this.dosage,
    required this.duration,
    required this.timings,
  });

  // Method to create a Reminder object from a Map (used for fetching from Firebase)
  factory Reminder.fromMap(Map<String, dynamic> data) {
    return Reminder(
      medicineName: data['medicineName'] ?? '',
      dosage: data['dosage'] ?? '', // Added dosage
      duration: data['duration'] ?? '', // Added duration
      timings: data['timings'] ?? '', // Added timings
    );
  }

  // Method to convert Reminder object to a Map (used for saving to Firebase)
  Map<String, dynamic> toMap() {
    return {
      'medicineName': medicineName,
      'dosage': dosage,
      'duration': duration,
      'timings': timings,
    };
  }
}
