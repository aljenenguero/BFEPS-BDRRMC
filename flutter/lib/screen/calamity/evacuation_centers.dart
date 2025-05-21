import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../constants/dropdown_options.dart';
import '../../dialogs/validation_dialog.dart';
import '../../screen/calamity/evacuees.dart';
import '../../widgets/buttons/add_button.dart';
import '../../widgets/buttons/save_button.dart';
import '../../widgets/context/form.dart'; // Import Form Helper

class Evacuationcenters extends StatefulWidget {
  final Map<String, dynamic> calamity;

  const Evacuationcenters({Key? key, required this.calamity}) : super(key: key);

  @override
  _EvacuationcentersState createState() => _EvacuationcentersState();
}

class _EvacuationcentersState extends State<Evacuationcenters> {
  List<Map<String, dynamic>> _allRecords = [];

  @override
  void initState() {
    super.initState();
    _fetchEvacuationCenters();
  }
    
  void onMenuSelect(String label, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  Future<void> _fetchEvacuationCenters() async {
    try {
      final calamityName = widget.calamity['calamity_name']; // Get calamity_name from passed data
      final encodedName = Uri.encodeComponent( calamityName); // Encode for safe URL usage

      final response = await http.get(Uri.parse('http://localhost/evc/api/evacuation/get_evacuationcenters.php?calamity_name=$encodedName'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _allRecords = List<Map<String, dynamic>>.from(data);
        });
      } else {
        print('Failed to load evacuation centers');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void _showEvacuationForm(
    BuildContext context,
    Map<String, dynamic>? existingData, {
    bool isViewMode = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              EvacuationForm(
                onSave: (newRecord) {
                  _fetchEvacuationCenters(); // Fetch again after saving
                },
                existingData: existingData,
                isViewMode: isViewMode,
                isUpdateMode: existingData != null,
                calamity: widget.calamity,
              ),
              Positioned(top: 10, right: 10, child: _buildCloseButton(context)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.close, color: Color(0xFF9E9E9E)),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      body: Stack(
        children: [
          Positioned(
            top: 70,
            right: 220,
            child: Container(
              width: 1490,
              height: 283,
              padding: const EdgeInsets.only(left: 30, top: 25),
              decoration: BoxDecoration(
                color: const Color(0xFFEAEFFF),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x40000000),
                    blurRadius: 2,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Row(
                // 🔄 CHANGED to Row
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 👈 LEFT side: EC Information Board texts
                  Container(
                    width: 300,
                    padding: const EdgeInsets.only(left: 30, top: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.calamity['calamity_name']?.toUpperCase() ??
                              "UNKNOWN CALAMITY",
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF5576F5),
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "EC Information Board",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF5576F5),
                          ),
                        ),
                      ],
                    ),
                  ),

                   const SizedBox(width: 40), // space between text and charts
                  // 👉 RIGHT side: Graph containers, centered vertically
                  Container(
                    margin: const EdgeInsets.only(right: 30),
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center, // ✅ Center vertically
                      children: [
                        Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(
                                right: 30,
                                bottom: 5,
                              ),
                              alignment:
                                  Alignment
                                      .center, // centers vertically in parent container
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 520,
                                    height: 251,
                                    margin: const EdgeInsets.only(right: 20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 0),
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "Bar Graph Placeholder",
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 520,
                                    height: 251,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 0),
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "Pie Graph Placeholder",
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 370,
            right: 220,
            child: Container(
              width: 1490,
              height: 558,
              padding: const EdgeInsets.only(left: 30, top: 25, right: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x40000000),
                    blurRadius: 2,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Evacuation Center List",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF9E9E9E),
                        ),
                      ),
                      AddButton(
                        label: "Add Evacuation Center",
                        onPressed: () {
                          _showEvacuationForm(context, null);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Divider(color: Color(0xFFDDDDDD), thickness: 1),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child:
                        _allRecords.isEmpty
                            ? const Center(
                              child: Text("No evacuation centers added yet."),
                            )
                            : SingleChildScrollView(
                              // ADDED: Makes card list scrollable
                              child: Wrap(
                                spacing: 20, // Horizontal space between cards
                                runSpacing: 20, // Vertical space between rows
                                children:
                                    _allRecords.map((record) {
                                      return MouseRegion(
                                        cursor:
                                            SystemMouseCursors
                                                .click, // 👈 change to pointing hand
                                        child: GestureDetector(
                                          onTap: () {
                                            onMenuSelect(
                                                'Evacuation Center',
                                            EvacueesPage(centerData: record, // Pass data if needed),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            width: 338,
                                            height: 133,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.25),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 0),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  record['evacuation_centername'] ??
                                                      'Unknown Center',
                                                  style: const TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF4B4B4B),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  "Zone ${record['zone'] ?? ''}",
                                                  style: const TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w400,
                                                    color: Color(0xFF4B4B4B),
                                                  ),
                                                ),
                                                Text(
                                                  record['evacuation_type'] ??
                                                      '',
                                                  style: const TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w400,
                                                    color: Color(0xFF4B4B4B),
                                                  ),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  record['contact_person'] ??
                                                      '',
                                                  style: const TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: Color(0xFF4B4B4B),
                                                  ),
                                                ),
                                                Text(
                                                  record['contact_number'] ??
                                                      '',
                                                  style: const TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: Color(0xFF4B4B4B),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Evacuation Form
// ignore: must_be_immutable
class EvacuationForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final Map<String, dynamic> calamity;
  final Map<String, dynamic>? existingData;
  final bool isUpdateMode;
  bool isViewMode;

  EvacuationForm({
    super.key,
    required this.onSave,
    required this.calamity, 
    this.existingData,
    this.isViewMode = false,
    this.isUpdateMode = false,
  });

  @override
  EvacuationFormState createState() => EvacuationFormState();
}

class EvacuationFormState extends State<EvacuationForm> {
  final TextEditingController contactController = TextEditingController();

  String? selectedEvacuationCenterName;
  String? selectedZone;
  String? selectedEvacuationType;
  String? selectedContactPerson;

  @override
  void initState() {
    super.initState();
    if (widget.existingData != null) {
      selectedEvacuationCenterName =
          widget.existingData!['evacuation_centername'];
      selectedZone = widget.existingData!['zone'];
      selectedContactPerson = widget.existingData!['contact_person'];
      contactController.text = widget.existingData!['contact_number'] ?? '';
      _setEvacuationType(selectedEvacuationCenterName);
    }
  }

  void _setEvacuationType(String? value) {
    setState(() {
      selectedEvacuationCenterName = value;
      selectedEvacuationType =
          (value == "School" || value == "Barangay Hall")
              ? "Public EC"
              : "Private EC";
    });
  }

  Future<void> _saveData() async {
    if (selectedEvacuationCenterName == null ||
        selectedZone == null ||
        selectedContactPerson == null ||
        contactController.text.isEmpty) {
      ValidationDialog.showErrorDialog(
        context,
        "Please fill out all required fields.",
      );
      return;
    }

    final newData = {
      'evacuation_centername': selectedEvacuationCenterName,
      'zone': selectedZone,
      'evacuation_type': selectedEvacuationType,
      'contact_person': selectedContactPerson,
      'contact_number': contactController.text,
      'calamity_name': widget.calamity['calamity_name'],
    };

    try {
      final response = await http.post(
        Uri.parse(
          'http://localhost/evc/api/evacuation/save_evacuationcenter.php',
        ),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(newData),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success']) {
          ValidationDialog.showSuccessDialog(
            context,
            body['message'] ?? "Saved Successfully!",
            () {
              Navigator.pop(context);
              widget.onSave(newData);
            },
          );
        } else {
          ValidationDialog.showErrorDialog(
            context,
            body['message'] ?? "Failed to save.",
          );
        }
      } else {
        ValidationDialog.showErrorDialog(
          context,
          "Failed to connect to server.",
        );
      }
    } catch (e) {
      ValidationDialog.showErrorDialog(context, "An error occurred. $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 800,
      height: 400,
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
                  'EVACUATION CENTER FORM',
                  style: TextStyle(
                    color: Color(0xFF5576F5),
                    fontSize: 24,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // FormHelper.buildDropdown("Name of Evacuation Center*", 'evacuationCentersNameOptions',
                //   _setEvacuationType,
                //   initialValue: selectedEvacuationCenterName,
                // ),
                // FormHelper.buildTextField(
                //   "Type of Evacuation Center*",
                //   TextEditingController(text: selectedEvacuationType ?? ''),
                //   isReadOnly: true,
                // ),
                // FormHelper.buildDropdown(
                //   "Zone No.*",
                //   zoneNumbers,
                //   (value) => setState(() => selectedZone = value),
                //   initialValue: selectedZone,
                // ),
                // FormHelper.buildDropdown(
                //   "Contact Person*",
                //   contactPerson,
                //   (value) => setState(() => selectedContactPerson = value),
                //   initialValue: selectedContactPerson,
                // ),
                FormHelper.buildTextField(
                  "Contact Number*",
                  contactController,
                  isReadOnly: false,
                ),
                SaveButton(label: "Save", onPressed: _saveData),
              ],
            ),
          ),
        ],
      ),
    );
  }
}