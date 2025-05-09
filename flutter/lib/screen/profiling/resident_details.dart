  // ignore_for_file: must_be_immutable
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bfeps_bdrrmc/constants/dropdown_options.dart';
import 'package:bfeps_bdrrmc/dialogs/validation_dialog.dart';
import 'package:bfeps_bdrrmc/widgets/buttons/update_button.dart';
import 'package:flutter/material.dart';
import '../../widgets/buttons/save_button.dart';
import '../../widgets/context/form.dart';

  class ResidentsForm extends StatefulWidget {
    final Map<String, dynamic> residentData;
    bool isViewMode; 

    ResidentsForm({super.key, required this.residentData, this.isViewMode = false});

    @override
    ResidentsFormState createState() => ResidentsFormState();
  }

  class ResidentsFormState extends State<ResidentsForm> {
    late TextEditingController profileController;
    late TextEditingController fnameController;
    late TextEditingController mnameController;
    late TextEditingController lnameController;
    late TextEditingController suffixController;
    late TextEditingController aliasController;
    late TextEditingController hhzoneController;
    late TextEditingController hhstreetController;
    late TextEditingController lotController;
    late TextEditingController cnumberController;
    late TextEditingController dbirthController;
    late TextEditingController ageController;
    late TextEditingController genderController;
    late TextEditingController cstatusController;
    late TextEditingController religionController;
    late TextEditingController educationController;
    late TextEditingController occupationController;
    late TextEditingController beneficiaryController;
    late TextEditingController pregnantController;
    late TextEditingController disabilityController;
    late TextEditingController hhtypeController;

    @override
    void initState() {
      super.initState();
      profileController = TextEditingController(text: widget.residentData['profilepicture']);
      fnameController = TextEditingController(text: widget.residentData['first_name']);
      mnameController = TextEditingController(text: widget.residentData['middle_name'] ?? 'N/A');
      lnameController = TextEditingController(text: widget.residentData['last_name']);
      suffixController = TextEditingController(text: widget.residentData['suffix'] ?? 'N/A');
      aliasController = TextEditingController(text: widget.residentData['alias'] ?? 'N/A');
      hhzoneController = TextEditingController(text: widget.residentData['household_zone']);
      hhstreetController = TextEditingController(text: widget.residentData['household_street']);
      lotController = TextEditingController(text: widget.residentData['household_lot'] ?? 'N/A');
      cnumberController = TextEditingController(text: widget.residentData['contact_number']);
      dbirthController = TextEditingController(text: widget.residentData['birth_date']);
      ageController = TextEditingController(text: widget.residentData['age'].toString());
      genderController = TextEditingController(text: widget.residentData['gender']);
      cstatusController = TextEditingController(text: widget.residentData['civil_status']);
      religionController = TextEditingController(text: widget.residentData['religion']);
      educationController = TextEditingController(text: widget.residentData['education']);
      occupationController = TextEditingController(text: widget.residentData['occupation']);
      beneficiaryController = TextEditingController(text: widget.residentData['beneficiary']);
      pregnantController = TextEditingController(text: widget.residentData['pregnant']);
      disabilityController = TextEditingController(text: widget.residentData['disability']);
      hhtypeController = TextEditingController(text: widget.residentData['household_type']);
    }

    Widget _buildRow(List<Widget> children) {
      return Row(
        children: children
            .expand((widget) => [Expanded(child: widget), const SizedBox(width: 8)])
            .toList()
          ..removeLast(),
      );
    }

    bool _isDirty = false; // Track if the form is dirty

    void _markDirty(String value) {
      setState(() {
        _isDirty = true;
      });
    }

    Widget _buildProfileSection() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfilePictureSection(profileController),
              Expanded(
                child: Column(
                  children: [
                    _buildRow([
                      FormHelper.buildTextField('Firstname*', fnameController, isReadOnly: widget.isViewMode, onChanged: _markDirty),
                      FormHelper.buildTextField('Middle Name', mnameController, isReadOnly: widget.isViewMode, onChanged: _markDirty),
                      FormHelper.buildTextField('Last Name', lnameController, isReadOnly: widget.isViewMode, onChanged: _markDirty),
                      FormHelper.buildTextField('Suffix', suffixController, isReadOnly: widget.isViewMode, onChanged: _markDirty),
                      FormHelper.buildTextField('Alias', aliasController, isReadOnly: widget.isViewMode, onChanged: _markDirty),
                    ]),
                    const SizedBox(height: 10),
                    _buildRow([
                      FormHelper.buildDropdown('Zone', 'household_zone', zoneOptions, { 'household_zone': hhzoneController.text }, isReadOnly: widget.isViewMode,  allowCustomInput: false, onChanged: (value) {
                        setState(() {
                          hhzoneController.text = value;
                           _markDirty(value);
                        });
                      }),
                      FormHelper.buildTextField('Street', hhstreetController, isReadOnly: widget.isViewMode, onChanged: _markDirty),
                      FormHelper.buildTextField('Lot', lotController, isReadOnly: widget.isViewMode, onChanged: _markDirty),
                      FormHelper.buildTextField('Contact Number', cnumberController, isReadOnly: widget.isViewMode, onChanged: _markDirty),
                    ]),

                    const SizedBox(height: 10),
                    _buildRow([
                      FormHelper.buildDateField(context, dbirthController, 'Date of Birth', isDateTime: false, isReadOnly: widget.isViewMode, onChanged: _markDirty),
                      FormHelper.buildTextField('Age', ageController, isReadOnly: widget.isViewMode, onChanged: _markDirty),
                      FormHelper.buildDropdown('Gender', 'gender', genderOptions, { 'gender': genderController.text }, isReadOnly: widget.isViewMode, allowCustomInput: true, onChanged: (value) {
                        setState(() {
                          genderController.text = value;
                           _markDirty(value);
                        });
                      }),
                    ]),
                    const SizedBox(height: 10),
                    _buildRow([
                      FormHelper.buildDropdown('Civil Status', 'civil_status', civilStatusOptions, { 'civil_status': cstatusController.text }, isReadOnly: widget.isViewMode, allowCustomInput: true, onChanged: (value) {
                        setState(() {
                          cstatusController.text = value;
                           _markDirty(value);
                        });
                      }),
                      FormHelper.buildDropdown('Religion', 'religion', religionOptions, { 'religion': religionController.text }, isReadOnly: widget.isViewMode, allowCustomInput: true, onChanged: (value) {
                        setState(() {
                          religionController.text = value;
                           _markDirty(value);
                        });
                      }),
                    ]),
                    const SizedBox(height: 10),
                    _buildRow([
                      FormHelper.buildDropdown('Education Attainment', 'education', educationOptions, { 'education': educationController.text }, isReadOnly: widget.isViewMode, allowCustomInput: true, onChanged: (value) {
                        setState(() {
                          educationController.text = value;
                           _markDirty(value);
                        });
                      }),
                      FormHelper.buildDropdown('Occupation', 'occupation', occupationOptions, { 'occupation': occupationController.text }, isReadOnly: widget.isViewMode,allowCustomInput: true,  onChanged: (value) {
                        setState(() {
                          occupationController.text = value;
                           _markDirty(value);
                        });
                      }),
                      FormHelper.buildDropdown("4p's", 'beneficiary', beneficiaryOptions, { 'beneficiary': beneficiaryController.text }, allowCustomInput: false, isReadOnly: widget.isViewMode, onChanged: (value) {
                        setState(() {
                          beneficiaryController.text = value;
                           _markDirty(value);
                        });
                      }),
                    ]),
                    const SizedBox(height: 10),
                    _buildRow([
                      FormHelper.buildDropdown('Pregnant', 'pregnant', pregnantOptions, { 'pregnant': pregnantController.text }, isReadOnly: widget.isViewMode, allowCustomInput: false, onChanged: (value) {
                        setState(() {
                          pregnantController.text = value;
                           _markDirty(value);
                        });
                      }),
                      FormHelper.buildDropdown('Disability', 'disability', disabilityOptions, { 'disability': disabilityController.text }, isReadOnly: widget.isViewMode, allowCustomInput: true, onChanged: (value) {
                        setState(() {
                          disabilityController.text = value;
                           _markDirty(value);
                        });
                      }),
                      FormHelper.buildDropdown('Household Member Type', 'household_type', householdMemberTypeOptions, { 'household_type': hhtypeController.text }, allowCustomInput: true, isReadOnly: widget.isViewMode, onChanged: (value) {
                        setState(() {
                          hhtypeController.text = value;
                           _markDirty(value);
                        });
                      }),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    }

    Widget _buildFormContainer() {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFCCCCCC), width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        height: 300,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileSection(),
          ],
        ),
      );
    }

    Widget _buildProfilePictureSection(TextEditingController profilePictureController) {
      String imageUrl = profilePictureController.text.trim();
      String encodedUrl = Uri.encodeFull(imageUrl);

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
            if (!widget.isViewMode) // Only show the edit button if not in view mode
              Positioned(
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
                      // Implement image picking functionality here
                      setState(() {});
                    },
                  ),
                ),
              ),
          ],
        ),
      );
    }

    @override
    Widget build(BuildContext context) {
      final screenSize = MediaQuery.of(context).size; 
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), 
        ),
        child: Stack(
          children: [
            Container(
              width: screenSize.width * 0.6, 
              height: screenSize.height * 0.48, 
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
                    'INDIVIDUAL DATA FORM',
                    style: TextStyle(
                      color: Color(0xFF5576F5),
                      fontSize: 24,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildFormContainer(),
                  const SizedBox(height: 10),
                  _buildButtonRow(),
                ],
              ),
            ),
            _buildCloseButton(), 
          ],
        ),
      );
    }

    Widget _buildButtonRow() {
      return Column(
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildViewHouseholdButton(),
              const SizedBox(width: 10),
              if (!widget.isViewMode) _buildSaveButton(),
              if (widget.isViewMode) _buildUpdateButton(),
            ],
          ),
        ],
      );
    }

    Widget _buildSaveButton() {
      return SaveButton(
        onPressed: () {
          _saveData();
        },
        label: 'Save',
      );
    }

    Widget _buildUpdateButton() {
      return UpdateButton(
        onPressed: () {
          setState(() {
            widget.isViewMode = false; // Toggle view mode to edit mode
          });
        },
        label: 'Edit', 
      );
    }

    Widget _buildViewHouseholdButton() {
      return TextButton(
        onPressed: () {
          // Implement the functionality to view the household information
        },
        child: const Text(
          'View Household',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: 'Poppins',
            color: Color(0xFF878787),
            decoration: TextDecoration.underline,
          ),
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

  void _saveData() async {
    // Prepare the data to be saved
    Map<String, dynamic> data = {
      'profile_picture': profileController.text,
      'first_name': fnameController.text,
      'middle_name': mnameController.text,
      'last_name': lnameController.text,
      'suffix': suffixController.text,
      'alias': aliasController.text,
      'household_zone': hhzoneController.text,
      'household_street': hhstreetController.text,
      'household_lot': lotController.text,
      'contact_number': cnumberController.text,
      'birth_date': dbirthController.text,
      'age': ageController.text,
      'gender': genderController.text,
      'civil_status': cstatusController.text,
      'religion': religionController.text,
      'education': educationController.text,
      'occupation': occupationController.text,
      'beneficiary': beneficiaryController.text,
      'pregnant': pregnantController.text,
      'disability': disabilityController.text,
      'household_type': hhtypeController.text,
    };

    // Print the data being saved for debugging
    print("Data being saved: $data");

    // Determine the API endpoint URL for updating resident details
    var url = Uri.parse('http://localhost/BFEPS-BDRRMC/api/profiling/individual_record.php');

    try {
      var response = await http.post(
        url,
        body: data,
      );

      if (response.statusCode == 200) {
        // Assuming the API returns JSON with a 'success' field
        var responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          ValidationDialog.showSuccessDialog(
            context,
            "Resident details updated successfully!",
            () {
              Navigator.of(context).pop(); // Close the dialog
            },
          );
        } else {
          ValidationDialog.showErrorDialog(context, "Failed to update resident details: ${responseData['message']}");
        }
      } else {
        ValidationDialog.showErrorDialog(context, "Failed to connect to the server");
      }
    } catch (e) {
      ValidationDialog.showErrorDialog(context, "Error occurred: $e");
    }
  }

    @override
    void dispose() {
      profileController.dispose();
      fnameController.dispose();
      mnameController.dispose();
      lnameController.dispose();
      suffixController.dispose();
      aliasController.dispose();
      hhzoneController.dispose();
      hhstreetController.dispose();
      lotController.dispose();
      cnumberController.dispose();
      dbirthController.dispose();
      ageController.dispose();
      genderController.dispose();
      cstatusController.dispose();
      religionController.dispose();
      educationController.dispose();
      occupationController.dispose();
      beneficiaryController.dispose();
      pregnantController.dispose();
      disabilityController.dispose();
      hhtypeController.dispose();
      super.dispose();
    }
  }