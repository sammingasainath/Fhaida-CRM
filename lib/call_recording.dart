import 'dart:io';
import 'package:crmapp/add_lead.dart';
import 'package:flutter/material.dart';
import 'package:crmapp/api/apikey.dart'; // Ensure this import points to your actual API key storage
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:crmapp/add_contact_extractedText.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: UploadAudioPage(),
    );
  }
}

class UploadAudioPage extends StatefulWidget {
  @override
  _UploadAudioPageState createState() => _UploadAudioPageState();
}

class _UploadAudioPageState extends State<UploadAudioPage> {
  String _transcription = '';
  bool _isLoading = false;

  Future<void> _pickAndUploadAudio() async {
    try {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(type: FileType.audio);

      if (result != null) {
        File audioFile = File(result.files.single.path!);
        print("Picked audio file: ${audioFile.path}");
        setState(() => _isLoading = true);
        _transcription = await _uploadAudioAndGetTranscription(audioFile);
        setState(() => _isLoading = false);
      } else {
        print("Audio file picking was canceled by the user.");
      }
    } catch (e) {
      print("An error occurred while picking the file: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<String> _uploadAudioAndGetTranscription(File audioFile) async {
    try {
      var requestUri =
          Uri.parse("https://api.openai.com/v1/audio/transcriptions");
      var request = http.MultipartRequest("POST", requestUri)
        ..headers['Authorization'] = 'Bearer $api_key'
        ..headers['Content-Type'] = 'multipart/form-data'
        ..files.add(await http.MultipartFile.fromPath('file', audioFile.path))
        ..fields['model'] = 'whisper-1';

      print("Sending audio file to Whisper API for transcription.");
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        print("Response data: $responseData");
        var decodedResponse = jsonDecode(responseData);
        // IMPORTANT: Adjust the parsing below according to the actual response structure
        var transcription =
            decodedResponse['text']; // Placeholder - adjust this!
        print("Transcription: $transcription");
        await TakePictureScreenState().sendToOpenAI(transcription, context);
        return transcription;
      } else {
        print(
            "Failed to get transcription with status code: ${response.statusCode}");
        return "Failed to get transcription: ${response.statusCode}";
      }
    } catch (e) {
      print("An error occurred during transcription: $e");
      return "Failed to get transcription: Error";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Audio for Transcription'),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: _pickAndUploadAudio,
                    child: Text('Pick and Upload Audio'),
                  ),
                  SizedBox(height: 20),
                  Text(_transcription),
                  SizedBox(height: 20),
                ],
              ),
      ),
    );
  }
}
