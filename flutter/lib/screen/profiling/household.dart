// ignore_for_file: must_be_immutable, avoid_print
import '../../widgets/buttons/save_button.dart';
import '../../widgets/buttons/update_button.dart';
import '/widgets/buttons/add_button.dart';
import '/widgets/context/form.dart';
import '/widgets/context/table.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io'; 
import '../../constants/dropdown_options.dart';
import '../../dialogs/validation_dialog.dart';
import '/widgets/search_bar.dart' as custom;

class HouseholdPage extends StatefulWidget {
  const HouseholdPage({super.key});

  @override
  HouseholdPageState createState() => HouseholdPageState();
}

class HouseholdPageState extends State<HouseholdPage> {

  bool _isSortedAscending = true; // Track sorting order

  int _currentPage = 0;
  final int _itemsPerPage = 15;
  List<Map<String, dynamic>> _allRecords = [];
  String _searchQuery = ""; // Stores search input

  @override
  void initState() {
    super.initState();
    _fetchRecords();
  }

  Future<void> _fetchRecords() async {
    try {
      final url = Uri.parse('http://localhost/BFEPS-BDRRMC/api/profiling/get_hhdata.php');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        print('Fetched data: $data'); // Debug print
        setState(() {
          _allRecords = List<Map<String, dynamic>>.from(data);
          // Sort records by household_id in descending order (newest first)
          _allRecords.sort((a, b) => b['household_id'].compareTo(a['household_id']));
        });
      } else {
        throw Exception('Failed to load records');
      }
    } catch (e) {
      print('Error fetching records: $e');
    }
  }
  
  void _deleteHouseholdRecord(String householdId) async {
    ValidationDialog.showDeleteDialog(
      context: context, 
      message: 'Are you sure you want to delete this record?',
      onConfirm: () async {
        Navigator.of(context).pop(); 
        try {
          final url = Uri.parse('http://localhost/BFEPS-BDRRMC/api/profiling/delete_hhdata.php');
          final response = await http.post(url, body: {'household_id': householdId});
          if (response.statusCode == 200) {
            var responseData = json.decode(response.body);
            if (responseData['success'] == true) {
              // Refresh reports
              await _fetchRecords();
              print('Record deleted successfully');
            } else {
              print('Failed to delete record: ${responseData['message']}');
            }
          } else {
            print('Failed to connect to the server');
          }
        } catch (e) {
          print('Error deleting record: $e');
        }
      },
    );
  }


  List<Map<String, dynamic>> _getPaginatedRecords() {
    // Normalize search query: trim, lowercase, and remove commas
    String normalizedQuery = _searchQuery.trim().toLowerCase().replaceAll(',', '');

    // Split search query into words
    List<String> queryWords = normalizedQuery.split(RegExp(r'\s+'));

    List<Map<String, dynamic>> filteredRecords = _allRecords.where((record) {
        // Normalize full name (remove commas)
        String fullName = "${record['residents'][0]['last_name']} ${record['residents'][0]['first_name']} ${record['residents'][0]['middle_name'] ?? ''} ${record['residents'][0]['suffix'] ?? ''}"
            .replaceAll(',', '') // Remove hardcoded commas
            .trim()
            .toLowerCase();

        // Normalize address (remove commas)
        String address = "${record['household_street']} ${record['household_zone']} ${record['household_lot'] ?? ''}"
            .replaceAll(',', '') // Remove hardcoded commas
            .trim()
            .toLowerCase();

        // Normalize contact number and age
        String contact = record['residents'][0]['contact_number'].toString().trim();
        String age = record['residents'][0]['age'].toString().trim();

        // Check if any of the fields match the search query
        bool nameMatches = queryWords.any((word) => fullName.contains(word));
        bool addressMatches = queryWords.any((word) => address.contains(word));
        bool contactMatches = queryWords.any((word) => contact.contains(word));
        bool ageMatches = queryWords.any((word) => age.contains(word));

        return nameMatches || addressMatches || contactMatches || ageMatches;
    }).toList();

    int start = _currentPage * _itemsPerPage;
    int end = start + _itemsPerPage;
    if (end > filteredRecords.length) {
        end = filteredRecords.length;
    }
    return filteredRecords.sublist(start, end);
  }

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
      _currentPage = 0; 
    });
  }

  void _goToNextPage() {
    int totalFilteredRecords = _allRecords
        .where((record) =>
            record['last_name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            record['first_name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            record['contact_number'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            record['household_street'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            record['household_zone'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            record['household_lot'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            record['age'].toString().toLowerCase().contains(_searchQuery.toLowerCase()))
        .length;

    int maxPages = (totalFilteredRecords / _itemsPerPage).ceil();

    if (_currentPage + 1 < maxPages) {
      setState(() {
        _currentPage++;
      });
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }
  }
  
  Widget _buildPagination() {
    int start = _currentPage * _itemsPerPage + 1;
    int end = start + _itemsPerPage - 1; 
    if (end > _allRecords.length) {
      end = _allRecords.length;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '$start-$end of ${_allRecords.length}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: 'Poppins',
            color: Color(0xFF9E9E9E),
          ),
        ),
        const SizedBox(width: 8), 
        Row(
          mainAxisSize: MainAxisSize.min, 
          children: [
            ElevatedButton(
              onPressed: _currentPage > 0 ? _goToPreviousPage : null,
              style: ElevatedButton.styleFrom(
                foregroundColor: Color(0xFF4B4B4B), 
                shape: const CircleBorder(
                  side: BorderSide(color: Color(0xFFCCCCCC), width: 1),
                ),
                backgroundColor: Color(0xFFFFFFFF), 
                padding: const EdgeInsets.all(5),
                minimumSize: const Size(40,40), 
              ),
              child: const Icon(Icons.navigate_before_rounded, color: Color(0xFF4B4B4B), size: 22),
            ),
            const SizedBox(width: 8), 
            ElevatedButton(
              onPressed: (_currentPage + 1) * _itemsPerPage < _allRecords.length ? _goToNextPage : null,
              style: ElevatedButton.styleFrom(
                foregroundColor: Color(0xFF4B4B4B), 
                shape: const CircleBorder(
                  side: BorderSide(color: Color(0xFFCCCCCC), width: 1),
                ),
                backgroundColor: Color(0xFFFFFFFF), 
                padding: const EdgeInsets.all(5),
                minimumSize: const Size(40, 40), 
              ),
              child: const Icon(Icons.navigate_next_rounded, color: Color(0xFF4B4B4B), size: 22),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 custom.SearchBar(onSearch: _updateSearchQuery), 
                AddButton(
                  label: 'Add Record',
                  onPressed: () {
                    _showOverlayForm(context,  null, isViewMode: false);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildHouseholdTable(),
            const SizedBox(height: 20), 
            _buildPagination(),
          ],
        ),
      ),
    );
  }

  Widget _buildHouseholdTable() {
    return Container(
      width: double.infinity,
      height: 700,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFCCCCCC)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          Expanded(
            child: _getPaginatedRecords().isEmpty
                ? const Center(
                    child: Text(
                      'No Records available.',
                      style: TextStyle(
                        color: Color(0xFFCBCBCB),
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  )
                : _buildTableRows(),
          ),
        ],
      ),
    );
  }

  void _toggleSortByLastName() {
    setState(() {
      _isSortedAscending = !_isSortedAscending; // Toggle sorting order
      _allRecords.sort((a, b) {
        String lastNameA = a['residents'][0]['last_name'].toLowerCase();
        String lastNameB = b['residents'][0]['last_name'].toLowerCase();
        return _isSortedAscending ? lastNameA.compareTo(lastNameB) : lastNameB.compareTo(lastNameA);
      });
    });
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFCCCCCC))),
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8), 
              child: Row(
                children: [
                  const Text(
                    'Household Head',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      color: Color(0xFF4B4B4B),
                    ),
                  ),
                  const SizedBox(width: 4), 
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: _toggleSortByLastName,
                      child: Icon(
                        _isSortedAscending ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
                        size: 20, 
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const HeaderCellWidget(label: 'Address', flex: 4),
          const HeaderCellWidget(label: 'Age', flex: 1, center: true),
          const HeaderCellWidget(label: 'Gender', flex: 2, center: true),
          const HeaderCellWidget(label: 'Contact Number', flex: 2, center: true),
          const HeaderCellWidget(label: 'Pregnant', flex: 1, center: true),
          const HeaderCellWidget(label: 'PWD\'s', flex: 1, center: true),
          const HeaderCellWidget(label: 'Senior', flex: 1, center: true),
          const HeaderCellWidget(label: 'Underaged', flex: 1, center: true),
          const HeaderCellWidget(label: 'Members', flex: 1, center: true),
          const HeaderCellWidget(label: 'Action', flex: 1, center: true),
        ],
      ),
    );
  }

  Widget _buildTableRows() {
    List<Map<String, dynamic>> paginatedRecords = _getPaginatedRecords();
    return ListView.builder(
      itemCount: paginatedRecords.length,
      itemBuilder: (context, index) {
        final record = paginatedRecords[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(  
            border: Border(bottom: BorderSide(color: Color(0xFFCCCCCC))),
          ),
          child: Row(
            children: [
              DataCellWidget(value: '${record['residents'][0]['last_name']}, ${record['residents'][0]['first_name']} ${record['residents'][0]['middle_name'] ?? ''} ${record['residents'][0]['suffix'] ?? ''}', flex: 3),
              DataCellWidget(value: '${record['household_street']}, ${record['household_zone']}, ${record['household_lot'] ?? ''} Barangay Buenavista', flex: 4),
              DataCellWidget(value: '${record['residents'][0]['age']}', flex: 1, center: true),
              DataCellWidget(value: '${record['residents'][0]['gender']}', flex: 2, center: true),
              DataCellWidget(value: '${record['residents'][0]['contact_number']}', flex: 2, center: true),
              DataCellWidget(value: record['PregnantCount'] ?? '0', flex: 1, center: true),
              DataCellWidget(value: record['PWDCount'] ?? '0', flex: 1, center: true),
              DataCellWidget(value: record['SeniorCount'] ?? '0', flex: 1, center: true),
              DataCellWidget(value: record['UnderagedCount'] ?? '0', flex: 1, center: true),
              DataCellWidget(value: record['HouseholdMembersCount'] ?? '0', flex: 1, center: true),
              Expanded(
                flex: 1,
                child: Center(
                  child: PopupMenuWidget(
                    onSelected: (value) {
                      if (value == 'View') {
                        _showOverlayForm(context, record, isViewMode: true);
                      } else if (value == 'Update') {
                        _showOverlayForm(context, record, isViewMode: false);
                      } else if (value == 'Delete') {
                        _deleteHouseholdRecord(record['household_id']);
                      } 
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showOverlayForm(BuildContext context, Map<String, dynamic>? existingData, {bool isViewMode = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: HouseholdForm(
            onSave: (newRecord) {
              print("Received data from form: $newRecord"); // Print the received data
              setState(() {
                // Update the existing record in _allRecords without refreshing counts
                if (existingData != null) {
                  int index = _allRecords.indexWhere((record) => record['household_id'] == existingData['household_id']);
                  if (index != -1) {
                    _allRecords[index] = newRecord; // Update the existing record
                  }
                } else {
                  _allRecords.add(newRecord); // Add new record if existingData is null
                }
              });
              _fetchRecords(); // Fetch updated records
            },
            existingData: existingData,
            isViewMode: isViewMode,
            isUpdateMode: existingData != null, // Set update mode if existing data is provided
          ),
        );
      },
    );
  }
}

class HouseholdForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave; 
  final Map<String, dynamic>? existingData; 
  bool isViewMode; 
  final bool isUpdateMode;

  HouseholdForm({super.key, 
    required this.onSave, 
    this.existingData, 
    this.isViewMode = false, 
    this.isUpdateMode = false,
  });

  @override
  HouseholdFormState createState() => HouseholdFormState();
}

class HouseholdFormState extends State<HouseholdForm> {
  bool _isDirty = false; // Track if the form is dirty

  final Map<String, TextEditingController> controllers = {
    'profile_picture': TextEditingController(),
    'first_name': TextEditingController(),
    'middle_name': TextEditingController(),
    'last_name': TextEditingController(),
    'suffix': TextEditingController(),
    'alias': TextEditingController(),
    'household_street': TextEditingController(),
    'household_lot': TextEditingController(),
    'contact_number': TextEditingController(),
    'birth_date': TextEditingController(),
    'age': TextEditingController(),
  };

  final Map<String, String?> dropdownValues = {
    'household_zone': null,
    'civil_status': null,
    'religion': null,
    'gender': null,
    'education': null,
    'occupation': null,
    'beneficiary': null,  
    'pregnant': null,
    'disability': null,
    'household_type': null,
    'material_used': null,
    'toilet_facility': null,
    'means_of_communication': null,
    'source_of_water': null,
    'electricity': null,
    'household_with': null,
    'family_income': null,
  };
  
  @override
  void initState() {
    super.initState();
    if (widget.existingData != null) {
      // Initialize variables to hold household head and members
      Map<String, dynamic>? householdHead;
      List<Map<String, dynamic>> members = [];

      // Loop through residents to find the household head
        for (var member in widget.existingData!['residents']) {
        if (member['household_type'] == 'Head of the Household') {
            householdHead = member; // Store household head
        } else {
            members.add(member); // Store other members
        }
      }

      // Populate the fields with household head data if available
      if (householdHead != null) {
          controllers['profile_picture']!.text = householdHead['profile_picture'] ?? '';
          controllers['first_name']!.text = householdHead['first_name'] ?? '';
          controllers['middle_name']!.text = householdHead['middle_name'] ?? '';
          controllers['last_name']!.text = householdHead['last_name'] ?? '';
          controllers['suffix']!.text = householdHead['suffix'] ?? '';
          controllers['alias']!.text = householdHead['alias'] ?? '';
          controllers['household_street']!.text = widget.existingData!['household_street'] ?? '';
          controllers['household_lot']!.text = widget.existingData!['household_lot'] ?? '';
          controllers['contact_number']!.text = householdHead['contact_number'] ?? '';
          controllers['birth_date']!.text = householdHead['birth_date'] ?? '';
          controllers['age']!.text = householdHead['age'] ?? '';

          // Populate dropdown values for household head
          dropdownValues['household_zone'] = widget.existingData!['household_zone'] as String?;
          dropdownValues['civil_status'] = householdHead['civil_status'] as String?;
          dropdownValues['religion'] = householdHead['religion'] as String?;
          dropdownValues['gender'] = householdHead['gender'] as String?;
          dropdownValues['education'] = householdHead['education'] as String?;
          dropdownValues['occupation'] = householdHead['occupation'] as String?;
          dropdownValues['beneficiary'] = householdHead['beneficiary'] as String?;
          dropdownValues['pregnant'] = householdHead['pregnant'] as String?;
          dropdownValues['disability'] = householdHead['disability'] as String?;
          dropdownValues['household_type'] = householdHead['household_type'] as String?;
          dropdownValues['material_used'] = widget.existingData!['material_used'] as String?;
          dropdownValues['toilet_facility'] = widget.existingData!['toilet_facility'] as String?;
          dropdownValues['means_of_communication'] = widget.existingData!['means_of_communication'] as String?;
          dropdownValues['source_of_water'] = widget.existingData!['source_of_water'] as String?;
          dropdownValues['electricity'] = widget.existingData!['electricity'] as String?;
          dropdownValues['household_with'] = widget.existingData!['household_with'] as String?;
          dropdownValues['family_income'] = widget.existingData!['family_income'] as String?;
      }

      // Populate household members if available
        for (var member in members) {
        householdMembers.add({
          'resident_id': member['resident_id'], 
          'controllers': {
            'profile_picture': TextEditingController(text: member['profile_picture'] ?? ''),
            'first_name': TextEditingController(text: member['first_name'] ?? ''),
            'middle_name': TextEditingController(text: member['middle_name'] ?? ''),
            'last_name': TextEditingController(text: member['last_name'] ?? ''),
            'suffix': TextEditingController(text: member['suffix'] ?? ''),
            'alias': TextEditingController(text: member['alias'] ?? ''),
            'contact_number': TextEditingController(text: member['contact_number'] ?? ''),
            'birth_date': TextEditingController(text: member['birth_date'] ?? ''),
            'age': TextEditingController(text: member['age'] ?? ''),
          },
          'dropdownValues': {
            'civil_status': member['civil_status'] as String?,
            'religion': member['religion'] as String?,
            'gender': member['gender'] as String?,
            'education': member['education'] as String?,
            'occupation': member['occupation'] as String?,
            'beneficiary': member['beneficiary'] as String?,
            'pregnant': member['pregnant'] as String?,
            'disability': member['disability'] as String?,
            'household_type': member['household_type'] as String?,
          },
        });
      }
    }
  }

  // For additional household members
  List<Map<String, dynamic>> householdMembers = [];

  void _addHouseholdMember() {
    setState(() {
      // Generate a temporary ID for the new member
      String tempId = DateTime.now().millisecondsSinceEpoch.toString(); // Used timestamp as a temporary ID
      householdMembers.add({
        'resident_id': tempId, // Assign the temporary ID
        'controllers': {
          'profile_picture': TextEditingController(),
          'first_name': TextEditingController(),
          'middle_name': TextEditingController(),
          'last_name': TextEditingController(),
          'suffix': TextEditingController(),
          'alias': TextEditingController(),
          'contact_number': TextEditingController(),
          'birth_date': TextEditingController(),
          'age': TextEditingController(),
        },
        'dropdownValues': {
          'household_zone': '',
          'civil_status': '',
          'religion': '',
          'gender': '',
          'education': '',
          'occupation': '',
          'beneficiary': '',
          'pregnant': '',
          'disability': '',
          'household_type': '',
        },
      });
    });
  }

  void _markDirty(String value) {
  setState(() {
    _isDirty = true;
  });
}

  void _deleteHouseholdMember(int index) {
    String memberId = householdMembers[index]['resident_id'];

    ValidationDialog.showDeleteDialog(
      context: context,
      message: 'Are you sure you want to delete this profile?',
      onConfirm: () async {
        Navigator.of(context).pop(); 

        if (memberId.startsWith('temp_')) {
          setState(() {
            householdMembers.removeAt(index);
          });
        } else {
          try {
            final url = Uri.parse('http://localhost/BFEPS-BDRRMC/api/profiling/delete_member.php');
            final response = await http.post(url, body: {'resident_id': memberId});
            if (response.statusCode == 200) {
              var responseData = json.decode(response.body);
              if (responseData['success'] == true) {
                setState(() {
                  householdMembers.removeAt(index);
                });
                print('Member deleted successfully');
              } else {
                print('Failed to delete member: ${responseData['message']}');
              }
            } else {
              print('Failed to connect to the server');
            }
          } catch (e) {
            print('Error deleting member: $e');
          }
        }
      },
    );
  }

  @override //dispose also the dropdowns
  void dispose() {
    controllers.values.forEach((controller) => controller.dispose());
    for (var member in householdMembers) {
      member['controllers']
          .values
          .forEach((controller) => controller.dispose());
    }
    super.dispose();
  }

  Future<void> _pickImage(TextEditingController profilePictureController) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      Uint8List? webImage;
      File? image;

      if (kIsWeb) {
        webImage = result.files.first.bytes;
      } else {
        image = File(result.files.single.path!);
      }
      String? imageUrl = await _uploadImage(
        file: image,
        webBytes: webImage,
        fileName: result.files.first.name,
      );
      if (imageUrl != null) {
        setState(() {
          profilePictureController.text = imageUrl;  // Set the image URL in the controller
        });
      }
    }
  }

  Future<String?> _uploadImage({File? file, Uint8List? webBytes, required String fileName}) async {
    var request = http.MultipartRequest('POST', Uri.parse('http://localhost/BFEPS-BDRRMC/api/profiling/upload_image.php'));

    if (kIsWeb && webBytes != null) {
        request.files.add(http.MultipartFile.fromBytes('profile_picture', webBytes, filename: fileName));
    } else if (file != null) {
        request.files.add(await http.MultipartFile.fromPath('profile_picture', file.path));
    }

    try {
        var response = await request.send();
        if (response.statusCode == 200) {
            var responseData = await response.stream.bytesToString();
            var jsonData = json.decode(responseData);

            if (jsonData is Map<String, dynamic> && jsonData['success'] == true) {
                print("Image uploaded successfully: ${jsonData['filepath']}");
                return jsonData['filepath'];
            } else {
                print("Image upload failed: ${jsonData['error']}");
            }
        } else {
            print("Server error: ${response.statusCode}");
        }
    } catch (e) {
        print("Error uploading image: $e");
    }
    return null;
}

  Widget _buildProfilePictureSection(TextEditingController profilePictureController) {
    String imageUrl = profilePictureController.text.trim();
    String encodedUrl = Uri.encodeFull(imageUrl); 

    print("Encoded Profile Picture URL: $encodedUrl"); 

    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Stack(
        children: [
          CircleAvatar(
            radius: 90,
            backgroundColor: Colors.white,
            backgroundImage: imageUrl.isNotEmpty
                ? NetworkImage(encodedUrl) as ImageProvider
                : const AssetImage('assets/images/profile-placeholder.png'),
            onBackgroundImageError: (error, stackTrace) {
              print("Image loading error: $error");
            },
          ),
           if (!widget.isViewMode) Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFF1F1F1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: IconButton(
                icon: Icon(
                  imageUrl.isNotEmpty ? Icons.edit : Icons.camera_alt,
                  color: Color(0xFF9E9E9E),
                  size: 25,
                ),
                onPressed: () async {
                  await _pickImage(profilePictureController);
                  setState(() {}); 
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  //Method to calculate age from the date of birth
  int _calculateAge(String birthDate) {
    DateTime birthDateTime = DateTime.parse(birthDate);
    DateTime today = DateTime.now();
    int age = today.year - birthDateTime.year;

    // Check if the birthday has occurred this year
    if (today.month < birthDateTime.month || (today.month == birthDateTime.month && today.day < birthDateTime.day)) {
      age--;
    }
    return age;
  }

  // Update the _buildProfileSection method
  Widget _buildProfileSection(Map<String, TextEditingController> controllers, Map<String, String?> dropdownValues, {VoidCallback? onDelete, bool isHouseholdHead = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfilePictureSection(controllers['profile_picture']!),
            Expanded(
              child: Column(
                children: [
                  _buildRow([
                    FormHelper.buildTextField('Firstname*', controllers['first_name']!, isReadOnly: widget.isViewMode, onChanged: _markDirty),
                    FormHelper.buildTextField('Middlename', controllers['middle_name']!, isReadOnly: widget.isViewMode, onChanged: _markDirty),
                    FormHelper.buildTextField('Lastname*', controllers['last_name']!, isReadOnly: widget.isViewMode, onChanged: _markDirty),
                    FormHelper.buildTextField('Suffix', controllers['suffix']!, isReadOnly: widget.isViewMode, onChanged: _markDirty),
                    FormHelper.buildTextField('Alias', controllers['alias']!, isReadOnly: widget.isViewMode, onChanged: _markDirty),
                  ]),
                  const SizedBox(height: 10),
                  if (isHouseholdHead) ...[
                    _buildRow([
                      FormHelper.buildTextField('Street*', controllers['household_street']!, isReadOnly: widget.isViewMode, onChanged: _markDirty),
                      FormHelper.buildDropdown('Zone*', 'household_zone', zoneOptions, dropdownValues, isReadOnly: widget.isViewMode, onChanged: _markDirty, allowCustomInput: false),
                      FormHelper.buildTextField('Lot No.*', controllers['household_lot']!, isReadOnly: widget.isViewMode, onChanged: _markDirty),
                      FormHelper.buildTextField('Contact Number', controllers['contact_number']!, isReadOnly: widget.isViewMode, onChanged: _markDirty),
                    ]),
                  ] else ...[
                    FormHelper.buildTextField('Contact Number', controllers['contact_number']!, isReadOnly: widget.isViewMode,  onChanged: _markDirty),
                  ],
                  const SizedBox(height: 10),
                  _buildRow([
                    FormHelper.buildDateField(
                      context,
                      controllers['birth_date']!,
                      'Date of Birth*',
                      isReadOnly: widget.isViewMode,
                      isDateTime: false,
                      onChanged: (value) {
                        // Calculate age when date of birth is selected
                        if (value.isNotEmpty) {
                          int age = _calculateAge(value);
                          controllers['age']!.text = age.toString(); // Update the age text field
                        }
                        _markDirty(value); // Mark the form as dirty
                      },
                    ),
                    FormHelper.buildTextField('Age*', controllers['age']!, isReadOnly: true, onChanged: _markDirty), // Make age field read-only
                    FormHelper.buildDropdown('Gender*', 'gender', genderOptions, dropdownValues, isReadOnly: widget.isViewMode, onChanged: (value) {
                      // Check if the selected gender is male or transwoman
                      if (value == 'Male' || value == 'Transwoman') {
                        setState(() {
                          dropdownValues['pregnant'] = 'No'; // Set pregnant field to 'No'
                        });
                      } else {
                        setState(() {
                          dropdownValues['pregnant'] = null; // Reset pregnant field for other genders
                        });
                      }
                      _markDirty(value); 
                    }),
                  ]),
                  const SizedBox(height: 10),
                  _buildRow([
                    FormHelper.buildDropdown('Civil Status*', 'civil_status', civilStatusOptions, dropdownValues, isReadOnly: widget.isViewMode, onChanged: _markDirty),
                    FormHelper.buildDropdown('Religion*', 'religion', religionOptions, dropdownValues, isReadOnly: widget.isViewMode, onChanged: _markDirty),
                  ]),
                  const SizedBox(height: 10),
                  _buildRow([
                    FormHelper.buildDropdown('Education Attainment*', 'education', educationOptions, dropdownValues, isReadOnly: widget.isViewMode, onChanged: _markDirty, allowCustomInput: false),
                    FormHelper.buildDropdown('Occupation*', 'occupation', occupationOptions, dropdownValues, isReadOnly: widget.isViewMode, onChanged: _markDirty, allowCustomInput: true),
                    FormHelper.buildDropdown("4p's Beneficiary*", 'beneficiary', beneficiaryOptions, dropdownValues, isReadOnly: widget.isViewMode, onChanged: _markDirty, allowCustomInput: false),
                  ]),
                  const SizedBox(height: 10),
                  _buildRow([
                    FormHelper.buildDropdown('Pregnant*', 'pregnant', pregnantOptions, dropdownValues, isReadOnly: widget.isViewMode, onChanged: (value) {
                      if (value == 'Yes') {
                        // Store the date of birth when pregnant is selected
                        DateTime birthDate = DateTime.parse(controllers['birth_date']!.text);
                        DateTime nineMonthsLater = DateTime(birthDate.year, birthDate.month + 9, birthDate.day);
                        if (DateTime.now().isAfter(nineMonthsLater)) {
                          setState(() {
                            dropdownValues['pregnant'] = 'No'; // Automatically set to 'No' if 9 months have passed
                          });
                        }
                      } else {
                        setState(() {
                          dropdownValues['pregnant'] = value; // Update the pregnant status
                        });
                      }
                      _markDirty(value);
                    }),
                    FormHelper.buildDropdown('Disability*', 'disability', disabilityOptions, dropdownValues, isReadOnly: widget.isViewMode, onChanged: _markDirty, allowCustomInput: true),
                    FormHelper.buildDropdown('Household Member Type*', 'household_type', householdMemberTypeOptions, dropdownValues, isReadOnly: widget.isViewMode, onChanged: _markDirty, allowCustomInput: false),
                  ]),
                ],
              ),
            ),
            if (!widget.isViewMode) if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete, color: Color(0xFFF55555)),
                onPressed: onDelete,
              ),
          ],
        ),
        const SizedBox(height: 10),
        const Divider(thickness: 1.8, color: Color(0xFFCBCBCB)),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1400,
      height: 840,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFCBCBCB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'HOUSEHOLD DATA FORM',
                  style: TextStyle(
                    color: Color(0xFF5576F5),
                    fontSize: 24,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                _buildFormContainer(),
                const SizedBox(height: 15), 
                _buildHouseholdDetailsSection(dropdownValues),
              ],
            ),
          ),
          _buildCloseButton(),
          if (!widget.isViewMode) _buildSaveButton(),
          if (widget.isViewMode) _buildUpdateButton(),
        ],
      ),
    );
  }

  Widget _buildFormContainer() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCCCCCC), width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      height: 600,
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: Column(
          children: [
            // Household Head
            _buildProfileSection(controllers, dropdownValues, isHouseholdHead: true),
            // Household Members
            ...householdMembers.asMap().entries.map((entry) =>
              _buildProfileSection(
                entry.value['controllers'],
                entry.value['dropdownValues'],
                onDelete: () => _deleteHouseholdMember(entry.key),
                isHouseholdHead: false, 
              ),
            ),
             if (!widget.isViewMode) Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.add, color: Color(0xFF9E9E9E)),
                onPressed: _addHouseholdMember,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHouseholdDetailsSection(Map<String, String?> dropdownValues) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRow([
          FormHelper.buildDropdown('Construction Materials Used*', 'material_used', constructionMaterialOptions, dropdownValues, isReadOnly: widget.isViewMode, onChanged: _markDirty, allowCustomInput: false ),
          FormHelper.buildDropdown('Toilet Facility*', 'toilet_facility', toiletFacilityOptions, dropdownValues, isReadOnly: widget.isViewMode, onChanged: _markDirty, allowCustomInput: false),
          FormHelper.buildDropdown('Means of Communication*', 'means_of_communication', meansOfCommunicationOptions, dropdownValues, isReadOnly: widget.isViewMode, onChanged: _markDirty, allowCustomInput: false),
          FormHelper.buildDropdown('Source of Water*', 'source_of_water', sourceOfWaterOptions, dropdownValues, isReadOnly: widget.isViewMode, onChanged: _markDirty),
        ]),
        const SizedBox(height: 10),
        _buildRow([
          FormHelper.buildDropdown('Electricity*', 'electricity', electricityOptions, dropdownValues, isReadOnly: widget.isViewMode, onChanged: _markDirty, allowCustomInput: false),
          FormHelper.buildDropdown('HH with..*', 'household_with', hhWithOptions, dropdownValues, isReadOnly: widget.isViewMode, onChanged: _markDirty, allowCustomInput: false),
          FormHelper.buildDropdown('Family Income*', 'family_income', familyIncomeOptions, dropdownValues, isReadOnly: widget.isViewMode, onChanged: _markDirty, allowCustomInput: false),
        ]),
        const SizedBox(height: 10),
        if (widget.existingData != null)
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormHelper.buildTimestamp('Created At:', widget.existingData!['household_created_at']),
              FormHelper.buildTimestamp('Updated At:', widget.existingData!['household_updated_at']),
            ],
          ),
        ),
      ],
    );
  }
   
  Widget _buildCloseButton() {
    return Positioned(
      top: 8,
      right: 8,
      child: IconButton(
        icon: const Icon(Icons.close, color: Color(0xFF9E9E9E)),
        onPressed: () {
          if (_isDirty) {
            ValidationDialog.showDiscardChangesDialog(
              context: context,
              onDiscard: () {
                Navigator.of(context).pop(); 
                Navigator.of(context).pop();
              },
            );
          } else {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

  Widget _buildUpdateButton() {
    return Positioned(
      bottom: 24,
      right: 25,
      child: UpdateButton(
        onPressed: () {
          setState(() {
            widget.isViewMode = false; 
          });
        },
        label: 'Edit', 
      ),
    );
  }

  Widget _buildSaveButton() {
    return Positioned(
      bottom: 24,
      right: 25,
      child: SaveButton(
        onPressed: () {
          _saveData(context);
        },
        label: 'Save',
      ),
    );
  }

  Widget _buildRow(List<Widget> children) {
    return Row(
      children: children
          .expand(
              (widget) => [Expanded(child: widget), const SizedBox(width: 8)])
          .toList()
        ..removeLast(),
    );
  }

  String toCamelCase(String input) {
    if (input.isEmpty) return input;
    return input.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
  
  Future<void> _saveData(BuildContext context) async {
    // Required fields for validation
    List<String> requiredControllers = ['first_name', 'last_name', 'birth_date', 'age'];
    List<String> requiredDropdowns = [
        'civil_status', 'religion', 'gender', 'education', 
        'occupation', 'beneficiary', 'pregnant', 
        'disability', 'household_type'
    ];
    List<String> requiredHouseholdFields = [
        'household_street', 'household_zone', 'household_lot', 'material_used', 
        'toilet_facility', 'means_of_communication', 
        'source_of_water', 'electricity', 'household_with', 'family_income'
    ];

    bool hasError = false;
    String errorMessage = "";

    // Validation logic
    for (var field in requiredHouseholdFields) {
      if (controllers.containsKey(field) && controllers[field]!.text.trim().isEmpty) {
        hasError = true;
        errorMessage = "Please fill in all required household details.";
        break;
      }
      if (dropdownValues.containsKey(field) && (dropdownValues[field] == null || dropdownValues[field].toString().trim().isEmpty)) {
        hasError = true;
        errorMessage = "Please select all required household options.";
        break;
      }
    }

    for (var field in requiredControllers) {
      if (controllers[field]!.text.trim().isEmpty) {
        hasError = true;
        errorMessage = "Please fill in all fields marked with an asterisk *";
        break;
      }
    }

    for (var field in requiredDropdowns) {
      if (dropdownValues[field] == null || dropdownValues[field].toString().trim().isEmpty) {
        hasError = true;
        errorMessage = "Please select all required personal details.";
        break;
      }
    }

    for (var member in householdMembers) {
      for (var field in requiredControllers) {
        if (member['controllers'][field]!.text.trim().isEmpty) {
            hasError = true;
            errorMessage = "Please fill in all required details for household members.";
            break;
        }
      }
      for (var field in requiredDropdowns) {
        if (member['dropdownValues'][field] == null || member['dropdownValues'][field].toString().trim().isEmpty) {
          hasError = true;
          errorMessage = "Please select all required options for household members.";
          break;
        }
      }
    }

    if (hasError) {
      ValidationDialog.showErrorDialog(context, errorMessage);
      return;
    }

    // Prepare the data for saving
    var data = {
      'household_id': widget.existingData?['household_id'], 
      'household_street': toCamelCase(controllers['household_street']!.text),
      'household_zone': dropdownValues['household_zone'],
      'household_lot': controllers['household_lot']!.text,
      'material_used': dropdownValues['material_used'],
      'toilet_facility': dropdownValues['toilet_facility'],
      'means_of_communication': dropdownValues['means_of_communication'],
      'source_of_water': dropdownValues['source_of_water'],
      'electricity': dropdownValues['electricity'],
      'household_with': dropdownValues['household_with'],
      'family_income': dropdownValues['family_income'],
      'residents': [
        // Household head
        {
          'id': widget.existingData?['residents'][0]['resident_id'], 
          'profile_picture': controllers['profile_picture']!.text,
          'first_name': toCamelCase(controllers['first_name']!.text),
          'middle_name': toCamelCase(controllers['middle_name']!.text),
          'last_name': toCamelCase(controllers['last_name']!.text),
          'suffix': toCamelCase(controllers['suffix']!.text),
          'alias': toCamelCase(controllers['alias']!.text),
          'contact_number': controllers['contact_number']!.text,
          'civil_status': dropdownValues['civil_status'],
          'religion': dropdownValues['religion'],
          'birth_date': controllers['birth_date']!.text,
          'age': controllers['age']!.text, 
          'gender': dropdownValues['gender'],
          'education': dropdownValues['education'],
          'occupation': dropdownValues['occupation'],
          'beneficiary': dropdownValues['beneficiary'],
          'pregnant': dropdownValues['pregnant'],
          'disability': dropdownValues['disability'],
          'household_type': dropdownValues['household_type'],
        },
        // Household Members
        ...householdMembers.map((member) {    
            return {
              'id': member['resident_id'], // Ensure resident_id is included for each member
              'profile_picture': member['controllers']['profile_picture']!.text,
              'first_name': toCamelCase(member['controllers']['first_name']!.text),
              'middle_name': toCamelCase(member['controllers']['middle_name']!.text),
              'last_name': toCamelCase(member['controllers']['last_name']!.text),
              'suffix': toCamelCase(member['controllers']['suffix']!.text),
              'alias': toCamelCase(member['controllers']['alias']!.text),
              'contact_number': member['controllers']['contact_number']!.text,
              'civil_status': member['dropdownValues']['civil_status'],
              'religion': member['dropdownValues']['religion'],
              'birth_date': member['controllers']['birth_date']!.text,
              'age': member['controllers']['age']!.text,
              'gender': member['dropdownValues']['gender'],
              'education': member['dropdownValues']['education'],
              'occupation': member['dropdownValues']['occupation'],
              'beneficiary': member['dropdownValues']['beneficiary'],
              'pregnant': member['dropdownValues']['pregnant'],
              'disability': member['dropdownValues']['disability'],
              'household_type': member['dropdownValues']['household_type'],
            };
        }).toList(),
      ]
    };

    // Log the state of the input fields before the API call
    print("Input Field States:");
    controllers.forEach((key, controller) {
        print("$key: ${controller.text}");
    });
    dropdownValues.forEach((key, value) {
        print("$key: $value");
    });
    print("Household Members: $householdMembers");
    
    // Print the data being sent to the API
    print("Data being sent to the API: ${json.encode(data)}");

    // Determine the URL based on whether it's an update or a new record
    var url = widget.isUpdateMode 
        ? Uri.parse('http://localhost/BFEPS-BDRRMC/api/profiling/update_hhdata.php') // Update URL
        : Uri.parse('http://localhost/BFEPS-BDRRMC/api/profiling/save_hhdata.php'); // Save URL

    var response = await http.post(url, body: json.encode(data), headers: {"Content-Type": "application/json"});

    if (response.statusCode == 200) {
        var responseData = json.decode(response.body);        
        if (responseData['success'] == true) {
            // Clear the controllers and dropdown values
            controllers.forEach((key, controller) => controller.clear());
            dropdownValues.forEach((key, value) => dropdownValues[key] = null);
            householdMembers.clear();

            print('Data saved successfully');

            // Call the onSave callback to refresh records
            widget.onSave(data); // Call the callback here
        
            // Show success dialog
            ValidationDialog.showSuccessDialog(
                context,
                "Data saved successfully!",
                () {
                    Navigator.pop(context); // Close the dialog
                    Navigator.pop(context); // Close the form dialog
                }
            );
            // Debugging: Check if the state is updated
              print("State updated with new data: $data");
        } else {
            // Handle the case where the response indicates failure
            ValidationDialog.showErrorDialog(context, "Error: ${responseData['message']}");
        }
    } else {
        ValidationDialog.showErrorDialog(context, "Failed to connect to the server");
    }
  }
}
