import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';
import 'package:intl/intl.dart';
import 'imageinput.dart';
import 'profile_pages.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime _currentDate = DateTime.now();
  List<Map<String, dynamic>> _reminders = [];

  @override
  void initState() {
    super.initState();
    _fetchReminders();
  }

  Future<void> _fetchReminders() async {
    String? userId = _auth.currentUser?.uid;

    if (userId != null) {
      try {
        // Fetch data from Firestore
        QuerySnapshot snapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('medicines')
            .get();

        // Map the data to a list of reminders
        setState(() {
          _reminders = snapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
        });

        // Debugging: Print the reminders fetched
        print('Fetched reminders: $_reminders');
      } catch (e) {
        print('Error fetching reminders: $e');
        _showSnackBar('Error fetching reminders: $e');
      }
    } else {
      print('User not logged in');
      _showSnackBar('User not logged in');
    }
  }

  void _updateReminder(String reminderId, String time, bool isActive) {
    String? userId = _auth.currentUser?.uid;

    if (userId != null) {
      _firestore
          .collection('users')
          .doc(userId)
          .collection('medicines')
          .doc(reminderId)
          .update({'time': time, 'isActive': isActive}).then((_) {
        print('Reminder updated successfully.');
      }).catchError((error) {
        print('Failed to update reminder: $error');
      });
    }
  }

  Future<void> _pickTime(
      String reminderId, String currentTime, bool isActive) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateFormat.jm().parse(currentTime)),
    );

    if (pickedTime != null) {
      // Convert the picked TimeOfDay to a formatted string
      final now = DateTime.now();
      final newDateTime = DateTime(
          now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);
      String formattedTime = DateFormat.jm().format(newDateTime);

      // Update the reminder in the database with the new time
      _updateReminder(reminderId, formattedTime, isActive);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _changeDate(int days) {
    setState(() {
      _currentDate = _currentDate.add(Duration(days: days));
    });
  }

  List<DateTime> _generateDates() {
    return List.generate(
      5,
      (index) => _currentDate.add(Duration(days: index - 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> dates = _generateDates();
    String currentMonth = DateFormat('MMMM').format(_currentDate);

    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            _buildDateHeader(currentMonth, dates),
            SizedBox(height: 20),
            _buildRemindersHeader(),
            SizedBox(height: 10),
            _buildReminderList(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildDateHeader(String currentMonth, List<DateTime> dates) {
    return Container(
      color: Colors.lightBlue.shade50,
      padding: EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(currentMonth,
              style: TextStyle(fontSize: 24, color: Colors.black)),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_left, color: Colors.black),
                onPressed: () => _changeDate(-1),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: dates.map((date) => _buildDateBox(date)).toList(),
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_right, color: Colors.black),
                onPressed: () => _changeDate(1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateBox(DateTime date) {
    bool isToday = DateUtils.isSameDay(date, DateTime.now());

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6),
      width: 48,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(DateFormat('EEE').format(date),
              style: TextStyle(color: Colors.black54)),
          Text(
            DateFormat('dd').format(date),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isToday ? Colors.black : Colors.black54,
            ),
          ),
        ],
      ),
      decoration: BoxDecoration(
        color: isToday ? Colors.yellow.shade200 : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildRemindersHeader() {
    return Text('Reminders',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold));
  }

  Widget _buildReminderList() {
    if (_reminders.isEmpty) {
      return Center(
        child: Text(
          'No reminders available.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: _reminders.length,
        itemBuilder: (context, index) {
          final reminder = _reminders[index];
          final reminderId = reminder['id'] ?? '';
          final reminderTime = reminder['time'] != null
              ? _convertStringToTime(reminder['time'])
              : 'No time';

          print(
              'Reminder $index: time - ${reminder['time']}'); // Debug statement

          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              title: Text(reminder['name'] ?? 'No name'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dosage: ${reminder['dosage'] ?? 'No dosage'}'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(reminderTime),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          if (reminder['time'] != null) {
                            _pickTime(reminderId, reminder['time'],
                                reminder['isActive'] ?? true);
                          } else {
                            _showSnackBar('No time available to edit.');
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              trailing: Switch(
                value: reminder['isActive'] ?? true,
                onChanged: (bool newValue) {
                  if (reminderId.isNotEmpty) {
                    _updateReminder(reminderId, reminder['time'], newValue);
                  }
                  setState(() {
                    reminder['isActive'] = newValue;
                  });
                },
              ),
            ),
          );
        },
      ),
    );
  }

  String _convertStringToTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) {
      return 'No time';
    }

    try {
      DateTime parsedTime = DateFormat.jm().parse(timeString);
      return DateFormat.jm().format(parsedTime);
    } catch (e) {
      print('Error parsing time: $e');
      return 'Invalid time format';
    }
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ImageInputPage()),
              );
            },
            icon: Icon(Icons.camera_alt, color: Colors.blue, size: 30),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
            icon: Icon(Icons.person, color: Colors.blue, size: 30),
          ),
          IconButton(
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            icon: Icon(Icons.logout, color: Colors.blue, size: 30),
          ),
        ],
      ),
    );
  }
}
