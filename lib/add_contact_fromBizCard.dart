import 'package:crmapp/add_contact.dart';
import 'package:crmapp/api/apikey.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(MaterialApp(
    theme: ThemeData.dark(),
    home: TakePictureScreen2(camera: firstCamera),
  ));
}

class TakePictureScreen2 extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen2({Key? key, required this.camera}) : super(key: key);

  @override
  TakePictureScreen2State createState() => TakePictureScreen2State();
}

class TakePictureScreen2State extends State<TakePictureScreen2> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      await _recognizeText(image.path);
    } catch (e) {
      print(e);
    }
  }

  Future<void> sendToOpenAI(String extractedText) async {
    const String openAiApiKey = api_key; // Replace with your actual API key
    const String openAiUrl = 'https://api.openai.com/v1/chat/completions';

    try {
      final response = await http.post(
        Uri.parse(openAiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAiApiKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {
              "role": "system",
              "content":
                  "You are a helpful assistant who extracts the data from a visiting card/business card from the given message and return only the JSON Object like : { name:, companyname:,contactnumber:,emailid: }designed to output JSON."
            },
            {
              "role": "user",
              "content": extractedText, // Use the extracted text here
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        // Cast to List to ensure correct type

        // final fjfjf = response.body;
        // Map<String, dynamic> content =
        //     jsonResponse['choices'][0]['message']['content'];

        print('################');

        print(jsonResponse);

        print('################');

        print(jsonResponse['choices'][0]['message']['content']);
        String contentStr = jsonResponse['choices'][0]['message']['content'];

        Map<String, dynamic> contentJson = jsonDecode(contentStr);

        String name = contentJson['name'];
        String phone = contentJson['contactnumber'];
        String compname = contentJson['companyname'];
        String emailid = contentJson[
            'emailid']; // Adjust field name as per actual JSON structure

        print('Name: $name');
        kuchtokaro(name, phone, compname, emailid);

        print('################');

        // print(content);
        // Handle JSON response as needed
      } else {
        print('Failed to send data to OpenAI: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending data to OpenAI: $e');
    }
  }

  void kuchtokaro(name, phone, compname, emailid) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AddContactWidget(
        name: name,
        contactNumber: phone,
        company: compname,
        email: emailid,
      );
    }));
    // Navigator.pop(context);
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        await _recognizeText(pickedFile.path);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _recognizeText(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final textRecognizer = GoogleMlKit.vision.textRecognizer();
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);
    textRecognizer.close();

    final StringBuffer buffer = StringBuffer();
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        buffer.writeln(line.text);
      }
    }

    _showTextDialog(buffer.toString());
  }

  void _showTextDialog(String text) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SelectableText(text),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Future.delayed(Duration.zero, () {
                  Navigator.pop(context);
                });
                await sendToOpenAI(text);
              },
              child: const Text('Add Contact'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take or Pick a Picture')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                CameraPreview(_controller),
                Positioned(
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.all(20),
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        FloatingActionButton(
                          heroTag: 'cameraBtn',
                          onPressed: _takePicture,
                          tooltip: 'Take Picture',
                          child: Icon(Icons.camera),
                        ),
                        FloatingActionButton(
                          heroTag: 'galleryBtn',
                          onPressed: _pickImageFromGallery,
                          tooltip: 'Pick from Gallery',
                          child: Icon(Icons.photo_library),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
