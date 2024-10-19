import 'package:cloud_firestore/cloud_firestore.dart';
import 'reminder.dart';

class ReminderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Reminder>> fetchReminders(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('medicines')
          .get();

      List<Reminder> reminders =
          snapshot.docs.map((doc) => Reminder.fromDocument(doc)).toList();

      return reminders;
    } catch (e) {
      print('Error fetching reminders from Firestore: $e');
      return [];
    }
  }
}
