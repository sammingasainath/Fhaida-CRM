import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social Media Management',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SocialMediaManagementPage(),
    );
  }
}

class SocialMediaManagementPage extends StatefulWidget {
  @override
  _SocialMediaManagementPageState createState() =>
      _SocialMediaManagementPageState();
}

class _SocialMediaManagementPageState extends State<SocialMediaManagementPage> {
  List<Map<String, dynamic>> socialMediaData = [
    {'platform': 'Twitter', 'posts': 50, 'reach': 10000},
    {'platform': 'Facebook', 'posts': 80, 'reach': 15000},
    {'platform': 'Instagram', 'posts': 30, 'reach': 8000},
  ];

  TextEditingController _postController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Social Media Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Connected Social Media Accounts:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: socialMediaData.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Icon(
                          getPlatformIcon(socialMediaData[index]['platform'])),
                      title: Text(socialMediaData[index]['platform']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Posts: ${socialMediaData[index]['posts']}'),
                          Text('Reach: ${socialMediaData[index]['reach']}'),
                        ],
                      ),
                      // Add more details or actions for each account if needed
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Add logic to navigate to the post scheduling page
                // You can use Navigator.push to navigate to another page
                // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => PostSchedulingPage()));
                print('Schedule Posts');
              },
              icon: Icon(Icons.schedule),
              label: Text('Schedule Posts'),
              style: ElevatedButton.styleFrom(
                // primary: Colors.indigo,
                // onPrimary: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Add logic for posting on all social media
                print('Post on All Social Media');
              },
              icon: Icon(Icons.send),
              label: Text('Post on All Social Media'),
              style: ElevatedButton.styleFrom(
                // primary: Colors.pink,
                // onPrimary: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Add logic for opening WhatsApp Business
                openWhatsApp();
              },
              icon: Icon(FontAwesomeIcons.whatsapp),
              label: Text('WhatsApp Business'),
              style: ElevatedButton.styleFrom(
                // primary: Colors.green,
                // onPrimary: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _postController,
              decoration: InputDecoration(
                labelText: 'Write your post...',
                suffixIcon: Icon(Icons.attach_file),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'twitter':
        return FontAwesomeIcons.twitter;
      case 'facebook':
        return Icons.facebook;
      case 'instagram':
        return FontAwesomeIcons.instagram;
      default:
        return Icons.web;
    }
  }

  // Function to open WhatsApp Business
  void openWhatsApp() async {
    // The phone number should be in the format: 'whatsapp://send?phone=+123456789'
    String phoneNumber =
        '+123456789'; // Replace with the desired WhatsApp number

    if (await canLaunch('whatsapp://send?phone=$phoneNumber')) {
      await launch('whatsapp://send?phone=$phoneNumber');
    } else {
      // WhatsApp Business is not installed
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('WhatsApp Business Not Installed'),
            content:
                Text('Please install WhatsApp Business to use this feature.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
