import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'package:intl/intl.dart';
import 'imageinput.dart';
import 'reminder.dart';
import 'reminder_service.dart';
import 'profile_pages.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DateTime _currentDate = DateTime.now();
  List<Reminder> _reminders = [];
  final ReminderService _reminderService = ReminderService();

  @override
  void initState() {
    super.initState();
    _fetchReminders();
  }

  Future<void> _fetchReminders() async {
    String? userId = _auth.currentUser?.uid;

    if (userId != null) {
      try {
        List<Reminder> reminders =
            await _reminderService.fetchReminders(userId);
        setState(() {
          _reminders = reminders;
        });
      } catch (e) {
        _showSnackBar('Error fetching reminders: $e');
      }
    } else {
      _showSnackBar('User not logged in');
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
        5, (index) => _currentDate.add(Duration(days: index - 2)));
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
                onPressed: () => _changeDate(-1), // Update here
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: dates.map((date) => _buildDateBox(date)).toList(),
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_right, color: Colors.black),
                onPressed: () => _changeDate(1), // Update here
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
    return Expanded(
      child: ListView.builder(
        itemCount: _reminders.length,
        itemBuilder: (context, index) {
          final reminder = _reminders[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              title: Text(reminder.medicineName ?? 'No name provided'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dosage: ${reminder.dosage ?? 'N/A'} mg'),
                  Text('Duration: ${reminder.duration ?? 'N/A'} days'),
                  Text('Times: ${reminder.times.join(', ') ?? 'N/A'}'),
                ],
              ),
            ),
          );
        },
      ),
    );
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
            icon: Icon(Icons.add, color: Colors.blue, size: 30),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
            icon: Icon(Icons.person, color: Colors.green, size: 30),
          ),
        ],
      ),
    );
  }
}
