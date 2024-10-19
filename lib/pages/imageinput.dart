import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';

class ImageInputPage extends StatefulWidget {
  @override
  _ImageInputPageState createState() => _ImageInputPageState();
}

class _ImageInputPageState extends State<ImageInputPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  String? _recognizedText;
  List<Map<String, dynamic>> _medicinesList = [];

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _selectedImage = pickedFile;
        });
        await _performOCR(pickedFile.path); // Call OCR processing
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No image selected')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _performOCR(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final textDetector = GoogleMlKit.vision.textRecognizer();

    try {
      final RecognizedText recognizedText =
          await textDetector.processImage(inputImage);
      setState(() {
        _recognizedText = recognizedText.text; // Store recognized text
      });

      _parseExtractedText(recognizedText.text); // Parse the recognized text
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error recognizing text: $e')),
      );
    } finally {
      await textDetector.close(); // Close the text detector when done
    }
  }

  void _parseExtractedText(String text) {
    final RegExp medicineRegex =
        RegExp(r'\b(TAB|CAP)\.\s*([\w\s]+)', caseSensitive: false);
    final RegExp dosageRegex =
        RegExp(r'(\d+)\s*(morning|evening|night)', caseSensitive: false);
    final RegExp durationRegex = RegExp(r'(\d+)\s*days?', caseSensitive: false);

    List<Map<String, dynamic>> medicinesList = [];

    Iterable<Match> medicineMatches = medicineRegex.allMatches(text);
    for (var match in medicineMatches) {
      String medicineName = match.group(0) ?? '';
      String duration = '';

      Iterable<Match> durationMatches = durationRegex.allMatches(text);
      if (durationMatches.isNotEmpty) {
        duration = '${durationMatches.first.group(1)}';
      }

      medicinesList.add({
        'name': medicineName.trim(),
        'dosage': 1, // Start with a default dosage of 1
        'duration':
            int.tryParse(duration) ?? 7, // Ensure duration is an integer
        'times': [], // Initialize as an empty list
      });
    }

    setState(() {
      _medicinesList = medicinesList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Medication Reminder'),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _selectedImage != null
                  ? Image.file(
                      File(_selectedImage!.path),
                      width: 200,
                      height: 200,
                    )
                  : Center(child: Text('No image selected.')),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: Center(child: Text('Choose Image from Gallery')),
              ),
              SizedBox(height: 20),
              _buildMedicinesList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicinesList() {
    return Column(
      children: _medicinesList.map((medicine) {
        return Card(
          margin: EdgeInsets.all(10),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: TextEditingController(text: medicine['name']),
                  decoration: InputDecoration(labelText: 'Medicine Name'),
                  onChanged: (value) => medicine['name'] = value,
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () {
                        setState(() {
                          if (medicine['dosage'] > 1) {
                            medicine['dosage']--;
                            // Ensure to remove the last selected time if possible
                            if (medicine['times'].isNotEmpty) {
                              medicine['times'].removeLast();
                            }
                          }
                        });
                      },
                    ),
                    Text('${medicine['dosage']} times/day'),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          medicine['dosage']++;
                        });
                      },
                    ),
                  ],
                ),
                TextField(
                  controller: TextEditingController(
                      text: medicine['duration'].toString()),
                  decoration: InputDecoration(labelText: 'Duration (days)'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) =>
                      medicine['duration'] = int.tryParse(value) ?? 7,
                ),
                Text('Select Times:'),
                SizedBox(height: 10),
                _buildTimeCarousel(medicine),
                SizedBox(height: 10),
                Text('Selected Times: ${medicine['times'].join(', ')}'),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimeCarousel(Map<String, dynamic> medicine) {
    List<String> timeSlots = _generateTimeSlots();
    return Container(
      height: 100, // Set a fixed height for the carousel
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: timeSlots.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                // Check if the selected time already exists
                if (medicine['times'].contains(timeSlots[index])) {
                  // Deselect the time
                  medicine['times'].remove(timeSlots[index]);
                } else {
                  // Allow selection only if dosage limit is not reached
                  if (medicine['times'].length < medicine['dosage']) {
                    medicine['times'].add(timeSlots[index]);
                  } else {
                    // Show a dialog if the limit is reached
                    _showDosageLimitDialog(context, medicine['dosage']);
                  }
                }
              });
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 5),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: medicine['times'].contains(timeSlots[index])
                    ? Colors.blue
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                // Center the text within the box
                child: Text(
                  timeSlots[index],
                  style: TextStyle(
                    color: medicine['times'].contains(timeSlots[index])
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDosageLimitDialog(BuildContext context, int dosageLimit) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Dosage Limit Reached'),
          content: Text('You can only select $dosageLimit timings.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  List<String> _generateTimeSlots() {
    List<String> timeSlots = [];
    for (int hour = 0; hour < 24; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        String timeString =
            '${hour % 12 == 0 ? 12 : hour % 12}:${minute.toString().padLeft(2, '0')} ${hour < 12 ? 'AM' : 'PM'}';
        timeSlots.add(timeString);
      }
    }
    return timeSlots;
  }
}
