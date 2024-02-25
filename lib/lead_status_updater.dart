import 'package:crmapp/add_contact_extractedText.dart';
import 'package:crmapp/add_contact_fromBizCard.dart';
import 'package:flutter/material.dart';
import 'package:circular_menu/circular_menu.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'add_contact.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contact Search',
      home: LeadStatusPage(),
    );
  }
}

class Contact {
  final String propertyType;
  List<dynamic> landmarks;
  final String ownerName;
  final String specialid;
  final String constructionStatus;
  final String exactAddress;

  bool isSelected;

  Contact(this.propertyType, this.landmarks, this.ownerName, this.specialid,
      this.constructionStatus, this.exactAddress,
      {this.isSelected = false});
}

class LeadStatusPage extends StatefulWidget {
  @override
  _LeadStatusPageState createState() => _LeadStatusPageState();

  const LeadStatusPage({Key? key, this.leadID});
  final String? leadID;
}

class _LeadStatusPageState extends State<LeadStatusPage> {
  final List<Contact> contacts = [];

  List<Contact> filteredContacts = [];

  List<Contact> selectedContacts = [];

  List<String> _selectedCategories = [];
  String? selectedLeadStatus;
  String? selectedLeadStatus1;

  @override
  void initState() {
    super.initState();
    _fetchContactsFromFirestore();
    print(widget.leadID);
  }

  void _filterContacts(String query) {
    setState(() {
      if (query.isNotEmpty) {
        filteredContacts = contacts
            .where((contact) =>
                contact.propertyType
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                contact.landmarks
                    .join(',')
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                contact.ownerName.toLowerCase().contains(query.toLowerCase()) ||
                contact.specialid.toLowerCase().contains(query.toLowerCase()))
            .toList();
      } else {
        filteredContacts = contacts;
      }
    });
  }

  void _toggleContactSelection(Contact contact) {
    setState(() {
      contact.isSelected = !contact.isSelected;

      if (contact.isSelected) {
        selectedContacts.add(contact);
      } else {
        selectedContacts.remove(contact);
      }

      print(
          'Properties Selected: ${selectedContacts.map((c) => c.specialid).toList()}');

      print(
          'Properties Selected: ${selectedContacts.map((c) => c.specialid).toList()}');
    });
  }

  void _fetchContactsFromFirestore() async {
    try {
      var user_id = FirebaseAuth.instance.currentUser!.uid;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user_id)
          .collection('properties')
          .get();

      setState(() {
        contacts.clear();
        contacts.addAll(snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Contact(
            data['propertyType'] ?? '',
            data['landmarks'] ?? '',
            data['ownerName'] ?? '',
            data['specialid'] ?? '',
            data['constructionStatus'] ?? '',
            data['exactAddress'] ?? '',
          );
        }));
        filteredContacts = contacts;
      });
    } catch (error) {
      print('Error fetching contacts: $error');
    }
  }

  void _showContactDetails(Contact contact) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(contact.propertyType),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Landmark: ${contact.landmarks.join(',')}'),
              Text('Owner Name: ${contact.ownerName.toString()}'),
              Text('SpecialId: ${contact.specialid.toString()}'),
              Text(
                  'Construction Status: ${contact.constructionStatus.toString()}'),
              Text('Exact Address: ${contact.exactAddress.toString()}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'),
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
        title: Text('Lead Status Updater'),
      ),
      body: Column(
        children: [
          SizedBox(
            width: 20,
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              value: selectedLeadStatus1,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedLeadStatus1 = newValue;
                    selectedLeadStatus =
                        selectedLeadStatus1!.replaceAll(' ', '');

                    // Assuming you want to apply filters based on the selected lead status
                  });
                  print(selectedLeadStatus);
                }
              },
              items: [
                'LEAD RECEIVED',
                'PROPERTIES SENT',
                'SITE VISIT SCHEDULED',
                'SITE VISIT DONE',
                'TOKEN AMOUNT SCHEDULED',
                '1ST - REGISTRATION DONE',
                'LOAN IN PROCESS',
                'REGISTRATION SCHEDULED',
                'REGISTRATION DONE',
                'COMMISION RECEIVED',
                'DEAL CLOSED'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Lead Status', // Customize the label as needed
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                TextField(
                  onChanged: _filterContacts,
                  decoration: InputDecoration(
                    labelText: 'Search Properties',
                    border: OutlineInputBorder(),
                  ),
                ),
                TextButton(
                  onPressed: _submitForm,
                  child: Text('Update'),
                  style: ButtonStyle(),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredContacts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(filteredContacts[index].propertyType),
                  subtitle: Text(filteredContacts[index].landmarks[0]),
                  onTap: () => _showContactDetails(filteredContacts[index]),
                  trailing: Checkbox(
                    value: filteredContacts[index].isSelected,
                    onChanged: (_) =>
                        _toggleContactSelection(filteredContacts[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _submitForm() async {
    String userUid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference contactsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userUid)
        .collection('leads');
    CollectionReference propertiesCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userUid)
        .collection('properties');

    try {
      // Convert the selectedContacts list into a list of specialids
      List<String> selectedSpecialIds =
          selectedContacts.map((contact) => contact.specialid).toList();

      // Iterate over each selectedSpecialId
      for (String specialId in selectedSpecialIds) {
        // Fetch the document from the 'properties' collection using the specialId
        DocumentSnapshot propertySnapshot =
            await propertiesCollection.doc(specialId).get();

        if (propertySnapshot.exists) {
          // Perform any action you want with the property data
          Map<String, dynamic> propertyData =
              propertySnapshot.data() as Map<String, dynamic>;

          List<String> existingList1 =
              List<String>.from(propertyData[selectedLeadStatus] ?? []);
          List<String> updatedList1 = [
            ...existingList1,
            widget.leadID.toString()
          ];

          await propertiesCollection.doc(specialId).update({
            selectedLeadStatus!: updatedList1,
          });

          // Example: Print the property data
          print('Property Data for $specialId: $propertyData');
        } else {
          print('Property with specialId $specialId does not exist.');
        }
      }

      // Fetch the current data from Firestore
      DocumentSnapshot documentSnapshot =
          await contactsCollection.doc(widget.leadID).get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> currentData =
            documentSnapshot.data() as Map<String, dynamic>;

        // Fetch the existing array (e.g., leadStatus) or create an empty list if it doesn't exist
        List<String> existingList =
            List<String>.from(currentData[selectedLeadStatus] ?? []);

        // Combine existing values with new values
        List<String> updatedList = [...existingList, ...selectedSpecialIds];

        // Update the document in Firestore
        await contactsCollection.doc(widget.leadID).update({
          selectedLeadStatus!: updatedList,
        });

        // Hide loading indicator
        Navigator.pop(context);

        // Show success Snackbar
        _showSuccessSnackbar();

        // Navigate back after a short delay (you can adjust the duration)
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      } else {
        print('Document does not exist.');
      }
    } catch (e) {
      _showErrorSnackbar(e.toString());
      return;
    }
  }

  void _showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lead Updated successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackbar(String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $errorMessage'),
        backgroundColor: Colors.red,
      ),
    );
  }

  List<ValueItem> _getCategoryOptions() {
    return contacts
        .map((contact) =>
            ValueItem(label: contact.specialid, value: contact.propertyType))
        .toSet() // Removes duplicates
        .toList();
  }
}
