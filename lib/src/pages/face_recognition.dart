import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class FaceRecognition extends StatefulWidget {
  const FaceRecognition({super.key});

  @override
  _FaceRecognitionState createState() => _FaceRecognitionState();
}

class _FaceRecognitionState extends State<FaceRecognition> {
  File? _capturedImage;
  File? _profileImage;
  final picker = ImagePicker();
  User? user = FirebaseAuth.instance.currentUser;
  bool _isProcessing = false;
  late Interpreter interpreter;

  @override
  void initState() {
    super.initState();
    _fetchProfileImage();
    _loadModel();
  }

  Future<void> _loadModel() async {
    interpreter = await Interpreter.fromAsset('assets/facenet.tflite');
  }

  Future<void> _fetchProfileImage() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('students').doc(user?.uid).get();
      String? imageUrl = userDoc['profileImageUrl'];
      if (imageUrl != null && imageUrl.isNotEmpty) {
        final response = await http.get(Uri.parse(imageUrl));
        final documentDirectory = await getApplicationDocumentsDirectory();
        File profileImageFile = File('${documentDirectory.path}/profile.jpg');
        await profileImageFile.writeAsBytes(response.bodyBytes);
        setState(() { _profileImage = profileImageFile; });
      }
    } catch (e) {
      print("Error fetching profile image: $e");
    }
  }

  // Future<void> _captureImage() async {
  //   final pickedFile = await picker.pickImage(source: ImageSource.camera);
  //   if (pickedFile != null) {
  //     setState(() { _capturedImage = File(pickedFile.path); });
  //     if (_profileImage != null) { _compareFaces(); }
  //   }
  // }

  // Future<void> _compareFaces() async {
  //   setState(() { _isProcessing = true; });
  //   try {
  //     final faceDetector = FaceDetector(options: FaceDetectorOptions(enableContours: true));
  //     final capturedEmbedding = await _getFaceEmbedding(_capturedImage!);
  //     final profileEmbedding = await _getFaceEmbedding(_profileImage!);
  //     double similarity = _cosineSimilarity(capturedEmbedding, profileEmbedding);
  //     bool isMatch = similarity > 0.7;
  //     _showResultDialog(isMatch);
  //   } catch (e) {
  //     print("Error in face detection: $e");
  //     _showResultDialog(false);
  //   } finally {
  //     setState(() { _isProcessing = false; });
  //   }
  // }

  // Future<List<double>> _getFaceEmbedding(File image) async {
  //   final inputImage = InputImage.fromFile(image);
  //   final faceDetector = FaceDetector(options: FaceDetectorOptions(enableContours: true));
  //   final faces = await faceDetector.processImage(inputImage);
  //   if (faces.isEmpty) throw Exception("No face detected");
  //   List<List<double>> output = List.generate(1, (_) => List.filled(128, 0));
  //   interpreter.run(image.readAsBytesSync(), output);
  //   return output[0];
  // }

  double _cosineSimilarity(List<double> a, List<double> b) {
    double dotProduct = 0, normA = 0, normB = 0;
    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    return dotProduct / (sqrt(normA) * sqrt(normB));
  }

  void _showResultDialog(bool isSuccess) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isSuccess ? "Face Matched!" : "Face Not Recognized"),
        content: Text(
          isSuccess ? "Attendance Marked Successfully!" : "Face does not match. Try again.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (isSuccess) Navigator.pop(context, _capturedImage!.path);
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFDF00),
      appBar: AppBar(
        title: Text("Face Recognition", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF0A0A23),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Capture Your Face for Attendance",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0A0A23)),
              ),
              SizedBox(height: 20),
              _capturedImage != null
                  ? Image.file(_capturedImage!, width: 200, height: 200)
                  : Icon(Icons.person, size: 100, color: Color(0xFF0A0A23)),
              SizedBox(height: 20),
              // ElevatedButton.icon(
              //   onPressed: _captureImage,
              //   icon: Icon(Icons.camera_alt, color: Colors.white),
              //   label: Text("Capture Face"),
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: Color(0xFF0A0A23),
              //     foregroundColor: Colors.white,
              //     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              //   ),
              // ),
              if (_isProcessing) ...[
                SizedBox(height: 20),
                CircularProgressIndicator(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
