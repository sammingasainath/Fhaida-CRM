import 'package:crmapp/add_property_fromDoc.dart';
import 'package:crmapp/task_add.dart';
import 'package:flutter/material.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:circular_menu/circular_menu.dart';
import 'add_contact.dart';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TaskManagementPage(),
    );
  }
}

class TaskManagementPage extends StatefulWidget {
  @override
  _TaskManagementPageState createState() => _TaskManagementPageState();
}

class _TaskManagementPageState extends State<TaskManagementPage> {
  void initState() {
    super.initState();
    _applyFilters(); // Call this to initialize the filteredTasks list
  }

  List<Task> tasks = [
    // Add more tasks as needed
  ];

  List<String> filteredTasks1 = [];

  final List<ValueItem> myOptions = [
    ValueItem(label: 'Meeting', value: 'Meeting'),
    ValueItem(label: 'Call', value: 'Call'),
    ValueItem(label: 'Follow-up', value: 'Follow-up'),
    // Add more task types as needed
  ];

  final List<ValueItem> priorityOptions = [
    ValueItem(label: 'High', value: 'High'),
    ValueItem(label: 'Medium', value: 'Medium'),
    ValueItem(label: 'Low', value: 'Low'),
  ];

  List<Task> filteredTasks = [];
  List<String> _selectedTaskTypes = [];
  List<String> _selectedPriorities = [];

  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: CircularMenu(
        alignment: Alignment.bottomRight,
        toggleButtonColor: Color.fromARGB(255, 141, 195, 243),
        toggleButtonSize: 36,
        items: [
          CircularMenuItem(
            icon: Icons.add,
            onTap: () {
              // Implement the action for the first button
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => TaskAddPage()));
              print('First button pressed');
            },
          ),
          CircularMenuItem(
            icon: Icons.camera_alt,
            onTap: () async {
              final cameras = await availableCameras();
              // Get a specific camera from the list of available cameras.
              final firstCamera = cameras.first;
              // Implement the action for the second button
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TakePictureScreen1(
                            camera: firstCamera,
                          )));
              print('Second button pressed');
            },
          ),
        ],
      ),
      appBar: AppBar(
        title: Text('Task Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFilterForm(),
            const SizedBox(height: 20),
            _buildTaskList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterForm() {
    return Column(
      children: [
        MultiSelectDropDown(
          options: myOptions,
          onOptionSelected: (selectedItems) {
            setState(() {
              _selectedTaskTypes = selectedItems
                  .map((item) => item.value)
                  .cast<String>()
                  .toList();
              _applyFilters();
            });
          },
          hint: 'Select Task Types',
        ),
        const SizedBox(height: 10),
        MultiSelectDropDown(
          options: priorityOptions,
          onOptionSelected: (selectedItems) {
            setState(() {
              _selectedPriorities = selectedItems
                  .map((item) => item.value)
                  .cast<String>()
                  .toList();
              _applyFilters();
            });
          },
          hint: 'Select Priorities',
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _searchController,
          onChanged: _searchTasks,
          decoration: InputDecoration(
            labelText: 'Search by Task Title',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskList() {
    return Expanded(
      child: ListView.builder(
        itemCount: filteredTasks.length,
        itemBuilder: (context, index) {
          Task task = filteredTasks[index];
          int timeDifference = task.endDate.difference(DateTime.now()).inDays;
          return ListTile(
            title: Text(task.taskName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Type: ${task.taskTypes.join(', ')}'),
                Text('Priority: ${task.priorityLevels.join(', ')}'),
                if (timeDifference == 1) Text('${timeDifference} day left'),
                if (timeDifference != 1)
                  Text('${timeDifference.abs()} days left'),
              ],
            ),
            onTap: () {
              _viewTaskDetails(task);
            },
          );
        },
      ),
    );
  }

  void _applyFilters() {
    setState(() {
      filteredTasks = tasks.where((task) {
        bool typeFilter = _selectedTaskTypes.isEmpty ||
            _selectedTaskTypes.contains(task.taskTypes);
        bool priorityFilter = _selectedPriorities.isEmpty ||
            _selectedPriorities.contains(task.priorityLevels);

        return typeFilter && priorityFilter;
      }).toList();
    });
  }

  void _searchTasks(String query) {
    setState(() {
      filteredTasks = tasks
          .where((task) =>
              task.taskName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _fetchtasksFromFirestore() async {
    try {
      var user_id = FirebaseAuth.instance.currentUser!.uid;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user_id)
          .collection('contacts')
          .get();

      setState(() {
        tasks.clear();
        tasks.addAll(snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Task(
            taskId: data['taskId'],
            // contactId: data['contactId'],
            taskName: data['taskName'],
            // taskDetails: data['taskDetails'],
            taskStatus: data['taskStatus'],
            taskTypes: data['taskTypes'],
            priorityLevels: data['priorityLevels'],
            assignedTo: data['assignedTo'],
            taskWithWhom: data['taskWithWhom'],
            budgetAllocated: data['budgetAllocated'],
            startDate: data['startDate'].toDate(),
            endDate: data['endDate'].toDate(),
            reminderDate: data['reminderDate'].toDate(),
            repeats: data['repeats'],
            otherDependentTask: data['otherDependentTask'],
            taskDescription: data['taskDescription'],
          );
        }));
        filteredTasks = tasks;
        // filteredTasks1 = filteredTasks
        //     .map((e) =>
        //         '${e..toString()} || ${e.category} || ${e.company.toString()}|| ${e.phoneNumber.toString()}')
        //     .toList();
      });
    } catch (error) {
      print('Error fetching contacts: $error');
    }
  }

  void _viewTaskDetails(Task task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(task.taskName),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Type: ${task.taskTypes.join(', ')}'),
              Text('Priority: ${task.priorityLevels.join(', ')}'),
              SizedBox(height: 10),
              Text('Due Date: ${task.endDate.toLocal()}'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

// assignedTo
// (array)

// 0
// "S. Srinivas Rao || Lead || AASTEE.COM|| +91 9970018181"
// (string)

// budgetAllocated
// "20000"
// (string)

// endDate
// February 29, 2024 at 12:00:00 AM UTC+5:30
// (timestamp)

// otherDependentTask
// ""
// (string)

// priorityLevels
// (array)

// 0
// "MEDIUM"
// (string)

// reminderDate
// February 24, 2024 at 12:00:00 AM UTC+5:30
// (timestamp)

// repeats
// (array)

// 0
// "DAILY"
// (string)

// startDate
// February 23, 2024 at 12:00:00 AM UTC+5:30
// (timestamp)

// taskDescription
// "TT jii ggo by think having"
// (string)

// taskId
// "121995"
// (string)

// taskName
// "rajanisha"
// (string)

// taskStatus
// (array)

// 0
// "IN PROGRESS - STEP 1"
// (string)

// taskTypes
// (array)

// 0
// "EVENT"
// (string)

// taskWithWhom
// (array)

// 0
// "Sainath || Steel Plant Employee || 2 BHK RESALE FLAT || 8232STEELPLANTEMPLOYEE73"

class Task {
  final String taskId;
  final String taskName;
  final String taskDescription;
  final List<String> taskStatus;
  final List<String> taskTypes;
  final List<String> priorityLevels;
  final List<String> assignedTo;
  final List<String> taskWithWhom;
  final String budgetAllocated;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime reminderDate;
  final List<String> repeats;
  final String otherDependentTask;

  Task({
    required this.taskId,
    required this.taskName,
    required this.taskDescription,
    required this.taskStatus,
    required this.taskTypes,
    required this.priorityLevels,
    required this.assignedTo,
    required this.taskWithWhom,
    required this.budgetAllocated,
    required this.startDate,
    required this.endDate,
    required this.reminderDate,
    required this.repeats,
    required this.otherDependentTask,
  });
}
