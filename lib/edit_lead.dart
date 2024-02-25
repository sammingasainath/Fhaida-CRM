import 'dart:ffi';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:mapbox_search/mapbox_search.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:multiselect_dropdown_flutter/multiselect_dropdown_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'api/apikey.dart';

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
      home: LeadEditPage(),
    );
  }
}

class LeadEditPage extends StatefulWidget {
  @override
  _LeadEditPageState createState() => _LeadEditPageState();
  const LeadEditPage(
      {Key? key,
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
      this.floors})
      : super(key: key);

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

class _LeadEditPageState extends State<LeadEditPage>
    with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();

  static const String _mapboxApiKey =
      mapbox_key;

  late final TextEditingController _phoneNumberController;
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

  void initState() {
    super.initState();
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

    /// The above Dart code snippet is initializing a TextEditingController named
    /// `_exactAddressController` with the text value from the `company` property of the `widget`. This
    /// means that the text field controlled by `_exactAddressController` will initially display the
    /// value of `widget.company`.
    /// The above Dart code snippet is initializing a TextEditingController named
    /// `_exactAddressController` with the text value from the `company` property of the `widget`. This
    /// means that the initial text value of the `_exactAddressController` will be set to the value of
    /// `widget.company`.
    /// The above Dart code snippet is initializing a TextEditingController named
    /// `_exactAddressController` with the text value from the `company` property of the `widget`. This
    /// means that the initial text value of the `_exactAddressController` will be set to the value of
    /// `widget.company`.
    _exactAddressController = TextEditingController(text: widget.company);

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
    // _exactAddressController = TextEditingController(text: widget.exactAddress);
  }

  List<dynamic> _selectedandmarks = [
    // Add more landmarks as needed
  ];

  List<String?> _documentPaths = [];
  List<String?> _imagePaths = [];
  List<String?> _searchResults = [];
  List<String> const_Landmarks = [
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
  ];

  int _yearsOld = 0;

  void _showPlacePickerDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        String searchQuery = '';
        return StatefulBuilder(
          // Use StatefulBuilder to manage dialog state
          builder: (BuildContext context, StateSetter setDialogState) {
            // Provide a setDialogState method
            return AlertDialog(
              title: Text('Select Location'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    onChanged: (value) {
                      searchQuery = value;
                      _searchPlaces(searchQuery).then((_) {
                        setDialogState(
                            () {}); // Use setDialogState to rebuild the dialog with new search results
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Search',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          // Optionally trigger search again
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_searchResults[index] ?? ''),
                          onTap: () {
                            _roughAddressController.text =
                                _searchResults[index] ?? '';
                            Navigator.of(context).pop(); // Close the dialog
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) return;

    final geocoding = GeoCoding(
        apiKey: _mapboxApiKey,
        country: 'IN',

        // bbox: BBox(min: ({ 82.83521239019063, 17.307130723846072}),
        // max: ({83.63035935374467, 18.03357751432462}))),
        // limit: 5,
        types: [
          PlaceType.address,
          PlaceType.place,
          PlaceType.poi,
          PlaceType.address,
          PlaceType.neighborhood
        ]);

    final response = await geocoding.getPlaces(
      query,
    );

    print(response);

    // For simplicity, just use the first result
    var place = response;
    setState(() {
      _searchResults = response.success!
          .map(
            (place) => place.placeName,
          )
          .toList();

      _roughAddressController.text = place.toString();
    });
    // Navigator.of(context).pop(); // Close the dialog
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _areaSqFtController.dispose();
    _totalFloorsController.dispose();
    _roughAddressController.dispose();
    _exactAddressController.dispose();
    _videoLinkController.dispose();
    _descriptionController.dispose();
    _priceExpectingController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Lead'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(
                  height: 25,
                ),
                _buildDropdown(
                  'TYPE OF PROPERTY',
                  [
                    '2 BHK NEW FLAT',
                    '3 BHK NEW FLAT',
                    '2 BHK RESALE FLAT',
                    '3 BHK RESALE FLAT',
                    'NEW INDIVIDUAL HOUSE',
                    'CUSTOMIZABLE INDIVIDUAL HOUSE',
                    'COMMERCIAL LAND',
                    'PLOTS',
                    'COMMERCIAL BUILDING',
                    'RESALE INDIVIDUAL HOUSE'
                  ],
                  _selectedPropertyType,
                  (value) => setState(() => _selectedPropertyType = value),
                ),
                const SizedBox(height: 20),
                Text('Select Locations Preffered:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: 1.5,
                      fontFamily: 'Roboto',
                    )),
                const SizedBox(height: 20),
                _buildMultiSelectDropdownSimpleList(
                  list: const_Landmarks,
                  initiallySelected: _selectedandmarks,
                  onChange: (newList) {
                    _selectedandmarks = newList;
                    // your logic
                  },
                  includeSearch: true,
                  includeSelectAll: true,
                ),
                const SizedBox(height: 20),
                _buildMultilineTextField(
                  'Transcription',
                  _transcriptionController,
                  // TextInputType.text,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  'Buyer Phone Number',
                  _ownerNumberController,
                  TextInputType.phone,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  'Buyer Name',
                  _ownerNameController,
                  TextInputType.text,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  'Agent Phone Number',
                  _agentNumberController,
                  TextInputType.phone,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  'Agent Name',
                  _agentNameController,
                  TextInputType.text,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  'Total Floors Desired',
                  _totalFloorsController,
                  TextInputType.number,
                ),
                const SizedBox(height: 20),
                _buildDropdown(
                  'Number of Bedrooms',
                  ['1', '2', '3', '4', '5+'],
                  _selectedNumberOfBedrooms,
                  (value) => setState(() => _selectedNumberOfBedrooms = value),
                ),
                const SizedBox(height: 20),
                _buildDropdown(
                  'Furnishing',
                  ['Fully Furnished', 'Semi Furnished', 'Unfurnished'],
                  _selectedFurnishing,
                  (value) => setState(() => _selectedFurnishing = value),
                ),
                const SizedBox(height: 20),
                _buildDropdown(
                  'Maintenance Rating',
                  ['1', '2', '3', '4', '5'],
                  _selectedMaintenanceRating,
                  (value) => setState(() => _selectedMaintenanceRating = value),
                ),
                const SizedBox(height: 20),
                _buildDropdown(
                  'Status',
                  [
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
                  ],
                  _selectedConstructionStatus,
                  (value) =>
                      setState(() => _selectedConstructionStatus = value),
                ),
                const SizedBox(height: 20),
                _buildDropdown(
                  'Facing',
                  ['North', 'South', 'East', 'West'],
                  _selectedFacing,
                  (value) => setState(() => _selectedFacing = value),
                ),
                const SizedBox(height: 20),
                _buildDropdown(
                  'Also Want to Sell?',
                  ['Yes', 'No', 'Maybe'],
                  _selectedWantToBuy,
                  (value) => setState(() => _selectedWantToBuy = value),
                ),
                const SizedBox(height: 20),
                _buildDropdown(
                  'Urgency Of Purchase',
                  ['1', '2', '3', '4', '5'],
                  _selectedWant2ToBuy,
                  (value) => setState(() => _selectedWant2ToBuy = value),
                ),
                const SizedBox(height: 20),
                _buildDropdown(
                  'SOURCE OF LEAD',
                  [
                    'WHATSAPP',
                    'CONTACT',
                    'EMAIL',
                    'WEBSITE',
                    'PREVIOUS CLIENT',
                    'NEWSPAPER',
                    'OTHERS'
                  ],
                  _selectedWant1ToBuy,
                  (value) => setState(() => _selectedWant1ToBuy = value),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  'Present Address of Buyer',
                  _roughAddressController,
                  TextInputType.text,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _showPlacePickerDialog,
                  child: Text('Select Location'),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  'Occupation of Buyer',
                  _exactAddressController,
                  TextInputType.text,
                ),
                const SizedBox(height: 20),
                _buildMultilineTextField(
                  'Comments, Motive of Purchase, etc.',
                  _descriptionController,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Save Lead'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DropdownButtonFormField<String> _buildDropdown(
    String label,
    List<String> items,
    String? selectedValue,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      onChanged: onChanged,
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  TextFormField _buildTextField(
    String label,
    TextEditingController controller,
    TextInputType keyboardType,
  ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  Widget _buildNumberPicker(String label) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          width: 25,
        ), // Add some spacing between the label and the picker
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.remove),
              onPressed: () {
                setState(() {
                  if (_yearsOld > 0)
                    _yearsOld--; // Decrement, but don't go below 0
                });
              },
            ),
            Text(
              '$_yearsOld',
              style: TextStyle(fontSize: 20),
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                setState(() {
                  _yearsOld++; // Increment
                });
              },
            ),
          ],
        ),
      ],
    );
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

  Widget _buildMultiSelectDropdown({
    required List<Map<String, String>> list,
    required List<dynamic> initiallySelected,
    required Function(List<dynamic>) onChange,
  }) {
    return MultiSelectDropdown(
      list: list,
      initiallySelected: initiallySelected,
      onChange: onChange,
    );
  }

  TextFormField _buildMultilineTextField(
    String label,
    TextEditingController controller,
  ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      maxLines: 5,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  ElevatedButton _buildElevatedButton(
    String label,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        // primary: Theme.of(context).primaryColor,
        padding: EdgeInsets.symmetric(vertical: 15),
      ),
    );
  }

  Future<void> _handleDocuments() async {
    try {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(allowMultiple: true);

      if (result != null) {
        setState(() {
          _documentPaths = result.paths ?? [];
        });
      }
    } catch (e) {
      print('Error picking documents: $e');
    }
  }

  Future<void> _handlePhotos() async {
    try {
      final List<XFile>? images = await ImagePicker().pickMultiImage();

      if (images != null) {
        setState(() {
          _imagePaths = images.map((img) => img.path).toList();
        });
      }
    } catch (e) {
      print('Error picking photos: $e');
    }
  }

  Future<void> _handleImageSelection() async {
    try {
      final List<XFile>? images = await ImagePicker().pickMultiImage();
      if (images != null) {
        setState(() {
          _documentPaths = images.map((img) => img.path).toList();
        });
      }
    } catch (e) {
      print('Error picking images: $e');
    }
  }

  void _submitForm() async {
    String userUid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference contactsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userUid)
        .collection('leads');

    var result = _ownerNumberController.text.substring(6, 10);
    var specialid1 = _exactAddressController.text.toString();
    int random1 = 1 + Random().nextInt(99);

    // specialid = '${result}${specialid1}${random1}'.toUpperCase();
    // Upload documents to Firebase Storage

    // FirebaseFirestore.instance
    //     .collection('users')
    //     .get()
    //     .then((value) => print(value.docChanges.first.doc.id));
    // print(productsCollection.toString());

    try {
      await contactsCollection.doc(specialid).set({
        'propertyType': _selectedPropertyType,
        'landmarks': _selectedandmarks,
        'transcription': _transcriptionController.text,
        'buyerphone': _ownerNumberController.text,
        'buyerName': _ownerNameController.text,
        'agentNumber': _agentNumberController.text,
        'agentName': _agentNameController.text,
        'totalFloors': _totalFloorsController.text,
        'bedrooms': _selectedNumberOfBedrooms,
        'furnishing': _selectedFurnishing,
        'maintenanceRating': _selectedMaintenanceRating,
        'leadStatus': _selectedConstructionStatus,
        'facing': _selectedFacing,
        'wantedToSell': _selectedWantToBuy,
        'urgencyOfPurchase': _selectedWant2ToBuy,
        'sourceOfLead': _selectedWant1ToBuy,
        'presentAddress': _roughAddressController.text,
        'occupation': _exactAddressController.text,
        'comments': _descriptionController.text,
        'specialid': specialid,
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

  void _showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Property added successfully!'),
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

  Future<List<String?>> _uploadFiles(
      List<String?> filePaths, String folderName) async {
    List<String?> fileUrls = [];

    try {
      for (String? filePath in filePaths) {
        if (filePath != null) {
          File file = File(filePath);
          String fileName = DateTime.now().millisecondsSinceEpoch.toString();

          Reference storageReference =
              FirebaseStorage.instance.ref().child('$folderName/$fileName');

          UploadTask uploadTask = storageReference.putFile(file);

          await uploadTask.whenComplete(() async {
            String fileUrl = await storageReference.getDownloadURL();
            fileUrls.add(fileUrl);
          });
        }
      }
    } catch (e) {
      print('Error uploading files: $e');
    }

    return fileUrls;
  }
}
