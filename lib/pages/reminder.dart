import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart'
    as tz; // This is important for TZDateTime

class RemindersPage extends StatefulWidget {
  @override
  _RemindersPageState createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  List<Map<String, dynamic>> _medicines = [];

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones(); // Initialize the time zone database
    _fetchMedicines();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _fetchMedicines() async {
    final user = _auth.currentUser;
    if (user != null) {
      final medicinesSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('medicines')
          .get();

      setState(() {
        _medicines = medicinesSnapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medicine Reminders'),
      ),
      body: _medicines.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _medicines.length,
              itemBuilder: (context, index) {
                return _buildMedicineCard(_medicines[index]);
              },
            ),
    );
  }

  Widget _buildMedicineCard(Map<String, dynamic> medicine) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              medicine['name'],
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('Dosage: ${medicine['dosage']} times/day'),
            Text('Duration: ${medicine['duration']} days'),
            Text('Selected Times: ${medicine['times'].join(', ')}'),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _scheduleNotifications(medicine);
              },
              child: Text('Schedule Reminders'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _scheduleNotifications(Map<String, dynamic> medicine) async {
    List<String> times = List<String>.from(medicine['times']);

    for (var time in times) {
      TZDateTime scheduledTime = _parseTimeStringToTZ(time);
      await flutterLocalNotificationsPlugin.zonedSchedule(
        0, // Notification ID
        'Time to take your medicine', // Title
        'Don\'t forget to take ${medicine['name']}', // Body
        scheduledTime, // Scheduled time
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'your_channel_id',
            'your_channel_name',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reminders scheduled for ${medicine['name']}')),
    );
  }

  TZDateTime _parseTimeStringToTZ(String timeString) {
    final timeParts = timeString.split(' ');
    final hourMinute = timeParts[0].split(':');
    int hour = int.parse(hourMinute[0]);
    final minute = int.parse(hourMinute[1]);

    if (timeParts[1] == 'PM' && hour < 12) {
      hour += 12; // Convert to 24-hour format
    } else if (timeParts[1] == 'AM' && hour == 12) {
      hour = 0; // Midnight case
    }

    // Create a TZDateTime object for the next occurrence of the specified time
    final now = tz.TZDateTime.now(tz.local);
    TZDateTime scheduledTime =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    // If the scheduled time is in the past, schedule it for the next day
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(Duration(days: 1));
    }

    return scheduledTime;
  }
}
