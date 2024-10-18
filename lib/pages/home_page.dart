import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart'; // Import your login page
import 'package:intl/intl.dart';
import 'imageinput.dart';

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

    // Determine the current month
    String currentMonth = DateFormat('MMMM').format(_currentDate);

    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Padding(
        // Added padding for screen border reduction
        padding: const EdgeInsets.symmetric(horizontal: 8.0), // Reduced padding
        child: Column(
          children: [
            Container(
              color: Colors.lightBlue.shade50, // Lighter pastel blue color
              padding: EdgeInsets.all(8.0), // Reduced padding
              child: Column(
                children: [
                  Text(
                    currentMonth, // Current month
                    style: TextStyle(fontSize: 24, color: Colors.black),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment
                        .spaceBetween, // Buttons on extreme ends
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_left, color: Colors.black),
                        onPressed: _previousDates,
                      ),
                      SizedBox(width: 10), // Space between button and carousel
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: dates.map((date) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6), // Space between boxes
                              width: 48, // Uniform width for boxes
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    DateFormat('EEE')
                                        .format(date), // Shortened day name
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                  Text(
                                    DateFormat('dd').format(date),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: DateUtils.isSameDay(
                                              date, DateTime.now())
                                          ? Colors.black
                                          : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                              decoration: BoxDecoration(
                                color: DateUtils.isSameDay(date, DateTime.now())
                                    ? Colors.yellow.shade200
                                    : Colors
                                        .transparent, // No box for non-highlighted dates
                                borderRadius: BorderRadius.circular(8),
                                // boxShadow: [
                                //   BoxShadow(
                                //     color: Colors.grey.withOpacity(0.5),
                                //     spreadRadius: 2,
                                //     blurRadius: 5,
                                //     offset: Offset(0, 3),
                                //   ),
                                // ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(width: 10), // Space between carousel and button
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
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, -3), // Shadow positioned above the bar
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
            vertical: 10), // Padding to make the bar a bit thicker
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ImageInputPage()),
                );
              },
              child: Icon(Icons.add),
              backgroundColor: Colors.blue, // Color for the floating button
            ),
          ],
        ),
      ),
    );
  }
}
