import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class FormHelper {
  static InputDecoration inputDecoration(
    String label, {
    bool alignLabel = false
    }) {

    return InputDecoration(
      labelText: label,
      alignLabelWithHint: alignLabel,
      labelStyle: const TextStyle(
        color: Color(0xFFCBCBCB),
        fontFamily: 'Poppins',
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      border: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFCBCBCB))),
      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF4076F5), width: 2.0)),
      enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFCBCBCB), width: 1.5)),
      floatingLabelStyle: const TextStyle(color: Color(0xFF4076F5), fontFamily: 'Poppins'),
    );
  }

  static Widget buildTextField(
    String label, 
    TextEditingController controller, {
    required bool isReadOnly, 
    double height = 35, 
    ValueChanged<String>? onChanged}) {

    return SizedBox(
      height: height,
      child: TextField(
        controller: controller,
        readOnly: isReadOnly,
        maxLines: height > 35 ? (height ~/ 20) : 1, 
        decoration: inputDecoration(label, alignLabel: height > 35),
        onChanged: onChanged, // Call the onChanged callback
      ),
    );
  }
  
  static Widget buildDateField(
    BuildContext context,
    TextEditingController dateController,
    String label, {
    required bool isReadOnly,
    required bool isDateTime, // Parameter to specify date or date-time
    ValueChanged<String>? onChanged, 
    }) {

    return GestureDetector(
      onTap: isReadOnly ? null : () async {
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
                dialogTheme: DialogThemeData(backgroundColor: Colors.white),
              ),
              child: child!,
            );
          },
        );

        if (pickedDate != null) {
          String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate); // Format date

          if (isDateTime) {
            TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );

            if (pickedTime != null) {
              // Convert to 12-hour format
              String formattedTime = DateFormat.jm().format(DateTime(0, 1, 1, pickedTime.hour, pickedTime.minute));
              // Combine date and time
              formattedDate += ' $formattedTime';
            }
          }

          dateController.text = formattedDate;
          if (onChanged != null) {
            onChanged(dateController.text); // Call the onChanged callback
          }
        }
      },
      child: AbsorbPointer(
        child: SizedBox(
          height: 35,
          child: TextField(
            controller: dateController,
            decoration: inputDecoration(label, alignLabel: true),
          ),
        ),
      ),
    );
  }

  static Widget buildTimestamp(String label, String? timestamp) {
    if (timestamp == null) return SizedBox.shrink();
    // Parse the timestamp string into a DateTime object
    DateTime dateTime = DateTime.parse(timestamp);

    // Format the date and time in 12-hour format
    String formattedDateTime = DateFormat('yyyy-MM-dd hh :mm a').format(dateTime);
    return Text(
      '$label $formattedDateTime',
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 12,
        color: Color.fromARGB(255, 193, 193, 193),
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  static Widget buildDropdown(
    String label,
    String key,
    List<String> options,
    Map<String, String?> dropdownValues, {
    bool isReadOnly = false,
    ValueChanged<String>? onChanged,
    bool allowCustomInput = true, // New parameter to control input mode
  }) {
    final controller = TextEditingController(
      text: dropdownValues[key] ?? '',
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: 35,
          child: Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (isReadOnly) return const Iterable<String>.empty();

              // If allowCustomInput is false, only show matching options, else show all options matching input or allow custom input
              return options.where((option) =>
                  option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
            },
            fieldViewBuilder:
                (context, textEditingController, focusNode, onFieldSubmitted) {
              // Synchronize internal controller text with external one only once
              if (textEditingController.text != controller.text) {
                textEditingController.text = controller.text;
                textEditingController.selection = TextSelection.fromPosition(
                  TextPosition(offset: textEditingController.text.length),
                );
              }

              return Stack(
                children: [
                  TextField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    readOnly: isReadOnly,
                    inputFormatters: allowCustomInput
                        ? null
                        : [
                            FilteringTextInputFormatter.deny(
                              RegExp('.*'),
                              replacementString: '',
                            ),
                          ],
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: inputDecoration(label),
                    onChanged: (value) {
                      if (allowCustomInput) {
                        dropdownValues[key] = value;
                        if (onChanged != null) onChanged(value);
                      }
                    },
                    onEditingComplete: () {
                      if (allowCustomInput) {
                        dropdownValues[key] = textEditingController.text;
                        if (onChanged != null) onChanged(textEditingController.text);
                      }
                    },
                  ),
                  Positioned(
                    right: 2,
                    top: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: () {
                        if (!isReadOnly) {
                          focusNode.requestFocus(); 
                        }
                      },
                      child: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ),
                  ),
                ],
              );
            },
            onSelected: (String selection) {
              if (!isReadOnly) {
                dropdownValues[key] = selection;
                if (onChanged != null) onChanged(selection);
              }
            },
            optionsViewBuilder: (context, onSelected, options) {
              if (isReadOnly) return const SizedBox.shrink();

              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: constraints.maxWidth,
                    constraints: const BoxConstraints(maxHeight: 100),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options.elementAt(index);
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              onSelected(option);
                            },
                            hoverColor: Colors.grey[200],
                            child: Container(
                              height: 40,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                option,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}



  // static Widget buildDropdownField(String label, List<String> items, ValueChanged<String?> onChanged, {String? initialValue}) {
  //   return SizedBox(
  //     height: 35,
  //     child: DropdownButtonFormField<String>(
  //       decoration: inputDecoration(label, alignLabel: true),
  //       dropdownColor: Colors.white,
  //       value: initialValue, // Set the initial value
  //       items: items.map((value) {
  //         return DropdownMenuItem<String>(
  //           value: value,
  //           child: Text(
  //             value,
  //             style: const TextStyle(
  //               fontFamily: 'Poppins',
  //               fontSize: 14,
  //               color: Color(0xFF4B4B4B),
  //               fontWeight: FontWeight.w400,
  //             ),
  //           ),
  //         );
  //       }).toList(),
  //       menuMaxHeight: 200.0,
  //       isDense: true,
  //       onChanged: (newValue) {
  //         onChanged(newValue); // Call the onChanged callback
  //       },
  //     ),
  //   );
  // }
  

  
  // static Widget buildDropdown(
  //   String label,
  //   String key,
  //   List<String> options,
  //   Map<String, String?> dropdownValues, {
  //   bool isReadOnly = false,
  //   ValueChanged<String>? onChanged,
  // }) {
  //   return SizedBox(
  //     height: 35,
  //     child: DropdownButtonFormField<String>(
  //       decoration: inputDecoration(label),
  //       dropdownColor: Colors.white,
  //       value: dropdownValues[key] != null && options.contains(dropdownValues[key]) ? dropdownValues[key] : null,
  //       items: options.map((value) {
  //         return DropdownMenuItem<String>(
  //           value: value,
  //           child: Text(
  //             value,
  //             style: const TextStyle(
  //               fontFamily: 'Poppins',
  //               fontSize: 14,
  //               color: Colors.black,
  //               fontWeight: FontWeight.w400,
  //             ),
  //           ),
  //         );
  //       }).toList(),
  //       menuMaxHeight: 200.0,
  //       isDense: true,
  //       onChanged: isReadOnly ? null : (newValue) {
  //         final val = newValue ?? '';
  //         dropdownValues[key] = val;
  //         if (onChanged != null) onChanged(val); // Notify on change
  //       },
  //     ),
  //   );
  // }
  

    // Widget _buildDropdown(String label, String key, List<String> options, Map<String, String?> dropdownValues, {bool isReadOnly = false}) {
  //   return SizedBox(
  //     height: 35,
  //     child: DropdownButtonFormField<String>(
  //       decoration: FormHelper.inputDecoration(label), 
  //       dropdownColor: Colors.white,
  //       value: dropdownValues[key] != null && options.contains(dropdownValues[key]) ? dropdownValues[key] : null,
  //       items: options.map((value) {
  //         return DropdownMenuItem<String>(
  //           value: value,
  //           child: Text(
  //             value,
  //             style: const TextStyle(
  //               fontFamily: 'Poppins',
  //               fontSize: 14,
  //               color: Colors.black,
  //               fontWeight: FontWeight.w400,
  //             ),
  //           ),
  //         );
  //       }).toList(),
  //       menuMaxHeight: 200.0,
  //       isDense: true,
  //       onChanged: isReadOnly ? null :  (newValue) {
  //         setState(() {
  //           dropdownValues[key] = newValue ?? ''; 
  //           print("Updated $key to $newValue, dropdownValues: $dropdownValues");
  //           _isDirty = true; // Mark as dirty
  //         });
  //       },
  //     ),
  //   );
  // }

