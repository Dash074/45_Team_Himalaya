import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart'; // Import your login page
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DateTime _currentDate = DateTime.now();

  void _logout(BuildContext context) async {
    await _auth.signOut();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logged out successfully')),
    );
    // Navigate back to the login page
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  void _previousDates() {
    setState(() {
      _currentDate = _currentDate.subtract(Duration(days: 1));
    });
  }

  void _nextDates() {
    setState(() {
      _currentDate = _currentDate.add(Duration(days: 1));
    });
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> dates = [];
    for (int i = -2; i <= 2; i++) {
      // Display 5 dates
      dates.add(_currentDate.add(Duration(days: i)));
    }

    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Column(
        children: [
          Container(
            color: Colors.lightBlue.shade50, // Lighter pastel blue color
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  DateFormat('MMMM').format(_currentDate), // Current month
                  style: TextStyle(fontSize: 24, color: Colors.black),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_left, color: Colors.black),
                      onPressed: _previousDates,
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: dates.map((date) {
                          bool isToday =
                              DateUtils.isSameDay(date, DateTime.now());
                          return Container(
                            decoration: BoxDecoration(
                              color: isToday
                                  ? Colors.yellow.shade200
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(8),
                            width: 48, // Adjust width for uniform size
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  DateFormat('dd').format(date),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isToday
                                          ? Colors.black
                                          : Colors.black54),
                                ),
                                Text(
                                  DateFormat('EEE').format(date),
                                  style: TextStyle(
                                      color: isToday
                                          ? Colors.black
                                          : Colors.black54),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_right, color: Colors.black),
                      onPressed: _nextDates,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () => _logout(context),
              child: Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
