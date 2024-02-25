import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:multiselect_dropdown_flutter/multiselect_dropdown_flutter.dart';

void main() {
  runApp(MaterialApp(
    home: TaskAddPage(),
    theme: ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
  ));
}

class TaskAddPage extends StatefulWidget {
  @override
  _TaskAddPageState createState() => _TaskAddPageState();
}

class _TaskAddPageState extends State<TaskAddPage> {
  TextEditingController _taskNameController = TextEditingController();
  String? _taskWithWhom;
  List<dynamic> _selectedContacts = [];
  List<String> _filteredProperties = [];
  List<String> _taskTypes = [];
  List<dynamic> _assignedTo = [];
  DateTime? _startDate;
  DateTime? _endDate;
  List<String> _priorityLevels = [];
  List<String> _taskStatus = [];
  TextEditingController _budgetAllocatedController = TextEditingController();
  TextEditingController _otherDependentTaskController = TextEditingController();
  DateTime? _reminderDate;
  List<String> _repeats = [];
  TextEditingController _taskDescriptionController = TextEditingController();
  List<Lead> filteredProperties = [];

  // Mock Data for Dropdowns

  List<Lead> leads = [
    // Add more properties as needed
  ];

  final List<Contact> contacts = [];
  List<Contact> filteredContacts = [];
  List<String> _filteredContacts1 = [];

  List<dynamic> _selectedLeads = [];

  final List<String> _taskWithWhomOptions = [
    'ASSOCIATE',
    'LEADS',
    'PROPERTY OWNER',
    'ADVOCATE',
    'MARKETING TEAM'
  ];

  final List<String> _taskTypeOptions = [
    'MEETING SCHEDULED',
    'EVENT',
    'APPROVALS',
    'VERIFICATION',
    'REPORT MANAGEMENT',
    'MARKETING',
    'DEAL MANAGEMENT',
    'FOLLOW UP',
    'INSPECTION',
    'OTHER OPPORTUNITIES',
    'TO-DO'
  ];

  final List<String> _priorityOptions = ['HIGH', 'MEDIUM', 'LOW'];
  final List<String> _statusOptions = [
    'NOT STARTED',
    'IN PROGRESS - STEP 1',
    'IN PROGRESS - STEP 2',
    'COMPLETED'
  ];
  final List<String> _repeatOptions = [
    'DAILY',
    'EVERY WEEKDAY',
    'EVERY MONTH',
    'OTHER'
  ];

  void initState() {
    super.initState();
    _fetchLeadsFromFirestore();
    _fetchContactsFromFirestore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Task'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(_taskNameController, 'Task Name'),
            _buildTitle('Select With Whom: Dynamic based on Task With Whom'),
            _buildMultiSelectDropdownSimpleList(
              list: _filteredProperties,
              initiallySelected: const [],
              onChange: (newList) {
                _selectedContacts = newList;
                // your logic
              },
              includeSearch: true,
              includeSelectAll: true,
            ),
            const SizedBox(height: 20),
            _buildTitle('Assigned To: Dynamic based on some criteria'),
            _buildMultiSelectDropdownSimpleList(
              list: _filteredContacts1,
              initiallySelected: const [],
              onChange: (newList) {
                _assignedTo = newList;
                // your logic
              },
              includeSearch: true,
              includeSelectAll: true,
            ),
            const SizedBox(height: 20),
            _buildMultiSelectBottomSheetField(
                _taskTypes, _taskTypeOptions, 'Task Types'),
            _buildDatePickerField(_startDate, 'Pick Start Date',
                (DateTime? newDate) {
              setState(() {
                _startDate = newDate;
              });
            }),
            _buildDatePickerField(_endDate, 'Pick End Date',
                (DateTime? newDate) {
              setState(() {
                _endDate = newDate;
              });
            }),
            _buildMultiSelectBottomSheetField(
                _priorityLevels, _priorityOptions, 'Priority Level'),
            _buildMultiSelectBottomSheetField(
                _taskStatus, _statusOptions, 'Status'),
            _buildTitle(
                'Location: Integration with Google Maps or similar service'),
            _buildTextField(_budgetAllocatedController, 'Budget Allocated',
                keyboardType: TextInputType.number),
            _buildTextField(
                _otherDependentTaskController, 'Other Dependent Task',
                maxLines: 3),
            _buildDatePickerField(_reminderDate, 'Pick Reminder Date',
                (DateTime? newDate) {
              setState(() {
                _reminderDate = newDate;
              });
            }),
            _buildMultiSelectBottomSheetField(
                _repeats, _repeatOptions, 'Repeats'),
            _buildTextField(_taskDescriptionController, 'Task Description',
                maxLines: 5),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  // primary: Theme.of(context).primaryColor, // Background color
                  // onPrimary: Colors.white, // Text Color (Foreground color)
                  ),
              onPressed: _submitForm,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Text('Submit Task', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String generateUniqueId() {
    // Generate a random 10-digit number
    Random random = Random();
    int uniqueId = random.nextInt(90000) + 100000;
    return uniqueId.toString();
  }

  Widget _buildMultiSelectDropdownSimpleList({
    required List<String> list,
    required List<dynamic> initiallySelected,
    required Function(List<dynamic>) onChange,
    bool includeSearch = false,
    bool includeSelectAll = false,
  }) {
    return MultiSelectDropdown.simpleList(
      list: list,
      initiallySelected: initiallySelected,
      onChange: onChange,
      includeSearch: includeSearch,
      includeSelectAll: includeSelectAll,
    );
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
        _filteredContacts1 = filteredContacts
            .map((e) =>
                '${e.name.toString()} || ${e.category} || ${e.company.toString()}|| ${e.phoneNumber.toString()}')
            .toList();
      });
    } catch (error) {
      print('Error fetching contacts: $error');
    }
  }

  void _fetchLeadsFromFirestore() async {
    try {
      var user_id = FirebaseAuth.instance.currentUser!.uid;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user_id)
          .collection('leads')
          .get();

      setState(() {
        leads.clear();
        leads.addAll(snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Lead(
            propertyType: data['propertyType'] ?? '',
            landmarks: data['landmarks'] ?? '',
            transcription: data['transcription'] ?? '',
            buyerphone: data['buyerphone'] ?? '',
            buyerName: data['buyerName'] ?? '',
            agentNumber: data['agentNumber'] ?? '',
            agentName: data['agentName'] ?? '',
            totalFloors: data['totalFloors'] ?? '',
            bedrooms: data['bedrooms'] ?? '',
            furnishing: data['furnishing'] ?? '',
            maintenanceRating: data['maintenanceRating'] ?? '',
            leadStatus: data['leadStatus'] ?? '',
            facing: data['facing'] ?? '',
            wantedToSell: data['wantedToSell'] ?? '',
            urgencyOfPurchase: data['urgencyOfPurchase'] ?? '',
            sourceOfLead: data['sourceOfLead'] ?? '',
            presentAddress: data['presentAddress'] ?? '',
            occupation: data['occupation'] ?? '',
            comments: data['comments'] ?? '',
            specialid: data['specialid'] ?? '',
          );
        }));
        filteredProperties = leads;
        _filteredProperties = filteredProperties
            .map((e) =>
                '${e.buyerName.toString()} || ${e.occupation} || ${e.propertyType.toString()} || ${e.specialid.toString()}')
            .toList();
      });
    } catch (error) {
      print('Error fetching contacts: $error');
    }
  }

  void _submitForm() async {
    String userUid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference tasksCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userUid)
        .collection('tasks');

    String uniqueId;
    var existingDoc;

    do {
      uniqueId = generateUniqueId();
      // Check if the generated ID already exists in the collection
      existingDoc = await tasksCollection.doc(uniqueId).get();
    } while (existingDoc.exists);

    try {
      await tasksCollection.doc(uniqueId).set({
        'taskId': uniqueId,
        'taskName': _taskNameController.text,
        'taskTypes': _taskTypes,
        'startDate': _startDate,
        'endDate': _endDate,
        'priorityLevels': _priorityLevels,
        'taskStatus': _taskStatus,
        'budgetAllocated': _budgetAllocatedController.text,
        'otherDependentTask': _otherDependentTaskController.text,
        'reminderDate': _reminderDate,
        'repeats': _repeats,
        'taskDescription': _taskDescriptionController.text,
        'assignedTo': _assignedTo,
        'taskWithWhom': _selectedContacts,

        // Add other fields as needed...
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

  void _showErrorSnackbar(String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $errorMessage'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task added successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
      ),
    );
  }

  Widget _buildDropdownButtonFormField(String? value, List<String> options,
      String label, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        items: options.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDatePickerField(DateTime? selectedDate, String label,
      ValueChanged<DateTime?> onDateSelected) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: ListTile(
        title: Text(selectedDate == null
            ? label
            : DateFormat('yyyy-MM-dd').format(selectedDate)),
        trailing: Icon(Icons.calendar_today),
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: selectedDate ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2025),
          );
          if (picked != null && picked != selectedDate) onDateSelected(picked);
        },
      ),
    );
  }

  Widget _buildMultiSelectBottomSheetField(
      List<String> initialValue, List<String> options, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: MultiSelectBottomSheetField<String?>(
        initialValue: initialValue,
        items: options.map((e) => MultiSelectItem(e, e)).toList(),
        title: Text(title),
        selectedColor: Theme.of(context).primaryColor,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        buttonText: Text(title),
        onConfirm: (values) {
          setState(() {
            initialValue = values.cast<String>();
            if (title == 'Task Types') {
              _taskTypes = initialValue;
            } else if (title == 'Status') {
              _taskStatus = initialValue;
            } else if (title == 'Repeats') {
              _repeats = initialValue;
            } else if (title == 'Priority Level') {
              _priorityLevels = initialValue;
            }
          });
        },
      ),
    );
  }
}

class Lead {
  final String? propertyType;
  final List<dynamic>? landmarks;
  final String? transcription;
  final String? buyerphone;
  final String? buyerName;
  final String? agentNumber;
  final String? agentName;
  final String? totalFloors;
  final String? bedrooms;
  final String? furnishing;
  final String? maintenanceRating;
  final String? leadStatus;
  final String? facing;
  final String? wantedToSell;
  final String? urgencyOfPurchase;
  final String? sourceOfLead;
  final String? presentAddress;
  final String? occupation;
  final String? comments;
  final String? specialid;

  Lead({
    this.propertyType,
    this.landmarks,
    this.transcription,
    this.buyerphone,
    this.buyerName,
    this.agentNumber,
    this.agentName,
    this.totalFloors,
    this.bedrooms,
    this.furnishing,
    this.maintenanceRating,
    this.leadStatus,
    this.facing,
    this.wantedToSell,
    this.urgencyOfPurchase,
    this.sourceOfLead,
    this.presentAddress,
    this.occupation,
    this.comments,
    this.specialid,
  });
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
