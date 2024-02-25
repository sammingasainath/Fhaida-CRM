import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(MaterialApp(home: AddContactWidget()));
}

class AddContactWidget extends StatefulWidget {
  final String? name;
  final String? contactNumber;
  final String? email;
  final String? company;

  const AddContactWidget(
      {Key? key, this.name, this.contactNumber, this.email, this.company})
      : super(key: key);

  @override
  _AddContactWidgetState createState() => _AddContactWidgetState();
}

class _AddContactWidgetState extends State<AddContactWidget> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

  late final TextEditingController _nameController;
  late final TextEditingController _contactNumberController;
  late final TextEditingController _emailController;
  late final TextEditingController _companyController;
  final TextEditingController _notesController = TextEditingController();
  String? _category;
  String? _sourceOfContact;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _contactNumberController =
        TextEditingController(text: widget.contactNumber);
    _emailController = TextEditingController(text: widget.email);
    _companyController = TextEditingController(text: widget.company);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactNumberController.dispose();
    _emailController.dispose();
    _companyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    String userUid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference contactsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userUid)
        .collection('contacts');

    // FirebaseFirestore.instance
    //     .collection('users')
    //     .get()
    //     .then((value) => print(value.docChanges.first.doc.id));
    // print(productsCollection.toString());

    try {
      await contactsCollection.doc(_contactNumberController.text).set({
        'name': _nameController.text,
        'phonenum': _contactNumberController.text,
        'email': _emailController.text,
        'company': _companyController.text,
        'category': _category,
        'source': _sourceOfContact,
        'notes': _notesController.text,
      });

      // Hide loading indicator
      Navigator.pop(context); // Pop the loading indicator dialog

      // Show success Snackbar
      _showSuccessSnackbar();

      // Navigate back after a short delay (you can adjust the duration)
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context); // Navigate back
      });
    } catch (e) {
      _showErrorSnackbar(e.toString());
      return;
    }
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      maxLines: maxLines,
    );
  }

  Widget _buildDropdownField(
      String label, List<String> options, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      onChanged: onChanged,
      items: options.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }

  void _showLoadingIndicator() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text("Saving details..."),
            ],
          ),
        );
      },
    );
  }

  void _showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Contact details saved successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackbar(String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error saving contact details: $errorMessage'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _imageSelectionArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: () async {
              final XFile? pickedFile =
                  await _picker.pickImage(source: ImageSource.camera);
              setState(() {
                _imageFile = pickedFile;
              });
            },
          ),
          Expanded(
            child: _imageFile != null
                ? Image.file(File(_imageFile!.path))
                : Container(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: const Text('Add Contact')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _imageSelectionArea(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTextField(_nameController, 'Name'),
                  SizedBox(height: 12),
                  _buildTextField(_contactNumberController, 'Contact Number'),
                  SizedBox(height: 12),
                  _buildTextField(_emailController, 'Email ID'),
                  SizedBox(height: 12),
                  _buildTextField(_companyController, 'Company'),
                  SizedBox(height: 12),
                  _buildDropdownField(
                    'Category',
                    [
                      'Associate',
                      'Lead',
                      'Property Owner',
                      'Advocate',
                      'Marketing Team',
                      'Other'
                    ],
                    (newValue) => setState(() => _category = newValue),
                  ),
                  SizedBox(height: 12),
                  _buildDropdownField(
                    'Source of Contact',
                    [
                      'Phone',
                      'Business Card',
                      'WhatsApp',
                      'Social Media',
                      'Others'
                    ],
                    (newValue) => setState(() => _sourceOfContact = newValue),
                  ),
                  SizedBox(height: 12),
                  _buildTextField(_notesController, 'Any Notes', maxLines: 5),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: Text('Create'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
