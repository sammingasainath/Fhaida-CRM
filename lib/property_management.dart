import 'package:crmapp/add_lead.dart';
import 'package:crmapp/add_property.dart';
import 'package:crmapp/add_property_fromDoc.dart';
import 'package:crmapp/property_edit.dart';
import 'package:flutter/material.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:circular_menu/circular_menu.dart';
import 'add_contact.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Property Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: PropertyManagementPage(),
    );
  }
}

class PropertyManagementPage extends StatefulWidget {
  @override
  PropertyManagementPageState createState() => PropertyManagementPageState();
}

class PropertyManagementPageState extends State<PropertyManagementPage> {
  void initState() {
    super.initState();

    _applyFilters();
    _fetchPropertiesFromFirestore(); // Call this to initialize the filteredProperties list
  }

  List<Property> properties = [
    // Add more properties as needed
  ];

  final List<ValueItem> myOptions = [
    ValueItem(label: '2 BHK NEW FLAT', value: '2 BHK NEW FLAT'),
    ValueItem(label: '3 BHK NEW FLAT', value: '3 BHK NEW FLAT'),
    ValueItem(label: '2 BHK RESALE FLAT', value: '2 BHK RESALE FLAT'),
    ValueItem(label: '3 BHK RESALE FLAT', value: '3 BHK RESALE FLAT'),
    ValueItem(label: 'NEW INDIVIDUAL HOUSE', value: 'NEW INDIVIDUAL HOUSE'),
    ValueItem(
        label: 'CUSTOMIZABLE INDIVIDUAL HOUSE',
        value: 'CUSTOMIZABLE INDIVIDUAL HOUSE'),
    ValueItem(label: 'COMMERCIAL LAND', value: 'COMMERCIAL LAND'),
    ValueItem(label: 'PLOTS', value: 'PLOTS'),
    ValueItem(label: 'COMMERCIAL BUILDING', value: 'COMMERCIAL BUILDING'),
    ValueItem(
        label: 'RESALE INDIVIDUAL HOUSE', value: 'RESALE INDIVIDUAL HOUSE'),
  ];

  final List<ValueItem> bedroomOptions = [
    ValueItem(label: '1', value: '1'),
    ValueItem(label: '2', value: '2'),
    ValueItem(label: '3', value: '3'),
    ValueItem(label: '4', value: '4'),
    ValueItem(label: '5+', value: '5+'),
  ];

  final List<ValueItem> maintenanceRatingOptions = [
    ValueItem(label: '1', value: '1'),
    ValueItem(label: '2', value: '2'),
    ValueItem(label: '3', value: '3'),
    ValueItem(label: '4', value: '4'),
    ValueItem(label: '5', value: '5'),
  ];

  List<Property> filteredProperties = [];
  List<String> _selectedPropertyTypes = [];
  List<String> _selectedBedrooms = [];
  List<String> _selectedMaintenanceRatings = [];

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
                  MaterialPageRoute(builder: (context) => PropertyAddWidget()));

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
        title: Text('Property Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFilterForm(),
            const SizedBox(height: 20),
            _buildPropertyList(),
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
              _selectedPropertyTypes = selectedItems
                  .map((item) => item.value)
                  .cast<String>()
                  .toList();
              _applyFilters();
            });
          },
          hint: 'Select Property Types',
        ),
        const SizedBox(height: 10),
        MultiSelectDropDown(
          options: bedroomOptions,
          onOptionSelected: (selectedItems) {
            setState(() {
              _selectedBedrooms = selectedItems
                  .map((item) => item.value)
                  .cast<String>()
                  .toList();
              _applyFilters();
            });
          },
          hint: 'Select Number of Bedrooms',
        ),
        const SizedBox(height: 10),
        MultiSelectDropDown(
          options: maintenanceRatingOptions,
          onOptionSelected: (selectedItems) {
            setState(() {
              _selectedMaintenanceRatings = selectedItems
                  .map((item) => item.value)
                  .cast<String>()
                  .toList();
              _applyFilters();
              print(_selectedMaintenanceRatings);
            });
          },
          hint: 'Select Maintenance Ratings',
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _searchController,
          onChanged: _searchProperties,
          decoration: InputDecoration(
            labelText: 'Search by Property Name',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyList() {
    return Expanded(
      child: ListView.builder(
        itemCount: filteredProperties.length,
        itemBuilder: (context, index) {
          Property property = filteredProperties[index];
          return ListTile(
            title: Text(property.name!),
            subtitle: Row(
              // Use Row instead of Column here
              children: [
                Image.network(
                  property.images![0],
                  width: 100,
                  height: 100,
                ),
                const SizedBox(
                    width: 8), // Add some spacing between image and text
                Expanded(
                  // Wrap the Column inside Expanded
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Type: ${property.type}',
                      ),
                      if (property.landmarks!.isNotEmpty)
                        Text('Landmarks: ${property.landmarks!.join(', ')}'),
                      if (property.facing!.isNotEmpty)
                        Text('Facing: ${property.facing}'),
                      if (property.furnishing!.isNotEmpty)
                        Text('Furnishing: ${property.furnishing}'),
                      if (property.listedBy!.isNotEmpty)
                        Text('Listed By: ${property.listedBy}'),
                      if (property.ageOfProperty!.isNotEmpty)
                        Text('Age of Property: ${property.ageOfProperty}'),
                      if (property.agentName!.isNotEmpty)
                        Text('Agent Name: ${property.agentName}'),
                      if (property.constructionStatus!.isNotEmpty)
                        Text(
                            'Construction Status: ${property.constructionStatus}'),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () {
              _viewPropertyDetails(property);
            },
          );
        },
      ),
    );
  }

  void _applyFilters() {
    setState(() {
      filteredProperties = properties.where((property) {
        bool typeFilter = _selectedPropertyTypes.isEmpty ||
            _selectedPropertyTypes.contains(property.type);
        bool bedroomsFilter = _selectedBedrooms.isEmpty ||
            _selectedBedrooms.contains(property.bedrooms);
        bool maintenanceRatingFilter = _selectedMaintenanceRatings.isEmpty ||
            _selectedMaintenanceRatings.contains(property.maintenanceRating);

        return typeFilter && bedroomsFilter && maintenanceRatingFilter;
      }).toList();
    });
  }

  void _fetchPropertiesFromFirestore() async {
    try {
      var user_id = FirebaseAuth.instance.currentUser!.uid;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user_id)
          .collection('properties')
          .get();

      setState(() {
        properties.clear();
        properties.addAll(snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Property(
            id: data['specialid'],
            name: data['name'] ?? '',
            type: data['propertyType'] ?? '', // Update to the correct field
            bedrooms: data['bedrooms'] ?? '', // Update to the correct field
            maintenanceRating: data['maintenanceRating'] ?? '',
            ageOfProperty: data['ageOfProperty'] ?? '',
            agentName: data['agentName'] ?? '',
            agentNumber: data['agentNumber'] ?? '',
            constructionStatus: data['constructionStatus'] ?? '',
            contactNumber: data['contactNumber'] ?? '',
            description: data['description'] ?? '',
            exactAddress: data['exactAddress'] ?? '',
            facing: data['facing'] ?? '',
            furnishing: data['furnishing'] ?? '',
            listedBy: data['listedBy'] ?? '',
            ownerName: data['ownerName'] ?? '',
            priceExpecting: data['priceExpecting'] ?? '',
            roughAddress: data['roughAddress'] ?? '',
            videoLink: data['videoLink'] ?? '',
            images: data['images'] ?? [],
            documents: data['documents'] ?? [],
            landmarks: data['landmarks'] ?? [],
            area: data['areainSFT'] ?? '',
            wantToBuy: data['wantToBuy'] ?? '',
          );
        }));
        filteredProperties = properties;
      });
    } catch (error) {
      print('Error fetching contacts: $error');
    }
  }

  void _searchProperties(String query) {
    setState(() {
      filteredProperties = properties
          .where((property) =>
              property.name!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _viewPropertyDetails(Property property) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyEditWidget(
          propertyType: property.type,
          bedrooms: property.bedrooms,
          maintenanceRating: property.maintenanceRating,
          ageOfProperty: property.ageOfProperty,
          agentName: property.agentName,
          agentNumber: property.agentNumber,
          constructionStatus: property.constructionStatus,
          contactNumber: property.contactNumber,
          description: property.description,
          exactAddress: property.exactAddress,
          facing: property.facing,
          furnishing: property.furnishing,
          listedBy: property.listedBy,
          ownerName: property.ownerName,
          priceExpecting: property.priceExpecting,
          roughAddress: property.roughAddress,
          videoLink: property.videoLink,
          images: property.images,
          documents: property.documents,
          landmarks: property.landmarks,
          area: property.area,
          wantToBuy: property.wantToBuy,
          specialid: property.id,
        ),
      ),
    );
  }
}

class Property {
  final String? id;
  final String? name;
  final String? type;
  final String? bedrooms;
  final String? maintenanceRating;
  final String? ageOfProperty;
  final String? agentName;
  final String? agentNumber;
  final String? constructionStatus;
  final String? contactNumber;
  final String? description;
  final String? exactAddress;
  final String? facing;
  final String? furnishing;
  final String? listedBy;
  final String? area;
  final String? wantToBuy;

  final String? ownerName;
  final String? priceExpecting;
  final String? roughAddress;
  final String? videoLink;
  final List<dynamic>? images;
  final List<dynamic>? documents;
  final List<dynamic>? landmarks;

  Property({
    this.id,
    this.name,
    this.type,
    this.bedrooms,
    this.maintenanceRating,
    this.ageOfProperty,
    this.agentName,
    this.agentNumber,
    this.constructionStatus,
    this.contactNumber,
    this.description,
    this.exactAddress,
    this.facing,
    this.furnishing,
    this.listedBy,
    this.ownerName,
    this.priceExpecting,
    this.roughAddress,
    this.videoLink,
    this.images,
    this.documents,
    this.landmarks,
    this.area,
    this.wantToBuy,
  });
}
