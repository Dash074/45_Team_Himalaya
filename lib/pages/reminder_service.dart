import 'package:cloud_firestore/cloud_firestore.dart';
import 'reminder.dart';

class ReminderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fetch reminders for a specific user
  Future<List<Reminder>> fetchReminders(String userId) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('users') // Assuming you have a collection named 'users'
          .doc(userId)
          .collection('medications') // Subcollection for the medications
          .orderBy('time') // Order reminders by time
          .get();

      // Map the documents to Reminder objects
      return snapshot.docs.map((doc) => Reminder.fromDocument(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch reminders: $e');
    }
  }

  // Add a new reminder
  Future<void> addReminder(String userId, Reminder reminder) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('medications')
          .add(reminder.toMap());
    } catch (e) {
      throw Exception('Failed to add reminder: $e');
    }
  }

  // Update an existing reminder
  Future<void> updateReminder(String userId, Reminder reminder) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('medications')
          .doc(reminder.id) // Use the id to find the correct document
          .update(reminder.toMap());
    } catch (e) {
      throw Exception('Failed to update reminder: $e');
    }
  }

  // Delete a reminder
  Future<void> deleteReminder(String userId, String reminderId) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('medications')
          .doc(reminderId) // Use the id to find the correct document
          .delete();
    } catch (e) {
      throw Exception('Failed to delete reminder: $e');
    }
  }
}
