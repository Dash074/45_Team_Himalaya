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

    // Create a text detector instance
    final textDetector = GoogleMlKit.vision.textRecognizer();

    // Process the image to extract text
    try {
      final RecognizedText recognizedText =
          await textDetector.processImage(inputImage);

      setState(() {
        _recognizedText = recognizedText.text; // Store recognized text
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error recognizing text: $e')),
      );
    } finally {
      // Close the text detector when done
      await textDetector.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select an Image'),
      ),
      body: Column(
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
            child: Text('Choose Image from Gallery'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Go back to the previous page
            },
            child: Text('Go Back'),
          ),
          SizedBox(height: 20),
          if (_recognizedText != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Recognized Text:\n$_recognizedText',
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
