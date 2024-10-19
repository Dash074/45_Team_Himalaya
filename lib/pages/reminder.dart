import 'package:cloud_firestore/cloud_firestore.dart';

class Reminder {
  final String id; // Assuming you have an id field
  final String medicineName;
  final int dosage;
  final int duration;
  final List<String> times; // Array of times

  Reminder({
    required this.id,
    required this.medicineName,
    required this.dosage,
    required this.duration,
    required this.times,
  });

  // Factory constructor to create a Reminder from Firestore document
  factory Reminder.fromDocument(DocumentSnapshot doc) {
    return Reminder(
      id: doc.id,
      medicineName:
          doc['name'] ?? '', // Adjust based on your Firestore field names
      dosage: doc['dosage'] ?? 0,
      duration: doc['duration'] ?? 0,
      times: List<String>.from(doc['times'] ?? []), // Convert to List<String>
    );
  }

  // Convert Reminder to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': medicineName,
      'dosage': dosage,
      'duration': duration,
      'times': times,
    };
  }
}
