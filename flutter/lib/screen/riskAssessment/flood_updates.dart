import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../dialogs/validation_dialog.dart';
import '../../widgets/buttons/add_button.dart';
import '../../widgets/buttons/save_button.dart';

class FloodUpdatesPage extends StatefulWidget {
  const FloodUpdatesPage({super.key});

  @override
  _FloodUpdatesPageState createState() => _FloodUpdatesPageState();
}

class _FloodUpdatesPageState extends State<FloodUpdatesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7F9),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AddButton(
                  label: 'Add Update',
                  onPressed: () {
                    _showUpdateForm(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildBlank(context),
          ],
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchReports() async {
    try {
      final url = Uri.parse('http://127.0.0.1/rareportdb/get_update.php');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> update = json.decode(response.body);
        return List<Map<String, dynamic>>.from(update);
      } else {
        throw Exception('Failed to load reports');
      }
    } catch (e) {
      print('Error fetching reports: $e');
      return [];
    }
  }

  Widget _buildBlank(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchReports(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmpty(); // Show "No Reports available."
        }

        return _buildListWithData(context, snapshot.data!);
      },
    );
  }

  Widget _buildEmpty() {
    return Container(
      width: double.infinity,
      height: 730,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFCCCCCC)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Center(
              child: Text(
                'No Update(s) available.',
                style: TextStyle(
                  color: Color(0xFFCBCBCB),
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showUpdateForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: FloodUpdateForm(),
        );
      },
    );
  }

  Widget _buildListWithData(
      BuildContext context, List<Map<String, dynamic>> reports) {
    double screenWidth = MediaQuery.of(context).size.width; // Get screen width

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
      child: Column(
        children: [
          const SizedBox(height: 20),
          SizedBox(
            height: 760, // Adjust height as needed
            child: reports.isEmpty
                ? const Center(child: Text("No updates available."))
                : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: screenWidth < 600
                          ? 1
                          : screenWidth < 900
                              ? 2
                              : screenWidth < 1200
                                  ? 3
                                  : 4, // Adjust number of columns based on screen width
                      childAspectRatio: 1.2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final report = reports[index];
                      return _buildUpdateCard(
                          report, screenWidth); // Pass screenWidth
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateCard(Map<String, dynamic> reports, double screenWidth) {
    double cardWidth = screenWidth / 4 - 24; // Maximum 4 columns
    if (screenWidth < 600) {
      cardWidth = screenWidth - 24; // Single column for small screens
    } else if (screenWidth < 900) {
      cardWidth = screenWidth / 2 - 24; // Two columns for medium screens
    } else if (screenWidth < 1200) {
      cardWidth = screenWidth / 3 - 24; // Three columns for larger screens
    }

    return Container(
      width: cardWidth,
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10),
                  color: Colors.blue[900],
                  child: Text(
                    reports['dtime'] ?? "Unknown Time",
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${reports['zonenum']}",
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Flood Level: ${reports['floodlevel']}",
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Flood Height: ${reports['floodheight']} ${reports['unit']}",
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Remarks: ${reports['remarks']}",
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (reports['image_path'] != null &&
                          reports['image_path'].toString().isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            'http://127.0.0.1/rareportdb/${reports['image_path']}',
                            width: 300,
                            height: 150,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.broken_image,
                              size: 150,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 8,
              right: 8,
              child: PopupMenuButton<String>(
                color: Colors.white,
                onSelected: (value) {
                  if (value == 'View') {
                    // Define your update logic here
                  } else if (value == 'Delete') {
                    // Define your delete logic here
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem(
                      value: 'View',
                      child: Text(
                        'View',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'Delete',
                      child: Text(
                        'Delete',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ];
                },
                child: const Icon(Icons.more_vert),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FloodUpdateForm extends StatefulWidget {
  @override
  _FloodUpdateFormState createState() => _FloodUpdateFormState();
}

class _FloodUpdateFormState extends State<FloodUpdateForm> {
  final TextEditingController dateTimeController = TextEditingController();
  final TextEditingController floodHeightController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();

  String? selectedZone;
  String? selectedFloodLevel;
  String? selectedUnit;
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;

  @override
  void dispose() {
    dateTimeController.dispose();
    floodHeightController.dispose();
    remarksController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null) {
      setState(() {
        _selectedImageBytes = result.files.first.bytes;
        _selectedImageName = result.files.first.name;
      });
      print(
          'Image Selected: $_selectedImageName, Bytes: ${_selectedImageBytes?.length}');
    } else {
      print('No image selected'); // Debugging
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 900,
      height: 400,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(60.0),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFCBCBCB))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FLOOD UPDATE FORM',
                  style: TextStyle(
                    color: Color(0xFF5576F5),
                    fontSize: 24,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 5,
                          spreadRadius: 1,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildDropdownField(
                                  'Zone',
                                  ['Zone 1', 'Zone 2', 'Zone 3'],
                                  (value) {
                                    setState(() {
                                      selectedZone = value;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: _buildDateField(context)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildDropdownField(
                                  'Flood Level',
                                  ['Normal', 'Warning', 'Critical', 'Severe'],
                                  (value) {
                                    setState(() {
                                      selectedFloodLevel = value;
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                  child: _buildTextField('Flood Height Value',
                                      floodHeightController)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildDropdownField(
                                  'Unit',
                                  ['ft'],
                                  (value) {
                                    setState(() {
                                      selectedUnit = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Flexible(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: _buildTextBigField(
                                      'Remarks', remarksController),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 25,
            bottom: 18,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5576F5),
                  ),
                  child: const Text(
                    'Upload Image',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(
                    width: 8), // Horizontal spacing between button and text
                _selectedImageBytes != null
                    ? Text(
                        'Image Selected: $_selectedImageName',
                        style: const TextStyle(color: Color(0xFF5576F5)),
                      )
                    : const Text(
                        'No Image Selected',
                        style: TextStyle(color: Colors.black),
                      ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Color(0xFF9E9E9E)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          Positioned(
            bottom: 18,
            right: 25,
            child: SaveButton(
              onPressed: () {
                _saveData(context);
              },
              label: 'Save',
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Color(0xFFCBCBCB),
        fontFamily: 'Poppins',
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      border: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFCBCBCB)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF4076F5), width: 2.0),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFCBCBCB), width: 1.5),
      ),
      floatingLabelStyle: const TextStyle(
        color: Color(0xFF4076F5),
        fontFamily: 'Poppins',
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return SizedBox(
      height: 35,
      width: 10,
      child: TextField(
        controller: controller,
        decoration: _inputDecoration(label),
      ),
    );
  }

  Widget _buildTextBigField(String label, TextEditingController controller) {
    return SizedBox(
      child: TextField(
        controller: controller,
        maxLines: 5,
        keyboardType: TextInputType.multiline,
        decoration: _inputDecoration(label),
      ),
    );
  }

  Widget _buildDropdownField(
      String label, List<String> items, ValueChanged<String?> onChanged) {
    return SizedBox(
      height: 35,
      child: DropdownButtonFormField<String>(
        decoration: _inputDecoration(label),
        dropdownColor: Colors.white,
        value: null,
        items: items.map((value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: ThemeData.light().copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFF4076F5),
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Color(0xFF4B4B4B),
                ),
                dialogBackgroundColor: Colors.white,
              ),
              child: child!,
            );
          },
        );

        if (pickedDate != null) {
          TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
            builder: (BuildContext context, Widget? child) {
              return Theme(
                data: ThemeData.light().copyWith(
                  colorScheme: ColorScheme.light(
                    primary: const Color(0xFF5576F5),
                    onPrimary: Colors.white,
                    onSurface: Colors.black,
                  ),
                  dialogBackgroundColor: Colors.white,
                ),
                child: child!,
              );
            },
          );
          if (pickedTime != null) {
            final dateTime = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            );
            // dateTimeController.text =
            //     DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
          }
        }
      },
      child: AbsorbPointer(
        child: SizedBox(
          height: 35,
          child: TextField(
            controller: dateTimeController,
            decoration: _inputDecoration('Date/Time'),
          ),
        ),
      ),
    );
  }

  Future<void> _saveData(BuildContext context) async {
    if (dateTimeController.text.isNotEmpty &&
        floodHeightController.text.isNotEmpty &&
        remarksController.text.isNotEmpty &&
        selectedFloodLevel != null &&
        selectedZone != null &&
        selectedUnit != null &&
        _selectedImageBytes != null &&
        _selectedImageName != null) {
      try {
        // Convert image bytes to Base64 string
        String base64Image = base64Encode(_selectedImageBytes!);

        final data = {
          'dtime': dateTimeController.text,
          'floodheight': floodHeightController.text,
          'remarks': remarksController.text,
          'unit': selectedUnit,
          'floodlevel': selectedFloodLevel,
          'zonenum': selectedZone,
          'image_data': base64Image,
          'image_name': _selectedImageName,
        };

        final url = Uri.parse('http://127.0.0.1/rareportdb/save_update.php');

        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(data),
        );

        var responseBody = jsonDecode(response.body);
        if (response.statusCode == 200 && responseBody["Success"] == true) {
          print('Data saved successfully');

          setState(() {
            dateTimeController.clear();
            floodHeightController.clear();
            remarksController.clear();
            selectedZone = null;
            selectedFloodLevel = null;
            selectedUnit = null;
            _selectedImageBytes = null;
            _selectedImageName = null;
          });

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
          ValidationDialog.showErrorDialog(
              context, 'Failed to save data. Please try again.');
        }
      } catch (e) {
        print('Error: $e');
        ValidationDialog.showErrorDialog(
            context, 'An error occurred. Please try again later.');
      }
    } else {
      ValidationDialog.showErrorDialog(context, 'All fields are required.');
    }
  }
}
