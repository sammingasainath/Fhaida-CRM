// import 'dart:html';

import 'package:crmapp/add_contact.dart';
import 'package:crmapp/add_lead.dart';
import 'package:crmapp/api/apikey.dart';
import 'package:crmapp/edit_lead.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:fuzzywuzzy/model/extracted_result.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(MaterialApp(
    theme: ThemeData.dark(),
    home: TakePictureScreen(camera: firstCamera),
  ));
}

class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({Key? key, required this.camera}) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
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

  Future<void> sendToOpenAI(String extractedText, BuildContext context) async {
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
                  "You are a helpful assistant who extracts the data from a Property Document from the given message and return only the JSON Object and nothing else , like : {location: ,propertyType:, buyerName:,numberofBedrooms:,furnishing:,facing:, occupationOfBuyer:,} few more instructions 1.the propertytype Must be one out of These only ['2 BHK NEW FLAT', '3 BHK NEW FLAT', '2 BHK RESALE FLAT', '3 BHK RESALE FLAT', 'NEW INDIVIDUAL HOUSE', 'CUSTOMIZABLE INDIVIDUAL HOUSE', 'COMMERCIAL LAND', 'PLOTS', 'COMMERCIAL BUILDING', 'RESALE INDIVIDUAL HOUSE']2. the age of the property must be a integer only 3. the furnishing must Be Out of the three ['Fully Furnished', 'Semi Furnished', 'Unfurnished'] 4. the facing of the property must be out of the four [North, South, East, West] 6. the number of bedrooms must be a integer only.7.The Landmark Must be one word it is actually the place where the buyer wants to buy the property.. designed to output JSON ",
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

        String name = contentJson['buyerName'];
        String landmark = contentJson['location'];
        String ptype = contentJson['propertyType'];
        String numbed = contentJson['numberofBedrooms'].toString();

        String furn = contentJson['furnishing'];
        String occupation = contentJson['occupationOfBuyer'];
        String facing = contentJson['facing'];

        // Adjust field name as per actual JSON structure

        print('Name: $name');
        kuchtokaro(name, ptype, numbed, furn, occupation, facing,
            landmark.toString(), context, extractedText);

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

  void kuchtokaro(name, ptype, numbed, furn, occupation, facing, location,
      context1, extractedText) {
    print('Name: $name  , function is running ');

    var location1 = extractOne(
      query: location,
      choices: [
        'Dwaraka Nagar',
        'Daba Gardens',
        'Asilmetta',
        'Siripuram',
        'Pithapuram Colony',
        'CBM Compound',
        'Maddilapalem',
        'Narasimha Nagar',
        'Balayya Sastri Layout',
        'Kailasapuram',
        'Seethammadhara',
        'Resapuvanipalem',
        'HB Colony',
        'Ramnagar',
        'Santhipuram',
        'Suryabagh',
        'Railway New Colony',
        'Venkojipalem',
        'Seethammapeta',
        'Waltair Uplands',
        'Dondaparthy',
        'Gnanapuram',
        'Akkayyapalem',
        'Shivaji Palem',
        'Thatichetlapalem',
        'Kancharapalem',
        'Isukathota',
        'Kommadi',
        'Rushikonda',
        'Sagar Nagar',
        'Yendada',
        'Madhurawada',
        'PM Palem',
        'Thimmapuram',
        'Jodugullapalem',
        'Kapuluppada',
        'Gambhiram',
        'Anandapuram',
        'Mangamaripeta',
        'Gajuwaka',
        'Pedagantyada',
        'Kurmannapalem',
        'Akkireddypalem',
        'Nathayyapalem',
        'Yarada',
        'Aganampudi',
        'Chinagantyada',
        'Nadupuru',
        'Duvvada',
        'Desapatrunipalem',
        'Sheela Nagar',
        'Sriharipuram',
        'Tunglam',
        'Mulagada',
        'Vadlapudi',
        'Ukkunagaram (Steel Plant Township)',
        'Gandhigram',
        'Gangavaram',
        'BHPV',
        'Mindi',
        'Scindia',
        'Malkapuram',
        'Gopalapatnam',
        'Naidu Thota',
        'Vepagunta',
        'Marripalem',
        'Simhachalam',
        'Prahaladapuram',
        'Pendurthi',
        'Chintalagraharam',
        'NAD',
        'Madhavadhara',
        'Sujatha Nagar',
        'Adavivaram',
        'Muralinagar',
        'Chinnamushidiwada',
        'Kakani Nagar',
        'Narava',
        'Pineapple Colony',
        'Jagadamba Centre',
        'Soldierpet',
        'MVP Colony',
        'Velampeta',
        'Chinna Waltair',
        'Kirlampudi Layout',
        'Pandurangapuram',
        'Daspalla Hills',
        'Town Kotha Road',
        'Peda Waltair',
        'Lawsons Bay Colony',
        'Prakashraopeta',
        'Burujupeta',
        'Jalari Peta',
        'One Town',
        'Poorna Market',
        'Allipuram',
        'Salipeta',
        'Relli Veedhi',
        'Maharanipeta',
        'Chengal Rao Peta',
        'Padmanabham',
        'Gidijala Gudilova Tagarapuvalasa',
        'Bheemunipatnam',
        'Nidigattu',
        'Vellanki',
        'Sontya',
        'Pudimadaka',
        'Dosuru',
        'Anakapalle',
        'Pedamadaka',
        'Duppituru',
        'Ravada',
        'Devada',
        'Lankelapalem',
        'Parawada',
        'Appikonda Atchutapuram',
        'Sabbavaram',
        'Devipuram',
        'Kothavalasa'
      ],
      cutoff: 50,
    );

    var location2 = extractText(location1.toString());
    var location3 = location2;

    print(location1);
    print(location2);
    Navigator.push(context1, MaterialPageRoute(builder: (context1) {
      return LeadAddPage(
        name: name.toString() ?? 'No Name',
        propertyType: ptype?.toString() ?? '2 BHK RESALE FLAT',
        bedrooms: numbed?.toString() ?? '2',
        furnishing: furn?.toString() ?? 'Unfurnished',
        company: occupation?.toString() ?? 'No Occupation',
        facing: facing?.toString() ?? 'North',
        landmarks: [location3],
        transcription: extractedText ?? 'Transcription not available',
      );
    }));
    // Navigator.pop(context);
  }

  String extractText(String input) {
    RegExp regExp = RegExp(r'string (\w+),');
    RegExpMatch? match = regExp.firstMatch(input);

    if (match != null && match.groupCount >= 1) {
      return match.group(1)!;
    } else {
      return ''; // Return an empty string if no match is found
    }
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

    // _showTextDialog(buffer.toString());
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
