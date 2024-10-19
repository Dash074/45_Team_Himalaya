// reminder_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'reminder.dart';

class ReminderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Reminder>> fetchReminders(String userId) async {
    final snapshot = await _db
        .collection('reminders')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) => Reminder.fromMap(doc.data())).toList();
  }
}
