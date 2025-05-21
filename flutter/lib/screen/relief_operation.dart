// ignore_for_file: file_names, must_be_immutable, avoid_print
import 'dart:io';
import 'dart:typed_data';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import '../constants/dropdown_options.dart';
import '../dialogs/validation_dialog.dart';
import '../widgets/buttons/add_button.dart';
import '../widgets/buttons/print_button.dart';
import '../widgets/buttons/save_button.dart';
import '../widgets/buttons/update_button.dart';
import '../widgets/context/form.dart';
import '../widgets/context/table.dart';
import '../widgets/search_bar.dart' as custom;
import 'package:http/http.dart' as http;

class ReliefOperationPage extends StatefulWidget {
  const ReliefOperationPage({super.key});

  @override
  ReliefOperationPageState createState() => ReliefOperationPageState();
}

class ReliefOperationPageState extends State<ReliefOperationPage> {

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
      final url = Uri.parse('http://localhost/BFEPS-BDRRMC/api/rop/get_report.php'); 
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        print('Fetched data: $data'); // Debug print
        setState(() {
          _allRecords = List<Map<String, dynamic>>.from(data);
          // Sort records by date in descending order
          _allRecords.sort((a, b) => DateTime.parse(b['report_date']).compareTo(DateTime.parse(a['report_date'])));
        });
      } else {
        throw Exception('Failed to load records');
      }
    } catch (e) {
      print('Error fetching records: $e');
    }
  }

  void _deleteReport(String id) async {
    ValidationDialog.showDeleteDialog(
      context: context, 
      message: 'Are you sure you want to delete this report?',
      onConfirm: () async {
        Navigator.of(context).pop(); 
        try {
          final url = Uri.parse('http://localhost/BFEPS-BDRRMC/api/rop/delete_report.php');
          final response = await http.post(url, body: {'id': id});
          if (response.statusCode == 200) {
            var responseData = json.decode(response.body);
            if (responseData['success'] == true) {
              // Refresh reports
              await _fetchRecords();
              print('Report deleted successfully');
            } else {
              print('Failed to delete report: ${responseData['message']}');
            }
          } else {
            print('Failed to connect to the server');
          }
        } catch (e) {
          print('Error deleting report: $e');
        }
      },
    );
  }

  List<Map<String, dynamic>> _getPaginatedRecords() {
    String normalizedQuery = _searchQuery.trim().toLowerCase().replaceAll(',', '');

    List<String> queryWords = normalizedQuery.split(RegExp(r'\s+'));

    List<Map<String, dynamic>> filteredRecords = _allRecords.where((report) {

      String fullName = "${report['donor_name'] ?? ''}"
          .replaceAll(',', '')
          .trim()
          .toLowerCase();

      String itemName = "${report['item_name'] ?? ''}"
          .replaceAll(',', '')
          .trim()
          .toLowerCase();

      String date = "${report['report_date'] ?? ''}".trim().toLowerCase(); 

      bool nameMatches = queryWords.every((word) => fullName.contains(word));
      bool itemnameMatches = queryWords.every((word) => itemName.contains(word));
      bool dateMatches = queryWords.every((word) => date.contains(word));

      return nameMatches || itemnameMatches || dateMatches;
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
        .where((report) =>
            report['report_date'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            report['donor_name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            report['item_name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()))
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
                  label: 'Add Report',
                  onPressed: () {
                    _showReliefForm(context, null, isViewMode: false);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildIndividualTable(),
            const SizedBox(height: 20), 
            _buildPagination(),
          ],
        ),
      ),
    );
  }

  Widget _buildIndividualTable() {
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
          const HeaderCellWidget(label: 'Date', flex: 2),
          const HeaderCellWidget(label: 'Donor Name', flex: 3),
          const HeaderCellWidget(label: 'Item Name', flex: 2),
          const HeaderCellWidget(label: 'Kind/Type', flex: 2, center: true),
          const HeaderCellWidget(label: 'Unit Measure', flex: 2, center: true),
          const HeaderCellWidget(label: 'Qty', flex: 1, center: true),
          const HeaderCellWidget(label: 'Tot. Cost', flex: 2, center: true),
          const HeaderCellWidget(label: 'Beneficiaries', flex: 2, center: true),
          const HeaderCellWidget(label: 'Distribution Process', flex: 3, center: true),
          const HeaderCellWidget(label: 'Venue', flex: 2, center: true),
          const HeaderCellWidget(label: 'Remarks', flex: 3, center: true),
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
        final report = paginatedRecords[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFCCCCCC))),
          ),
          child: Row(
            children: [ 
              DataCellWidget(value: report['report_date'] ?? '', flex: 2),
              DataCellWidget(value: report['donor_name'] ?? '', flex: 3),
              DataCellWidget(value: report['item_name'] ?? '', flex: 2),
              DataCellWidget(value: report['donated_type'] ?? '', flex: 2, center: true),
              DataCellWidget(value: report['measure'] ?? '', flex: 2, center: true),
              DataCellWidget(value: report['quantity'] ?? '', flex: 1, center: true),
              DataCellWidget(value: '₱''${report['cost'] ?? ''}', flex: 2, center: true),
              DataCellWidget(value: report['beneficiaries'] ?? '', flex: 2, center: true),
              DataCellWidget(value: report['process'] ?? '', flex: 3, center: true),
              DataCellWidget(value: report['venue'] ?? '', flex: 2, center: true),
              DataCellWidget(value: report['remarks'] ?? '', flex: 3, center: true),
              Expanded(
                flex: 1,
                child: Center(
                  child: PopupMenuWidget(
                    onSelected: (value) {
                      if (value == 'View') {
                        _showReliefForm(context, report, isViewMode: true);
                      } else if (value == 'Update') {
                        _showReliefForm(context, report, isViewMode: false);
                      } else if (value == 'Delete') {
                        _deleteReport(report['id']);
                      }
                    },
                    showEvacuationCenter: false, // Set to true or false based on your requirement
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }           

  void _showReliefForm(BuildContext context, Map<String, dynamic>? existingData, {bool isViewMode = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ReliefReportForm(
            onSave: (newRecord) {
              setState(() {
                // Update the existing record in _allRecords
                if (existingData != null) {
                  int index = _allRecords.indexWhere((record) => record['id'] == existingData['id']);
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
            isUpdateMode: existingData != null,
          ),
        );
      },
    );
  }
}

class ReliefReportForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave; 
  final Map<String, dynamic>? existingData; 
  bool isViewMode;
  final bool isUpdateMode;

  ReliefReportForm({super.key, 
    required this.onSave, 
    this.existingData, 
    this.isViewMode = false,  
    this.isUpdateMode = false
  }); 

  @override
  ReliefReportFormState createState() => ReliefReportFormState();
}

class ReliefReportFormState extends State<ReliefReportForm> {
  bool _isDirty = false; // Track if the form is dirty
  // Existing controllers
  final TextEditingController dateController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController inameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController costController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  final TextEditingController picturesController = TextEditingController();


  List<TextEditingController> picturesControllers = [TextEditingController()];


  // Existing dropdown variables
  String? selectedType;
  String? selectedMeasure;
  String? selectedBeneficiaries;
  String? selectedProcess;
  String? selectedVenue;

  @override
  void initState() {
    super.initState();
    if (widget.existingData != null) {
      // Populate the fields with existing data if available
      dateController.text = widget.existingData!['report_date'] ?? '';
      nameController.text = widget.existingData!['donor_name'] ?? '';
      inameController.text = widget.existingData!['item_name'] ?? '';
      quantityController.text = widget.existingData!['quantity'] ?? '';
      costController.text = widget.existingData!['cost'] ?? '';
      selectedBeneficiaries = widget.existingData!['beneficiaries'];
      selectedType = widget.existingData!['donated_type'];
      selectedMeasure = widget.existingData!['measure'];
      selectedProcess = widget.existingData!['process'];
      selectedVenue = widget.existingData!['venue'];
      remarksController.text = widget.existingData!['remarks'] ?? '';
      picturesController.text = widget.existingData!['pictures'] ?? '';
    }
  }

  void _markDirty(String value) {
    setState(() {
      _isDirty = true;
    });
  }

  Future<void> _pickImage(TextEditingController picturesController) async {
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
          picturesController.text = imageUrl;  // Set the image URL in the controller
        });
      }
    }
  }

  Future<String?> _uploadImage({File? file, Uint8List? webBytes, required String fileName}) async {
    var request = http.MultipartRequest('POST', Uri.parse('http://localhost/BFEPS-BDRRMC/api/profiling/upload_image.php'));

    if (kIsWeb && webBytes != null) {
        request.files.add(http.MultipartFile.fromBytes('pictures', webBytes, filename: fileName));
    } else if (file != null) {
        request.files.add(await http.MultipartFile.fromPath('pictures', file.path));
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

Widget _buildPicturesSection() {
  return Padding(
    padding: const EdgeInsets.only(right: 20),
    child: Row(
      children: [
        ...picturesControllers.map((controller) {
          String imageUrl = controller.text.trim();
          String encodedUrl = Uri.encodeFull(imageUrl);

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[200],
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            encodedUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print("Image loading error: $error");
                              return Container(color: Colors.grey[300]);
                            },
                          )
                        : null,
                  ),
                ),
                if (!widget.isViewMode)
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F1F1),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: IconButton(
                          icon: Icon(
                            imageUrl.isNotEmpty ? Icons.edit : Icons.camera_alt,
                            color: const Color(0xFF9E9E9E),
                            size: 25,
                          ),
                          onPressed: () async {
                            await _pickImage(controller);
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),

        if (!widget.isViewMode && picturesControllers.length < 5)
          GestureDetector(
            onTap: () {
              setState(() {
                picturesControllers.add(TextEditingController());
              });
            },
          child: DottedBorder(
            borderType: BorderType.RRect,
            radius: const Radius.circular(15),
            dashPattern: [6, 4], // 6 pixels dash, 4 pixels gap
            color: Colors.grey,
            strokeWidth: 1,
            child: Container(
              width: 100,
              height: 100,
              alignment: Alignment.center,
              child: const Icon(Icons.add, size: 30, color: Colors.grey),
            ),
          ),
          ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 800,
      height: 620,
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
                  'RELIEF REPORT FORM',
                  style: TextStyle(
                    color: Color(0xFF5576F5),
                    fontSize: 24,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                _buildForm({
                  'selectedType': selectedType,
                  'selectedMeasure': selectedMeasure,
                  'selectedBeneficiaries': selectedBeneficiaries,
                  'selectedProcess': selectedProcess,
                  'selectedVenue': selectedVenue,
                })
              ],
            ),
          ),
          _buildCloseButton(),
          if (!widget.isViewMode) _buildSaveButton(), 
          if (widget.isViewMode) _buildUpdateButton(),
          if (widget.isViewMode) _buildPrintButton(),
        ],
      ),
    );
  }

Widget _buildForm(Map<String, String?> dropdownValues) {
  return Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRow([
          FormHelper.buildDateField(context, dateController, 'Date*', isReadOnly: widget.isViewMode, isDateTime: false, onChanged: _markDirty),
        ]),
        const SizedBox(height: 10),
        _buildRow([
          FormHelper.buildTextField('Name of Donor*', nameController, isReadOnly: widget.isViewMode, onChanged: _markDirty),
          FormHelper.buildTextField('Name of Item*', inameController, isReadOnly: widget.isViewMode, onChanged: _markDirty),
        ]),
        const SizedBox(height: 10),
        _buildRow([
          FormHelper.buildDropdown('Kind/Type*', 'selectedType', kindOptions, dropdownValues, isReadOnly: widget.isViewMode,
            onChanged: widget.isViewMode ? null : (newValue) {
              setState(() {
                selectedType = newValue;
                _isDirty = true;
              });
            },
            allowCustomInput: false
          ),
          FormHelper.buildDropdown('Unit Measure*', 'selectedMeasure', unitMeasureOptions, dropdownValues, isReadOnly: widget.isViewMode,
            onChanged: widget.isViewMode ? null : (newValue) {
              setState(() {
                selectedMeasure = newValue;
                _isDirty = true;
              });
            },
            allowCustomInput: false
          ),
        ]),
        const SizedBox(height: 10),
        _buildRow([
          FormHelper.buildTextField('Quantity*', quantityController, isReadOnly: widget.isViewMode, onChanged: _markDirty),
          FormHelper.buildTextField('Total Cost*', costController, isReadOnly: widget.isViewMode, onChanged: _markDirty),
          FormHelper.buildDropdown( 'Beneficiaries*', 'selectedBeneficiaries', beneficiariesOptions, dropdownValues, isReadOnly: widget.isViewMode,
            onChanged: widget.isViewMode ? null : (newValue) {
              setState(() {
                selectedBeneficiaries = newValue;
                _isDirty = true;
              });
            },
            allowCustomInput: false
          ),
        ]),
        const SizedBox(height: 10),
        _buildRow([
          FormHelper.buildDropdown('Distribution Process*', 'selectedProcess', distributionProcessOptions, dropdownValues, isReadOnly: widget.isViewMode,
            onChanged: widget.isViewMode ? null : (newValue) {
              setState(() {
                selectedProcess = newValue;
                _isDirty = true;
              });
            },
            allowCustomInput: false
          ),
          FormHelper.buildDropdown('Venue*', 'selectedVenue', venueOptions, dropdownValues, isReadOnly: widget.isViewMode,
            onChanged: widget.isViewMode ? null : (newValue) {
              setState(() {
                selectedVenue = newValue;
                _isDirty = true;
              });
            },
            allowCustomInput: false
          ),
        ]),
        const SizedBox(height: 10),
        _buildRow([
          FormHelper.buildTextField('Remarks*', remarksController, isReadOnly: widget.isViewMode, height: 150, onChanged: _markDirty),
        ]),
        const SizedBox(height: 10),
        _buildRow([
          _buildPicturesSection(),
        ]),
      ],
    ),
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

  Widget _buildSaveButton() {
    return Positioned(
      bottom: 14,
      right: 25,
      child: SaveButton(
        onPressed: () {
          _saveData(context);
        },
        label: 'Save',
      ),
    );
  }

  Widget _buildPrintButton() {
    return Positioned(
      bottom: 14,
      right: 25, 
      child: PrintButton(
        onPressed: () {
          print('Print button pressed');
          // add package nalang to handle actual printing
        },
        label:  'Print',
      ),
    );
  }

  Widget _buildUpdateButton() {
    return Positioned(
      bottom: 14,
      right: 115,
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
    if (dateController.text.isNotEmpty &&
        nameController.text.isNotEmpty &&
        inameController.text.isNotEmpty &&
        selectedType != null &&
        selectedMeasure != null &&
        quantityController.text.isNotEmpty &&
        costController.text.isNotEmpty &&
        selectedBeneficiaries != null &&
        selectedProcess != null &&
        selectedVenue != null &&
        remarksController.text.isNotEmpty &&
        picturesController.text.isNotEmpty) {
      try {
        final data = {
          'id': widget.existingData?['id'], 
          'report_date': dateController.text,
          'donor_name': toCamelCase(nameController.text),
          'item_name': toCamelCase(inameController.text),
          'donated_type': selectedType,
          'measure': selectedMeasure,
          'quantity': quantityController.text,
          'cost': costController.text,
          'beneficiaries': selectedBeneficiaries,
          'process': selectedProcess,
          'venue': selectedVenue,
          'remarks': toCamelCase(remarksController.text),
          'pictures': picturesControllers.map((controller) => controller.text).toList(),
        };

        var url = widget.isUpdateMode 
            ? Uri.parse('http://localhost/BFEPS-BDRRMC/api/rop/update_report.php') 
            : Uri.parse('http://localhost/BFEPS-BDRRMC/api/rop/save_report.php');

        var response = await http.post(url, body: json.encode(data), headers: {"Content-Type": "application/json"});
        // Log the response for debugging
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        var responseBody = jsonDecode(response.body);
        if (response.statusCode == 200 && responseBody["success"] == true) {
          print('Data saved successfully');

          // Call the onSave callback to update the records in the parent widget
          widget.onSave(data); // Pass the new data to the parent

          // Clear the form fields
          setState(() {
            dateController.clear();
            nameController.clear();
            inameController.clear();
            quantityController.clear();
            costController.clear();
            selectedBeneficiaries = null;
            selectedType = null;
            selectedMeasure = null;
            selectedProcess = null;
            selectedVenue = null;
            remarksController.clear();
            picturesControllers.clear();
          });

          // Show success dialog
          ValidationDialog.showSuccessDialog(
            context,
            'Data saved successfully!',
            () {
              Navigator.pop(context); // Close success dialog
              Navigator.pop(context); // Close form
            },
          );
        } else {
          print('Failed to save data: ${response.body}');
          ValidationDialog.showErrorDialog(context, 'Failed to save data. Please try again.');
        }
      } catch (e) {
        print('Error: $e');
        ValidationDialog.showErrorDialog(context, 'An error occurred. Please try again later.');
      }
    } else {
      ValidationDialog.showErrorDialog(context, 'Please fill in all fields marked with an asterisk *');
    }
  }
}
