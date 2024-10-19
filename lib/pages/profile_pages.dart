import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';

class ProfilePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _logout(BuildContext context) async {
    try {
      await _auth.signOut();
      // Navigate back to login page after logout
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) =>
                LoginPage()), // Make sure to import your LoginPage
      );
    } catch (e) {
      // Handle errors during sign out if needed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed. Please try again.')),
      );
    }
  }

  Future<void> _editName(BuildContext context, String currentName) async {
    final TextEditingController _nameController =
        TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Name'),
          content: TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Enter your name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String newName = _nameController.text.trim();
                if (newName.isNotEmpty) {
                  try {
                    await _firestore
                        .collection('users')
                        .doc(_auth.currentUser?.uid)
                        .update({
                      'name': newName,
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Name updated successfully!')),
                    );
                    Navigator.of(context).pop(); // Close the dialog
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update name.')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Name cannot be empty.')),
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // Fetch current user name from Firestore before editing
              _firestore
                  .collection('users')
                  .doc(_auth.currentUser?.uid)
                  .get()
                  .then((doc) {
                if (doc.exists) {
                  var userData = doc.data() as Map<String, dynamic>;
                  _editName(context, userData['name'] ?? 'N/A');
                }
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            _firestore.collection('users').doc(_auth.currentUser?.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error fetching data.'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('No data found.'));
          }

          // Get user data from Firestore document
          var userData = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Name
                Text(
                  'Name:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Text(
                  '${userData['name'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),

                // User Email
                Text(
                  'Email:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Text(
                  '${userData['email'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),

                // User ID
                Spacer(),
                Center(
                  child: Text(
                    'User ID: ${_auth.currentUser?.uid}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),

                // Logout Button
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () => _logout(context),
                    child: Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
