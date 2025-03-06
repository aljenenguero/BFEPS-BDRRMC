import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FormHelper {
  static InputDecoration inputDecoration(String label, {bool alignLabel = false}) {
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

  static Widget buildTextField(String label, TextEditingController controller, {required bool isReadOnly, double height = 35, ValueChanged<String>? onChanged}) {
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
  
  static Widget buildDateField(
      BuildContext context,
      TextEditingController dateController,
      String label, {
      required bool isReadOnly,
      required bool isDateTime, // New parameter to specify date or date-time
      ValueChanged<String>? onChanged, // Add this parameter
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
              // Convert to 12-hou  r format
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
    String formattedDateTime = DateFormat('yyyy-MM-dd hh:mm a').format(dateTime);
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
}