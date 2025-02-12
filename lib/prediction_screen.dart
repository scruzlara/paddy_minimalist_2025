import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:math';

class HuggingFaceService {
  //final String apiUrl = 'https://europython2022-paddy-disease-classification.hf.space/api/predict';
  final String apiUrl =
      'https://scruzlara-paddy-disease-classification.hf.space/api/predict';

  // Generate a random session hash
  String _generateSessionHash() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    final result =
        List.generate(11, (index) => chars[random.nextInt(chars.length)])
            .join();
    return result;
  }

  Future<Map<String, dynamic>> makePrediction(String base64Image) async {
    try {
      // Format the base64 string correctly
      if (!base64Image.startsWith('data:image')) {
        base64Image = 'data:image/jpeg;base64,' + base64Image;
      }

      // Generate a session hash
      final sessionHash = _generateSessionHash();

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'data': [
            base64Image,
          ],
          'session_hash': sessionHash,
          'fn_index': 0 // Adding this as it's often required by Gradio
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('API Response: ${response.body}'); // Debug print
        throw Exception(
            'Failed to make prediction: ${response.statusCode}\nResponse: ${response.body}');
      }
    } catch (e) {
      print('Error details: $e'); // Debug print
      throw Exception('Error making prediction: $e');
    }
  }
}

class PredictionScreen extends StatefulWidget {
  @override
  _PredictionScreenState createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final HuggingFaceService _service = HuggingFaceService();
  final ImagePicker _picker = ImagePicker();

  String _result = '';
  bool _isLoading = false;
  File? _selectedImage;

  Future<void> _selectImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _result = '';
        });
        await _predictWithImage();
      }
    } catch (e) {
      _showError('Error selecting image: $e');
    }
  }

  Future<void> _predictWithImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Convert image to base64
      final bytes = await _selectedImage!.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Make prediction
      final result = await _service.makePrediction(base64Image);

      setState(() {
        // Format the result nicely
        if (result.containsKey('data')) {
          if (result['data'] is List && result['data'].isNotEmpty) {
            _result = 'Prediction: ${result['data'][0]}';
          } else {
            _result = 'Prediction: ${result['data']}';
          }
        } else {
          _result = 'Received result: $result';
        }
      });
    } catch (e) {
      _showError(e.toString());
      setState(() {
        _result = '';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plant Disease Prediction'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading
                      ? null
                      : () => _selectImage(ImageSource.camera),
                  icon: Icon(Icons.camera_alt),
                  label: Text('Take Photo'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading
                      ? null
                      : () => _selectImage(ImageSource.gallery),
                  icon: Icon(Icons.photo_library),
                  label: Text('Choose from Gallery'),
                ),
              ],
            ),
            SizedBox(height: 20),
            if (_selectedImage != null) ...[
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
            if (_isLoading)
              Center(child: CircularProgressIndicator())
            else if (_result.isNotEmpty)
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prediction Result:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 8),
                      Text(_result),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
