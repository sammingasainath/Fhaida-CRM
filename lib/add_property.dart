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
      home: PropertyAddWidget(),
    );
  }
}

class PropertyAddWidget extends StatefulWidget {
  @override
  _PropertyAddWidgetState createState() => _PropertyAddWidgetState();
  const PropertyAddWidget(
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
      this.company})
      : super(key: key);

  final String? propertyType;
  final String? area;
  final String? ageOfProperty;
  final String? constructionStatus;
  final String? facing;

  final String? furnishing;
  final String? listedBy;

  final String? maintenanceRating;
  final String? bedrooms;
  final String? roughAddress;
  final String? exactAddress;
  final List<String>? landmarks;
  final String? videoLink;
  final String? description;
  final List<String>? documents;
  final List<String>? images;
  final String? priceExpecting;
  final String? name;
  final String? contactNumber;
  final String? email;
  final String? company;
}

class _PropertyAddWidgetState extends State<PropertyAddWidget>
    with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();

  static const String _mapboxApiKey =
      mapbox_key;

  final TextEditingController _phoneNumberController = TextEditingController();
  late final TextEditingController _areaSqFtController;
  final TextEditingController _totalFloorsController = TextEditingController();
  final TextEditingController _exactAddressController = TextEditingController();
  final TextEditingController _roughAddressController = TextEditingController();
  final TextEditingController _ownerNumberController = TextEditingController();
  late final TextEditingController _ownerNameController;
  final TextEditingController _agentNumberController = TextEditingController();
  final TextEditingController _agentNameController = TextEditingController();

  final TextEditingController _videoLinkController = TextEditingController();
  late final TextEditingController _descriptionController;
  final TextEditingController _priceExpectingController =
      TextEditingController();

  String? _selectedPropertyType;

  String? _selectedNumberOfBedrooms;
  String? _selectedFurnishing;
  String? _selectedMaintenanceRating;
  String? _selectedConstructionStatus;
  String? _selectedListedBy;
  String? _selectedFacing;
  String? _selectedWantToBuy;

  void initState() {
    super.initState();
    // _selectedNumberOfBedrooms = widget.bedrooms;
    _selectedFurnishing = widget.furnishing;

    // _selectedMaintenanceRating = widget.maintenanceRating;
    // _selectedConstructionStatus = widget.constructionStatus;
    // _selectedListedBy = widget.listedBy;
    // _selectedFacing = widget.facing;
    _selectedWantToBuy = 'No';

    _areaSqFtController = TextEditingController(text: widget.area);
    _descriptionController = TextEditingController(text: widget.description);
    _ownerNameController = TextEditingController(text: widget.name);

    if (widget.ageOfProperty != null) {
      _yearsOld = int.tryParse(widget.ageOfProperty ?? '') ?? 0;
    }

    _selectedandmarks = widget.landmarks ?? [];
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
        title: Text('Add Property'),
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
                  'Property Type',
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
                _buildNumberPicker('How Many Years Old?'),
                const SizedBox(height: 20),
                _buildTextField(
                  'Owner Phone Number',
                  _ownerNumberController,
                  TextInputType.phone,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  'Owner Name',
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
                  'Area in Sq. Ft.',
                  _areaSqFtController,
                  TextInputType.number,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  'Total Floors',
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
                  'Construction Status',
                  ['New Launch', 'Ready to Move', 'Under Construction'],
                  _selectedConstructionStatus,
                  (value) =>
                      setState(() => _selectedConstructionStatus = value),
                ),
                const SizedBox(height: 20),
                _buildDropdown(
                  'Listed By',
                  ['Owner', 'Dealer', 'Builder'],
                  _selectedListedBy,
                  (value) => setState(() => _selectedListedBy = value),
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
                  'Also Want to Buy?',
                  ['Yes', 'No', 'Maybe'],
                  _selectedWantToBuy,
                  (value) => setState(() => _selectedWantToBuy = value),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  'Rough Address - Shown to Customer',
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
                  'Exact Address - Hidden From Customer',
                  _exactAddressController,
                  TextInputType.text,
                ),
                const SizedBox(height: 20),

                Text('Select Landmarks Nearby:',
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
                  initiallySelected: const [],
                  onChange: (newList) {
                    _selectedandmarks = newList;
                    // your logic
                  },
                  includeSearch: true,
                  includeSelectAll: true,
                ),
                const SizedBox(height: 20),

                // Display the selected address

                _buildTextField(
                  'Video Link (URL)',
                  _videoLinkController,
                  TextInputType.url,
                ),
                const SizedBox(height: 20),
                _buildMultilineTextField(
                  'Description of Property',
                  _descriptionController,
                ),
                const SizedBox(height: 20),
                _buildElevatedButton(
                  'DOCUMENTS RELATED TO PROPERTY',
                  _handleImageSelection,
                ),
                if (_documentPaths.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8.0, // Gap between adjacent chips.
                    runSpacing: 4.0, // Gap between lines.
                    children: _documentPaths.map((path) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.file(File(path!),
                            width: 100, height: 100, fit: BoxFit.cover),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 20),
                _buildElevatedButton(
                  'ADD AT LEAST 5 PHOTOS OF PROPERTY',
                  _handlePhotos,
                ),
                if (_imagePaths.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8.0, // Gap between adjacent chips.
                    runSpacing: 4.0, // Gap between lines.
                    children: _imagePaths.map((path) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.file(File(path!),
                            width: 100, height: 100, fit: BoxFit.cover),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 20),
                _buildTextField(
                  'Price You Are Expecting',
                  _priceExpectingController,
                  TextInputType.number,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Add Property'),
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

  void _submitForm() async {
    String userUid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference contactsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userUid)
        .collection('properties');

    var result = _ownerNumberController.text.substring(6, 10);
    var specialid1 = _areaSqFtController.text.toString();

    var specialid =
        '${_yearsOld}${result}${_selectedFacing!}${specialid1}'.toUpperCase();
    // Upload documents to Firebase Storage
    List<String?> documentUrls =
        await _uploadFiles(_documentPaths, 'documents');

    // Upload images to Firebase Storage
    List<String?> imageUrls = await _uploadFiles(_imagePaths, 'images');

    // FirebaseFirestore.instance
    //     .collection('users')
    //     .get()
    //     .then((value) => print(value.docChanges.first.doc.id));
    // print(productsCollection.toString());

    try {
      await contactsCollection.doc(specialid).set({
        'propertyType': _selectedPropertyType,
        'ageOfProperty': _yearsOld.toString(),
        'constructionStatus': _selectedConstructionStatus,
        'facing': _selectedFacing,
        'furnishing': _selectedFurnishing,
        'listedBy': _selectedListedBy,
        'maintenanceRating': _selectedMaintenanceRating,
        'bedrooms': _selectedNumberOfBedrooms,
        'roughAddress': _roughAddressController.text,
        'exactAddress': _exactAddressController.text,
        'landmarks': _selectedandmarks,
        'videoLink': _videoLinkController.text,
        'description': _descriptionController.text,
        'documents': documentUrls,
        'images': imageUrls,
        'priceExpecting': _priceExpectingController.text,
        'ownerName': _ownerNameController.text,
        'contactNumber': _ownerNumberController.text,
        'agentNumber': _agentNumberController.text,
        'agentName': _agentNameController.text,
        'specialid': specialid,
        'wantedToBuy': _selectedWantToBuy,
        'areainSFT': _areaSqFtController.text,
        'totalFloors': _totalFloorsController.text,
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
}
