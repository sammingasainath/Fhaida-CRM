import 'package:crmapp/add_contact_extractedText.dart';
import 'package:crmapp/add_contact_fromBizCard.dart';
import 'package:flutter/material.dart';
import 'package:circular_menu/circular_menu.dart';
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
      home: ContactSearchPage(),
    );
  }
}

class Contact {
  final String name;
  final String phoneNumber;
  final String category;
  final String company;
  final String email;
  final String notes;

  bool isSelected;

  Contact(this.name, this.phoneNumber, this.category, this.company, this.email,
      this.notes,
      {this.isSelected = false});
}

class ContactSearchPage extends StatefulWidget {
  @override
  _ContactSearchPageState createState() => _ContactSearchPageState();
}

class _ContactSearchPageState extends State<ContactSearchPage> {
  final List<Contact> contacts = [];

  List<Contact> filteredContacts = [];

  List<Contact> selectedContacts = [];

  List<String> _selectedCategories = [];

  @override
  void initState() {
    super.initState();
    _fetchContactsFromFirestore();
  }

  void _filterContacts(String query) {
    setState(() {
      if (query.isNotEmpty) {
        filteredContacts = contacts
            .where((contact) =>
                contact.name.toLowerCase().contains(query.toLowerCase()) ||
                contact.phoneNumber.contains(query) ||
                contact.company.toLowerCase().contains(query.toLowerCase()) ||
                contact.notes.toLowerCase().contains(query.toLowerCase()))
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
          'Selected Contacts: ${selectedContacts.map((c) => c.name).toList()}');
    });
  }

  void _fetchContactsFromFirestore() async {
    try {
      var user_id = FirebaseAuth.instance.currentUser!.uid;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user_id)
          .collection('contacts')
          .get();

      setState(() {
        contacts.clear();
        contacts.addAll(snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Contact(
            data['name'] ?? '',
            data['phonenum'] ?? '',
            data['category'] ?? '',
            data['company'] ?? '',
            data['email'] ?? '',
            data['notes'] ?? '',
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
          title: Text(contact.name),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Phone Number: ${contact.phoneNumber.toString()}'),
              Text('Category: ${contact.category.toString()}'),
              Text('Company: ${contact.company.toString()}'),
              Text('Email: ${contact.email.toString()}'),
              Text('Notes: ${contact.notes.toString()}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
            TextButton(
              onPressed: () async {
                final Uri launchUri =
                    Uri(scheme: 'tel', path: contact.phoneNumber.toString());
                if (await canLaunchUrl(launchUri)) {
                  await launchUrl(launchUri);
                } else {
                  throw 'Could not launch $launchUri';
                }
              },
              child: Text('Call Customer'),
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
        title: Text('Contact Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                MultiSelectDropDown(
                  options: _getCategoryOptions(),
                  onOptionSelected: (selectedItems) {
                    setState(() {
                      _selectedCategories = selectedItems
                          .map((item) => item.value)
                          .cast<String>()
                          .toList();
                      _applyFilters();
                    });
                  },
                  hint: 'Select Categories',
                ),
                const SizedBox(height: 10),
                TextField(
                  onChanged: _filterContacts,
                  decoration: InputDecoration(
                    labelText: 'Search Contacts',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredContacts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(filteredContacts[index].name),
                  subtitle: Text(filteredContacts[index].phoneNumber),
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
      floatingActionButton: CircularMenu(
        alignment: Alignment.bottomRight,
        toggleButtonColor: Color.fromARGB(255, 141, 195, 243),
        toggleButtonSize: 36,
        items: [
          CircularMenuItem(
            icon: Icons.add,
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AddContactWidget()));
            },
          ),
          CircularMenuItem(
            icon: Icons.camera_alt,
            onTap: () async {
              final cameras = await availableCameras();
              final firstCamera = cameras.first;
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TakePictureScreen2(
                            camera: firstCamera,
                          )));
            },
          ),
        ],
      ),
    );
  }

  List<ValueItem> _getCategoryOptions() {
    return contacts
        .map((contact) =>
            ValueItem(label: contact.category, value: contact.category))
        .toSet() // Removes duplicates
        .toList();
  }

  void _applyFilters() {
    setState(() {
      filteredContacts = contacts.where((contact) {
        bool categoryFilter = _selectedCategories.isEmpty ||
            _selectedCategories.contains(contact.category);
        return categoryFilter;
      }).toList();
    });
  }
}
