import 'package:crmapp/property_edit.dart';
import 'package:crmapp/property_view.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Property Add',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LeadProfilePage(),
    );
  }
}

class LeadProfilePage extends StatefulWidget {
  @override
  _LeadProfilePageState createState() => _LeadProfilePageState();
  const LeadProfilePage({
    Key? key,
    this.propertyType,
    this.area,
    this.ageOfProperty,
    this.constructionStatus,
    this.facing,
    this.furnishing,
    this.listedBy,
    this.maintenanceRating,
    this.bedrooms,
    this.roughAddress,
    this.exactAddress,
    this.landmarks,
    this.videoLink,
    this.description,
    this.documents,
    this.images,
    this.priceExpecting,
    this.name,
    this.contactNumber,
    this.email,
    this.company,
    this.transcription,
    this.specialid,
    this.buyerNumber,
    this.agentNumber,
    this.buyerName,
    this.agentName,
    this.wantedToSell,
    this.urgencyOfPurchase,
    this.floors,
  }) : super(key: key);

  final String? propertyType;
  final String? area;
  final String? ageOfProperty;
  final String? constructionStatus;
  final String? facing;
  final String? specialid;
  final String? buyerNumber;
  final String? agentNumber;
  final String? buyerName;
  final String? agentName;
  final String? floors;

  final String? furnishing;
  final String? listedBy;

  final String? maintenanceRating;
  final String? bedrooms;
  final String? roughAddress;
  final String? exactAddress;
  final List<dynamic>? landmarks;
  final String? videoLink;
  final String? description;
  final List<String>? documents;
  final List<String>? images;
  final String? priceExpecting;
  final String? name;
  final String? contactNumber;
  final String? email;
  final String? company;
  final String? transcription;

  final String? wantedToSell;
  final String? urgencyOfPurchase;
}

class _LeadProfilePageState extends State<LeadProfilePage>
    with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _transcriptionController;
  late final TextEditingController _areaSqFtController;
  late final TextEditingController _totalFloorsController;
  late final TextEditingController _exactAddressController;
  late final TextEditingController _roughAddressController;
  late final TextEditingController _ownerNumberController;
  late final TextEditingController _ownerNameController;
  late final TextEditingController _agentNumberController;
  late final TextEditingController _agentNameController;

  final TextEditingController _videoLinkController = TextEditingController();
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceExpectingController;

  String? _selectedPropertyType;

  String? _selectedNumberOfBedrooms;
  String? _selectedFurnishing;
  String? _selectedMaintenanceRating;
  String? _selectedConstructionStatus;
  String? _selectedListedBy;
  String? _selectedFacing;
  String? _selectedWantToBuy;
  String? _selectedWant1ToBuy;
  String? _selectedWant2ToBuy;
  String? specialid;
  List<Property> properties = [
    // Add more properties as needed
  ];

  void initState() {
    super.initState();

    print(widget.bedrooms.toString());
    _selectedNumberOfBedrooms = widget.bedrooms.toString();

    _selectedFurnishing = widget.furnishing;
    _selectedNumberOfBedrooms = widget.bedrooms.toString();
    _selectedPropertyType = widget.propertyType;
    _transcriptionController =
        TextEditingController(text: widget.transcription);

    _selectedMaintenanceRating = widget.maintenanceRating;
    _selectedConstructionStatus = widget.constructionStatus;
    _selectedListedBy = widget.listedBy;
    _selectedFacing = widget.facing;
    _selectedWantToBuy = 'No';

    _areaSqFtController = TextEditingController(text: widget.area);
    _descriptionController = TextEditingController(text: widget.description);
    _ownerNameController = TextEditingController(text: widget.name);

    _exactAddressController = TextEditingController(text: widget.exactAddress);

    _selectedandmarks = widget.landmarks ?? [];
    _selectedFacing = widget.facing ?? 'East';
    specialid = widget.specialid;
    _ownerNumberController = TextEditingController(text: widget.buyerNumber);
    _agentNumberController = TextEditingController(text: widget.agentNumber);
    _agentNameController = TextEditingController(text: widget.agentName);
    _priceExpectingController =
        TextEditingController(text: widget.priceExpecting);
    _roughAddressController = TextEditingController(text: widget.roughAddress);
    _totalFloorsController = TextEditingController(text: widget.floors);
    _selectedWantToBuy = widget.wantedToSell;
    _selectedWant2ToBuy = widget.urgencyOfPurchase;
    _selectedWant1ToBuy = widget.listedBy;
  }

  List<dynamic> _selectedandmarks = [];
  List<Property> filteredProperties = [];
  String? selectedLeadStatus;
  String? selectedLeadStatus1;

  Widget buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  void dispose() {
    _areaSqFtController.dispose();
    _totalFloorsController.dispose();
    _roughAddressController.dispose();
    _exactAddressController.dispose();
    _videoLinkController.dispose();
    _descriptionController.dispose();
    _priceExpectingController.dispose();
    super.dispose();
  }

  Widget _buildPropertyList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: filteredProperties.length,
      itemBuilder: (context, index) {
        Property property = filteredProperties[index];
        return ListTile(
          title: Text(property.name!),
          subtitle: Row(
            children: [
              Image.network(
                property.images![0],
                width: 100,
                height: 100,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Type: ${property.type}'),
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
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lead Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildInfoRow('Property Type', widget.propertyType.toString()),
              buildInfoRow('Landmarks', _selectedandmarks.join(', ')),
              buildInfoRow('Transcription', _transcriptionController.text),
              buildInfoRow('Owner Number', _ownerNumberController.text),
              buildInfoRow('Owner Name', _ownerNameController.text),
              buildInfoRow('Agent Number', _agentNumberController.text),
              buildInfoRow('Agent Name', _agentNameController.text),
              buildInfoRow('Total Floors', _totalFloorsController.text),
              buildInfoRow(
                  'Number of Bedrooms', _selectedNumberOfBedrooms.toString()),
              buildInfoRow(
                  'Furnishing Desired', _selectedFurnishing.toString()),
              buildInfoRow(
                  'Maintenance Rating', _selectedMaintenanceRating.toString()),
              buildInfoRow('Status', _selectedConstructionStatus.toString()),
              buildInfoRow('Facing', _selectedFacing.toString()),
              buildInfoRow('Will Sell', _selectedWantToBuy.toString()),
              buildInfoRow(
                'Urgency Of Purchase',
                _selectedWant2ToBuy ?? 'Not specified',
              ),
              buildInfoRow(
                'Source Of Lead',
                _selectedWant1ToBuy ?? 'Not specified',
              ),
              buildInfoRow('Rough Address', _roughAddressController.text),
              buildInfoRow('Exact Address', _exactAddressController.text),
              buildInfoRow('Description', _descriptionController.text),
              buildInfoRow('Special ID', specialid ?? 'Not specified'),
              DropdownButtonFormField<String>(
                value: selectedLeadStatus1,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedLeadStatus1 = newValue;
                      selectedLeadStatus =
                          selectedLeadStatus1!.replaceAll(' ', '');
                      _fetchPropertiesFromFirestore(selectedLeadStatus!);

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
              _buildPropertyList(),
            ],
          ),
        ),
      ),
    );
  }

  void _fetchPropertiesFromFirestore(String leadStatus) async {
    try {
      // Get the current user's ID
      var user_id = FirebaseAuth.instance.currentUser!.uid;

      // Query the Firestore collection based on leadStatus
      final snapshot1 = await FirebaseFirestore.instance
          .collection('users')
          .doc(user_id)
          .collection('leads')
          .doc(widget.specialid)
          .get();

      List snapshot2 = snapshot1.data()![leadStatus];
      String c;

      for (c in snapshot2) {
        print(c);
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user_id)
          .collection('properties')
          .where('specialid', whereIn: snapshot2)
          .get();

      setState(() {
        // Clear existing properties and populate with the new data
        properties.clear();
        properties.addAll(snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Property(
            id: data['specialid'],
            name: data['name'] ?? '',
            type: data['propertyType'] ?? '',
            bedrooms: data['bedrooms'] ?? '',
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
            area: data['area'] ?? '',
            wantToBuy: data['wantToBuy'] ?? '',
          );
        }));
        filteredProperties = properties;
        print(filteredProperties);
      });
    } catch (error) {
      print('Error fetching properties: $error');
      setState(() {
        filteredProperties = [];
      });
    }
  }

  void _viewPropertyDetails(Property property) {
    // Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyViewWidget(
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
