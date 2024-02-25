import 'package:crmapp/add_lead.dart';
import 'package:crmapp/add_property.dart';
import 'package:crmapp/add_property_fromDoc.dart';
import 'package:crmapp/call_recording.dart';
import 'package:crmapp/edit_lead.dart';
import 'package:crmapp/lead_status_updater.dart';
import 'package:crmapp/view_lead_profile.dart';
import 'package:flutter/material.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:circular_menu/circular_menu.dart';
import 'add_contact.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lead Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LeadManagementPage(),
    );
  }
}

class LeadManagementPage extends StatefulWidget {
  @override
  _LeadManagementPageState createState() => _LeadManagementPageState();
}

class _LeadManagementPageState extends State<LeadManagementPage> {
  void initState() {
    super.initState();
    _applyFilters();
    _fetchLeadsFromFirestore(); // Call this to initialize the filteredProperties list
  }

  List<Lead> leads = [
    // Add more properties as needed
  ];

  final List<ValueItem> myOptions = const [
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

  final List<ValueItem> myLocations = const [
    ValueItem(label: 'Dwaraka Nagar', value: 'Dwaraka Nagar'),
    ValueItem(label: 'Daba Gardens', value: 'Daba Gardens'),
    ValueItem(label: 'Asilmetta', value: 'Asilmetta'),
    ValueItem(label: 'Siripuram', value: 'Siripuram'),
    ValueItem(label: 'Pithapuram Colony', value: 'Pithapuram Colony'),
    ValueItem(label: 'CBM Compound', value: 'CBM Compound'),
    ValueItem(label: 'Maddilapalem', value: 'Maddilapalem'),
    ValueItem(label: 'Narasimha Nagar', value: 'Narasimha Nagar'),
    ValueItem(label: 'Balayya Sastri Layout', value: 'Balayya Sastri Layout'),
    ValueItem(label: 'Kailasapuram', value: 'Kailasapuram'),
    ValueItem(label: 'Seethammadhara', value: 'Seethammadhara'),
    ValueItem(label: 'Resapuvanipalem', value: 'Resapuvanipalem'),
    ValueItem(label: 'HB Colony', value: 'HB Colony'),
    ValueItem(label: 'Ramnagar', value: 'Ramnagar'),
    ValueItem(label: 'Santhipuram', value: 'Santhipuram'),
    ValueItem(label: 'Suryabagh', value: 'Suryabagh'),
    ValueItem(label: 'Railway New Colony', value: 'Railway New Colony'),
    ValueItem(label: 'Venkojipalem', value: 'Venkojipalem'),
    ValueItem(label: 'Seethammapeta', value: 'Seethammapeta'),
    ValueItem(label: 'Waltair Uplands', value: 'Waltair Uplands'),
    ValueItem(label: 'Dondaparthy', value: 'Dondaparthy'),
    ValueItem(label: 'Gnanapuram', value: 'Gnanapuram'),
    ValueItem(label: 'Akkayyapalem', value: 'Akkayyapalem'),
    ValueItem(label: 'Shivaji Palem', value: 'Shivaji Palem'),
    ValueItem(label: 'Thatichetlapalem', value: 'Thatichetlapalem'),
    ValueItem(label: 'Kancharapalem', value: 'Kancharapalem'),
    ValueItem(label: 'Isukathota', value: 'Isukathota'),
    ValueItem(label: 'Kommadi', value: 'Kommadi'),
    ValueItem(label: 'Rushikonda', value: 'Rushikonda'),
    ValueItem(label: 'Sagar Nagar', value: 'Sagar Nagar'),
    ValueItem(label: 'Yendada', value: 'Yendada'),
    ValueItem(label: 'Madhurawada', value: 'Madhurawada'),
    ValueItem(label: 'PM Palem', value: 'PM Palem'),
    ValueItem(label: 'Thimmapuram', value: 'Thimmapuram'),
    ValueItem(label: 'Jodugullapalem', value: 'Jodugullapalem'),
    ValueItem(label: 'Kapuluppada', value: 'Kapuluppada'),
    ValueItem(label: 'Gambhiram', value: 'Gambhiram'),
    ValueItem(label: 'Anandapuram', value: 'Anandapuram'),
    ValueItem(label: 'Mangamaripeta', value: 'Mangamaripeta'),
    ValueItem(label: 'Gajuwaka', value: 'Gajuwaka'),
    ValueItem(label: 'Pedagantyada', value: 'Pedagantyada'),
    ValueItem(label: 'Kurmannapalem', value: 'Kurmannapalem'),
    ValueItem(label: 'Akkireddypalem', value: 'Akkireddypalem'),
    ValueItem(label: 'Nathayyapalem', value: 'Nathayyapalem'),
    ValueItem(label: 'Yarada', value: 'Yarada'),
    ValueItem(label: 'Aganampudi', value: 'Aganampudi'),
    ValueItem(label: 'Chinagantyada', value: 'Chinagantyada'),
    ValueItem(label: 'Nadupuru', value: 'Nadupuru'),
    ValueItem(label: 'Duvvada', value: 'Duvvada'),
    ValueItem(label: 'Desapatrunipalem', value: 'Desapatrunipalem'),
    ValueItem(label: 'Sheela Nagar', value: 'Sheela Nagar'),
    ValueItem(label: 'Sriharipuram', value: 'Sriharipuram'),
    ValueItem(label: 'Tunglam', value: 'Tunglam'),
    ValueItem(label: 'Mulagada', value: 'Mulagada'),
    ValueItem(label: 'Vadlapudi', value: 'Vadlapudi'),
    ValueItem(
        label: 'Ukkunagaram (Steel Plant Township)',
        value: 'Ukkunagaram (Steel Plant Township)'),
    ValueItem(label: 'Gandhigram', value: 'Gandhigram'),
    ValueItem(label: 'Gangavaram', value: 'Gangavaram'),
    ValueItem(label: 'BHPV', value: 'BHPV'),
    ValueItem(label: 'Mindi', value: 'Mindi'),
    ValueItem(label: 'Scindia', value: 'Scindia'),
    ValueItem(label: 'Malkapuram', value: 'Malkapuram'),
    ValueItem(label: 'Gopalapatnam', value: 'Gopalapatnam'),
    ValueItem(label: 'Naidu Thota', value: 'Naidu Thota'),
    ValueItem(label: 'Vepagunta', value: 'Vepagunta'),
    ValueItem(label: 'Marripalem', value: 'Marripalem'),
    ValueItem(label: 'Simhachalam', value: 'Simhachalam'),
    ValueItem(label: 'Prahaladapuram', value: 'Prahaladapuram'),
    ValueItem(label: 'Pendurthi', value: 'Pendurthi'),
    ValueItem(label: 'Chintalagraharam', value: 'Chintalagraharam'),
    ValueItem(label: 'NAD', value: 'NAD'),
    ValueItem(label: 'Madhavadhara', value: 'Madhavadhara'),
    ValueItem(label: 'Sujatha Nagar', value: 'Sujatha Nagar'),
    ValueItem(label: 'Adavivaram', value: 'Adavivaram'),
    ValueItem(label: 'Muralinagar', value: 'Muralinagar'),
    ValueItem(label: 'Chinnamushidiwada', value: 'Chinnamushidiwada'),
    ValueItem(label: 'Kakani Nagar', value: 'Kakani Nagar'),
    ValueItem(label: 'Narava', value: 'Narava'),
    ValueItem(label: 'Pineapple Colony', value: 'Pineapple Colony'),
    ValueItem(label: 'Jagadamba Centre', value: 'Jagadamba Centre'),
    ValueItem(label: 'Soldierpet', value: 'Soldierpet'),
    ValueItem(label: 'MVP Colony', value: 'MVP Colony'),
    ValueItem(label: 'Velampeta', value: 'Velampeta'),
    ValueItem(label: 'Chinna Waltair', value: 'Chinna Waltair'),
    ValueItem(label: 'Kirlampudi Layout', value: 'Kirlampudi Layout'),
    ValueItem(label: 'Pandurangapuram', value: 'Pandurangapuram'),
    ValueItem(label: 'Daspalla Hills', value: 'Daspalla Hills'),
    ValueItem(label: 'Town Kotha Road', value: 'Town Kotha Road'),
    ValueItem(label: 'Peda Waltair', value: 'Peda Waltair'),
    ValueItem(label: 'Lawsons Bay Colony', value: 'Lawsons Bay Colony'),
    ValueItem(label: 'Prakashraopeta', value: 'Prakashraopeta'),
    ValueItem(label: 'Burujupeta', value: 'Burujupeta'),
    ValueItem(label: 'Jalari Peta', value: 'Jalari Peta'),
    ValueItem(label: 'One Town', value: 'One Town'),
    ValueItem(label: 'Poorna Market', value: 'Poorna Market'),
    ValueItem(label: 'Allipuram', value: 'Allipuram'),
    ValueItem(label: 'Salipeta', value: 'Salipeta'),
    ValueItem(label: 'Relli Veedhi', value: 'Relli Veedhi'),
    ValueItem(label: 'Maharanipeta', value: 'Maharanipeta'),
    ValueItem(label: 'Chengal Rao Peta', value: 'Chengal Rao Peta'),
    ValueItem(label: 'Padmanabham', value: 'Padmanabham'),
    ValueItem(
        label: 'Gidijala Gudilova Tagarapuvalasa',
        value: 'Gidijala Gudilova Tagarapuvalasa'),
    ValueItem(label: 'Bheemunipatnam', value: 'Bheemunipatnam'),
    ValueItem(label: 'Nidigattu', value: 'Nidigattu'),
    ValueItem(label: 'Vellanki', value: 'Vellanki'),
    ValueItem(label: 'Sontya', value: 'Sontya'),
    ValueItem(label: 'Pudimadaka', value: 'Pudimadaka'),
    ValueItem(label: 'Dosuru', value: 'Dosuru'),
    ValueItem(label: 'Anakapalle', value: 'Anakapalle'),
    ValueItem(label: 'Pedamadaka', value: 'Pedamadaka'),
    ValueItem(label: 'Duppituru', value: 'Duppituru'),
    ValueItem(label: 'Ravada', value: 'Ravada'),
    ValueItem(label: 'Devada', value: 'Devada'),
    ValueItem(label: 'Lankelapalem', value: 'Lankelapalem'),
    ValueItem(label: 'Parawada', value: 'Parawada'),
    ValueItem(label: 'Appikonda Atchutapuram', value: 'Appikonda Atchutapuram'),
    ValueItem(label: 'Sabbavaram', value: 'Sabbavaram'),
    ValueItem(label: 'Devipuram', value: 'Devipuram'),
    ValueItem(label: 'Kothavalasa', value: 'Kothavalasa'),
  ];

  final List<ValueItem> myStatusOptions = const [
    ValueItem(label: 'LEAD RECEIVED', value: 'LEAD RECEIVED'),
    ValueItem(label: 'PROPERTIES SENT', value: 'PROPERTIES SENT'),
    ValueItem(label: 'SITE VISIT SCHEDULED', value: 'SITE VISIT SCHEDULED'),
    ValueItem(label: 'SITE VISIT DONE', value: 'SITE VISIT DONE'),
    ValueItem(label: 'TOKEN AMOUNT SCHEDULED', value: 'TOKEN AMOUNT SCHEDULED'),
    ValueItem(
        label: '1ST - REGISTRATION DONE', value: '1ST - REGISTRATION DONE'),
    ValueItem(label: 'LOAN IN PROCESS', value: 'LOAN IN PROCESS'),
    ValueItem(label: 'REGISTRATION SCHEDULED', value: 'REGISTRATION SCHEDULED'),
    ValueItem(label: 'REGISTRATION DONE', value: 'REGISTRATION DONE'),
    ValueItem(label: 'COMMISION RECEIVED', value: 'COMMISION RECEIVED'),
    ValueItem(label: 'DEAL CLOSED', value: 'DEAL CLOSED'),
  ];

  final List<ValueItem> maintenanceRatingOptions = const [
    ValueItem(label: 'North', value: 'North'),
    ValueItem(label: 'East', value: 'East'),
    ValueItem(label: 'West', value: 'West'),
    ValueItem(label: 'South', value: 'South'),
  ];

  List<Lead> filteredProperties = [];
  List<String> _selectedPropertyTypes = [];
  List<String> _selectedBedrooms = [];
  List<String> _selectedBedrooms1 = [];
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

              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LeadAddPage(
                          furnishing: 'Semi Furnished',
                          transcription: '',
                          roughAddress: '',
                          facing: 'North',
                          maintenanceRating: '2',
                          constructionStatus: 'LEAD RECEIVED',
                          listedBy: 'DEALER',
                          description: '',
                          bedrooms: '2',
                          propertyType: '2 BHK NEW FLAT',
                          landmarks: [])));

              print('First button pressed');
            },
          ),
          CircularMenuItem(
            icon: Icons.mic,
            onTap: () async {
              final cameras = await availableCameras();

              // Get a specific camera from the list of available cameras.
              final firstCamera = cameras.first;
              // Implement the action for the second button
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => UploadAudioPage()));

              print('Second button pressed');
            },
          ),
        ],
      ),
      appBar: AppBar(
        title: Text('Lead Management'),
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
          searchEnabled: true,
          options: myLocations,
          onOptionSelected: (selectedItems) {
            setState(() {
              _selectedBedrooms = selectedItems
                  .map((item) => item.value)
                  .cast<String>()
                  .toList();
              _applyFilters();
            });
          },
          hint: 'Select Landmarks',
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
          hint: 'Select Facing',
        ),
        const SizedBox(height: 10),
        MultiSelectDropDown(
          searchEnabled: true,
          options: myStatusOptions,
          onOptionSelected: (selectedItems) {
            setState(() {
              _selectedBedrooms1 = selectedItems
                  .map((item) => item.value)
                  .cast<String>()
                  .toList();
              _applyFilters();
            });
          },
          hint: 'Select Status',
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _searchController,
          onChanged: _searchProperties,
          decoration: InputDecoration(
            labelText: 'Search by Customer',
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
          Lead lead = filteredProperties[index];
          return ListTile(
            title: Text(lead.buyerName.toString()),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Type: ${lead.propertyType}'),
                Text('LandMark: ${lead.landmarks!.join(', ')}'),
                Text('Facing: ${lead.facing}'),
                Text('Status: ${lead.leadStatus}'),
              ],
            ),
            onTap: () {
              _viewPropertyDetails(lead);
            },
          );
        },
      ),
    );
  }

  void _applyFilters() {
    setState(() {
      filteredProperties = leads.where((property) {
        bool typeFilter = _selectedPropertyTypes.isEmpty ||
            _selectedPropertyTypes.contains(property.propertyType);
        bool landmarkFilter = _selectedBedrooms.isEmpty ||
            property.landmarks!
                .any((landmark) => _selectedBedrooms.contains(landmark));
        bool maintenanceRatingFilter = _selectedMaintenanceRatings.isEmpty ||
            _selectedMaintenanceRatings.contains(property.facing);
        bool statusFilter = _selectedBedrooms1.isEmpty ||
            _selectedBedrooms1.contains(property.leadStatus);

        return typeFilter &&
            landmarkFilter &&
            maintenanceRatingFilter &&
            statusFilter;
      }).toList();
    });
  }

  void _searchProperties(String query) {
    setState(() {
      filteredProperties = leads
          .where((property) =>
              property.buyerName!.toLowerCase().contains(query.toLowerCase()) ||
              property.specialid!
                  .toLowerCase()
                  .toString()
                  .contains(query)) // Assuming number is a String
          .toList();
    });
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
      });
    } catch (error) {
      print('Error fetching contacts: $error');
    }
  }

  void _viewPropertyDetails(Lead lead) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Text(lead.buyerName.toString()),
              // SizedBox(
              //     width: 8), // Add some spacing between the text and IconButton
              IconButton(
                icon: Icon(Icons.person),
                tooltip: 'View Profile',
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LeadProfilePage(
                        name: lead.buyerName.toString(),
                        buyerNumber: lead.buyerphone.toString(),
                        buyerName: lead.buyerName.toString(),
                        agentNumber: lead.agentNumber.toString(),
                        agentName: lead.agentName.toString(),
                        furnishing: lead.furnishing.toString(),
                        bedrooms: lead.bedrooms.toString(),
                        propertyType: lead.propertyType.toString(),
                        transcription: lead.transcription.toString(),
                        roughAddress: lead.presentAddress.toString(),
                        specialid: lead.specialid.toString(),
                        facing: lead.facing.toString(),
                        maintenanceRating: lead.maintenanceRating.toString(),
                        constructionStatus: lead.leadStatus.toString(),
                        listedBy: lead.sourceOfLead.toString(),
                        urgencyOfPurchase: lead.urgencyOfPurchase.toString(),
                        wantedToSell: lead.wantedToSell.toString(),
                        description: lead.comments.toString(),
                        landmarks: lead.landmarks,
                        floors: lead.totalFloors.toString(),
                        company: lead.occupation.toString(),
                        
                      ),
                    ),
                  );
                },
              ),
              Text(
                'Profile',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.end,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Type: ${lead.propertyType}'),
              Text('Landmark: ${lead.landmarks!.join(', ')}'),
              Text('Facing: ${lead.facing}'),
              Text('Name: ${lead.buyerName}'),
              Text('Occupation: ${lead.occupation}'),
              SizedBox(height: 10),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.link),
              tooltip: 'Update Status',
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LeadStatusPage(
                      leadID: lead.specialid,
                      // specialid: lead.specialid.toString(),
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LeadEditPage(
                      name: lead.buyerName.toString(),
                      buyerNumber: lead.buyerphone.toString(),
                      buyerName: lead.buyerName.toString(),
                      agentNumber: lead.agentNumber.toString(),
                      agentName: lead.agentName.toString(),
                      furnishing: lead.furnishing.toString(),
                      bedrooms: lead.bedrooms.toString(),
                      propertyType: lead.propertyType.toString(),
                      transcription: lead.transcription.toString(),
                      roughAddress: lead.presentAddress.toString(),
                      specialid: lead.specialid.toString(),
                      facing: lead.facing.toString(),
                      maintenanceRating: lead.maintenanceRating.toString(),
                      constructionStatus: lead.leadStatus.toString(),
                      listedBy: lead.sourceOfLead.toString(),
                      urgencyOfPurchase: lead.urgencyOfPurchase.toString(),
                      wantedToSell: lead.wantedToSell.toString(),
                      description: lead.comments.toString(),
                      landmarks: lead.landmarks,
                      floors: lead.totalFloors.toString(),
                      company: lead.occupation.toString(),
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.call),
              onPressed: () async {
                final Uri launchUri =
                    Uri(scheme: 'tel', path: lead.buyerphone.toString());
                if (await canLaunchUrl(launchUri)) {
                  await launchUrl(launchUri);
                } else {
                  throw 'Could not launch $launchUri';
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () async {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
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
